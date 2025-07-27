import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../config/appconstants.dart';
import '../config/common_utils.dart';
import '../config/shared_preference.dart';
import '../widgets/custom_displays.dart';
import 'api_client.dart';

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
  static final SharedPreference _sharedPreference = SharedPreference();
  static late ApiClient _apiClient;
  
  /// Initialize the network service
  static void initialize() {
    _apiClient = ApiHelper.getApiClient();
  }

  /// GET Request
  static Future<dynamic> getData(
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

      return response.data;
    } on DioException catch (dioError) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {
        await ApiErrorHandler.handleError(dioError);
      }

      rethrow;
    } catch (error) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {
        CommonUtils.debugLog(error.toString());
        CustomDisplays.showSnackBar(message: error.toString());
      }

      rethrow;
    }
  }

  /// POST Request
  static Future<dynamic> postData(
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

      return response.data;
    } on DioException catch (dioError) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {
        await ApiErrorHandler.handleError(dioError);
      }

      rethrow;
    } catch (error) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {
        CommonUtils.debugLog(error.toString());
        CustomDisplays.showSnackBar(message: error.toString());
      }

      rethrow;
    }
  }

  /// PUT Request with Body
  static Future<dynamic> putDataWithBody(
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

      return response.data;
    } on DioException catch (dioError) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {
        await ApiErrorHandler.handleError(dioError);
      }

      rethrow;
    } catch (error) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {
        CommonUtils.debugLog(error.toString());
        CustomDisplays.showSnackBar(message: error.toString());
      }

      rethrow;
    }
  }

  /// PUT Request without Body
  static Future<dynamic> putDataWithoutBody(
    String apiUrl, {
    bool bearerToken = false,
    bool showLoader = true,
    bool handleError = true,
  }) async {
    try {
      if (showLoader) {
        ApiHelper.showLoader();
      }

      final response = await _apiClient.put(apiUrl, {});

      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      return response.data;
    } on DioException catch (dioError) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {
        await ApiErrorHandler.handleError(dioError);
      }

      rethrow;
    } catch (error) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {
        CommonUtils.debugLog(error.toString());
        CustomDisplays.showSnackBar(message: error.toString());
      }

      rethrow;
    }
  }

  /// DELETE Request
  static Future<dynamic> deleteData(
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

      return response.data;
    } on DioException catch (dioError) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {
        await ApiErrorHandler.handleError(dioError);
      }

      rethrow;
    } catch (error) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {
        CommonUtils.debugLog(error.toString());
        CustomDisplays.showSnackBar(message: error.toString());
      }

      rethrow;
    }
  }

  /// Upload File
  static Future<dynamic> uploadFile(
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

      return response.data;
    } on DioException catch (dioError) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {
        await ApiErrorHandler.handleError(dioError);
      }

      rethrow;
    } catch (error) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      if (handleError) {
        CommonUtils.debugLog(error.toString());
        CustomDisplays.showSnackBar(message: error.toString());
      }

      rethrow;
    }
  }

  /// Authentication Methods
  
  /// Login
  static Future<dynamic> login(
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

      return response.data;
    } catch (error) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }
      
      CommonUtils.debugLog(error.toString());
      rethrow;
    }
  }

  static Future<dynamic> sendOtp(
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

      return response.data;
    } catch (error) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }
      
      CommonUtils.debugLog(error.toString());
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
      
      CommonUtils.debugLog(error.toString());
      rethrow;
    }
  }

   static Future<dynamic> registerDeliveryPerson(
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

      final response = await _apiClient.registerDeliveryPerson(data);

      if (showLoader) {
        ApiHelper.dismissLoader();
      }

      return response.data;
    } catch (error) {
      if (showLoader) {
        ApiHelper.dismissLoader();
      }
      
      CommonUtils.debugLog(error.toString());
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
      
      CommonUtils.debugLog(error.toString());
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
      CommonUtils.debugLog(error.toString());
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
      CommonUtils.debugLog(error.toString());
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
      CommonUtils.debugLog(error.toString());
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
      CommonUtils.debugLog(error.toString());
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
      CommonUtils.debugLog(error.toString());
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
      CommonUtils.debugLog(error.toString());
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
      CommonUtils.debugLog(error.toString());
      rethrow;
    }
  }


  

  /// Logout
  // static Future<dynamic> logout() async {
  //   try {
  //     ApiHelper.showLoader();

  //     final response = await _apiClient.logout({});

  //     // Clear local storage
  //     await _sharedPreference.remove(AppConstants.bearerToken);

  //     ApiHelper.dismissLoader();

  //     return response.data;
  //   } catch (error) {
  //     ApiHelper.dismissLoader();
  //     CommonUtils.debugLog(error.toString());
  //     rethrow;
  //   }
  // }

  // /// Get User Profile
  // static Future<dynamic> getProfile() async {
  //   try {
  //     ApiHelper.showLoader();

  //     final response = await _apiClient.getProfile();

  //     ApiHelper.dismissLoader();

  //     return response.data;
  //   } catch (error) {
  //     ApiHelper.dismissLoader();
  //     CommonUtils.debugLog(error.toString());
  //     rethrow;
  //   }
  // }

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

  /// Show loader
  static void showLoader() {
    if (!EasyLoading.isShow) {
      EasyLoading.show();
    }
  }

  /// Dismiss loader
  static void dismissLoader() {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await _sharedPreference.get(AppConstants.bearerToken);
    return token != null && token.isNotEmpty;
  }

  /// Get stored token
  static Future<String?> getToken() async {
    return await _sharedPreference.get(AppConstants.bearerToken);
  }

  /// Store token
  static Future<void> storeToken(String token) async {
    await _sharedPreference.save(AppConstants.bearerToken, token);
  }

  /// Clear token (also clears refresh token for complete logout)
  static Future<void> clearToken() async {
    await clearAllTokens();
  }

  /// Store authentication tokens from login/register response
  static Future<void> storeAuthTokens(Map<String, dynamic> response) async {
    if (response['token'] != null) {
      await storeToken(response['token']);
    }
    
    if (response['refreshToken'] != null) {
      await storeRefreshToken(response['refreshToken']);
    }
  }

  /// Get stored refresh token
  static Future<String?> getRefreshToken() async {
    return await _sharedPreference.get(AppConstants.refreshToken);
  }

  /// Store refresh token
  static Future<void> storeRefreshToken(String refreshToken) async {
    await _sharedPreference.save(AppConstants.refreshToken, refreshToken);
  }

  /// Store both access and refresh tokens
  static Future<void> storeTokens(String accessToken, String refreshToken) async {
    await storeToken(accessToken);
    await storeRefreshToken(refreshToken);
  }

  /// Clear refresh token
  static Future<void> clearRefreshToken() async {
    await _sharedPreference.remove(AppConstants.refreshToken);
  }

  /// Clear both access and refresh tokens
  static Future<void> clearAllTokens() async {
    await _sharedPreference.remove(AppConstants.bearerToken);
    await clearRefreshToken();
  }

  /// Refresh access token using refresh token
  static Future<Map<String, dynamic>?> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      final response = await _apiClient.refreshToken({'refreshToken': refreshToken});
      
      if (response.response.statusCode == 200) {
        final data = response.data;
        
        if (data != null && data['token'] != null) {
          // Store new tokens
          await storeToken(data['token']);
          
          if (data['refreshToken'] != null) {
            await storeRefreshToken(data['refreshToken']);
          }
          
          return data;
        }
      }
      
      return null;
    } catch (error) {
      CommonUtils.debugLog('Token refresh failed: $error');
      return null;
    }
  }
}

