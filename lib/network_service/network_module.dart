import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

import '../config/appconstants.dart';
import '../config/shared_preference.dart';
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
      },
      responseType: ResponseType.json,
      followRedirects: false,
      validateStatus: (status) {
        return status! >= 200 && status < 300; // Only 2xx status codes are successful
      },
    );

    // Add interceptors
    _addInterceptors(dio);

    return dio;
  }

  /// Add all required interceptors
  static void _addInterceptors(Dio dio) {
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
        final noNeedAuth = options.extra[keyNoNeedAuthToken] ?? false;
        
        if (!noNeedAuth) {
          // Add authentication token
          final token = await _sharedPreference.get(AppConstants.bearerToken);
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
          // Check if this is already a refresh token request to avoid infinite loop
          final isRefreshTokenRequest = error.requestOptions.path.contains('refresh-token');
          
          if (!isRefreshTokenRequest) {
            // Try to refresh token
            final refreshResult = await _tryRefreshToken();
            
            if (refreshResult != null) {
              // Token refreshed successfully, retry original request
              final retryOptions = error.requestOptions;
              retryOptions.headers['Authorization'] = 'Bearer ${refreshResult['token']}';
              
              try {
                final retryResponse = await _dio!.fetch(retryOptions);
                handler.resolve(retryResponse);
                return;
              } catch (retryError) {
                // Retry failed, proceed with logout
                debugPrint('Retry after token refresh failed: $retryError');
              }
            }
          }
          
          // Token refresh failed or this was already a refresh request, logout user
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
        // Log error details
        debugPrint('API Error: ${error.message}');
        debugPrint('Status Code: ${error.response?.statusCode}');
        debugPrint('Response Data: ${error.response?.data}');

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
          final retryCount = requestOptions.extra['retry_count'] ?? 0;
          
          if (retryCount < NetworkConfig.maxRetries) {
            requestOptions.extra['retry_count'] = retryCount + 1;
            
            // Wait before retry
            await Future.delayed(
              Duration(seconds: NetworkConfig.retryDelaySeconds),
            );
            
            try {
              final response = await _dio!.fetch(requestOptions);
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

  /// Add logging interceptor
  static void _addLoggingInterceptor(Dio dio) {
    // Use TalkerDioLogger for comprehensive logging
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

    // Alternative: Use PrettyDioLogger for simpler logging
    // dio.interceptors.add(PrettyDioLogger(
    //   requestHeader: true,
    //   requestBody: true,
    //   responseHeader: true,
    //   responseBody: true,
    //   error: true,
    //   compact: true,
    //   maxWidth: 90,
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
          message = error.response?.data?['message'] ?? errorBadRequest;
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
          message = error.response?.data?['message'] ?? errorUnknown;
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
            error.response!.statusCode! >= 500);
  }

  /// Handle unauthorized error (logout user)
  static Future<void> _handleUnauthorizedError() async {
    // Clear stored tokens
    await _sharedPreference.remove(AppConstants.bearerToken);
    await _sharedPreference.remove(AppConstants.refreshToken);
    
    // Navigate to login screen
    // You can customize this based on your app's navigation structure
    debugPrint('Admin session expired. Please login again.');
    
    // If using GetX for navigation:
    // Get.offAllNamed('/login');
  }

  /// Try to refresh access token using refresh token
  static Future<Map<String, dynamic>?> _tryRefreshToken() async {
    try {
      final refreshToken = await _sharedPreference.get(AppConstants.refreshToken);
      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint('No refresh token available');
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

      final response = await tempDio.post(
        AppUrl.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        
        if (data['token'] != null) {
          // Store new tokens
          await _sharedPreference.save(AppConstants.bearerToken, data['token']);
          
          if (data['refreshToken'] != null) {
            await _sharedPreference.save(AppConstants.refreshToken, data['refreshToken']);
          }
          
          debugPrint('Admin token refreshed successfully');
          return data;
        }
      }
      
      debugPrint('Admin token refresh failed: Invalid response');
      return null;
    } catch (error) {
      debugPrint('Admin token refresh error: $error');
      return null;
    }
  }

  /// Clear Dio instance (useful for testing or resetting configuration)
  static void clearDio() {
    _dio?.close();
    _dio = null;
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

 