import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:retrofit/retrofit.dart';


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

  @POST(AppUrl.logout)
  Future<HttpResponse<dynamic>> logout();
  @POST(AppUrl.sendOtp)
  @Extra(extraNoNeedAuthToken)
  Future<HttpResponse<dynamic>> sendOtp(@Body() Map<String, dynamic> body);

  @POST(AppUrl.registerAdmin)
  Future<HttpResponse<dynamic>> registerAdmin(@Body() Map<String, dynamic> body);

  @POST(AppUrl.registerDeliveryPerson)
  Future<HttpResponse<dynamic>> registerDeliveryPerson(@Body() Map<String, dynamic> body);

  @GET(AppUrl.registerDeliveryPerson)
  Future<HttpResponse<dynamic>> getDeliveryPersons();

  @PUT('${AppUrl.registerDeliveryPerson}/{id}')
  Future<HttpResponse<dynamic>> updateDeliveryPerson(@Path('id')String id, @Body() Map<String,dynamic> body);

  @DELETE('${AppUrl.registerDeliveryPerson}/{id}')
  Future<HttpResponse<dynamic>> deleteDeliveryPerson(@Path('id') String id);
  // Recipe endpoints
  @GET(AppUrl.getRecipes)
  Future<HttpResponse<dynamic>> getRecipes();

  @GET('${AppUrl.getRecipes}/{id}')
  Future<HttpResponse<dynamic>> getRecipeById(@Path('id') String id);

  @POST(AppUrl.recipes)
  Future<HttpResponse<dynamic>> createRecipe(@Body() Map<String, dynamic> body);

  @PUT('${AppUrl.recipes}/{id}')
  Future<HttpResponse<dynamic>> updateRecipe(@Path('id') String id, @Body() Map<String, dynamic> body);

  @DELETE('${AppUrl.recipes}/{id}')
  Future<HttpResponse<dynamic>> deleteRecipe(@Path('id') String id);

  // Ingredient endpoints
  @GET(AppUrl.ingredients)
  Future<HttpResponse<dynamic>> getIngredients();

  @POST(AppUrl.ingredients)
  Future<HttpResponse<dynamic>> createIngredient(@Body() Map<String, dynamic> body);

  @PUT('${AppUrl.ingredients}/{id}')
  Future<HttpResponse<dynamic>> updateIngredient(@Path('id') String id, @Body() Map<String, dynamic> body);

  @DELETE('${AppUrl.ingredients}/{id}')
  Future<HttpResponse<dynamic>> deleteIngredient(@Path('id') String id);

  // Admin meal plan endpoints

  @GET(AppUrl.getAdminMealPlan)
  Future<HttpResponse<dynamic>> getMealPlan();

  @GET('${AppUrl.adminMealPlanByDate}/{date}')
  Future<HttpResponse<dynamic>> getMealPlanByDate(@Path('date') String date);

  @GET('${AppUrl.getAdminMealPlan}/{id}')
  Future<HttpResponse<dynamic>> getMealPlanById(@Path('id') String id);

  @POST(AppUrl.adminMealPlan)
  Future<HttpResponse<dynamic>> createMealPlan(@Body() Map<String, dynamic> body);

  @PUT('${AppUrl.adminMealPlan}/{id}')
  Future<HttpResponse<dynamic>> updateMealPlan(@Path('id') String id, @Body() Map<String, dynamic> body);

  @DELETE('${AppUrl.adminMealPlan}/{id}')
  Future<HttpResponse<dynamic>> deleteMealPlan(@Path('id') String id);



  // @POST(AppUrl.logout)
  // Future<HttpResponse<dynamic>> logout(@Body() Map<String, dynamic> body);

  @POST(AppUrl.refreshToken)
  @Extra(extraNoNeedAuthToken)
  Future<HttpResponse<dynamic>> refreshToken(@Body() Map<String, dynamic> body);

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
        return AppStringConfig.somethingWentWrong;
    }
  }

  /// Handle bad response errors
  static String _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    // Extract server error message if available, but sanitize it to be user-friendly
    String? serverMessage;
    if (responseData != null && responseData is Map<String, dynamic>) {
      serverMessage = responseData['message'] as String?;

      // If server message contains technical details, don't use it
      if (serverMessage != null &&
          (serverMessage.contains('Exception') ||
              serverMessage.contains('Error:') ||
              serverMessage.contains('DioException') ||
              serverMessage.contains('sql') ||
              serverMessage.contains('null') ||
              serverMessage.contains('undefined'))) {
        serverMessage = null;
      }
    }

    switch (statusCode) {
      case statusCodeBadRequest:
        return serverMessage ?? AppStringConfig.invalidRequest;
      case statusCodeUnauthorized:
        return AppStringConfig.sessionExpired;
      case statusCodeForbidden:
        return AppStringConfig.noPermission;
      case statusCodeNotFound:
        return AppStringConfig.resourceNotFound;
      case statusCodeMethodNotAllowed:
        return 'This action is not allowed';
      case statusCodeRequestTimeout:
        return AppStringConfig.requestTimeout;
      case statusCodeConflict:
        return 'This operation could not be completed due to a conflict';
      case statusCodeUnprocessableEntity:
        return serverMessage ?? AppStringConfig.validationFailed;
      case statusCodeTooManyRequests:
        return AppStringConfig.tooManyRequests;
      case statusCodeInternalServerError:
        return AppStringConfig.serverError;
      case statusCodeBadGateway:
        return AppStringConfig.serviceUnavailable;
      case statusCodeServiceUnavailable:
        return AppStringConfig.serviceUnavailable;
      case statusCodeGatewayTimeout:
        return AppStringConfig.requestTimeout;
      default:
        return serverMessage ?? AppStringConfig.somethingWentWrong;
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
  }

  /// Handle forbidden error
  static Future<void> _handleForbiddenError() async {
    // User doesn't have permission
  }

  /// Handle too many requests error
  static Future<void> _handleTooManyRequestsError() async {
    // Rate limiting
  }

  /// Show error to user
  static void _showErrorToUser(String message) {
    if (message == AppStringConfig.sessionExpired) {
      CustomDisplays.showSessionExpiredMessage();
    } else {
      CustomDisplays.showToast(
        message: message,
        type: MessageType.error,
        allowDuplicate: false,
      );
    }
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
          ApiErrorHandler._showErrorToUser(customErrorMessage);
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
        ApiErrorHandler._showErrorToUser(errorMessage);
      }
      
      return null;
    }
  }

  /// Show loader - Disabled (no overscreen loading)
  static void showLoader() {
    // Overscreen loading removed
  }

  /// Dismiss loader - Disabled (no overscreen loading)
  static void dismissLoader() {
    // Overscreen loading removed
  }
} 