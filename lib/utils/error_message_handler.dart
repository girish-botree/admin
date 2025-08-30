import 'package:flutter/foundation.dart';
import '../config/app_string_config.dart';
import '../widgets/custom_displays.dart';


/// Enhanced utility class to provide user-friendly error messages with smart categorization
class ErrorMessageHandler {
  /// Error categories for better organization
  static const Map<String, String> _networkErrors = {
    'no_internet': 'No internet connection available',
    'connection_timeout': 'Connection timed out. Please try again',
    'server_unreachable': 'Server is currently unreachable',
    'connection_failed': 'Failed to connect to server',
    'dns_failure': 'Network connection error',
  };
  
  static const Map<String, String> _authErrors = {
    'invalid_credentials': 'Invalid username or password',
    'account_locked': 'Account has been temporarily locked',
    'session_expired': 'Your session has expired. Please log in again',
    'unauthorized': 'You are not authorized to perform this action',
    'token_invalid': 'Authentication failed. Please log in again',
  };
  
  static const Map<String, String> _validationErrors = {
    'required_field': 'This field is required',
    'invalid_email': 'Please enter a valid email address',
    'password_too_short': 'Password must be at least 8 characters',
    'passwords_dont_match': 'Passwords do not match',
    'invalid_phone': 'Please enter a valid phone number',
  };
  
  static const Map<String, String> _dataErrors = {
    'not_found': 'The requested item was not found',
    'already_exists': 'This item already exists',
    'insufficient_permissions': 'You do not have permission to access this',
    'quota_exceeded': 'You have exceeded your usage limit',
    'invalid_format': 'Invalid data format provided',
  };
  /// Get a user-friendly error message for a specific operation with enhanced categorization
  static String getUserFriendlyMessage(dynamic error, {
    required String operation,
    bool isNetworkError = false,
    String? errorCode,
    String? context,
  }) {
    // Error logging disabled to reduce console noise

    // Check for specific error codes first
    if (errorCode != null) {
      final specificMessage = _getMessageByErrorCode(errorCode);
      if (specificMessage != null) {
        return specificMessage;
      }
    }

    // Handle network errors with better messaging
    if (isNetworkError || _isNetworkError(error)) {
      return _getNetworkErrorMessage(error);
    }
    
    // Handle authentication errors
    if (_isAuthError(error)) {
      return _getAuthErrorMessage(error);
    }

    // Map specific operations to user-friendly messages with context
    final cleanOperation = operation.toLowerCase().replaceAll(' ', '');
    switch (cleanOperation) {
      // Authentication operations
      case 'login':
        return context != null ? 'Login failed: $context' : AppStringConfig.loginFailed;
      case 'logout':
        return 'Logout failed. Please try again';
      case 'register':
      case 'registeradmin':
      case 'registerdeliveryperson':
        return AppStringConfig.registrationFailed;
        
      // Communication operations
      case 'sendotp':
        return AppStringConfig.failedToSendOtp;
        
      // File operations
      case 'upload':
      case 'uploadfile':
        return AppStringConfig.failedToUploadFile;
      case 'download':
        return 'Failed to download file. Please check your connection';
        
      // CRUD operations with specific context
      case 'update':
      case 'updatedeliveryperson':
      case 'updaterecipe':
      case 'updateingredient':
      case 'updatemealplan':
        return context != null 
            ? 'Failed to update $context' 
            : AppStringConfig.failedToUpdateData;
            
      case 'delete':
      case 'deletedelivelyperson':
      case 'deleterecipe':
      case 'deleteingredient':
      case 'deletemealplan':
        return context != null 
            ? 'Failed to delete $context' 
            : AppStringConfig.failedToDeleteData;
            
      case 'create':
      case 'createrecipe':
      case 'createingredient':
      case 'createmealplan':
        return context != null 
            ? 'Failed to create $context' 
            : AppStringConfig.failedToCreateData;
            
      // Data loading operations
      case 'getdeliverypersons':
        return 'Failed to load delivery persons. Please try again';
      case 'getrecipes':
        return 'Failed to load recipes. Please try again';
      case 'getrecipebyid':
        return 'Failed to load recipe details. Please try again';
      case 'getingredients':
        return 'Failed to load ingredients. Please try again';
      case 'getmealplans':
        return 'Failed to load meal plans. Please try again';
      case 'getdashboardstats':
        return 'Failed to load dashboard statistics. Please try again';
        
      // Search operations
      case 'search':
        return 'Search failed. Please try again';
      case 'filter':
        return 'Failed to apply filters. Please try again';
        
      default:
        return context != null 
            ? 'Operation failed: $context' 
            : AppStringConfig.somethingWentWrong;
    }
  }
  
