import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Base64 Image Utility
/// Provides standardized base64 image encoding/decoding for API uploads
/// All image uploads throughout the application should use base64 format
class ImageBase64Util {

  /// Convert File to base64 string for API upload
  /// This is the standard format for all image uploads in the application
  static Future<String> fileToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      return base64String;
    } catch (e) {
      throw Exception('Failed to convert image to base64: $e');
    }
  }

  /// Convert base64 string back to bytes for display
  /// Handles both raw base64 and data URL formats
  static Uint8List base64ToBytes(String base64String) {
    try {
      String cleanBase64 = base64String;

      // Handle data URL format (data:image/jpeg;base64,...)
      if (base64String.startsWith('data:image/')) {
        cleanBase64 = base64String.split(',')[1];
      }

      return base64Decode(cleanBase64);
    } catch (e) {
      throw Exception('Failed to decode base64 image: $e');
    }
  }

  /// Check if a string is valid base64
  static bool isValidBase64(String str) {
    try {
      // Remove any whitespace and check if it's valid base64
      final cleanStr = str.replaceAll(RegExp(r'\s+'), '');

      // Base64 strings should be divisible by 4 in length (with padding)
      if (cleanStr.length % 4 != 0) return false;

      // Try to decode - if it fails, it's not valid base64
      base64Decode(cleanStr);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Build Image widget from base64 string or URL
  /// Handles both base64 data and network URLs
  static Widget buildImage(String? imageData, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (imageData == null || imageData.isEmpty) {
      return placeholder ?? _buildPlaceholderWidget(width, height);
    }

    try {
      // Check if it's base64 data
      if (imageData.startsWith('data:image/') || isValidBase64(imageData)) {
        final bytes = base64ToBytes(imageData);
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) =>
          errorWidget ?? _buildErrorWidget(width, height),
        );
      } else {
        // Assume it's a network URL
        return Image.network(
          imageData,
          fit: fit,
          width: width,
          height: height,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return placeholder ?? _buildPlaceholderWidget(width, height);
          },
          errorBuilder: (context, error, stackTrace) =>
          errorWidget ?? _buildErrorWidget(width, height),
        );
      }
    } catch (e) {
      return errorWidget ?? _buildErrorWidget(width, height);
    }
  }

  /// Validate image file before conversion
  static bool isValidImageFile(File file) {
    final extension = file.path
        .toLowerCase()
        .split('.')
        .last;
    final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return validExtensions.contains(extension);
  }

  /// Get file size in MB
  static Future<double> getFileSizeMB(File file) async {
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }

  /// Validate file size (default max 5MB)
  static Future<bool> isValidFileSize(File file,
      {double maxSizeMB = 5.0}) async {
    final sizeMB = await getFileSizeMB(file);
    return sizeMB <= maxSizeMB;
  }

  /// Convert image file to base64 with validation
  /// This is the recommended method for all image uploads
  static Future<String> processImageForUpload(File imageFile, {
    double maxSizeMB = 5.0,
  }) async {
    // Validate file type
    if (!isValidImageFile(imageFile)) {
      throw Exception(
          'Invalid image file type. Supported formats: JPG, JPEG, PNG, GIF, BMP, WEBP');
    }

    // Validate file size
    if (!await isValidFileSize(imageFile, maxSizeMB: maxSizeMB)) {
      final sizeMB = await getFileSizeMB(imageFile);
      throw Exception('Image file too large: ${sizeMB.toStringAsFixed(
          1)}MB. Maximum allowed: ${maxSizeMB}MB');
    }

    // Convert to base64
    return await fileToBase64(imageFile);
  }

  /// Default placeholder widget
  static Widget _buildPlaceholderWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.withOpacity(0.3),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }

  /// Default error widget
  static Widget _buildErrorWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.red.withOpacity(0.1),
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 48,
          color: Colors.red,
        ),
      ),
    );
  }
}