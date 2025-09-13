import 'dart:io';
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
      if (response.data != null && response.data['success'] == true) {
        final fileUrl = response.data['data']['fileUrl'] as String?;
        if (fileUrl != null) {
          return FileUploadResult.success(fileUrl);
        }
      }

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
  }) async {
    return await Get.dialog<FileUploadResult>(
      ImagePickerDialog(
        fileType: fileType,
        description: description,
        onProgress: onProgress,
        showProgressDialog: showProgressDialog,
      ),
      barrierDismissible: false,
    ) ?? FileUploadResult.cancelled();
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

/// Image picker dialog
class ImagePickerDialog extends StatelessWidget {
  final String fileType;
  final String? description;
  final void Function(double)? onProgress;
  final bool showProgressDialog;

  const ImagePickerDialog({
    super.key,
    required this.fileType,
    this.description,
    this.onProgress,
    this.showProgressDialog = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Image Source'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () => _pickAndUpload(context, ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () => _pickAndUpload(context, ImageSource.camera),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: FileUploadResult.cancelled()),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Future<void> _pickAndUpload(BuildContext context, ImageSource source) async {
    Get.back<void>(); // Close the picker dialog
    
    final result = await FileUploadService().pickAndUploadImage(
      fileType: fileType,
      description: description,
      source: source,
      onProgress: onProgress,
      showProgressDialog: showProgressDialog,
    );
    
    Get.back(result: result);
  }
}

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
