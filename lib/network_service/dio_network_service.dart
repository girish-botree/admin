import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/auth_service.dart';
import '../config/common_utils.dart';
import '../widgets/custom_displays.dart';
import 'api_client.dart';
import 'app_url_config.dart';

/// Dio Network Service
/// This class provides a modern, robust network service using Dio
/// with comprehensive error handling, logging, and authentication management
/// 
/// REFRESH TOKEN SYSTEM:
/// - Access tokens expire in 15 minutes (configurable on backend)
/// - Refresh tokens expire in 7 days (configurable on backend)  
/// - When a 401 error occurs, the system automatically tries to refresh the access token
/// - If refresh succeeds, the original request is retried with the new access token
/// - If refresh fails, the user is logged out and redirected to login
/// - The refresh token itself is also rotated on each refresh for security
/// 
/// USAGE EXAMPLES:
/// ```dart
/// // Login and store both tokens
/// final response = await DioNetworkService.login(email, password);
/// if (response != null && response['token'] != null) {
///   await DioNetworkService.storeAuthTokens(response);
/// }
/// 
/// // Make authenticated requests (tokens handled automatically)
/// final adminData = await DioNetworkService.getData('api/admin/dashboard');
/// 
/// // Manual token refresh (usually not needed)
/// final newTokens = await DioNetworkService.refreshAccessToken();
/// 
/// // Logout (clears all tokens)
/// await DioNetworkService.clearToken();
/// ```
class DioNetworkService {
  static late ApiClient _apiClient;

  static AuthService get _authService => AuthService.to;
  
  /// Initialize the network service
  static void initialize() {
    _apiClient = ApiHelper.getApiClient();
  }

  /// GET Request with Enhanced Response Handling
  static Future<Map<String, dynamic>> getData(
    String apiUrl, {
    bool bearerToken = false,
    Map<String, dynamic>? queryParameters,
    bool showLoader = true,
    bool handleError = true,
  }) async {
    try {
      if (showLoader) {
        ApiHelper.showLoader();
      }

      final response = await _apiClient.get(
        apiUrl,
        queryParameters,
      );

      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      // Create comprehensive response structure
      final Map<String, dynamic> enhancedResponse = <String, dynamic>{
        'httpResponse': <String, dynamic>{
          'method': 'GET',
          'url': '${AppUrl.getBaseUrl()}$apiUrl',
          'status': response.response.statusCode ?? 200,
          'statusMessage': response.response.statusMessage ?? 'OK',
          'data': response.data,
          'headers': response.response.headers.map,
          'responseTime': DateTime.now().toIso8601String(),
        },
      };
      
      // Add response data to the enhanced response if it exists
      if (response.data != null && response.data is Map<String, dynamic>) {
        enhancedResponse.addAll(response.data as Map<String, dynamic>);
      }

      // Log the detailed response in the desired format
      _logDetailedResponse(enhancedResponse);

      return enhancedResponse;
    } on DioException catch (dioError) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {
        await ApiErrorHandler.handleError(dioError);
      }

      rethrow;
    } catch (e) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {

        CustomDisplays.showToast(
          message: 'Something went wrong, please try again later',
          type: MessageType.error,
        );
      }

