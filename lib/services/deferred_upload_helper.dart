import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'deferred_upload_service.dart';

/// Deferred Upload Helper
/// Provides utilities for handling deferred image upload workflows with save operations
/// Images are only uploaded when save/submit is triggered
class DeferredUploadHelper {
  DeferredUploadHelper._internal();
  
  static final DeferredUploadHelper _instance = DeferredUploadHelper._internal();
  factory DeferredUploadHelper() => _instance;

  final DeferredUploadService _uploadService = DeferredUploadService();

  /// Upload selected images and then execute save operation
  /// This ensures images are uploaded first, then save operation executes with URLs
  Future<bool> uploadThenSave({
    required Future<bool> Function(Map<String, String?> imageUrls) saveOperation,
    required Map<String, DeferredImageResult> selectedImages,
    String? successMessage,
    String? errorMessage,
    Duration uploadTimeout = const Duration(seconds: 60),
    void Function(String)? onProgress,
  }) async {
    try {
      // Check if there are any images to upload
      final imagesToUpload = selectedImages.entries
          .where((entry) => entry.value.isSelected && entry.value.isReadyForUpload)
          .toList();

      Map<String, String?> imageUrls = {};

      if (imagesToUpload.isNotEmpty) {
        // Show progress
        onProgress?.call('Uploading ${imagesToUpload.length} image(s)...');
        
        // Upload all selected images
        final uploadResults = await _uploadService.uploadMultipleDeferredImages(
          Map.fromEntries(imagesToUpload.map((e) => MapEntry(e.key, e.value))),
        );

        // Process upload results
        for (final entry in uploadResults.entries) {
          if (entry.value.isSuccess && entry.value.fileUrl != null) {
            imageUrls[entry.key] = entry.value.fileUrl;
            onProgress?.call('Uploaded ${entry.key} successfully');
          } else if (!entry.value.isCancelled) {
            _showError('Failed to upload ${entry.key}: ${entry.value.errorMessage ?? 'Unknown error'}');
            return false;
          }
        }

        onProgress?.call('All images uploaded successfully');
      }

      // Add any existing URLs for images that weren't selected/uploaded
      for (final entry in selectedImages.entries) {
        if (!imageUrls.containsKey(entry.key)) {
          imageUrls[entry.key] = null; // No image for this key
        }
      }

      onProgress?.call('Saving data...');

      // Execute the save operation with the uploaded image URLs
      final success = await saveOperation(imageUrls);

      if (success) {
        _showSuccess(successMessage ?? 'Saved successfully');
        return true;
      } else {
        _showError(errorMessage ?? 'Failed to save. Please try again.');
        return false;
      }
    } catch (e) {
      debugPrint('Error in uploadThenSave: $e');
      _showError('An unexpected error occurred: ${e.toString()}');
      return false;
    }
  }

  /// Upload single image and then execute save operation
  Future<bool> uploadSingleThenSave({
    required Future<bool> Function(String? imageUrl) saveOperation,
    required DeferredImageResult selectedImage,
    String? successMessage,
    String? errorMessage,
    void Function(String)? onProgress,
  }) async {
    return uploadThenSave(
      saveOperation: (imageUrls) => saveOperation(imageUrls.values.first),
      selectedImages: {'image': selectedImage},
      successMessage: successMessage,
      errorMessage: errorMessage,
      onProgress: onProgress,
    );
  }