/// Backward Compatibility Layer
/// This class provides the same interface as the old NetworkService
/// but uses the new Dio-based implementation underneath
class NetworkService {
  /// Initialize the service
  static void initialize() {
    DioNetworkService.initialize();
  }

  /// POST Data - Backward compatibility
  static Future<dynamic> postData(
    dynamic data,
    String apiUrl, {
    bool bearerToken = false,
  }) async {
    return await DioNetworkService.postData(
      data,
      apiUrl,
      bearerToken: bearerToken,
    );
  }

  /// GET Data - Backward compatibility
  static Future<dynamic> getData(
    String apiUrl, {
    bool bearerToken = false,
  }) async {
    return await DioNetworkService.getData(
      apiUrl,
      bearerToken: bearerToken,
    );
  }

  /// PUT Data with Body - Backward compatibility
  static Future<dynamic> putDataWithBody(
    dynamic data,
    String apiUrl, {
    bool bearerToken = false,
  }) async {
    return await DioNetworkService.putDataWithBody(
      data,
      apiUrl,
      bearerToken: bearerToken,
    );
  }

  /// PUT Data without Body - Backward compatibility
  static Future<dynamic> putDataWithOutBody(
    String apiUrl, {
    bool bearerToken = false,
  }) async {
    return await DioNetworkService.putDataWithoutBody(
      apiUrl,
      bearerToken: bearerToken,
    );
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