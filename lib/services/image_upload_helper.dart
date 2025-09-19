import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'file_upload_service.dart';
import '../widgets/image_upload_widget.dart';

/// Image Upload Helper
/// Provides utilities for handling image upload workflows with save operations
class ImageUploadHelper {
  ImageUploadHelper._internal();
  
  static final ImageUploadHelper _instance = ImageUploadHelper._internal();
  factory ImageUploadHelper() => _instance;

  /// Upload image and then execute save operation
  /// This ensures the save operation only executes after image upload completes
  Future<bool> uploadThenSave({
    required Future<bool> Function(String? imageUrl) saveOperation,
    String? currentImageUrl,
    String? pendingImageUpload,
    RxBool? isUploadingStatus,
    Duration uploadTimeout = const Duration(seconds: 30),
    String? successMessage,
    String? errorMessage,
  }) async {
    try {
      String? finalImageUrl = currentImageUrl;

      // Wait for any ongoing upload to complete
      if (isUploadingStatus?.value == true) {
        _showWaitingMessage();
        
        final uploadCompleted = await _waitForUploadToComplete(
          isUploadingStatus!,
          uploadTimeout,
        );

        if (!uploadCompleted) {
          _showTimeoutError();
          return false;
        }

        // Use the pending upload URL if available
        finalImageUrl = pendingImageUpload ?? currentImageUrl;
      }

      // Execute the save operation with the final image URL
      final success = await saveOperation(finalImageUrl);

      if (success) {
        _showSuccess(successMessage ?? 'Operation completed successfully');
        return true;
      } else {
        _showError(errorMessage ?? 'Operation failed. Please try again.');
        return false;
      }
    } catch (e) {
      debugPrint('Error in uploadThenSave: $e');
      _showError('An unexpected error occurred: ${e.toString()}');
      return false;
    }
  }

  /// Wait for upload to complete with timeout
  Future<bool> _waitForUploadToComplete(
    RxBool isUploadingStatus,
    Duration timeout,
  ) async {
    final completer = Completer<bool>();
    Timer? timeoutTimer;

    // Set up timeout
    timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    // Listen for upload completion
    late final Worker uploadWorker;
    uploadWorker = ever(isUploadingStatus, (bool isUploading) {
      if (!isUploading && !completer.isCompleted) {
        timeoutTimer?.cancel();
        uploadWorker.dispose();
        completer.complete(true);
      }
    });

    // If already not uploading, complete immediately
    if (!isUploadingStatus.value && !completer.isCompleted) {
      timeoutTimer.cancel();
      uploadWorker.dispose();
      completer.complete(true);
    }

    return completer.future;
  }

