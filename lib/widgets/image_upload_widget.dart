import 'package:flutter/material.dart';
import '../services/file_upload_service.dart';

/// Reusable Image Upload Widget
/// Provides a Material Design interface for image uploads
class ImageUploadWidget extends StatefulWidget {
  final String fileType;
  final String? description;
  final String? currentImageUrl;
  final void Function(String)? onImageUploaded;
  final void Function(String)? onError;
  final void Function()? onUploadStart;
  final String? label;
  final String? hintText;
  final double? width;
  final double? height;
  final bool showRemoveButton;
  final bool isRequired;
  final BorderRadius? borderRadius;

  const ImageUploadWidget({
    super.key,
    required this.fileType,
    this.description,
    this.currentImageUrl,
    this.onImageUploaded,
    this.onError,
    this.onUploadStart,
    this.label,
    this.hintText,
    this.width,
    this.height,
    this.showRemoveButton = true,
    this.isRequired = false,
    this.borderRadius,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  String? _uploadedImageUrl;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _uploadedImageUrl = widget.currentImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Upload area
        _buildUploadArea(context),

        // Error message
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],

        // Hint text
        if (widget.hintText != null && _errorMessage == null) ...[
          const SizedBox(height: 8),
          Text(
            widget.hintText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUploadArea(BuildContext context) {
    final hasImage = _uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty;
    
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 200,
      decoration: BoxDecoration(
        border: Border.all(
          color: hasImage 
            ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)
            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          width: 2,
        ),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        color: hasImage 
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: hasImage 
        ? _buildImagePreview(context)
        : _buildUploadPrompt(context),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return Stack(
      children: [
        // Image
        ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(10),
          child: Image.network(
            _uploadedImageUrl!,
            width: double.infinity,
            height: double.infinity,
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
              return _buildErrorState(context);
            },
          ),
        ),

        // Overlay with actions
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.3),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Upload button
                Positioned(
                  top: 8,
                  right: 8,
                  child: _buildUploadButton(context, isOverlay: true),
                ),

                // Remove button
                if (widget.showRemoveButton)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: _buildRemoveButton(context),
                  ),
              ],
            ),
          ),
        ),

        // Uploading indicator
        if (_isUploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(10),
                color: Colors.black.withValues(alpha: 0.5),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      'Uploading...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUploadPrompt(BuildContext context) {
    return InkWell(
      onTap: _isUploading ? null : _showImagePicker,
      borderRadius: widget.borderRadius ?? BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Tap to upload image',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'JPG, PNG up to 10MB',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(
            'Failed to load image',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          _buildUploadButton(context),
        ],
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context, {bool isOverlay = false}) {
    return Material(
      color: isOverlay 
        ? Colors.white.withValues(alpha: 0.9)
        : Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: _isUploading ? null : _showImagePicker,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.camera_alt,
                size: 16,
                color: isOverlay 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(width: 4),
              Text(
                'Change',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isOverlay 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRemoveButton(BuildContext context) {
    return Material(
      color: Colors.red.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: _removeImage,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.delete_outline,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              const Text(
                'Remove',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showImagePicker() async {
    widget.onUploadStart?.call();
    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      final result = await FileUploadService().showImagePickerDialog(
        fileType: widget.fileType,
        description: widget.description,
        showProgressDialog: false,
      );

      if (result.isSuccess && result.fileUrl != null) {
        setState(() {
          _uploadedImageUrl = result.fileUrl;
          _isUploading = false;
        });
        widget.onImageUploaded?.call(result.fileUrl!);
      } else if (result.isCancelled) {
        setState(() {
          _isUploading = false;
        });
      } else {
        setState(() {
          _isUploading = false;
          _errorMessage = result.errorMessage ?? 'Upload failed';
        });
        widget.onError?.call(_errorMessage!);
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _errorMessage = 'Upload failed: ${e.toString()}';
      });
      widget.onError?.call(_errorMessage!);
    }
  }

  void _removeImage() {
    setState(() {
      _uploadedImageUrl = null;
      _errorMessage = null;
    });
    widget.onImageUploaded?.call('');
  }

  /// Get the current uploaded image URL
  String? get uploadedImageUrl => _uploadedImageUrl;

  /// Check if an image is uploaded
  bool get hasImage => _uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty;

  /// Check if currently uploading
  bool get isUploading => _isUploading;
}

/// Compact image upload widget for smaller spaces
class CompactImageUploadWidget extends StatelessWidget {
  final String fileType;
  final String? description;
  final String? currentImageUrl;
  final void Function(String)? onImageUploaded;
  final void Function(String)? onError;
  final void Function()? onUploadStart;
  final double size;
  final bool showRemoveButton;

  const CompactImageUploadWidget({
    super.key,
    required this.fileType,
    this.description,
    this.currentImageUrl,
    this.onImageUploaded,
    this.onError,
    this.onUploadStart,
    this.size = 80,
    this.showRemoveButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return ImageUploadWidget(
      fileType: fileType,
      description: description,
      currentImageUrl: currentImageUrl,
      onImageUploaded: onImageUploaded,
      onError: onError,
      onUploadStart: onUploadStart,
      width: size,
      height: size,
      showRemoveButton: showRemoveButton,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }
}
