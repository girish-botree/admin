import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:retrofit/retrofit.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../widgets/custom_displays.dart';
import '../config/app_string_config.dart';
import 'api_constants.dart';
import 'app_url_config.dart';
import 'network_module.dart';

part 'api_client.g.dart';

/// API Client
/// This class defines all API endpoints using Retrofit annotations
@RestApi(baseUrl: '')
abstract class ApiClient {
  factory ApiClient(Dio dio, {String? baseUrl}) = _ApiClient;

  /// Authentication endpoints
  @POST(AppUrl.login)
  @Extra(extraNoNeedAuthToken)
  Future<HttpResponse<dynamic>> login(@Body() Map<String, dynamic> body);

  // @POST(AppUrl.logout)
  // Future<HttpResponse<dynamic>> logout(@Body() Map<String, dynamic> body);

  // @POST(AppUrl.refreshToken)
  // Future<HttpResponse<dynamic>> refreshToken(@Body() Map<String, dynamic> body);

  // @GET(AppUrl.profile)
  // Future<HttpResponse<dynamic>> getProfile();

  // @POST(AppUrl.authenticate)
  // @Extra(extraNoNeedAuthToken)
  // Future<HttpResponse<dynamic>> authenticate(@Body() Map<String, dynamic> body);

  // /// User management endpoints
  // @GET(AppUrl.users)
  // Future<HttpResponse<dynamic>> getUsers();

  // @GET('${AppUrl.users}/{id}')
  // Future<HttpResponse<dynamic>> getUserById(@Path('id') String userId);

  // @POST(AppUrl.users)
  // Future<HttpResponse<dynamic>> createUser(@Body() Map<String, dynamic> body);

  // @PUT('${AppUrl.users}/{id}')
  // Future<HttpResponse<dynamic>> updateUser(
  //   @Path('id') String userId,
  //   @Body() Map<String, dynamic> body,
  // );

  // @DELETE('${AppUrl.users}/{id}')
  // Future<HttpResponse<dynamic>> deleteUser(@Path('id') String userId);

  // /// File upload endpoints
  // @POST(AppUrl.uploadImage)
  // @MultiPart()
  // Future<HttpResponse<dynamic>> uploadImage(
  //   @Part() File file,
  //   @Part() String? description,
  // );

  // @POST(AppUrl.uploadFile)
  // @MultiPart()
  // Future<HttpResponse<dynamic>> uploadFile(
  //   @Part() File file,
  //   @Part() String? fileName,
  //   @Part() String? fileType,
  // );

  // /// Configuration endpoints
  // @GET(AppUrl.appConfig)
  // @Extra(extraNoNeedAuthToken)
  // Future<HttpResponse<dynamic>> getAppConfiguration();

  // @GET(AppUrl.appVersion)
  // @Extra(extraNoNeedAuthToken)
  // Future<HttpResponse<dynamic>> checkAppVersion();

  /// Generic GET request
  @GET('{path}')
  Future<HttpResponse<dynamic>> get(
    @Path('path') String path,
    @Queries() Map<String, dynamic>? queryParameters,
  );

  /// Generic POST request
  @POST('{path}')
  Future<HttpResponse<dynamic>> post(
    @Path('path') String path,
    @Body() dynamic body,
  );

  /// Generic PUT request
  @PUT('{path}')
  Future<HttpResponse<dynamic>> put(
    @Path('path') String path,
    @Body() dynamic body,
  );

  /// Generic DELETE request
  @DELETE('{path}')
  Future<HttpResponse<dynamic>> delete(
    @Path('path') String path,
    @Queries() Map<String, dynamic>? queryParameters,
  );
}

/// API Error Handler
/// This class handles API errors and provides user-friendly error messages
class ApiErrorHandler {
  /// Handle API errors and show appropriate messages
  static Future<bool> handleError(DioException error) async {
    ApiHelper.dismissLoader();
    
    debugPrint('API Error: ${error.message}');
    debugPrint('Status Code: ${error.response?.statusCode}');
    debugPrint('Response Data: ${error.response?.data}');

    String errorMessage = _getErrorMessage(error);
    
    // Show error to user
    _showErrorToUser(errorMessage);
    
    // Handle specific error types
    await _handleSpecificErrors(error);
    
    return true; // Error handled
  }

  /// Get user-friendly error message
  static String _getErrorMessage(DioException error) {
    if (error.error is SocketException) {
      return AppStringConfig.noInternetConnection;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return AppStringConfig.couldNotReachTheServer;
      case DioExceptionType.badCertificate:
        return AppStringConfig.certificateVerifyFailed;
      case DioExceptionType.badResponse:
        return _handleBadResponse(error);
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.connectionError:
        return AppStringConfig.noInternetConnection;
      case DioExceptionType.unknown:
        return error.message ?? 'An unexpected error occurred';
    }
  }