      rethrow;
    }
  }

  /// POST Request with Enhanced Response Handling
  static Future<Map<String, dynamic>> postData(
    dynamic data,
    String apiUrl, {
    bool bearerToken = false,
    bool showLoader = true,
    bool handleError = true,
  }) async {
    try {
      if (showLoader) {
        ApiHelper.showLoader();
      }

      // Convert data to appropriate format
      final requestData = _prepareRequestData(data);

      final response = await _apiClient.post(apiUrl, requestData);

      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      // Create comprehensive response structure
      final Map<String, dynamic> enhancedResponse = <String, dynamic>{
        'httpResponse': <String, dynamic>{
          'method': 'POST',
          'url': '${AppUrl.getBaseUrl()}$apiUrl',
          'status': response.response.statusCode ?? 200,
          'statusMessage': response.response.statusMessage ?? 'OK',
          'data': response.data,
          'headers': response.response.headers.map,
          'responseTime': DateTime.now().toIso8601String(),
        },
      };
      
      // Add response data to the enhanced response if it exists
      if (response.data != null && response.data is Map<String, dynamic>) {
        enhancedResponse.addAll(response.data as Map<String, dynamic>);
      }

      // Log the detailed response in the desired format
      _logDetailedResponse(enhancedResponse);

      return enhancedResponse;
    } on DioException catch (dioError) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {
        await ApiErrorHandler.handleError(dioError);
      }

      rethrow;
    } catch (e) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {

        CustomDisplays.showToast(
          message: 'Something went wrong, please try again later',
          type: MessageType.error,
        );
      }

      rethrow;
    }
  }

  /// PUT Request with Body and Enhanced Response Handling
  static Future<Map<String, dynamic>> putDataWithBody(
    dynamic data,
    String apiUrl, {
    bool bearerToken = false,
    bool showLoader = true,
    bool handleError = true,
  }) async {
    try {
      if (showLoader) {
        ApiHelper.showLoader();
      }

      // Convert data to appropriate format
      final requestData = _prepareRequestData(data);

      final response = await _apiClient.put(apiUrl, requestData);

      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      // Create comprehensive response structure
      final Map<String, dynamic> enhancedResponse = <String, dynamic>{
        'httpResponse': <String, dynamic>{
          'method': 'PUT',
          'url': '${AppUrl.getBaseUrl()}$apiUrl',
          'status': response.response.statusCode ?? 200,
          'statusMessage': response.response.statusMessage ?? 'OK',
          'data': response.data,
          'headers': response.response.headers.map,
          'responseTime': DateTime.now().toIso8601String(),
        },
      };
      
      // Add response data to the enhanced response if it exists
      if (response.data != null && response.data is Map<String, dynamic>) {
        enhancedResponse.addAll(response.data as Map<String, dynamic>);
      }

      // Log the detailed response in the desired format
      _logDetailedResponse(enhancedResponse);

      return enhancedResponse;
    } on DioException catch (dioError) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {
        await ApiErrorHandler.handleError(dioError);
      }

      rethrow;
    } catch (e) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {

        CustomDisplays.showToast(
          message: 'Something went wrong, please try again later',
          type: MessageType.error,
        );
      }

      rethrow;
    }
  }

  /// PUT Request without Body and Enhanced Response Handling
  static Future<Map<String, dynamic>> putDataWithoutBody(
    String apiUrl, {
    bool bearerToken = false,
    bool showLoader = true,
    bool handleError = true,
  }) async {
    try {
      if (showLoader) {
        ApiHelper.showLoader();
      }

      final response = await _apiClient.put(apiUrl, <String, dynamic>{});

      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      // Create comprehensive response structure
      final Map<String, dynamic> enhancedResponse = <String, dynamic>{
        'httpResponse': <String, dynamic>{
          'method': 'PUT',
          'url': '${AppUrl.getBaseUrl()}$apiUrl',
          'status': response.response.statusCode ?? 200,
          'statusMessage': response.response.statusMessage ?? 'OK',
          'data': response.data,
          'headers': response.response.headers.map,
          'responseTime': DateTime.now().toIso8601String(),
        },
      };
      
      // Add response data to the enhanced response if it exists
      if (response.data != null && response.data is Map<String, dynamic>) {
        enhancedResponse.addAll(response.data as Map<String, dynamic>);
      }

      // Log the detailed response in the desired format
      _logDetailedResponse(enhancedResponse);

      return enhancedResponse;
    } on DioException catch (dioError) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {
        await ApiErrorHandler.handleError(dioError);
      }

      rethrow;
    } catch (e) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {

        CustomDisplays.showToast(
          message: 'Something went wrong, please try again later',
          type: MessageType.error,
        );
      }

      rethrow;
    }
  }

  /// DELETE Request with Enhanced Response Handling
  static Future<Map<String, dynamic>> deleteData(
    String apiUrl, {
    Map<String, dynamic>? queryParameters,
    bool bearerToken = false,
    bool showLoader = true,
    bool handleError = true,
  }) async {
    try {
      if (showLoader) {
        ApiHelper.showLoader();
      }

      final response = await _apiClient.delete(
        apiUrl,
        queryParameters,
      );

      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      // Create comprehensive response structure
      final Map<String, dynamic> enhancedResponse = <String, dynamic>{
        'httpResponse': <String, dynamic>{
          'method': 'DELETE',
          'url': '${AppUrl.getBaseUrl()}$apiUrl',
          'status': response.response.statusCode ?? 200,
          'statusMessage': response.response.statusMessage ?? 'OK',
          'data': response.data,
          'headers': response.response.headers.map,
          'responseTime': DateTime.now().toIso8601String(),
        },
      };
      
      // Add response data to the enhanced response if it exists
      if (response.data != null && response.data is Map<String, dynamic>) {
        enhancedResponse.addAll(response.data as Map<String, dynamic>);
      }

      // Log the detailed response in the desired format
      _logDetailedResponse(enhancedResponse);

      return enhancedResponse;
    } on DioException catch (dioError) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {
        await ApiErrorHandler.handleError(dioError);
      }

      rethrow;
    } catch (e) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {

        CustomDisplays.showToast(
          message: 'Something went wrong, please try again later',
          type: MessageType.error,
        );
      }

      rethrow;
    }
  }

  /// Upload File with Enhanced Response Handling
  static Future<Map<String, dynamic>> uploadFile(
    File file,
    String apiUrl, {
    String? fileName,
    String? fileType,
    Map<String, dynamic>? additionalData,
    bool showLoader = true,
    bool handleError = true,
  }) async {
    try {
      if (showLoader) {
        ApiHelper.showLoader();
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName ?? file.path.split('/').last,
        ),
        if (additionalData != null) ...additionalData,
      });

      final response = await _apiClient.post(apiUrl, formData);

      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      // Create comprehensive response structure
      final Map<String, dynamic> enhancedResponse = <String, dynamic>{
        'httpResponse': <String, dynamic>{
          'method': 'POST',
          'url': '${AppUrl.getBaseUrl()}$apiUrl',
          'status': response.response.statusCode ?? 200,
          'statusMessage': response.response.statusMessage ?? 'OK',
          'data': response.data,
          'headers': response.response.headers.map,
          'responseTime': DateTime.now().toIso8601String(),
        },
      };
      
      // Add response data to the enhanced response if it exists
      if (response.data != null && response.data is Map<String, dynamic>) {
        enhancedResponse.addAll(response.data as Map<String, dynamic>);
      }

      // Log the detailed response in the desired format
      _logDetailedResponse(enhancedResponse);

      return enhancedResponse;
    } on DioException catch (dioError) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {
        await ApiErrorHandler.handleError(dioError);
      }

      rethrow;
    } catch (e) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {

        CustomDisplays.showToast(
          message: 'Failed to upload file. Please try again later',
          type: MessageType.error,
        );
      }

      rethrow;
    }
  }

  /// Authentication Methods
  
  /// Login with Enhanced Response Handling
  static Future<Map<String, dynamic>> login(
    String email,
    String password, {
    bool showLoader = true,
  }) async {
    try {
      if (showLoader) {
        ApiHelper.showLoader();
      }

      final data = {
        'email': email,
        'password': password,
      };

      final response = await _apiClient.login(data);

      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      // Create comprehensive response structure similar to your desired format
      final Map<String, dynamic> enhancedResponse = <String, dynamic>{
        'httpResponse': <String, dynamic>{
          'method': 'POST',
          'url': '${AppUrl.getBaseUrl()}${AppUrl.login}',
          'status': response.response.statusCode ?? 200,
          'statusMessage': response.response.statusMessage ?? 'OK',
          'data': response.data,
          'headers': response.response.headers.map,
          'responseTime': DateTime.now().toIso8601String(),
        },
      };
      
      // Add response data to the enhanced response if it exists
      if (response.data != null && response.data is Map<String, dynamic>) {
        enhancedResponse.addAll(response.data as Map<String, dynamic>);
      }

      // Log the detailed response in the desired format
      _logDetailedResponse(enhancedResponse);

      return enhancedResponse;
    } catch (error) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }


      CustomDisplays.showToast(
        message: 'Login failed. Please check your credentials and try again',
        type: MessageType.error,
        allowDuplicate: false,
      );

      rethrow;
    }
  }

  /// Log detailed HTTP response in the desired format
  static void _logDetailedResponse(Map<String, dynamic> enhancedResponse) {
    final httpResponse = enhancedResponse['httpResponse'];
    final method = httpResponse['method'];
    final url = httpResponse['url'];
    final status = httpResponse['status'];
    final statusMessage = httpResponse['statusMessage'];
    final data = httpResponse['data'];
    final headers = httpResponse['headers'];


  }

  /// Format JSON for display with proper indentation
  static String _formatJsonForDisplay(dynamic jsonData, {int indent = 0}) {
    if (jsonData == null) return 'null';
    
    const String tab = '  ';
    final String currentIndent = tab * indent;
    final String nextIndent = tab * (indent + 1);
    
    if (jsonData is Map) {
      if (jsonData.isEmpty) return '{}';
      
      final buffer = StringBuffer('{\n');
      final entries = jsonData.entries.toList();
      
      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];
        buffer.write('│ $nextIndent"${entry.key}": ');
        buffer.write(_formatJsonForDisplay(entry.value, indent: indent + 1));
        if (i < entries.length - 1) buffer.write(',');
        buffer.write('\n');
      }
      
      buffer.write('│ $currentIndent}');
      return buffer.toString();
    } else if (jsonData is List) {
      if (jsonData.isEmpty) return '[]';
      
      final buffer = StringBuffer('[\n');
      for (int i = 0; i < jsonData.length; i++) {
        buffer.write('│ $nextIndent');
        buffer.write(_formatJsonForDisplay(jsonData[i], indent: indent + 1));
        if (i < jsonData.length - 1) buffer.write(',');
        buffer.write('\n');
      }
      buffer.write('│ $currentIndent]');
      return buffer.toString();
    } else if (jsonData is String) {
      // Try to parse JSON strings (like vitamins, minerals, fatBreakdown)
      if (jsonData.startsWith('{') && jsonData.endsWith('}')) {
        try {
          final parsed = json.decode(jsonData);
          return _formatJsonForDisplay(parsed, indent: indent);
        } catch (e) {
          // If parsing fails, treat as regular string
        }
      }
      
      return '"$jsonData"';
    } else {
      return jsonData.toString();
    }
  }

  static Future<Map<String, dynamic>> sendOtp(
    String email, {
    bool showLoader = true,
  }) async {
    try {
      if (showLoader) {
        ApiHelper.showLoader();
      }

      final data = {
        'email': email,
      };

      final response = await _apiClient.sendOtp(data);

      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      // Create comprehensive response structure
      final Map<String, dynamic> enhancedResponse = <String, dynamic>{
        'httpResponse': <String, dynamic>{
          'method': 'POST',
          'url': '${AppUrl.getBaseUrl()}${AppUrl.sendOtp}',
          'status': response.response.statusCode ?? 200,
          'statusMessage': response.response.statusMessage ?? 'OK',
          'data': response.data,
          'headers': response.response.headers.map,
          'responseTime': DateTime.now().toIso8601String(),
        },
      };
      
      // Add response data to the enhanced response if it exists
      if (response.data != null && response.data is Map<String, dynamic>) {
        enhancedResponse.addAll(response.data as Map<String, dynamic>);
      }

      // Log the detailed response in the desired format
      _logDetailedResponse(enhancedResponse);

      return enhancedResponse;
    } catch (error) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }


      CustomDisplays.showToast(
        message: 'Failed to send OTP. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }

  static Future<dynamic> registerAdmin(
    String firstName,
    String lastName,
    String email,
    String otp,
    String password, {
    bool showLoader = true,
  }) async {
    try {
      if (showLoader) {
        ApiHelper.showLoader();
      }

      final data = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'otp': otp,
        'password': password,
      };

      final response = await _apiClient.registerAdmin(data);

      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      return response.data;
    } catch (error) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }


      CustomDisplays.showToast(
        message: 'Registration failed. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }

  static Future<dynamic> registerDeliveryPerson(
    String firstName,
    String lastName,
    String email,
    String otp,
      String password,
      String phoneNumber,
      String address,
      String identificationNumber,
      String vehicleType,
      String vehicleNumber,
      DateTime dateOfBirth,
      String emergencyContact, {
        String? profilePictureUrl,
        String? documentsUrl,
    bool showLoader = true,
  }) async {
    try {
      if (showLoader) {
        ApiHelper.showLoader();
      }

      final data = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'otp': otp,
        'password': password,
        'phoneNumber': phoneNumber,
        'address': address,
        'identificationNumber': identificationNumber,
        'vehicleType': vehicleType,
        'vehicleNumber': vehicleNumber,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'emergencyContact': emergencyContact,
        if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
        if (documentsUrl != null) 'documentsUrl': documentsUrl,
      };

      final response = await _apiClient.registerDeliveryPerson(data);

      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      return response.data;
    } catch (error) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }


      CustomDisplays.showToast(
        message: 'Registration failed. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }

  static Future<dynamic> getDeliveryPersons({bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();
      final response = await _apiClient.getDeliveryPersons();
      if (showLoader) ApiHelper.dismissLoader();
      return response.data;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();

      CustomDisplays.showToast(
        message: 'Failed to load delivery persons. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }

  static Future<dynamic> updateDeliveryPerson(String id,
      Map<String, dynamic> data, {bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();
      final response = await _apiClient.updateDeliveryPerson(id, data);
      if (showLoader) ApiHelper.dismissLoader();
      return response.data;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();

      CustomDisplays.showToast(
        message: 'Failed to update delivery person. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }

  static Future<dynamic> deleteDeliveryPerson(String id,
      {bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();
      final response = await _apiClient.deleteDeliveryPerson(id);
      if (showLoader) ApiHelper.dismissLoader();
      return response.data;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();

      CustomDisplays.showToast(
        message: 'Failed to delete delivery person. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }

  // Delivery Agent methods (Admin API endpoints)
  static Future<dynamic> getAllDeliveryAgents({bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();
      final response = await getData(
          'api/admin/delivery-agents', showLoader: false);
      if (showLoader) ApiHelper.dismissLoader();
      return response;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();
      CustomDisplays.showToast(
        message: 'Failed to load delivery agents. Please try again later',
        type: MessageType.error,
      );
      rethrow;
    }
  }

  static Future<dynamic> createDeliveryAgent(Map<String, dynamic> data,
      {bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();
      final response = await postData(
          data, 'api/admin/delivery-agents', showLoader: false);
      if (showLoader) ApiHelper.dismissLoader();
      return response;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();
      CustomDisplays.showToast(
        message: 'Failed to create delivery agent. Please try again later',
        type: MessageType.error,
      );
      rethrow;
    }
  }

  static Future<dynamic> updateDeliveryAgent(String id,
      Map<String, dynamic> data, {bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();
      final response = await putDataWithBody(
          data, 'api/admin/delivery-agents/$id', showLoader: false);
      if (showLoader) ApiHelper.dismissLoader();
      return response;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();
      CustomDisplays.showToast(
        message: 'Failed to update delivery agent. Please try again later',
        type: MessageType.error,
      );
      rethrow;
    }
  }

  static Future<dynamic> deleteDeliveryAgent(String id,
      {bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();
      final response = await deleteData(
          'api/admin/delivery-agents/$id', showLoader: false);
      if (showLoader) ApiHelper.dismissLoader();
      return response;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();
      CustomDisplays.showToast(
        message: 'Failed to delete delivery agent. Please try again later',
        type: MessageType.error,
      );
      rethrow;
    }
  }

  // Recipe methods
  static Future<dynamic> getRecipes({
    bool showLoader = true,
  }) async {
    try {
      if (showLoader) {
        ApiHelper.showLoader();
      }

      final response = await _apiClient.getRecipes();

      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      return response.data;
    } catch (error) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }


      CustomDisplays.showToast(
        message: 'Failed to load recipes. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }

  static Future<dynamic> getRecipeById(String id, {
    bool showLoader = true,
  }) async {
    try {
      if (showLoader) {
        ApiHelper.showLoader();
      }

      final response = await _apiClient.getRecipeById(id);

      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      return response.data;
    } catch (error) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }


      CustomDisplays.showToast(
        message: 'Failed to load recipe. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }

  static Future<dynamic> getRecipeDetails(String id, {
    bool showLoader = true,
  }) async {
    try {
      if (showLoader) {
        ApiHelper.showLoader();
      }

      final response = await _apiClient.getRecipeDetails(id);

      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      return response.data;
    } catch (error) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }


      CustomDisplays.showToast(
        message: 'Failed to load recipe details. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }

  static Future<dynamic> createRecipe(Map<String, dynamic> data, {bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();
      final response = await _apiClient.createRecipe(data);
      if (showLoader) ApiHelper.dismissLoader();
      return response.data;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();

      CustomDisplays.showToast(
        message: 'Failed to create recipe. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }
  
  static Future<dynamic> updateRecipe(String id, Map<String, dynamic> data, {bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();
      final response = await _apiClient.updateRecipe(id, data);
      if (showLoader) ApiHelper.dismissLoader();
      return response.data;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();

      CustomDisplays.showToast(
        message: 'Failed to update recipe. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }
  
  static Future<dynamic> deleteRecipe(String id, {bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();
      final response = await _apiClient.deleteRecipe(id);
      if (showLoader) ApiHelper.dismissLoader();
      return response.data;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();

      CustomDisplays.showToast(
        message: 'Failed to delete recipe. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }
  
  // Ingredient methods
  static Future<dynamic> getIngredients({bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();
      final response = await _apiClient.getIngredients();
      if (showLoader) ApiHelper.dismissLoader();
      return response.data;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();

      CustomDisplays.showToast(
        message: 'Failed to load ingredients. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }
  
  
  static Future<dynamic> createIngredient(Map<String, dynamic> data, {bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();
      final response = await _apiClient.createIngredient(data);
      if (showLoader) ApiHelper.dismissLoader();
      return response.data;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();

      CustomDisplays.showToast(
        message: 'Failed to create ingredient. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }
  
  static Future<dynamic> updateIngredient(String id, Map<String, dynamic> data, {bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();
      final response = await _apiClient.updateIngredient(id, data);
      if (showLoader) ApiHelper.dismissLoader();
      return response.data;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();

      CustomDisplays.showToast(
        message: 'Failed to update ingredient. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }
  
  static Future<dynamic> deleteIngredient(String id, {bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();
      final response = await _apiClient.deleteIngredient(id);
      if (showLoader) ApiHelper.dismissLoader();
      return response.data;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();

      CustomDisplays.showToast(
        message: 'Failed to delete ingredient. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }

  // Exercise methods
  static Future<dynamic> getExercises({bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();
      final response = await _apiClient.getExercises();
      if (showLoader) ApiHelper.dismissLoader();
      return response.data;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();

      CustomDisplays.showToast(
        message: 'Failed to load exercises. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }

  static Future<dynamic> getExerciseById(String id,
      {bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();
      final response = await _apiClient.getExerciseById(id);
      if (showLoader) ApiHelper.dismissLoader();
      return response.data;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();

      CustomDisplays.showToast(
        message: 'Failed to load exercise. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }

  static Future<dynamic> createExercise(Map<String, dynamic> data,
      {bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();
      final response = await _apiClient.createExercise(data);
      if (showLoader) ApiHelper.dismissLoader();
      return response.data;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();

      CustomDisplays.showToast(
        message: 'Failed to create exercise. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }

  static Future<dynamic> updateExercise(String id, Map<String, dynamic> data,
      {bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();
      final response = await _apiClient.updateExercise(id, data);
      if (showLoader) ApiHelper.dismissLoader();
      return response.data;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();

      CustomDisplays.showToast(
        message: 'Failed to update exercise. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }

  static Future<dynamic> deleteExercise(String id,
      {bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();
      final response = await _apiClient.deleteExercise(id);
      if (showLoader) ApiHelper.dismissLoader();
      return response.data;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();

      CustomDisplays.showToast(
        message: 'Failed to delete exercise. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }

  // Delivery Report methods
  static Future<dynamic> getDeliveryReportAvailableDates(
      {bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();
      final response = await _apiClient.getDeliveryReportAvailableDates();
      if (showLoader) ApiHelper.dismissLoader();
      return response.data;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();

      CustomDisplays.showToast(
        message: 'Failed to load available delivery dates. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }

  static Future<dynamic> getDeliveryReportData(String deliveryDate,
      int mealPeriod, {bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();

      print('Sending request to get delivery report data:');
      print('- Date: $deliveryDate');
      print('- Meal Period: $mealPeriod (${_getMealPeriodName(mealPeriod)})');

      // API endpoint: POST /api/admin/AdminDeliveryReport/data
      final response = await _apiClient.getDeliveryReportData({
        'deliveryDate': deliveryDate,
        'mealPeriod': mealPeriod,
      });

      if (showLoader) ApiHelper.dismissLoader();

      // Log successful response
      if (response.data != null && response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] != null) {
          final reportData = responseData['data'] as Map<String, dynamic>;
          final deliveriesCount = reportData['data'] != null ?
          (reportData['data'] as List<dynamic>).length : 0;
          final summary = reportData['summary'] as Map<String, dynamic>?;

          print('Report data retrieved successfully:');
          print('- Total deliveries: ${summary?['totalDeliveries'] ??
              deliveriesCount}');
          print('- Delivered: ${summary?['delivered'] ?? 'N/A'}');
          print('- Pending: ${summary?['pending'] ?? 'N/A'}');
        }
      }

      return response.data;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();

      print('Error getting delivery report data: $error');

      CustomDisplays.showToast(
        message: 'Failed to load delivery report data. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }

  static Future<dynamic> getDeliveryReportDateRangeData(String startDate,
      String endDate,
      int mealPeriod,
      {bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();

      // API endpoint: POST /api/admin/AdminDeliveryReport/dateRangeData
      final response = await _apiClient.post(
        'api/admin/AdminDeliveryReport/dateRangeData',
        {
          'startDate': startDate,
          'endDate': endDate,
          'mealPeriod': mealPeriod,
        },
      );

      if (showLoader) ApiHelper.dismissLoader();

      // Log successful response
      if (response.data != null && response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] != null) {
          final reportData = responseData['data'] as Map<String, dynamic>;
          final deliveriesCount = reportData['data'] != null ?
          (reportData['data'] as List<dynamic>).length : 0;
          final summary = reportData['summary'] as Map<String, dynamic>?;

          print('Date range report data retrieved successfully:');
          print('- Total deliveries: ${summary?['totalDeliveries'] ??
              deliveriesCount}');
          print('- Delivered: ${summary?['delivered'] ?? 'N/A'}');
          print('- Pending: ${summary?['pending'] ?? 'N/A'}');
        }
      }

      return response.data;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();

      print('Error getting date range delivery report data: $error');

      CustomDisplays.showToast(
        message: 'Failed to load date range delivery report data. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }

  static Future<dynamic> generateDeliveryReportExcel(String deliveryDate,
      int mealPeriod, {bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();

      print('Generating Excel report:');
      print('- Date: $deliveryDate');
      print('- Meal Period: $mealPeriod (${_getMealPeriodName(mealPeriod)})');

      // API endpoint: POST /api/admin/AdminDeliveryReport/generate-excel
      final response = await _apiClient.generateDeliveryReportExcel({
        'deliveryDate': deliveryDate,
        'mealPeriod': mealPeriod,
      });

      if (showLoader) ApiHelper.dismissLoader();

      // For Excel file download, we should receive a binary response or a download URL
      print('Excel generation response received');

      // The API might return different response formats:  
      // 1. Binary data directly (blob)  
      // 2. A URL to download the file  
      // 3. A JSON response with file info

      if (response.data != null) {
        if (response.data is Map<String, dynamic>) {
          final responseData = response.data as Map<String, dynamic>;
          if (responseData['fileUrl'] != null) {
            print('Excel file URL: ${responseData['fileUrl']}');
          } else if (responseData['fileName'] != null) {
            print('Excel file name: ${responseData['fileName']}');
          }
        }
      }

      return response.data;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();

      print('Error generating Excel report: $error');

      CustomDisplays.showToast(
        message: 'Failed to generate Excel report. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }

  static Future<dynamic> generateDeliveryReportExcelRange(String startDate,
      String endDate,
      int mealPeriod,
      {bool showLoader = true}) async {
    try {
      if (showLoader) ApiHelper.showLoader();

      print('Generating date range Excel report:');
      print('- Start Date: $startDate');
      print('- End Date: $endDate');
      print('- Meal Period: $mealPeriod (${_getMealPeriodName(mealPeriod)})');

      // API endpoint: POST /api/admin/AdminDeliveryReport/generate-excel-range
      final response = await _apiClient.post(
        'api/admin/AdminDeliveryReport/generate-excel-range',
        {
          'startDate': startDate,
          'endDate': endDate,
          'mealPeriod': mealPeriod,
        },
      );

      if (showLoader) ApiHelper.dismissLoader();

      print('Date range Excel generation response received');

      if (response.data != null) {
        if (response.data is Map<String, dynamic>) {
          final responseData = response.data as Map<String, dynamic>;
          if (responseData['fileUrl'] != null) {
            print('Excel file URL: ${responseData['fileUrl']}');
          } else if (responseData['fileName'] != null) {
            print('Excel file name: ${responseData['fileName']}');
          }
        }
      }

      return response.data;
    } catch (error) {
      if (showLoader) ApiHelper.dismissLoader();

      print('Error generating date range Excel report: $error');

      CustomDisplays.showToast(
        message: 'Failed to generate date range Excel report. Please try again later',
        type: MessageType.error,
      );

      rethrow;
    }
  }

  // Helper method to get meal period name
  static String _getMealPeriodName(int mealPeriod) {
    switch (mealPeriod) {
      case 0:
        return 'Breakfast';
      case 1:
        return 'Lunch';
      case 2:
        return 'Dinner';
      default:
        return 'Unknown';
    }
  }

  /// Utility Methods

  /// Prepare request data
  static dynamic _prepareRequestData(dynamic data) {
    if (data is String) {
      try {
        // Try to parse as JSON
        return json.decode(data);
      } catch (e) {
        // If not JSON, return as is
        return data;
      }
    }
    return data;
  }

  /// Show loader - Disabled (no overscreen loading)
  static void showLoader() {
    // Overscreen loading removed
  }

  /// Dismiss loader - Disabled (no overscreen loading)
  static void dismissLoader() {
    // Overscreen loading removed
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await _authService.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get stored token
  static Future<String?> getToken() async {
    return await _authService.getToken();
  }

  /// Store token
  static Future<void> storeToken(String token) async {
    await _authService.storeToken(token);
  }

  /// Clear token (also clears refresh token for complete logout)
  static Future<void> clearToken() async {
    await _authService.clearToken();
  }

  /// Store authentication tokens from login/register response
  static Future<void> storeAuthTokens(Map<String, dynamic> response) async {
    if (response['token'] != null) {
      await _authService.storeToken(response['token'] as String);
    }
    
    if (response['refreshToken'] != null) {
      await _authService.storeRefreshToken(response['refreshToken'] as String);
    }
  }

  /// Get stored refresh token
  static Future<String?> getRefreshToken() async {
    return await _authService.getRefreshToken();
  }

  /// Store refresh token
  static Future<void> storeRefreshToken(String refreshToken) async {
    await _authService.storeRefreshToken(refreshToken);
  }

  /// Store both access and refresh tokens
  static Future<void> storeTokens(String accessToken, String refreshToken) async {
    await _authService.storeToken(accessToken);
    await _authService.storeRefreshToken(refreshToken);
  }

  /// Clear refresh token
  static Future<void> clearRefreshToken() async {
    await _authService.clearRefreshToken();
  }

  /// Clear both access and refresh tokens
  static Future<void> clearAllTokens() async {
    await _authService.clearToken();
  }

  /// Refresh access token using refresh token
  static Future<Map<String, dynamic>?> refreshAccessToken() async {
    try {
      final refreshToken = await _authService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      final response = await _apiClient.refreshToken({'refreshToken': refreshToken});
      
      if (response.response.statusCode == 200) {
        final data = response.data;

        if (data != null && data is Map<String, dynamic> &&
            data['token'] != null) {
          // Store new tokens
          await _authService.storeToken(data['token'] as String);
          
          if (data['refreshToken'] != null) {
            await _authService.storeRefreshToken(
                data['refreshToken'] as String);
          }
          
          return data;
        }
      }
      
      return null;
    } catch (error) {

      return null;
    }
  }
}

/// Backward Compatibility Layer
/// This class provides the same interface as the old NetworkService
/// but uses the new Dio-based implementation underneath
/// Note: Returns only the data portion for backward compatibility
class NetworkService {
  /// Initialize the service
  static void initialize() {
    DioNetworkService.initialize();
  }

  /// POST Data - Backward compatibility (returns only data)
  static Future<dynamic> postData(
    dynamic data,
    String apiUrl, {
    bool bearerToken = false,
  }) async {
    final enhancedResponse = await DioNetworkService.postData(
      data,
      apiUrl,
      bearerToken: bearerToken,
    );
    // Return only the actual response data for backward compatibility
    return enhancedResponse['httpResponse']?['data'] ?? enhancedResponse['data'];
  }

  /// GET Data - Backward compatibility (returns only data)
  static Future<dynamic> getData(
    String apiUrl, {
    bool bearerToken = false,
  }) async {
    final enhancedResponse = await DioNetworkService.getData(
      apiUrl,
      bearerToken: bearerToken,
    );
    // Return only the actual response data for backward compatibility
    return enhancedResponse['httpResponse']?['data'] ?? enhancedResponse['data'];
  }

  /// PUT Data with Body - Backward compatibility (returns only data)
  static Future<dynamic> putDataWithBody(
    dynamic data,
    String apiUrl, {
    bool bearerToken = false,
  }) async {
    final enhancedResponse = await DioNetworkService.putDataWithBody(
      data,
      apiUrl,
      bearerToken: bearerToken,
    );
    // Return only the actual response data for backward compatibility
    return enhancedResponse['httpResponse']?['data'] ?? enhancedResponse['data'];
  }

  /// PUT Data without Body - Backward compatibility (returns only data)
  static Future<dynamic> putDataWithOutBody(
    String apiUrl, {
    bool bearerToken = false,
  }) async {
    final enhancedResponse = await DioNetworkService.putDataWithoutBody(
      apiUrl,
      bearerToken: bearerToken,
    );
    // Return only the actual response data for backward compatibility
    return enhancedResponse['httpResponse']?['data'] ?? enhancedResponse['data'];
  }

  /// Headers with token - Backward compatibility
  static Map<String, String> headersWithToken(String token) => {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  /// Headers without token - Backward compatibility
  static Map<String, String> headersWithoutToken(String? token) => {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };

  /// Show loader - Backward compatibility
  static void showLoader() {
    DioNetworkService.showLoader();
  }

  /// Dismiss loader - Backward compatibility
  static void dismissLoader() {
    DioNetworkService.dismissLoader();
  }
}