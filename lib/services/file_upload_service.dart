import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../network_service/api_client.dart';
import '../widgets/custom_displays.dart';

/// File Upload Service
/// Handles file uploads with progress tracking and error handling
class FileUploadService {
  static final FileUploadService _instance = FileUploadService._internal();
  factory FileUploadService() => _instance;
  FileUploadService._internal();

  final ImagePicker _imagePicker = ImagePicker();
  final ApiClient _apiClient = ApiHelper.getApiClient();

  /// File types for different use cases
  static const String recipeImage = 'RecipeImage';
  static const String profilePicture = 'ProfilePicture';
  static const String workoutImage = 'WorkoutImage';
  static const String exerciseImage = 'ExerciseImage';
  static const String driverImage = 'DriverImage';
  static const String ingredientImage = 'IngredientImage';

  /// Upload a file with progress tracking
  Future<FileUploadResult> uploadFile({
    required File file,
    required String fileType,
    String? description,
    void Function(double)? onProgress,
    bool showProgressDialog = true,
  }) async {
    try {
      // Show progress dialog if requested
      if (showProgressDialog) {
        _showProgressDialog();
      }

      // For debugging
      print('Attempting to upload file: ${file.path}');
      print('File type: $fileType');
      print('Description: $description');
      print('File exists: ${await file.exists()}');
      print('File size: ${await file.length()} bytes');

      // Make the upload request with progress tracking
      final response = await _apiClient.uploadFile(
        file,
        fileType,
        description,
      );

      // Hide progress dialog
      if (showProgressDialog) {
        Get.back<void>();
      }

      // Parse response
      print('Upload response: ${response.data}');

      if (response.data != null && response.data['success'] == true) {
        final fileUrl = response.data['data']['fileUrl'] as String?;
        if (fileUrl != null) {
          print('File uploaded successfully: $fileUrl');
          return FileUploadResult.success(fileUrl);
        }
      }

      print('Upload failed: Invalid response format');
      return FileUploadResult.error('Upload failed: Invalid response');
    } catch (e) {
      // Hide progress dialog on error
      if (showProgressDialog) {
        Get.back<void>();
      }

      String errorMessage = 'Upload failed';
      if (e is dio.DioException) {
        switch (e.type) {
          case dio.DioExceptionType.connectionTimeout:
          case dio.DioExceptionType.receiveTimeout:
          case dio.DioExceptionType.sendTimeout:
            errorMessage = 'Upload timeout. Please check your connection.';
            break;
          case dio.DioExceptionType.connectionError:
            errorMessage = 'No internet connection. Please try again.';
            break;
          case dio.DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 413) {
              errorMessage = 'File too large. Please choose a smaller file.';
            } else if (statusCode == 415) {
              errorMessage = 'Unsupported file type. Please choose a valid image.';
            } else {
              errorMessage = 'Upload failed. Please try again.';
            }
            break;
          default:
            errorMessage = 'Upload failed. Please try again.';
        }
      }

      return FileUploadResult.error(errorMessage);
    }
  }

  /// Pick and upload an image
  Future<FileUploadResult> pickAndUploadImage({
    required String fileType,
    String? description,
    ImageSource source = ImageSource.gallery,
    void Function(double)? onProgress,
    bool showProgressDialog = true,
  }) async {
    try {
      // Pick image
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return FileUploadResult.cancelled();
      }

      final file = File(pickedFile.path);

      // Validate file size (max 10MB)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        return FileUploadResult.error('File size must be less than 10MB');
      }

      // Upload the file
      return await uploadFile(
        file: file,
        fileType: fileType,
        description: description,
        onProgress: onProgress,
        showProgressDialog: showProgressDialog,
      );
    } catch (e) {
      return FileUploadResult.error('Failed to pick image: ${e.toString()}');
    }
  }

  /// Show image picker dialog
  Future<FileUploadResult> showImagePickerDialog({
    required String fileType,
    String? description,
    void Function(double)? onProgress,
    bool showProgressDialog = true,
    Widget Function(String imageUrl)? onImageUploaded,
  }) async {
    // We'll use a completer to handle the result without closing the parent dialog
    final Completer<FileUploadResult> completer = Completer<FileUploadResult>();

    // Show only the image source selection dialog
    await Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select Image Source', style: Get.textTheme.titleLarge),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Get.back<void>(); // Close only this dialog

                  // Show progress dialog if requested
                  if (showProgressDialog) {
                    _showProgressDialog();
                  }

                  // Pick and upload from gallery
                  final result = await pickAndUploadImage(
                    fileType: fileType,
                    description: description,
                    source: ImageSource.gallery,
                    onProgress: onProgress,
                    showProgressDialog: false, // We're already showing it
                  );

                  // Hide progress dialog
                  if (showProgressDialog && Get.isDialogOpen!) {
                    Get.back<void>();
                  }

                  // If upload was successful and callback is provided, show the image
                  if (result.isSuccess && result.fileUrl != null &&
                      onImageUploaded != null) {
                    showSuccessMessage('Image uploaded successfully');
                    onImageUploaded(result.fileUrl!);
                  } else if (result.isSuccess && result.fileUrl != null) {
                    showSuccessMessage('Image uploaded successfully');
                  } else
                  if (!result.isCancelled && result.errorMessage != null) {
                    showErrorMessage(result.errorMessage!);
                  }

                  // Complete with result but don't close parent dialog
                  completer.complete(result);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Get.back<void>(); // Close only this dialog

                  // Show progress dialog if requested
                  if (showProgressDialog) {
                    _showProgressDialog();
                  }

                  // Pick and upload from camera
                  final result = await pickAndUploadImage(
                    fileType: fileType,
                    description: description,
                    source: ImageSource.camera,
                    onProgress: onProgress,
                    showProgressDialog: false, // We're already showing it
                  );

                  // Hide progress dialog
                  if (showProgressDialog && Get.isDialogOpen!) {
                    Get.back<void>();
                  }

                  // If upload was successful and callback is provided, show the image
                  if (result.isSuccess && result.fileUrl != null &&
                      onImageUploaded != null) {
                    showSuccessMessage('Image uploaded successfully');
                    onImageUploaded(result.fileUrl!);
                  } else if (result.isSuccess && result.fileUrl != null) {
                    showSuccessMessage('Image uploaded successfully');
                  } else
                  if (!result.isCancelled && result.errorMessage != null) {
                    showErrorMessage(result.errorMessage!);
                  }

                  // Complete with result but don't close parent dialog
                  completer.complete(result);
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Get.back<void>(); // Close only this dialog
                  completer.complete(FileUploadResult.cancelled());
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Return the result without closing the parent dialog
    return completer.future;
  }

  /// Show progress dialog
  void _showProgressDialog() {
    Get.dialog<void>(
      const UploadProgressDialog(),
      barrierDismissible: false,
    );
  }

  /// Show success message
  void showSuccessMessage(String message) {
    CustomDisplays.showToast(
      message: message,
      type: MessageType.success,
    );
  }

  /// Show error message
  void showErrorMessage(String message) {
    CustomDisplays.showToast(
      message: message,
      type: MessageType.error,
    );
  }

  /// Show uploaded image in a widget
  Widget buildImageWidget(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 64,
          color: Colors.grey,
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(
            Icons.broken_image,
            size: 64,
            color: Colors.red,
          ),
        );
      },
    );
  }
}

