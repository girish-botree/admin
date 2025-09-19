import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:talker_dio_logger/talker_dio_logger.dart';

import '../config/appconstants.dart';
import '../config/shared_preference.dart';
import '../widgets/custom_displays.dart';
import 'api_constants.dart';
import 'app_url_config.dart';

/// Network Module
/// This class provides a configured Dio instance with interceptors,
/// logging, error handling, and authentication management
class NetworkModule {
  static Dio? _dio;
  static final SharedPreference _sharedPreference = SharedPreference();

  /// Get configured Dio instance
  static Dio getDio() {
    return _dio ??= _createDio();
  }

  /// Create and configure Dio instance
  static Dio _createDio() {
    final dio = Dio();

    // Configure base options
    dio.options = BaseOptions(
      baseUrl: AppUrl.getBaseUrl(),
      connectTimeout: Duration(milliseconds: connectTimeout),
      receiveTimeout: Duration(milliseconds: receiveTimeout),
      sendTimeout: Duration(milliseconds: sendTimeout),
      headers: {
        'Content-Type': contentTypeJson,
        'Accept': contentTypeJson,
        // Web-specific headers to help with CORS
        if (kIsWeb) ...{
          'X-Requested-With': 'XMLHttpRequest',
        }
      },
      responseType: ResponseType.json,
      followRedirects: false,
      validateStatus: (status) {
        return status! >= 200 && status < 300; // Only 2xx status codes are successful
      },
    );

    // Configure HttpClient for handling certificate issues
    if (!kIsWeb) {
      _configureHttpClient(dio);
    }

    // Add interceptors
    _addInterceptors(dio);

    return dio;
  }

  /// Add all required interceptors
  static void _addInterceptors(Dio dio) {
    // Add CORS interceptor for web builds
    if (kIsWeb) {
      dio.interceptors.add(_createCorsInterceptor());
    }

    // Add authentication interceptor
    dio.interceptors.add(_createAuthInterceptor());

    // Add error handling interceptor
    dio.interceptors.add(_createErrorInterceptor());

    // Add retry interceptor
    dio.interceptors.add(_createRetryInterceptor());

    // Add logging interceptor (only in debug mode)
    if (kDebugMode && NetworkConfig.enableLogging) {
      _addLoggingInterceptor(dio);
    }
  }

  /// Create authentication interceptor
  static InterceptorsWrapper _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Check if this request needs authentication
        final noNeedAuth = options.extra[keyNoNeedAuthToken] as bool? ?? false;
        
        if (!noNeedAuth) {
          // Add authentication token - use getSecure to match how tokens are stored
          final token = await _sharedPreference.getSecure(
              AppConstants.bearerToken);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }

        // Add additional headers
        options.headers.addAll({
          'User-Agent': 'Admin-Flutter-App',
          'X-Platform': _getPlatformName(),
          'X-App-Version': '1.0.0', // You can get this from package_info
        });

