import 'package:flutter/material.dart';

abstract class AppColor {
  // Basic Colors
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const transparent = Color(0x00000000);

  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onError = Color(0xFFFFFFFF);
  static const onErrorContainer = Color(0xFF93000A);

  // Status Colors
  static const success = Color(0xFF2E7D32);
  static const successContainer = Color(0xFFE8F5E8);
  static const warning = Color(0xFFF57C00);
  static const warningContainer = Color(0xFFFFF3E0);
  static const info = Color(0xFF1976D2);
  static const infoContainer = Color(0xFFE3F2FD);

  // Utility Colors
  static const outline = Color(0xFF817567);
  static const outlineVariant = Color(0xFFD3C4B4);
  static const shadow = Color(0xFF000000);
  static const scrim = Color(0xFF000000);
  static const inverseSurface = Color(0xFF362F27);
  static const inversePrimary = Color(0xFFF5BD6F);
  static const onInverseSurface = Color(0xFFEDE0D4);

  // Additional UI Colors
  static const divider = Color(0xFFD3C4B4);
  static const disabled = Color(0xFFBFBFBF);
  static const hover = Color(0x0F000000);
  static const focus = Color(0x1F000000);
  static const pressed = Color(0x14000000);
  static const dragged = Color(0x14000000);
  static const selected = Color(0x1F805610);

  // Input Field Colors
  static const inputFill = Color(0xFFF5BD6F);
  static const inputBorder = Color(0xFFD3C4B4);
  static const inputFocused = Color(0xFF805610);
  static const inputError = Color(0xFFBA1A1A);
  static const inputHint = Color(0xFF817567);
  static const inputLabel = Color(0xFF4F4539);

  // Progress Colors
  static const progressIndicator = Color(0xFF805610);
  static const progressBackground = Color(0xFFE0E0E0);
  static const progressSuccess = Color(0xFF2E7D32);
  static const progressWarning = Color(0xFFF57C00);
  static const progressError = Color(0xFFBA1A1A);

  
  // Shimmer Colors
  static const shimmerBase = Color(0xFFE0E0E0);
  static const shimmerHighlight = Color(0xFFF5F5F5);

  // Social Media Colors
  static const google = Color(0xFF4285F4);
  static const facebook = Color(0xFF1877F2);
  static const twitter = Color(0xFF1DA1F2);
  static const linkedin = Color(0xFF0A66C2);
  static const github = Color(0xFF333333);

  // Color Lists for Charts/Graphs
  static const List<Color> chartColors = [
    Color(0xFF805610),
    Color(0xFF904A46),
    Color(0xFF52643F),
    Color(0xFFF5BD6F),
    Color(0xFFFFB3AD),
    Color(0xFFB8CDA1),
    Color(0xFFFFDDB4),
    Color(0xFFFFDAD7),
    Color(0xFFD4EABB),
  ];

  static const List<Color> pastelColors = [
    Color(0xFFFFE5CC),
    Color(0xFFFFE5E5),
    Color(0xFFE5F5E5),
    Color(0xFFE5E5FF),
    Color(0xFFFFF5E5),
    Color(0xFFFFE5F5),
    Color(0xFFE5FFF5),
    Color(0xFFF5E5FF),
  ];

  // Helper methods
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static Color withAlpha(Color color, int alpha) {
    return color.withAlpha(alpha);
  }

  static Color blend(Color color1, Color color2, double t) {
    return Color.lerp(color1, color2, t) ?? color1;
  }
} 