/// File upload result
class FileUploadResult {
  final bool isSuccess;
  final bool isCancelled;
  final String? fileUrl;
  final String? errorMessage;

  FileUploadResult._({
    required this.isSuccess,
    required this.isCancelled,
    this.fileUrl,
    this.errorMessage,
  });

  factory FileUploadResult.success(String fileUrl) {
    return FileUploadResult._(
      isSuccess: true,
      isCancelled: false,
      fileUrl: fileUrl,
    );
  }

  factory FileUploadResult.error(String errorMessage) {
    return FileUploadResult._(
      isSuccess: false,
      isCancelled: false,
      errorMessage: errorMessage,
    );
  }

  factory FileUploadResult.cancelled() {
    return FileUploadResult._(
      isSuccess: false,
      isCancelled: true,
    );
  }
}

/* Usage Example:

class MyImageUploadWidget extends StatefulWidget {
  const MyImageUploadWidget({super.key});

  @override
  State<MyImageUploadWidget> createState() => _MyImageUploadWidgetState();
}

class _MyImageUploadWidgetState extends State<MyImageUploadWidget> {
  String? _imageUrl;
  final FileUploadService _uploadService = FileUploadService();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display the image if available
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _imageUrl != null 
              ? _uploadService.buildImageWidget(_imageUrl)
              : const Center(child: Text('No image selected')),
        ),
        
        const SizedBox(height: 16),
        
        // Upload button
        ElevatedButton(
          onPressed: () async {
            // Show image picker and upload dialog
            await _uploadService.showImagePickerDialog(
              fileType: FileUploadService.profilePicture,
              onImageUploaded: (imageUrl) {
                // Update state with the new image URL
                setState(() {
                  _imageUrl = imageUrl;
                });
              },
            );
          },
          child: const Text('Upload Image'),
        ),
      ],
    );
  }
}
*/

/// Upload progress dialog
class UploadProgressDialog extends StatelessWidget {
  const UploadProgressDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Uploading...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while your file is being uploaded',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
