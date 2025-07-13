import 'package:flutter/material.dart';

Widget buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required double containerWidth,
    required double containerHeight,
    required double borderRadius,
    required double blurRadius,
    required double iconSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: containerWidth,
        height: containerHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: blurRadius,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: iconSize, color: color),
      ),
    );
  }