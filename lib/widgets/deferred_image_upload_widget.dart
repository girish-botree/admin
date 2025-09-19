import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/deferred_upload_service.dart';

/// Deferred Image Upload Widget
/// Allows image selection without immediate upload
/// Upload happens only when explicitly triggered (e.g., on save/submit)
class DeferredImageUploadWidget extends StatefulWidget {
  final String fileType;
  final String? description;
  final void Function(DeferredImageResult)? onImageSelected;
  final void Function(String)? onError;
  final String? label;
  final String? hintText;
  final double? width;
  final double? height;
  final bool showRemoveButton;
  final bool isRequired;
  final BorderRadius? borderRadius;
  final DeferredImageResult? initialImage;

  const DeferredImageUploadWidget({
    super.key,
    required this.fileType,
    this.description,
    this.onImageSelected,
    this.onError,
    this.label,
    this.hintText,
    this.width,
    this.height,
    this.showRemoveButton = true,
    this.isRequired = false,
    this.borderRadius,
    this.initialImage,
  });

  @override
  State<DeferredImageUploadWidget> createState() => _DeferredImageUploadWidgetState();
}

class _DeferredImageUploadWidgetState extends State<DeferredImageUploadWidget> {
  late DeferredImageResult _selectedImage;
  final DeferredUploadService _uploadService = DeferredUploadService();

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage ?? DeferredImageResult.cancelled();
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

        // Image info
        if (_selectedImage.isSelected) ...[
          const SizedBox(height: 8),
          _buildImageInfo(context),
        ],

        // Error message
        if (_selectedImage.hasError) ...[
          const SizedBox(height: 8),
          Text(
            _selectedImage.errorMessage!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],

        // Hint text
        if (widget.hintText != null && !_selectedImage.hasError) ...[
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
    final hasImage = _selectedImage.isSelected;
    
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
        // Image preview
        ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(10),
          child: _uploadService.buildDeferredImagePreview(
            _selectedImage,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
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
                // Change button
                Positioned(
                  top: 8,
                  right: 8,
                  child: _buildChangeButton(context),
                ),

                // Remove button
                if (widget.showRemoveButton)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: _buildRemoveButton(context),
                  ),

                // Upload indicator
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Will upload on save',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPrompt(BuildContext context) {
    return InkWell(
      onTap: _selectImage,
      borderRadius: widget.borderRadius ?? BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Tap to select image',
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
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Upload happens on save',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _selectedImage.displayInfo,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeButton(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: _selectImage,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                'Change',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
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

  Future<void> _selectImage() async {
    try {
      final result = await _uploadService.showDeferredImagePickerDialog(
        fileType: widget.fileType,
        description: widget.description,
      );

      if (result.isSelected || result.hasError) {
        setState(() {
          _selectedImage = result;
        });
        widget.onImageSelected?.call(result);
        
        if (result.hasError) {
          widget.onError?.call(result.errorMessage!);
        }
      }
    } catch (e) {
      widget.onError?.call('Failed to select image: ${e.toString()}');
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = DeferredImageResult.cancelled();
    });
    widget.onImageSelected?.call(_selectedImage);
  }

  /// Get the current selected image
  DeferredImageResult get selectedImage => _selectedImage;

  /// Check if an image is selected
  bool get hasImage => _selectedImage.isSelected;

  /// Update the image externally
  void updateImage(DeferredImageResult newImage) {
    setState(() {
      _selectedImage = newImage;
    });
  }
}

/// Compact deferred image upload widget for smaller spaces
class CompactDeferredImageUploadWidget extends StatelessWidget {
  final String fileType;
  final String? description;
  final void Function(DeferredImageResult)? onImageSelected;
  final void Function(String)? onError;
  final double size;
  final bool showRemoveButton;
  final DeferredImageResult? initialImage;

  const CompactDeferredImageUploadWidget({
    super.key,
    required this.fileType,
    this.description,
    this.onImageSelected,
    this.onError,
    this.size = 80,
    this.showRemoveButton = true,
    this.initialImage,
  });

  @override
  Widget build(BuildContext context) {
    return DeferredImageUploadWidget(
      fileType: fileType,
      description: description,
      onImageSelected: onImageSelected,
      onError: onError,
      width: size,
      height: size,
      showRemoveButton: showRemoveButton,
      borderRadius: BorderRadius.circular(size / 2),
      initialImage: initialImage,
    );
  }
}