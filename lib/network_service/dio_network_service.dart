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
    _sharedPreference.save(AppConstants.bearerToken, token);
  }

  /// Clear token
  static Future<void> clearToken() async {
    await _sharedPreference.remove(AppConstants.bearerToken);
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