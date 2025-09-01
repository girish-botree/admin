import 'package:flutter/material.dart';

import '../config/app_config.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppBorderRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 28.0;
}

class AppShadows {
  static List<BoxShadow> get cardShadow =>
      [
        BoxShadow(
      color: Theme.of(Get.context!).shadowColor.withAlpha(20),
      blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
        BoxShadow(
      color: Theme.of(Get.context!).shadowColor.withAlpha(10),
      blurRadius: 6,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get chartShadow =>
      [
        BoxShadow(
      color: Theme.of(Get.context!).shadowColor.withAlpha(20),
      blurRadius: 24,
          offset: const Offset(0, 12),
          spreadRadius: 0,
        ),
        BoxShadow(
      color: Theme.of(Get.context!).shadowColor.withAlpha(10),
      blurRadius: 6,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];
}