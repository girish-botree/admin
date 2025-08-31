import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Centralized Error Handler
/// Provides consistent error handling across the application
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// Handle API errors with user-friendly messages
  void handleApiError(dynamic error, {String? customMessage}) {
    String message = customMessage ?? 'An error occurred';
    
    if (error is Exception) {
      message = _getErrorMessage(error);
    }
    
    _showErrorSnackBar(message);
  }

  /// Handle network errors
  void handleNetworkError(dynamic error) {
    String message = 'Network error occurred';
    
    if (error.toString().contains('timeout')) {
      message = 'Request timeout. Please try again.';
    }
    
    _showErrorSnackBar(message);
  }

  /// Handle validation errors
  void handleValidationError(String field, String message) {
    _showErrorSnackBar('$field: $message');
  }

  /// Handle authentication errors
  void handleAuthError(dynamic error) {
    String message = 'Authentication failed';
    
    if (error.toString().contains('401')) {
      message = 'Session expired. Please login again.';
      // TODO: Redirect to login screen
    } else if (error.toString().contains('403')) {
      message = 'Access denied. Insufficient permissions.';
    }
    
    _showErrorSnackBar(message);
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('400')) {
      return 'Invalid request. Please check your input.';
    } else if (error.toString().contains('404')) {
      return 'Resource not found.';
    } else if (error.toString().contains('500')) {
      return 'Server error. Please try again later.';
    } else if (error.toString().contains('timeout')) {
      return 'Request timeout. Please try again.';
    }
    
    return 'An unexpected error occurred.';
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error_outline, color: Colors.red),
    );
  }

  /// Show success message
  void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
    );
  }

  /// Show warning message
  void showWarning(String message) {
    Get.snackbar(
      'Warning',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.orange.shade900,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.warning_amber_outlined, color: Colors.orange),
    );
  }

  /// Show info message
  void showInfo(String message) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade900,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.info_outline, color: Colors.blue),
    );
  }
}