  /// Build a save button that handles deferred uploads
  Widget buildDeferredUploadSaveButton({
    required String buttonText,
    required Future<bool> Function(Map<String, String?> imageUrls) onSave,
    required Map<String, DeferredImageResult> selectedImages,
    bool isEnabled = true,
    IconData? icon,
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 16),
    String? successMessage,
    String? errorMessage,
  }) {
    final RxBool isProcessing = false.obs;
    final RxString progressText = ''.obs;

    return Obx(() {
      return FilledButton.icon(
        onPressed: (isEnabled && !isProcessing.value) ? () async {
          isProcessing.value = true;
          progressText.value = 'Processing...';

          await uploadThenSave(
            saveOperation: onSave,
            selectedImages: selectedImages,
            successMessage: successMessage,
            errorMessage: errorMessage,
            onProgress: (progress) => progressText.value = progress,
          );

          isProcessing.value = false;
          progressText.value = '';
        } : null,
        icon: isProcessing.value 
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon ?? Icons.save),
        label: Text(
          isProcessing.value 
            ? (progressText.value.isNotEmpty ? progressText.value : 'Processing...')
            : buttonText
        ),
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

  /// Build a save button for single image upload
  Widget buildSingleImageSaveButton({
    required String buttonText,
    required Future<bool> Function(String? imageUrl) onSave,
    required DeferredImageResult selectedImage,
    bool isEnabled = true,
    IconData? icon,
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 16),
    String? successMessage,
    String? errorMessage,
  }) {
    return buildDeferredUploadSaveButton(
      buttonText: buttonText,
      onSave: (imageUrls) => onSave(imageUrls.values.first),
      selectedImages: {'image': selectedImage},
      isEnabled: isEnabled,
      icon: icon,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: padding,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  /// Validate that all required images are selected
  bool validateRequiredImages(Map<String, DeferredImageResult> selectedImages, List<String> requiredKeys) {
    for (final key in requiredKeys) {
      final image = selectedImages[key];
      if (image == null || !image.isSelected) {
        _showError('$key is required. Please select an image.');
        return false;
      }
    }
    return true;
  }

  /// Get upload summary
  String getUploadSummary(Map<String, DeferredImageResult> selectedImages) {
    final selected = selectedImages.values.where((img) => img.isSelected).length;
    final total = selectedImages.length;
    
    if (selected == 0) {
      return 'No images selected';
    } else if (selected == total) {
      return '$selected image${selected > 1 ? 's' : ''} ready to upload';
    } else {
      return '$selected of $total images selected';
    }
  }

  /// Get total file size of selected images
  String getTotalFileSize(Map<String, DeferredImageResult> selectedImages) {
    int totalBytes = 0;
    int count = 0;

    for (final image in selectedImages.values) {
      if (image.isSelected && image.fileSize != null) {
        totalBytes += image.fileSize!;
        count++;
      }
    }

    if (count == 0) return 'No images selected';
    
    return _formatFileSize(totalBytes);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // UI Helper Methods
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
extension DeferredUploadHelperExtensions on DeferredUploadHelper {
  /// Quick method for exercise image upload and save
  Future<bool> uploadExerciseImageThenSave({
    required Future<bool> Function(String? imageUrl) saveExercise,
    required DeferredImageResult selectedImage,
  }) {
    return uploadSingleThenSave(
      saveOperation: saveExercise,
      selectedImage: selectedImage,
      successMessage: 'Exercise saved successfully',
      errorMessage: 'Failed to save exercise',
    );
  }

  /// Quick method for recipe image upload and save
  Future<bool> uploadRecipeImageThenSave({
    required Future<bool> Function(String? imageUrl) saveRecipe,
    required DeferredImageResult selectedImage,
  }) {
    return uploadSingleThenSave(
      saveOperation: saveRecipe,
      selectedImage: selectedImage,
      successMessage: 'Recipe saved successfully',
      errorMessage: 'Failed to save recipe',
    );
  }

  /// Quick method for ingredient image upload and save
  Future<bool> uploadIngredientImageThenSave({
    required Future<bool> Function(String? imageUrl) saveIngredient,
    required DeferredImageResult selectedImage,
  }) {
    return uploadSingleThenSave(
      saveOperation: saveIngredient,
      selectedImage: selectedImage,
      successMessage: 'Ingredient saved successfully',
      errorMessage: 'Failed to save ingredient',
    );
  }
}