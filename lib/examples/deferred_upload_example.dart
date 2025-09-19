import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/deferred_upload_service.dart';
import '../services/deferred_upload_helper.dart';
import '../widgets/deferred_image_upload_widget.dart';

/// Example demonstrating the new deferred upload system
/// Images are selected but NOT uploaded until Save is clicked
class DeferredUploadExample extends StatefulWidget {
  const DeferredUploadExample({super.key});

  @override
  State<DeferredUploadExample> createState() => _DeferredUploadExampleState();
}

class _DeferredUploadExampleState extends State<DeferredUploadExample> {
  final DeferredUploadHelper _uploadHelper = DeferredUploadHelper();
  
  // Form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  // Deferred image state
  DeferredImageResult selectedImage = DeferredImageResult.cancelled();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deferred Upload Example'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deferred Upload System',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Images are selected but NOT uploaded until you click Save. This prevents unwanted data in the backend.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Form fields
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                hintText: 'Enter item name',
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
            
            // Deferred image upload widget
            DeferredImageUploadWidget(
              fileType: 'ExampleImage',
              description: 'Example deferred image upload',
              initialImage: selectedImage,
              onImageSelected: (DeferredImageResult imageResult) {
                setState(() {
                  selectedImage = imageResult;
                });
              },
              onError: (String error) {
                Get.snackbar('Selection Error', error);
              },
              label: 'Select Image',
              hintText: 'Select an image (will upload on save)',
              height: 200,
              isRequired: true,
            ),
            
            const SizedBox(height: 24),
            
            // Upload status
            _buildUploadStatus(),
            
            const SizedBox(height: 24),
            
            // Save button using DeferredUploadHelper
            _uploadHelper.buildSingleImageSaveButton(
              buttonText: 'Save Item (Upload Then Save)',
              onSave: _saveItem,
              selectedImage: selectedImage,
              isEnabled: _canSave(),
              successMessage: 'Item saved successfully!',
              errorMessage: 'Failed to save item. Please try again.',
            ),
            
            const Spacer(),
            
            // Flow explanation
            _buildFlowExplanation(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(
                  selectedImage.isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selectedImage.isSelected ? Colors.green : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Image Selected: ${selectedImage.isSelected ? "Yes" : "No"}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            
            if (selectedImage.isSelected) ...[
              const SizedBox(height: 8),
              Text(
                'File: ${selectedImage.displayInfo}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.cloud_upload,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Upload Status: Pending (will upload on save)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowExplanation() {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How This Works',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            ..._buildFlowSteps(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFlowSteps() {
    final steps = [
      'User selects image from gallery/camera',
      'Image is stored locally (NOT uploaded yet)',
      'User fills out the form',
      'User clicks "Save"',
      'System uploads image to api/FileUpload/upload',
      'System gets file URL from upload response',
      'System saves form data with file URL via PUT/POST',
    ];

    return steps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;
      final isCompleted = index < 3; // First 3 steps completed
      final isCurrent = index == 3 && selectedImage.isSelected; // Step 4 is current
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted 
                  ? Colors.green 
                  : isCurrent 
                    ? Colors.blue 
                    : Colors.grey.withValues(alpha: 0.3),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: (isCompleted || isCurrent) ? Colors.white : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                step,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isCompleted 
                    ? Colors.green.shade700
                    : isCurrent 
                      ? Colors.blue.shade700
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: (isCompleted || isCurrent) ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  bool _canSave() {
    return nameController.text.isNotEmpty && 
           descriptionController.text.isNotEmpty && 
           selectedImage.isSelected;
  }

  /// This method simulates saving to an API
  /// In real usage, this would be your actual save operation
  Future<bool> _saveItem(String? imageUrl) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Validate form (already checked in _canSave, but good practice)
      if (nameController.text.isEmpty) {
        Get.snackbar('Validation Error', 'Name is required');
        return false;
      }
      
      // Create data object that would be sent to your API
      final data = {
        'name': nameController.text,
        'description': descriptionController.text,
        'imageUrl': imageUrl, // This is the uploaded file URL from api/FileUpload/upload
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // Log what would be sent to API
      debugPrint('=== SAVING TO API ===');
      debugPrint('Endpoint: POST /api/items');
      debugPrint('Data: $data');
      debugPrint('Image URL: $imageUrl');
      debugPrint('====================');
      
      // Simulate API success/failure (95% success rate)
      final random = DateTime.now().millisecond;
      if (random % 20 == 0) {
        // 5% failure rate for demonstration
        return false;
      }
      
      // Success - clear form
      nameController.clear();
      descriptionController.clear();
      setState(() {
        selectedImage = DeferredImageResult.cancelled();
      });
      
      return true;
    } catch (e) {
      debugPrint('Error saving item: $e');
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}

/// Comparison example showing the old vs new approach
class UploadComparisonExample extends StatelessWidget {
  const UploadComparisonExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Approaches Comparison'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Old approach
            Card(
              color: Colors.red.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.close, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          'OLD APPROACH (Problematic)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1. User selects image\n'
                      '2. Image uploads IMMEDIATELY to api/FileUpload/upload\n'
                      '3. User fills form\n'
                      '4. User clicks Save\n'
                      '5. Form saves with uploaded URL\n\n'
                      '❌ Problem: If user cancels or closes dialog, image is already uploaded (wasted storage)\n'
                      '❌ Problem: Creates orphaned files in backend\n'
                      '❌ Problem: Unnecessary bandwidth usage',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // New approach
            Card(
              color: Colors.green.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'NEW APPROACH (Robust)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1. User selects image\n'
                      '2. Image stored LOCALLY (not uploaded yet)\n'
                      '3. User fills form\n'
                      '4. User clicks Save\n'
                      '5. Image uploads to api/FileUpload/upload\n'
                      '6. Form saves with uploaded URL\n\n'
                      '✅ Benefit: No upload if user cancels\n'
                      '✅ Benefit: No orphaned files\n'
                      '✅ Benefit: Better user experience\n'
                      '✅ Benefit: Only uploads when actually needed',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            FilledButton(
              onPressed: () => Get.to(() => const DeferredUploadExample()),
              child: const Text('Try New Deferred Upload System'),
            ),
          ],
        ),
      ),
    );
  }
}