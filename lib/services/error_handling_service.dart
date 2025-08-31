import 'package:dio/dio.dart';
import '../widgets/custom_displays.dart';
import '../config/app_string_config.dart';

/// Centralized error handling service that provides deduplicated error messages
/// and consistent error handling across the app
class ErrorHandlingService {
  static final ErrorHandlingService _instance = ErrorHandlingService._internal();
  factory ErrorHandlingService() => _instance;
  ErrorHandlingService._internal();

  /// Handle API errors with deduplication
  static void handleApiError(dynamic error, {String? customMessage}) {
    String message = customMessage ?? _extractErrorMessage(error);
    
    // Handle specific error types with deduplication
    if (_isSessionExpiredError(message)) {
      CustomDisplays.showSessionExpiredMessage();
    } else {
      CustomDisplays.showToast(
        message: message,
        type: MessageType.error,
        allowDuplicate: false,
      );
    }
  }

  /// Handle DioException specifically
  static void handleDioError(DioException error, {String? customMessage}) {
    String message = customMessage ?? _extractDioErrorMessage(error);
    
    // Handle specific error types with deduplication
    if (_isSessionExpiredError(message)) {
      CustomDisplays.showSessionExpiredMessage();
    } else {
      CustomDisplays.showToast(
        message: message,
        type: MessageType.error,
        allowDuplicate: false,
      );
    }
  }

  /// Handle login errors specifically
  static void handleLoginError(dynamic error) {
    String message = _extractLoginErrorMessage(error);
    
    CustomDisplays.showToast(
      message: message,
      type: MessageType.error,
      allowDuplicate: false,
    );
  }

  /// Extract error message from various error types
  static String _extractErrorMessage(dynamic error) {
    if (error is DioException) {
      return _extractDioErrorMessage(error);
    } else if (error is String) {
      return error;
    } else if (error.toString().contains('Exception')) {
      return error.toString().replaceAll('Exception:', '').trim();
    } else {
      return error.toString();
    }
  }

  /// Extract error message from DioException
  static String _extractDioErrorMessage(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final responseData = error.response!.data;
      
      // Handle specific status codes
      switch (statusCode) {
        case 401:
          return AppStringConfig.sessionExpired;
        case 403:
          return AppStringConfig.noPermission;
        case 404:
          return AppStringConfig.resourceNotFound;
        case 429:
          return AppStringConfig.tooManyRequests;
        case 500:
          return AppStringConfig.serverError;
        case 502:
        case 503:
        case 504:
          return AppStringConfig.serviceUnavailable;
        default:
          // Try to extract message from response data
          if (responseData is Map<String, dynamic>) {
            final serverMessage = responseData['message']?.toString();
            if (serverMessage != null && serverMessage.isNotEmpty) {
              return serverMessage;
            }
          }
          return AppStringConfig.somethingWentWrong;
      }
    } else {
      // Handle network errors
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return AppStringConfig.requestTimeout;
        case DioExceptionType.connectionError:
          return AppStringConfig.noInternetConnection;
        case DioExceptionType.badCertificate:
          return AppStringConfig.certificateVerifyFailed;
        default:
          return AppStringConfig.somethingWentWrong;
      }
    }
  }

  /// Extract login-specific error message
  static String _extractLoginErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.statusCode == 401) {
        return 'Invalid email or password. Please check your credentials.';
      } else if (error.response?.statusCode == 403) {
        return 'Access denied. You do not have admin privileges.';
      } else if (error.response?.statusCode == 429) {
        return 'Too many login attempts. Please try again later.';
      }
    }
    
    return _extractErrorMessage(error);
  }

  /// Check if error is network-related
  static bool _isNetworkError(String message) {
    final lowerMessage = message.toLowerCase();
    return lowerMessage.contains('network') ||
           lowerMessage.contains('internet') ||
           lowerMessage.contains('connection') ||
           lowerMessage.contains('timeout') ||
           message == AppStringConfig.noInternetConnection ||
           message == AppStringConfig.couldNotReachTheServer ||
           message == AppStringConfig.requestTimeout ||
           message == AppStringConfig.serviceUnavailable;
  }

  /// Check if DioException is network-related
  static bool _isDioNetworkError(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           error.type == DioExceptionType.sendTimeout ||
           error.type == DioExceptionType.connectionError ||
           error.type == DioExceptionType.badCertificate;
  }

  /// Check if error is session expired
  static bool _isSessionExpiredError(String message) {
    return message.toLowerCase().contains('session') ||
           message.toLowerCase().contains('expired') ||
           message.toLowerCase().contains('unauthorized') ||
           message == AppStringConfig.sessionExpired;
  }

  /// Clear all notifications (useful for cleanup)
  static void clearAllNotifications() {
    CustomDisplays.clearAllNotifications();
  }

  /// Show success message with deduplication
  static void showSuccessMessage(String message) {
    CustomDisplays.showToast(
      message: message,
      type: MessageType.success,
      allowDuplicate: false,
    );
  }

  /// Show warning message with deduplication
  static void showWarningMessage(String message) {
    CustomDisplays.showToast(
      message: message,
      type: MessageType.warning,
      allowDuplicate: false,
    );
  }

  /// Show info message with deduplication
  static void showInfoMessage(String message) {
    CustomDisplays.showToast(
      message: message,
      type: MessageType.info,
      allowDuplicate: false,
    );
  }
}