  /// Create a unified upload and save widget
  Widget buildUploadThenSaveButton({
    required String buttonText,
    required Future<bool> Function(String? imageUrl) onSave,
    required String? currentImageUrl,
    RxBool? isUploadingStatus,
    String? pendingImageUpload,
    bool isEnabled = true,
    IconData? icon,
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 16),
    String? successMessage,
    String? errorMessage,
  }) {
    return Obx(() {
      final isProcessing = isUploadingStatus?.value == true;
      
      return FilledButton.icon(
        onPressed: (isEnabled && !isProcessing) ? () async {
          await uploadThenSave(
            saveOperation: onSave,
            currentImageUrl: currentImageUrl,
            pendingImageUpload: pendingImageUpload,
            isUploadingStatus: isUploadingStatus,
            successMessage: successMessage,
            errorMessage: errorMessage,
          );
        } : null,
        icon: isProcessing 
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon ?? Icons.save),
        label: Text(isProcessing ? 'Processing...' : buttonText),
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });
  }

  /// Enhanced image upload widget with built-in save integration
  Widget buildIntegratedUploadWidget({
    required String fileType,
    required Future<bool> Function(String? imageUrl) onSave,
    required String saveButtonText,
    String? description,
    String? currentImageUrl,
    String? label,
    String? hintText,
    double? width,
    double? height,
    bool showRemoveButton = true,
    bool isRequired = false,
    BorderRadius? borderRadius,
    String? successMessage,
    String? errorMessage,
  }) {
    final RxString uploadedImageUrl = (currentImageUrl ?? '').obs;
    final RxBool isUploading = false.obs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image upload widget
        ImageUploadWidget(
          fileType: fileType,
          description: description,
          currentImageUrl: currentImageUrl,
          onUploadStart: () => isUploading.value = true,
          onImageUploaded: (String imageUrl) {
            uploadedImageUrl.value = imageUrl;
            isUploading.value = false;
          },
          onError: (String error) {
            isUploading.value = false;
            _showError(error);
          },
          label: label,
          hintText: hintText,
          width: width,
          height: height,
          showRemoveButton: showRemoveButton,
          isRequired: isRequired,
          borderRadius: borderRadius,
        ),
        
        const SizedBox(height: 16),
        
        // Save button with upload integration
        buildUploadThenSaveButton(
          buttonText: saveButtonText,
          onSave: onSave,
          currentImageUrl: uploadedImageUrl.value,
          isUploadingStatus: isUploading,
          successMessage: successMessage,
          errorMessage: errorMessage,
        ),
      ],
    );
  }

  /// Validate that all required images are uploaded
  bool validateRequiredImages(Map<String, String?> imageUrls) {
    for (final entry in imageUrls.entries) {
      if (entry.value == null || entry.value!.isEmpty) {
        _showError('${entry.key} is required. Please upload an image.');
        return false;
      }
    }
    return true;
  }

  /// Batch upload multiple images then save
  Future<bool> uploadMultipleThenSave({
    required Future<bool> Function(Map<String, String?> imageUrls) saveOperation,
    required Map<String, String?> currentImageUrls,
    required Map<String, RxBool> uploadStatuses,
    Duration uploadTimeout = const Duration(seconds: 60),
    String? successMessage,
    String? errorMessage,
  }) async {
    try {
      // Check if any uploads are in progress
      final anyUploading = uploadStatuses.values.any((status) => status.value);
      
      if (anyUploading) {
        _showWaitingMessage();
        
        // Wait for all uploads to complete
        final allCompleted = await _waitForAllUploadsToComplete(
          uploadStatuses,
          uploadTimeout,
        );

        if (!allCompleted) {
          _showTimeoutError();
          return false;
        }
      }

      // Execute save operation
      final success = await saveOperation(currentImageUrls);

      if (success) {
        _showSuccess(successMessage ?? 'All items saved successfully');
        return true;
      } else {
        _showError(errorMessage ?? 'Failed to save. Please try again.');
        return false;
      }
    } catch (e) {
      debugPrint('Error in uploadMultipleThenSave: $e');
      _showError('An unexpected error occurred: ${e.toString()}');
      return false;
    }
  }

  /// Wait for all uploads to complete
  Future<bool> _waitForAllUploadsToComplete(
    Map<String, RxBool> uploadStatuses,
    Duration timeout,
  ) async {
    final completer = Completer<bool>();
    Timer? timeoutTimer;

    // Set up timeout
    timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    // Check completion periodically
    late final Timer checkTimer;
    checkTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final anyStillUploading = uploadStatuses.values.any((status) => status.value);
      
      if (!anyStillUploading && !completer.isCompleted) {
        checkTimer.cancel();
        timeoutTimer?.cancel();
        completer.complete(true);
      }
    });

    return completer.future;
  }

  // UI Helper Methods
  void _showWaitingMessage() {
    Get.snackbar(
      'Please wait',
      'Waiting for image upload to complete...',
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withValues(alpha: 0.1),
      colorText: Colors.blue,
      icon: const Icon(Icons.hourglass_empty, color: Colors.blue),
    );
  }

  void _showTimeoutError() {
    Get.snackbar(
      'Upload Timeout',
      'Image upload timed out. Please try again.',
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withValues(alpha: 0.1),
      colorText: Colors.red,
      icon: const Icon(Icons.error, color: Colors.red),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.1),
      colorText: Colors.green,
      icon: const Icon(Icons.check_circle, color: Colors.green),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withValues(alpha: 0.1),
      colorText: Colors.red,
      icon: const Icon(Icons.error, color: Colors.red),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}

/// Extensions for common patterns
extension ImageUploadHelperExtensions on ImageUploadHelper {
  /// Quick method for recipe image upload and save
  Future<bool> uploadRecipeImageThenSave({
    required Future<bool> Function(String? imageUrl) saveRecipe,
    required String? currentImageUrl,
    required RxBool isUploading,
  }) {
    return uploadThenSave(
      saveOperation: saveRecipe,
      currentImageUrl: currentImageUrl,
      isUploadingStatus: isUploading,
      successMessage: 'Recipe saved successfully',
      errorMessage: 'Failed to save recipe',
    );
  }

  /// Quick method for exercise image upload and save
  Future<bool> uploadExerciseImageThenSave({
    required Future<bool> Function(String? imageUrl) saveExercise,
    required String? currentImageUrl,
    required RxBool isUploading,
  }) {
    return uploadThenSave(
      saveOperation: saveExercise,
      currentImageUrl: currentImageUrl,
      isUploadingStatus: isUploading,
      successMessage: 'Exercise saved successfully',
      errorMessage: 'Failed to save exercise',
    );
  }

  /// Quick method for ingredient image upload and save
  Future<bool> uploadIngredientImageThenSave({
    required Future<bool> Function(String? imageUrl) saveIngredient,
    required String? currentImageUrl,
    required RxBool isUploading,
  }) {
    return uploadThenSave(
      saveOperation: saveIngredient,
      currentImageUrl: currentImageUrl,
      isUploadingStatus: isUploading,
      successMessage: 'Ingredient saved successfully',
      errorMessage: 'Failed to save ingredient',
    );
  }
}