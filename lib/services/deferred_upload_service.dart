import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'file_upload_service.dart';

/// Deferred Upload Service
/// Handles image selection without immediate upload
/// Only uploads when explicitly triggered (e.g., on save/submit)
class DeferredUploadService {
  static final DeferredUploadService _instance = DeferredUploadService._internal();
  factory DeferredUploadService() => _instance;
  DeferredUploadService._internal();

  final ImagePicker _imagePicker = ImagePicker();
  final FileUploadService _fileUploadService = FileUploadService();

  /// Pick image without uploading
  Future<DeferredImageResult> pickImageForLater({
    required String fileType,
    String? description,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return DeferredImageResult.cancelled();
      }

      final file = File(pickedFile.path);

      // Validate file size (max 10MB)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        return DeferredImageResult.error('File size must be less than 10MB');
      }

      // Return result with local file info (no upload yet)
      return DeferredImageResult.selected(
        localFile: file,
        fileType: fileType,
        description: description,
        fileName: pickedFile.name,
        fileSize: fileSize,
      );
    } catch (e) {
      return DeferredImageResult.error('Failed to pick image: ${e.toString()}');
    }
  }

  /// Show image picker dialog for deferred upload
  Future<DeferredImageResult> showDeferredImagePickerDialog({
    required String fileType,
    String? description,
  }) async {
    final Completer<DeferredImageResult> completer = Completer<DeferredImageResult>();

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
                  Get.back<void>();
                  final result = await pickImageForLater(
                    fileType: fileType,
                    description: description,
                    source: ImageSource.gallery,
                  );
                  completer.complete(result);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Get.back<void>();
                  final result = await pickImageForLater(
                    fileType: fileType,
                    description: description,
                    source: ImageSource.camera,
                  );
                  completer.complete(result);
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Get.back<void>();
                  completer.complete(DeferredImageResult.cancelled());
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    return completer.future;
  }

  /// Upload the selected image when ready
  Future<FileUploadResult> uploadDeferredImage(DeferredImageResult deferredResult) async {
    if (!deferredResult.isSelected || deferredResult.localFile == null) {
      return FileUploadResult.error('No image selected for upload');
    }

    return await _fileUploadService.uploadFile(
      file: deferredResult.localFile!,
      fileType: deferredResult.fileType!,
      description: deferredResult.description,
      showProgressDialog: false, // Let caller handle progress
    );
  }

  /// Upload multiple deferred images
  Future<Map<String, FileUploadResult>> uploadMultipleDeferredImages(
    Map<String, DeferredImageResult> deferredResults,
  ) async {
    final Map<String, FileUploadResult> results = {};

    for (final entry in deferredResults.entries) {
      if (entry.value.isSelected) {
        results[entry.key] = await uploadDeferredImage(entry.value);
      } else {
        results[entry.key] = FileUploadResult.cancelled();
      }
    }

    return results;
  }

  /// Get image preview widget for selected image
  Widget buildDeferredImagePreview(DeferredImageResult result, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (!result.isSelected || result.localFile == null) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey.withValues(alpha: 0.1),
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      );
    }

    return Image.file(
      result.localFile!,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.red.withValues(alpha: 0.1),
          child: const Center(
            child: Icon(Icons.error, color: Colors.red),
          ),
        );
      },
    );
  }

  /// Get file size formatted string
  String getFormattedFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Result of deferred image selection
class DeferredImageResult {
  final bool isSelected;
  final bool isCancelled;
  final bool hasError;
  final File? localFile;
  final String? fileType;
  final String? description;
  final String? fileName;
  final int? fileSize;
  final String? errorMessage;

  DeferredImageResult._({
    required this.isSelected,
    required this.isCancelled,
    required this.hasError,
    this.localFile,
    this.fileType,
    this.description,
    this.fileName,
    this.fileSize,
    this.errorMessage,
  });

