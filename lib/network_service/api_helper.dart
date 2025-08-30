import 'package:dio/dio.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../widgets/custom_displays.dart';
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
        _extractErrorMessage(dioError, customErrorMessage);
      }
      
      return null;
    } catch (error) {
      if (showLoadingIndicator) {
        dismissLoader();
      }
      
      if (handleError) {
        final errorMessage = error.toString();
        if (errorMessage.toLowerCase().contains('network') ||
            errorMessage.toLowerCase().contains('internet') ||
            errorMessage.toLowerCase().contains('connection')) {
          CustomDisplays.showInfoBar(
            message: errorMessage,
            type: InfoBarType.networkError,
            actionText: 'Retry',
            onAction: () {
              CustomDisplays.dismissInfoBar();
            },
          );
        } else {
          CustomDisplays.showToast(
            message: errorMessage,
            type: MessageType.error,
          );
        }
      }
      
      return null;
    }
  }

  static void _extractErrorMessage(DioException dioError,
      [String? customErrorMessage]) {
    if (customErrorMessage != null) {
      // Use InfoBar for network-related errors, Toast for others
      if (customErrorMessage.toLowerCase().contains('network') ||
          customErrorMessage.toLowerCase().contains('internet') ||
          customErrorMessage.toLowerCase().contains('connection')) {
        CustomDisplays.showInfoBar(
          message: customErrorMessage,
          type: InfoBarType.networkError,
          actionText: 'Retry',
          onAction: () {
            // Dismiss the info bar when user taps retry
            CustomDisplays.dismissInfoBar();
          },
        );
      } else {
        CustomDisplays.showToast(
          message: customErrorMessage,
          type: MessageType.error,
        );
      }
    } else {
      final errorMessage = dioError.message ?? 'API Error occurred';
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.connectionError ||
          dioError.type == DioExceptionType.receiveTimeout) {
        CustomDisplays.showInfoBar(
          message: errorMessage,
          type: InfoBarType.networkError,
          actionText: 'Retry',
          onAction: () {
            CustomDisplays.dismissInfoBar();
          },
        );
      } else {
        CustomDisplays.showToast(
          message: errorMessage,
          type: MessageType.error,
        );
      }
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