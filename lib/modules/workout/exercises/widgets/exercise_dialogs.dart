import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../exercise_controller.dart';
import '../../../../widgets/image_upload_widget.dart';

class ExerciseDialogs {
  static void showAddExerciseDialog(BuildContext context,
      ExerciseController controller) {
    controller.clearExerciseForm();
    _showExerciseFormDialog(
      context: context,
      controller: controller,
      title: 'Add New Exercise',
      actionText: 'Add Exercise',
      onSubmit: (String? imageUrl) => _handleAddExercise(context, controller, imageUrl),
    );
  }

  static void showEditExerciseDialog(BuildContext context,
      ExerciseController controller,
      dynamic exercise,) {
    controller.setupExerciseForm(exercise);
    String? initialImageUrl = exercise['imageUrl']?.toString();
    _showExerciseFormDialog(
      context: context,
      controller: controller,
      title: 'Edit Exercise',
      actionText: 'Update Exercise',
      onSubmit: (String? imageUrl) => _handleEditExercise(context, controller, exercise, imageUrl),
      initialImageUrl: initialImageUrl,
    );
  }

  static void _showExerciseFormDialog({
    required BuildContext context,
    required ExerciseController controller,
    required String title,
    required String actionText,
    required void Function(String?) onSubmit,
    String? initialImageUrl,
  }) {
    String? uploadedImageUrl = initialImageUrl;
    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: StatefulBuilder(
              builder: (context, setState) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: context.theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back<void>(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Form content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildExerciseForm(context, controller, uploadedImageUrl, (String imageUrl) {
                          setState(() {
                            uploadedImageUrl = imageUrl.isNotEmpty ? imageUrl : null;
                            // When image URL is updated, also update the controller's image URL field
                            controller.imageUrlController.text = imageUrl;
                          });
                        }),
                      ],
                    ),
                  ),
                ),

                // Action buttons
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back<void>(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => onSubmit(uploadedImageUrl),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(actionText),
                      ),
                    ),
                  ],
                ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static Widget _buildExerciseForm(BuildContext context,
      ExerciseController controller, String? uploadedImageUrl, void Function(String) onImageUploaded) {
    return Column(
      children: [
        // Exercise name
        Obx(() =>
            _buildTextField(
              controller: controller.nameController,
              label: 'Exercise Name',
              hint: 'Enter exercise name',
              errorText: controller.nameError.value,
              onChanged: (value) => controller.validateName(value),
            )),
        const SizedBox(height: 16),

        // Description
        Obx(() =>
            _buildTextField(
              controller: controller.descriptionController,
              label: 'Description',
              hint: 'Enter exercise description',
              maxLines: 3,
              errorText: controller.descriptionError.value,
              onChanged: (value) => controller.validateDescription(value),
            )),
        const SizedBox(height: 16),

        // Muscle group and Equipment (row)
        Row(
          children: [
            Expanded(
              child: Obx(() =>
                  _buildTextField(
                    controller: controller.muscleGroupController,
                    label: 'Muscle Group',
                    hint: 'e.g., Chest, Back, Legs',
                    errorText: controller.muscleGroupError.value,
                    onChanged: (value) => controller.validateMuscleGroup(value),
                  )),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() =>
                  _buildTextField(
                    controller: controller.equipmentController,
                    label: 'Equipment',
                    hint: 'e.g., Bodyweight, Dumbbell',
                    errorText: controller.equipmentError.value,
                    onChanged: (value) => controller.validateEquipment(value),
                  )),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Difficulty
        Obx(() =>
            _buildTextField(
              controller: controller.difficultyController,
              label: 'Difficulty (1-5)',
              hint: 'Enter difficulty level',
              keyboardType: TextInputType.number,
              errorText: controller.difficultyError.value,
              onChanged: (value) => controller.validateDifficulty(value),
            )),
        const SizedBox(height: 16),

        // Image upload
        ImageUploadWidget(
          fileType: 'ExerciseImage',
          description: 'Exercise image for ${controller.nameController.text.isNotEmpty ? controller.nameController.text : 'new exercise'}',
          currentImageUrl: uploadedImageUrl,
          onUploadStart: () {
            controller.isImageUploading.value = true;
          },
          onImageUploaded: (String imageUrl) {
            uploadedImageUrl = imageUrl.isNotEmpty ? imageUrl : null;
            // When image URL is updated, also update the controller's image URL field
            controller.imageUrlController.text = imageUrl;
            controller.isImageUploading.value = false;
          },
          onError: (String error) {
            Get.snackbar('Upload Error', error);
            controller.isImageUploading.value = false;
          },
          label: 'Exercise Image',
          hintText: 'Upload a photo of the exercise (JPG, PNG up to 10MB)',
          height: 200,
        ),
        const SizedBox(height: 16),

        // Video URL
        _buildTextField(
          controller: controller.videoUrlController,
          label: 'Video URL (Optional)',
          hint: 'Enter video URL',
        ),
        const SizedBox(height: 16),

        // Instructions
        Obx(() =>
            _buildTextField(
              controller: controller.instructionsController,
              label: 'Instructions',
              hint: 'Enter step-by-step instructions (one per line)',
              maxLines: 5,
              errorText: controller.instructionsError.value,
              onChanged: (value) => controller.validateInstructions(value),
            )),
      ],
    );
  }

  static Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? errorText,
    int maxLines = 1,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Get.context!.theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText?.isNotEmpty == true ? errorText : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Get.context!.theme.colorScheme.outline.withAlpha(
                    76),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Get.context!.theme.colorScheme.outline.withAlpha(
                    76),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Get.context!.theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Get.context!.theme.colorScheme.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  static Future<void> _handleAddExercise(BuildContext context,
      ExerciseController controller, String? uploadedImageUrl) async {
    if (!controller.validateExerciseForm()) {
      return;
    }

    // Always make sure the imageUrl is taken from the most recent controller field unless an uploaded URL is explicitly given
    String? imageUrlToUse = uploadedImageUrl ??
        controller.imageUrlController.text;
    if (imageUrlToUse != null && imageUrlToUse.isEmpty) {
      imageUrlToUse = null;
    }

    try {
      // Wait for any ongoing image upload to complete
      if (controller.isImageUploading.value) {
        // Show a loading indicator
        Get.snackbar(
          'Please wait',
          'Waiting for image upload to complete...',
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
        );

        // Wait for upload to complete
        final uploadCompleted = await controller.waitForImageUpload();
        if (!uploadCompleted) {
          _showErrorSnackbar('Image upload timed out. Please try again.');
          return;
        }

        // Refresh the image URL after upload completes
        imageUrlToUse = controller.imageUrlController.text;
        if (imageUrlToUse.isEmpty) {
          imageUrlToUse = null;
        }
      }

      final data = controller.createExerciseData(
          uploadedImageUrl: imageUrlToUse);

      print('Attempting to create exercise with data: ${data.toString()}');
      print('Image URL being used: ${data['imageUrl']}');

      final success = await controller.createExercise(data);

      if (success) {
        // Only close the dialog if creation succeeded
        Get.back<void>();
        Get.snackbar(
          'Success',
          'Exercise added successfully',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          icon: const Icon(Icons.check_circle, color: Colors.green),
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } else {
        // Do not close dialog on failure
        _showErrorSnackbar(
          'Failed to add exercise. Please check your network connection and try again.',
        );
      }
    } catch (e) {
      print('Error adding exercise: $e');
      String errorMessage = 'An error occurred while adding exercise';

      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Network is unreachable')) {
        errorMessage =
        'Network error. Please check your internet connection and try again.';
      } else if (e.toString().contains('500')) {
        errorMessage =
        'Server error. Please try again later or contact support.';
      } else if (e.toString().contains('400') || e.toString().contains('422')) {
        errorMessage =
        'Invalid data. Please check your form input and try again.';
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        errorMessage =
        'You don\'t have permission to add exercises. Please log in again.';
      }

      _showErrorSnackbar(errorMessage);
    }
  }

  static Future<void> _handleEditExercise(BuildContext context,
      ExerciseController controller,
      dynamic exercise, String? uploadedImageUrl) async {
    if (!controller.validateExerciseForm()) {
      return;
    }

    try {
      // Always make sure the imageUrl is taken from the most recent controller field unless an uploaded URL is explicitly given
      String? imageUrlToUse = uploadedImageUrl ??
          controller.imageUrlController.text;
      if (imageUrlToUse != null && imageUrlToUse.isEmpty) {
        imageUrlToUse = null;
      }

      // Wait for any ongoing image upload to complete
      if (controller.isImageUploading.value) {
        // Show a loading indicator
        Get.snackbar(
          'Please wait',
          'Waiting for image upload to complete...',
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
        );

        // Wait for upload to complete
        final uploadCompleted = await controller.waitForImageUpload();
        if (!uploadCompleted) {
          _showErrorSnackbar('Image upload timed out. Please try again.');
          return;
        }

        // Refresh the image URL after upload completes
        imageUrlToUse = controller.imageUrlController.text;
        if (imageUrlToUse.isEmpty) {
          imageUrlToUse = null;
        }
      }

      final data = controller.createExerciseData(
          uploadedImageUrl: imageUrlToUse);
      final exerciseId = exercise['exerciseId']?.toString() ??
          exercise['id']?.toString();

      if (exerciseId == null) {
        _showErrorSnackbar('Exercise ID not found');
        return;
      }

      // For debugging purposes, print the data being sent
      print('Attempting to update exercise with ID: $exerciseId');
      print('Update data: ${data.toString()}');
      print('Image URL being used: ${data['imageUrl']}');

      final success = await controller.updateExercise(exerciseId, data);

      if (success) {
        Get.back<void>();
        Get.snackbar(
          'Success',
          'Exercise updated successfully',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          icon: const Icon(Icons.check_circle, color: Colors.green),
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } else {
        _showErrorSnackbar('Failed to update exercise');
      }
    } catch (e) {
      print('Error updating exercise: $e');
      _showErrorSnackbar('An error occurred while updating exercise');
    }
  }

  static void showDeleteConfirmation(BuildContext context,
      dynamic exercise,
      ExerciseController controller,) {
    Get.dialog<void>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Exercise'),
        content: Text(
          'Are you sure you want to delete "${exercise['name'] ??
              'this exercise'}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => _handleDeleteExercise(exercise, controller),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  static void showDeleteAllConfirmation(BuildContext context,
      ExerciseController controller) {
    Get.dialog<void>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete All Exercises'),
        content: const Text(
          'Are you sure you want to delete all exercises? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => _handleDeleteAllExercises(controller),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  static Future<void> _handleDeleteExercise(dynamic exercise,
      ExerciseController controller) async {
    Get.back<void>(); // Close confirmation dialog

    try {
      final exerciseId = exercise['exerciseId']?.toString() ??
          exercise['id']?.toString();

      if (exerciseId == null) {
        _showErrorSnackbar('Exercise ID not found');
        return;
      }

      final success = await controller.deleteExercise(exerciseId);

      if (success) {
        Get.snackbar(
          'Success',
          'Exercise deleted successfully',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          icon: const Icon(Icons.check_circle, color: Colors.green),
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } else {
        _showErrorSnackbar('Failed to delete exercise');
      }
    } catch (e) {
      _showErrorSnackbar('An error occurred while deleting exercise');
    }
  }

  static Future<void> _handleDeleteAllExercises(
      ExerciseController controller) async {
    Get.back<void>(); // Close confirmation dialog

    try {
      // Delete all exercises one by one
      bool allDeleted = true;
      for (final exercise in controller.exercises.toList()) {
        final exerciseId = exercise['exerciseId']?.toString() ??
            exercise['id']?.toString();
        if (exerciseId != null) {
          final success = await controller.deleteExercise(exerciseId);
          if (!success) {
            allDeleted = false;
            break;
          }
        }
      }

      if (allDeleted) {
        Get.snackbar(
          'Success',
          'All exercises deleted successfully',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          icon: const Icon(Icons.check_circle, color: Colors.green),
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } else {
        _showErrorSnackbar('Failed to delete some exercises');
      }
    } catch (e) {
      _showErrorSnackbar('An error occurred while deleting exercises');
    }
  }

  static void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red,
      icon: const Icon(Icons.error, color: Colors.red),
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}