        handler.next(options);
      },
      onResponse: (response, handler) {
        // Handle successful response
        handler.next(response);
      },
      onError: (error, handler) async {
        // Handle authentication errors
        if (error.response?.statusCode == statusCodeUnauthorized) {
          final requestOptions = error.requestOptions;
          // Do not refresh for public endpoints (login/register/otp/reset) or the refresh call itself
          final isNoAuthRequest = requestOptions.extra[keyNoNeedAuthToken] == true;
          final isRefreshTokenRequest = requestOptions.path.contains('refresh-token');

          if (isNoAuthRequest || isRefreshTokenRequest) {
            // Let the 401 propagate without attempting refresh or logging out
            handler.next(error);
            return;
          }

          // Try to refresh token for protected endpoints only
          final refreshResult = await _tryRefreshToken();

          if (refreshResult != null) {
            // Token refreshed successfully, retry original request
            final retryOptions = requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer ${refreshResult['token']}';

            try {
              final retryResponse = await _dio!.fetch<Map<String, dynamic>>(retryOptions);
              handler.resolve(retryResponse);
              return;
            } catch (retryError) {
              // Retry failed, proceed with logout
            }
          }
          
          // Token refresh failed, logout user for protected endpoints
          await _handleUnauthorizedError();
        }
        handler.next(error);
      },
    );
  }

  /// Create error handling interceptor
  static InterceptorsWrapper _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        // Transform error into user-friendly format
        final transformedError = _transformError(error);
        handler.next(transformedError);
      },
    );
  }

  /// Create retry interceptor
  static InterceptorsWrapper _createRetryInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        // Retry logic for specific errors
        if (_shouldRetry(error)) {
          final requestOptions = error.requestOptions;
          final retryCountValue = requestOptions.extra['retry_count'];
          final retryCount = (retryCountValue is int) ? retryCountValue : 0;
          
          if (retryCount < NetworkConfig.maxRetries) {
            requestOptions.extra['retry_count'] = retryCount + 1;
            
            // Wait before retry
            await Future<void>.delayed(
              Duration(seconds: NetworkConfig.retryDelaySeconds),
            );
            
            try {
              final response = await _dio!.fetch<dynamic>(requestOptions);
              handler.resolve(response);
              return;
            } catch (e) {
              // Continue with original error if retry fails
            }
          }
        }
        
        handler.next(error);
      },
    );
  }

  /// Create CORS interceptor for web builds
  static InterceptorsWrapper _createCorsInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add CORS-friendly headers for web requests
        options.headers.addAll({
          'Accept': 'application/json, text/plain, */*',
          'Content-Type': 'application/json',
        });

        // Remove any headers that might trigger CORS preflight
        options.headers.remove('X-Requested-With');

        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (error, handler) {
        // Handle CORS-related errors
        if (error.message?.contains('XMLHttpRequest') == true) {
          final corsError = DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            type: DioExceptionType.connectionError,
            error: 'CORS Error: The server must allow cross-origin requests from your domain',
            message: 'CORS Error: The server must allow cross-origin requests from your domain',
          );
          handler.next(corsError);
          return;
        }
        handler.next(error);
      },
    );
  }

  /// Add logging interceptor
  static void _addLoggingInterceptor(Dio dio) {
    // Use TalkerDioLogger for colored terminal output
    dio.interceptors.add(TalkerDioLogger(
      settings: TalkerDioLoggerSettings(
        printRequestHeaders: true,
        printResponseHeaders: true,
        printRequestData: true,
        printResponseData: true,
        printErrorData: true,
        printErrorHeaders: true,
        printErrorMessage: true,
      ),
    ));

    // Alternative: Use PrettyDioLogger for even better formatting
    // dio.interceptors.add(PrettyDioLogger(
    //   requestHeader: true,
    //   requestBody: true,
    //   responseBody: true,
    //   responseHeader: false,
    //   error: true,
    //   compact: false,
    //   maxWidth: 120,
    // ));
  }

  /// Transform DioException into user-friendly error
  static DioException _transformError(DioException error) {
    String message = errorUnknown;
    
    if (error.error is SocketException) {
      message = errorNoInternet;
    } else if (error.type == DioExceptionType.connectionTimeout ||
               error.type == DioExceptionType.receiveTimeout ||
               error.type == DioExceptionType.sendTimeout) {
      message = errorTimeout;
    } else if (error.response != null) {
      switch (error.response!.statusCode) {
        case statusCodeBadRequest:
          message =
              (error.response?.data?['message'] as String?) ?? errorBadRequest;
          break;
        case statusCodeUnauthorized:
          message = errorUnauthorized;
          break;
        case statusCodeForbidden:
          message = errorForbidden;
          break;
        case statusCodeNotFound:
          message = errorNotFound;
          break;
        case statusCodeTooManyRequests:
          message = errorTooManyRequests;
          break;
        case statusCodeInternalServerError:
          message = errorServerError;
          break;
        default:
          message =
              (error.response?.data?['message'] as String?) ?? errorUnknown;
      }
    }

    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: message,
      message: message,
    );
  }

  /// Check if request should be retried
  static bool _shouldRetry(DioException error) {
    // Retry for network errors, timeouts, and 5xx server errors
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           error.type == DioExceptionType.sendTimeout ||
           error.error is SocketException ||
           (error.response?.statusCode != null &&
               error.response!.statusCode! >= 500 &&
               error.response!.statusCode! < 600);
  }

  /// Handle unauthorized error (logout user)
  static Future<void> _handleUnauthorizedError() async {
    // Clear stored tokens - use removeSecure to match storage method
    await _sharedPreference.removeSecure(AppConstants.bearerToken);
    await _sharedPreference.removeSecure(AppConstants.refreshToken);
    
    // Show session expired message (deduplicated)
    CustomDisplays.showSessionExpiredMessage();
    
    // Navigate to login screen
    // You can customize this based on your app's navigation structure
    // If using GetX for navigation:
    Get.offAllNamed<void>('/login');
  }

  /// Try to refresh access token using refresh token
  static Future<Map<String, dynamic>?> _tryRefreshToken() async {
    try {
      final refreshToken = await _sharedPreference.getSecure(
          AppConstants.refreshToken);
      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      // Create a separate Dio instance to avoid interceptor loops
      final tempDio = Dio();
      tempDio.options = BaseOptions(
        baseUrl: AppUrl.getBaseUrl(),
        connectTimeout: Duration(milliseconds: connectTimeout),
        receiveTimeout: Duration(milliseconds: receiveTimeout),
        headers: {
          'Content-Type': contentTypeJson,
          'Accept': contentTypeJson,
        },
      );

      final response = await tempDio.post<dynamic>(
        AppUrl.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final data = responseData;

          if (data['token'] != null) {
            // Store new tokens using secure storage
            final newToken = data['token'] as String?;
            if (newToken != null) {
              await _sharedPreference.saveSecure(
                  AppConstants.bearerToken, newToken);
            }

            final refreshToken = data['refreshToken'] as String?;
            if (refreshToken != null) {
              await _sharedPreference.saveSecure(
                  AppConstants.refreshToken, refreshToken);
            }

            return data;
          }
        }
      }
      
      return null;
    } catch (error) {
      return null;
    }
  }

  /// Clear Dio instance (useful for testing or resetting configuration)
  static void clearDio() {
    _dio?.close();
    _dio = null;
  }

  /// Configure HttpClient to handle certificate issues for specific hosts
  static void _configureHttpClient(Dio dio) {
    if (!kIsWeb) {
      final httpClientAdapter = dio.httpClientAdapter;
      if (httpClientAdapter is IOHttpClientAdapter) {
        httpClientAdapter.createHttpClient = () {
          final client = HttpClient();

          // Define hosts that need certificate bypass
          // Note: Only include hosts that you control and trust
          final trustedHosts = ['15.207.67.98'];

          client.badCertificateCallback = (cert, host, port) {
            // Only bypass certificate validation for trusted hosts
            if (trustedHosts.contains(host)) {
              if (kDebugMode) {
                debugPrint('INFO: Bypassing certificate validation for trusted host: $host');
              }
              return true; // Allow the request for trusted hosts
            }
            return false; // Reject for all other hosts
          };

          return client;
        };
      }
    }
  }

  /// Get platform name for cross-platform compatibility
  static String _getPlatformName() {
    if (kIsWeb) {
      return 'web';
    }
    
    try {
      if (Platform.isAndroid) {
        return 'android';
      } else if (Platform.isIOS) {
        return 'ios';
      } else if (Platform.isWindows) {
        return 'windows';
      } else if (Platform.isMacOS) {
        return 'macos';
      } else if (Platform.isLinux) {
        return 'linux';
      } else {
        return 'unknown';
      }
    } catch (e) {
      // Fallback for platforms where Platform class is not available
      return 'unknown';
    }
  }
}

 