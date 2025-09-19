import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/image_upload_helper.dart';
import '../widgets/image_upload_widget.dart';

/// Example demonstrating how to properly use image upload with save operations
class ImageUploadExample extends StatefulWidget {
  const ImageUploadExample({super.key});

  @override
  State<ImageUploadExample> createState() => _ImageUploadExampleState();
}

class _ImageUploadExampleState extends State<ImageUploadExample> {
  final ImageUploadHelper _uploadHelper = ImageUploadHelper();
  
  // Form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  // Image upload state
  final RxString uploadedImageUrl = ''.obs;
  final RxBool isImageUploading = false.obs;
  final RxBool isSaving = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Upload Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form fields
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // Image upload widget
            ImageUploadWidget(
              fileType: 'ExampleImage',
              description: 'Example image upload',
              currentImageUrl: uploadedImageUrl.value.isEmpty ? null : uploadedImageUrl.value,
              onUploadStart: () => isImageUploading.value = true,
              onImageUploaded: (String imageUrl) {
                uploadedImageUrl.value = imageUrl;
                isImageUploading.value = false;
              },
              onError: (String error) {
                isImageUploading.value = false;
                Get.snackbar('Upload Error', error);
              },
              label: 'Upload Image',
              hintText: 'Upload an image (JPG, PNG up to 10MB)',
              height: 200,
            ),
            
            const SizedBox(height: 24),
            
            // Save button using ImageUploadHelper
            Obx(() => _uploadHelper.buildUploadThenSaveButton(
              buttonText: 'Save Item',
              onSave: _saveItem,
              currentImageUrl: uploadedImageUrl.value.isEmpty ? null : uploadedImageUrl.value,
              isUploadingStatus: isImageUploading,
              isEnabled: !isSaving.value,
              successMessage: 'Item saved successfully!',
              errorMessage: 'Failed to save item. Please try again.',
            )),
            
            const SizedBox(height: 16),
            
            // Alternative: Manual save with upload helper
            Obx(() => FilledButton(
              onPressed: (isSaving.value || isImageUploading.value) ? null : _manualSave,
              child: isSaving.value
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Saving...'),
                    ],
                  )
                : const Text('Manual Save'),
            )),
            
            const Spacer(),
            
            // Status display
            Obx(() => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status:', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Image Uploading: ${isImageUploading.value}'),
                    Text('Saving: ${isSaving.value}'),
                    Text('Image URL: ${uploadedImageUrl.value.isEmpty ? 'None' : uploadedImageUrl.value}'),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  /// Save method that will be called after image upload completes
  Future<bool> _saveItem(String? imageUrl) async {
    isSaving.value = true;
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Validate form
      if (nameController.text.isEmpty) {
        Get.snackbar('Validation Error', 'Name is required');
        return false;
      }
      
      // Create data object
      final data = {
        'name': nameController.text,
        'description': descriptionController.text,
        'imageUrl': imageUrl,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // Log the data (in real app, this would be sent to API)
      debugPrint('Saving item with data: $data');
      
      // Simulate success/failure (90% success rate)
      if (DateTime.now().millisecond % 10 == 0) {
        return false; // 10% failure rate for demonstration
      }
      
      return true;
    } catch (e) {
      debugPrint('Error saving item: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Manual save using the upload helper directly
  Future<void> _manualSave() async {
    final success = await _uploadHelper.uploadThenSave(
      saveOperation: _saveItem,
      currentImageUrl: uploadedImageUrl.value.isEmpty ? null : uploadedImageUrl.value,
      isUploadingStatus: isImageUploading,
      successMessage: 'Item saved with manual method!',
      errorMessage: 'Manual save failed. Please try again.',
    );
    
    if (success) {
      // Clear form on success
      nameController.clear();
      descriptionController.clear();
      uploadedImageUrl.value = '';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}

/// Example with multiple images
class MultiImageUploadExample extends StatefulWidget {
  const MultiImageUploadExample({super.key});

  @override
  State<MultiImageUploadExample> createState() => _MultiImageUploadExampleState();
}

class _MultiImageUploadExampleState extends State<MultiImageUploadExample> {
  final ImageUploadHelper _uploadHelper = ImageUploadHelper();
  
  // Multiple image upload state
  final Map<String, RxString> imageUrls = {
    'mainImage': ''.obs,
    'thumbnailImage': ''.obs,
    'galleryImage': ''.obs,
  };
  
  final Map<String, RxBool> uploadStatuses = {
    'mainImage': false.obs,
    'thumbnailImage': false.obs,
    'galleryImage': false.obs,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Image Upload Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Multiple image upload widgets
            ...imageUrls.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ImageUploadWidget(
                fileType: 'Example${entry.key}',
                description: 'Upload ${entry.key}',
                currentImageUrl: entry.value.value.isEmpty ? null : entry.value.value,
                onUploadStart: () => uploadStatuses[entry.key]!.value = true,
                onImageUploaded: (String imageUrl) {
                  entry.value.value = imageUrl;
                  uploadStatuses[entry.key]!.value = false;
                },
                onError: (String error) {
                  uploadStatuses[entry.key]!.value = false;
                  Get.snackbar('Upload Error', error);
                },
                label: entry.key.replaceAllMapped(
                  RegExp(r'([A-Z])'),
                  (match) => ' ${match.group(0)}',
                ).trim(),
                height: 150,
              ),
            )).toList(),
            
            const SizedBox(height: 24),
            
            // Save all button
            FilledButton(
              onPressed: _saveAllImages,
              child: const Text('Save All Images'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAllImages() async {
    // Convert RxString to String? for the helper method
    final imageUrlMap = imageUrls.map(
      (key, value) => MapEntry(key, value.value.isEmpty ? null : value.value),
    );
    
    final success = await _uploadHelper.uploadMultipleThenSave(
      saveOperation: (Map<String, String?> urls) async {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));
        debugPrint('Saving multiple images: $urls');
        return true;
      },
      currentImageUrls: imageUrlMap,
      uploadStatuses: uploadStatuses,
      successMessage: 'All images saved successfully!',
      errorMessage: 'Failed to save images. Please try again.',
    );
    
    if (success) {
      // Clear all images on success
      for (final entry in imageUrls.entries) {
        entry.value.value = '';
      }
    }
  }
}