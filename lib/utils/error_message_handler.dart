import 'package:flutter/foundation.dart';
import '../config/app_string_config.dart';

/// Utility class to provide user-friendly error messages for different operations
class ErrorMessageHandler {
  /// Get a user-friendly error message for a specific operation
  static String getUserFriendlyMessage(dynamic error, {
    required String operation,
    bool isNetworkError = false,
  }) {
    // Always log the original error for debugging purposes
    debugPrint('Error in $operation: $error');

    // Handle network errors
    if (isNetworkError ||
        error.toString().toLowerCase().contains('network') ||
        error.toString().toLowerCase().contains('internet') ||
        error.toString().toLowerCase().contains('connection') ||
        error.toString().toLowerCase().contains('socket') ||
        error.toString().toLowerCase().contains('timeout')) {
      return AppStringConfig.networkConnectionIssue;
    }

    // Map specific operations to user-friendly messages
    switch (operation) {
      case 'login':
        return AppStringConfig.loginFailed;
      case 'register':
      case 'registerAdmin':
      case 'registerDeliveryPerson':
        return AppStringConfig.registrationFailed;
      case 'sendOtp':
        return AppStringConfig.failedToSendOtp;
      case 'upload':
      case 'uploadFile':
        return AppStringConfig.failedToUploadFile;
      case 'update':
      case 'updateDeliveryPerson':
      case 'updateRecipe':
      case 'updateIngredient':
        return AppStringConfig.failedToUpdateData;
      case 'delete':
      case 'deleteDeliveryPerson':
      case 'deleteRecipe':
      case 'deleteIngredient':
        return AppStringConfig.failedToDeleteData;
      case 'create':
      case 'createRecipe':
      case 'createIngredient':
        return AppStringConfig.failedToCreateData;
      case 'getDeliveryPersons':
        return 'Failed to load delivery persons. Please try again later';
      case 'getRecipes':
        return 'Failed to load recipes. Please try again later';
      case 'getRecipeById':
        return 'Failed to load recipe details. Please try again later';
      case 'getIngredients':
        return 'Failed to load ingredients. Please try again later';
      default:
        return AppStringConfig.somethingWentWrong;
    }
  }

  /// Checks if an error is a network-related error
  static bool isNetworkError(dynamic error) {
    final errorMessage = error.toString().toLowerCase();
    return errorMessage.contains('network') ||
        errorMessage.contains('internet') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('socket') ||
        errorMessage.contains('timeout');
  }
}