  factory DeferredImageResult.selected({
    required File localFile,
    required String fileType,
    String? description,
    String? fileName,
    int? fileSize,
  }) {
    return DeferredImageResult._(
      isSelected: true,
      isCancelled: false,
      hasError: false,
      localFile: localFile,
      fileType: fileType,
      description: description,
      fileName: fileName,
      fileSize: fileSize,
    );
  }

  factory DeferredImageResult.cancelled() {
    return DeferredImageResult._(
      isSelected: false,
      isCancelled: true,
      hasError: false,
    );
  }

  factory DeferredImageResult.error(String errorMessage) {
    return DeferredImageResult._(
      isSelected: false,
      isCancelled: false,
      hasError: true,
      errorMessage: errorMessage,
    );
  }

  /// Check if image is ready for upload
  bool get isReadyForUpload => isSelected && localFile != null && localFile!.existsSync();

  /// Get display info
  String get displayInfo {
    if (hasError) return 'Error: $errorMessage';
    if (isCancelled) return 'No image selected';
    if (isSelected) {
      final sizeStr = fileSize != null 
        ? DeferredUploadService().getFormattedFileSize(fileSize!)
        : 'Unknown size';
      return '${fileName ?? 'Selected image'} ($sizeStr)';
    }
    return 'No image selected';
  }
}

/// Controller for managing deferred uploads in forms
class DeferredUploadController extends GetxController {
  final Map<String, Rx<DeferredImageResult>> _deferredImages = {};
  final RxBool isUploading = false.obs;
  final RxString uploadProgress = ''.obs;

  /// Add a deferred image slot
  void addImageSlot(String key) {
    _deferredImages[key] = DeferredImageResult.cancelled().obs;
  }

  /// Get deferred image result
  Rx<DeferredImageResult> getDeferredImage(String key) {
    if (!_deferredImages.containsKey(key)) {
      addImageSlot(key);
    }
    return _deferredImages[key]!;
  }

  /// Set deferred image result
  void setDeferredImage(String key, DeferredImageResult result) {
    if (!_deferredImages.containsKey(key)) {
      addImageSlot(key);
    }
    _deferredImages[key]!.value = result;
  }

  /// Clear specific image
  void clearImage(String key) {
    if (_deferredImages.containsKey(key)) {
      _deferredImages[key]!.value = DeferredImageResult.cancelled();
    }
  }

  /// Clear all images
  void clearAllImages() {
    for (final entry in _deferredImages.entries) {
      entry.value.value = DeferredImageResult.cancelled();
    }
  }

  /// Check if any images are selected
  bool get hasSelectedImages {
    return _deferredImages.values.any((result) => result.value.isSelected);
  }

  /// Get all selected images
  Map<String, DeferredImageResult> get selectedImages {
    final Map<String, DeferredImageResult> selected = {};
    for (final entry in _deferredImages.entries) {
      if (entry.value.value.isSelected) {
        selected[entry.key] = entry.value.value;
      }
    }
    return selected;
  }

  /// Upload all selected images and return URLs
  Future<Map<String, String?>> uploadAllImages() async {
    if (!hasSelectedImages) {
      return {};
    }

    isUploading.value = true;
    uploadProgress.value = 'Uploading images...';

    try {
      final deferredService = DeferredUploadService();
      final results = await deferredService.uploadMultipleDeferredImages(selectedImages);
      
      final Map<String, String?> urls = {};
      for (final entry in results.entries) {
        if (entry.value.isSuccess) {
          urls[entry.key] = entry.value.fileUrl;
        } else {
          urls[entry.key] = null;
          if (!entry.value.isCancelled) {
            debugPrint('Failed to upload ${entry.key}: ${entry.value.errorMessage}');
          }
        }
      }

      uploadProgress.value = 'Upload complete';
      return urls;
    } catch (e) {
      uploadProgress.value = 'Upload failed';
      debugPrint('Error uploading images: $e');
      return {};
    } finally {
      isUploading.value = false;
      // Clear progress after a delay
      Future.delayed(const Duration(seconds: 2), () {
        uploadProgress.value = '';
      });
    }
  }

  @override
  void onClose() {
    _deferredImages.clear();
    super.onClose();
  }
}