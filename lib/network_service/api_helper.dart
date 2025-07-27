import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:admin/widgets/custom_displays.dart';
import 'api_client.dart';
import 'app_url_config.dart';
import 'network_module.dart';

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
        showLoader();
      }
      
      final result = await apiCall();
      
      if (showLoadingIndicator) {
        dismissLoader();
      }
      
      return result;
    } on DioException catch (dioError) {
      if (showLoadingIndicator) {
        dismissLoader();
      }
      
      if (handleError) {
        if (customErrorMessage != null) {
          CustomDisplays.showSnackBar(message: customErrorMessage);
        } else {
          CustomDisplays.showSnackBar(message: dioError.message ?? 'API Error occurred');
          debugPrint('API Error: ${dioError.message}');
        }
      }
      
      return null;
    } catch (error) {
      if (showLoadingIndicator) {
        dismissLoader();
      }
      
      if (handleError) {
        final errorMessage = customErrorMessage ?? error.toString();
        CustomDisplays.showSnackBar(message: errorMessage);
        debugPrint('Unexpected error: $errorMessage');
      }
      
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