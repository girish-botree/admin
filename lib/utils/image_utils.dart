import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// A utility class for safely loading images across different platforms
class SafeImageLoader {
  /// Loads an image from a URL with appropriate fallback mechanisms
  /// 
  /// - Uses CachedNetworkImage on mobile platforms (Android/iOS)
  /// - Uses regular Image.network on other platforms to avoid SQLite FFI issues
  /// 
  /// Parameters:
  /// - imageUrl: URL of the image to load
  /// - placeholderWidget: Optional widget to show while loading
  /// - errorWidget: Optional widget to show on error
  /// - fit: How the image should be inscribed into the box
  /// - width: Optional width constraint
  /// - height: Optional height constraint
  static Widget loadImage({
    required String imageUrl,
    required Widget placeholderWidget,
    required Widget errorWidget,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    int? memCacheWidth,
    int? maxHeightDiskCache,
  }) {
    // Use standard Image.network for web and desktop platforms
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholderWidget;
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error');
          return errorWidget;
        },
      );
    }

    // Use CachedNetworkImage for mobile platforms
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) => placeholderWidget,
      errorWidget: (context, url, error) {
        print('Error loading image: $error');
        return errorWidget;
      },
      memCacheWidth: memCacheWidth,
      maxHeightDiskCache: maxHeightDiskCache,
    );
  }
}