  /// Get user-friendly message based on error code
  static String? _getMessageByErrorCode(String errorCode) {
    final code = errorCode.toLowerCase();
    
    return _networkErrors[code] ?? 
           _authErrors[code] ?? 
           _validationErrors[code] ?? 
           _dataErrors[code];
  }
  
  /// Get network-specific error message
  static String _getNetworkErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('timeout')) {
      return 'Connection timed out. Please check your internet and try again';
    } else if (errorStr.contains('unreachable') || errorStr.contains('host')) {
      return 'Server is unreachable. Please try again later';
    } else if (errorStr.contains('dns')) {
      return 'Network connection error. Please check your internet';
    } else {
      return AppStringConfig.networkConnectionIssue;
    }
  }
  
  /// Get authentication-specific error message
  static String _getAuthErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('unauthorized') || errorStr.contains('401')) {
      return 'You are not authorized to perform this action';
    } else if (errorStr.contains('token') || errorStr.contains('expired')) {
      return 'Your session has expired. Please log in again';
    } else {
      return 'Authentication failed. Please try again';
    }
  }

  /// Enhanced network error detection
  static bool isNetworkError(dynamic error) {
    return _isNetworkError(error);
  }
  
  static bool _isNetworkError(dynamic error) {
    if (error == null) return false;
    
    final errorMessage = error.toString().toLowerCase();
    return errorMessage.contains('network') ||
        errorMessage.contains('internet') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('socket') ||
        errorMessage.contains('timeout') ||
        errorMessage.contains('unreachable') ||
        errorMessage.contains('dns') ||
        errorMessage.contains('offline') ||
        errorMessage.contains('host');
  }
  
  /// Check if error is related to authentication
  static bool isAuthError(dynamic error) {
    return _isAuthError(error);
  }
  
  static bool _isAuthError(dynamic error) {
    if (error == null) return false;
    
    final errorMessage = error.toString().toLowerCase();
    return errorMessage.contains('unauthorized') ||
        errorMessage.contains('authentication') ||
        errorMessage.contains('token') ||
        errorMessage.contains('session') ||
        errorMessage.contains('login') ||
        errorMessage.contains('credential') ||
        errorMessage.contains('401') ||
        errorMessage.contains('403');
  }
  
  /// Check if error is a validation error
  static bool isValidationError(dynamic error) {
    if (error == null) return false;
    
    final errorMessage = error.toString().toLowerCase();
    return errorMessage.contains('validation') ||
        errorMessage.contains('invalid') ||
        errorMessage.contains('required') ||
        errorMessage.contains('format') ||
        errorMessage.contains('missing') ||
        errorMessage.contains('400');
  }
  
  /// Show user-friendly error message using the custom display system
  static void showUserFriendlyError(String operation, {
    String? errorCode,
    String? context,
    dynamic originalError,
    bool persistent = false,
  }) {
    final message = getUserFriendlyMessage(
      originalError,
      operation: operation,
      errorCode: errorCode,
      context: context,
    );
    
    if (_isNetworkError(originalError)) {
      CustomDisplays.showInfoBar(
        message: message,
        type: InfoBarType.networkError,
        actionText: 'Retry',
        persistent: persistent,
        onAction: () => CustomDisplays.dismissInfoBar(),
      );
    } else if (_isAuthError(originalError)) {
      CustomDisplays.showToast(
        message: message,
        type: MessageType.warning,
        duration: const Duration(seconds: 4),
      );
    } else {
      CustomDisplays.showToast(
        message: message,
        type: MessageType.error,
        duration: const Duration(seconds: 3),
      );
    }
  }
  
  /// Get error severity based on error type
  static ErrorSeverity getErrorSeverity(dynamic error) {
    if (_isNetworkError(error)) {
      return ErrorSeverity.warning;
    } else if (_isAuthError(error)) {
      return ErrorSeverity.high;
    } else if (isValidationError(error)) {
      return ErrorSeverity.low;
    } else {
      return ErrorSeverity.medium;
    }
  }
}

/// Error severity levels for different error handling strategies
enum ErrorSeverity {
  low,     // Validation errors, minor issues
  medium,  // General application errors
  high,    // Authentication errors, data corruption
  critical,// System failures, security issues
  warning, // Network issues, temporary problems
}