  /// Handle bad response errors
  static String _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    switch (statusCode) {
      case statusCodeBadRequest:
        return responseData?['message'] ?? errorBadRequest;
      case statusCodeUnauthorized:
        return errorUnauthorized;
      case statusCodeForbidden:
        return errorForbidden;
      case statusCodeNotFound:
        return errorNotFound;
      case statusCodeMethodNotAllowed:
        return 'Method not allowed';
      case statusCodeRequestTimeout:
        return errorTimeout;
      case statusCodeConflict:
        return 'Conflict occurred';
      case statusCodeUnprocessableEntity:
        return responseData?['message'] ?? 'Validation failed';
      case statusCodeTooManyRequests:
        return errorTooManyRequests;
      case statusCodeInternalServerError:
        return errorServerError;
      case statusCodeBadGateway:
        return 'Bad gateway';
      case statusCodeServiceUnavailable:
        return 'Service unavailable';
      case statusCodeGatewayTimeout:
        return 'Gateway timeout';
      default:
        return responseData?['message'] ?? errorUnknown;
    }
  }

  /// Handle specific error types
  static Future<void> _handleSpecificErrors(DioException error) async {
    final statusCode = error.response?.statusCode;

    switch (statusCode) {
      case statusCodeUnauthorized:
        await _handleUnauthorizedError();
        break;
      case statusCodeForbidden:
        await _handleForbiddenError();
        break;
      case statusCodeTooManyRequests:
        await _handleTooManyRequestsError();
        break;
      default:
        break;
    }
  }

  /// Handle unauthorized error
  static Future<void> _handleUnauthorizedError() async {
    // Clear user session
    // await SharedPreference().remove(AppConstants.bearerToken);
    
    // Navigate to login screen
    // if (Get.currentRoute != '/login') {
    //   Get.offAllNamed('/login');
    // }
    
    debugPrint('User unauthorized. Redirecting to login...');
  }

  /// Handle forbidden error
  static Future<void> _handleForbiddenError() async {
    // User doesn't have permission
    debugPrint('User does not have permission for this action');
  }

  /// Handle too many requests error
  static Future<void> _handleTooManyRequestsError() async {
    // Rate limiting
    debugPrint('Too many requests. Please try again later');
  }

  /// Show error to user
  static void _showErrorToUser(String message) {
    // You can customize this based on your UI preferences
    CustomDisplays.showSnackBar(message: message);
    
    // Alternative: Show dialog
    // Get.dialog(
    //   AlertDialog(
    //     title: Text('Error'),
    //     content: Text(message),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Get.back(),
    //         child: Text('OK'),
    //       ),
    //     ],
    //   ),
    // );
  }
}

/// API Helper Functions
/// This class provides helper functions for API calls
class ApiHelper {
  static ApiClient? _apiClient;
  
  /// Get API client instance
  static ApiClient getApiClient() {
    if (_apiClient == null) {
      final dio = NetworkModule.getDio();
      _apiClient = ApiClient(dio, baseUrl: AppUrl.getBaseUrl());
    }
    return _apiClient!;
  }

    /// Make API call with error handling
  static Future<T?> callApi<T>(
    Future<T> Function() apiCall, {
    bool showLoadingIndicator = true,
    bool handleError = true,
    String? customErrorMessage,
  }) async {
    try {
      if (showLoadingIndicator) {
        ApiHelper.showLoader();
      }
      
      final result = await apiCall();
      
      if (showLoadingIndicator) {
        ApiHelper.dismissLoader();
      }
      
      return result;
    } on DioException catch (dioError) {
      if (showLoadingIndicator) {
        ApiHelper.dismissLoader();
      }
      
      if (handleError) {
        if (customErrorMessage != null) {
          CustomDisplays.showSnackBar(message: customErrorMessage);
        } else {
          await ApiErrorHandler.handleError(dioError);
        }
      }
      
      return null;
    } catch (error) {
      if (showLoadingIndicator) {
        ApiHelper.dismissLoader();
      }
      
      if (handleError) {
        final errorMessage = customErrorMessage ?? error.toString();
        CustomDisplays.showSnackBar(message: errorMessage);
      }
      
      debugPrint('Unexpected error: $error');
      return null;
    }
  }

  /// Show loader
  static void showLoader() {
    if (!EasyLoading.isShow) {
      EasyLoading.show(status: 'Loading...');
    }
  }

  /// Dismiss loader
  static void dismissLoader() {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
  }
} 