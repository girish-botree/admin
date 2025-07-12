import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../themes/blue_theme.dart';

enum ThemeConfig {
  themeBlue
}

class ThemeUtil {

  static ThemeData getAppLightTheme(ThemeConfig appTheme) {
    switch (appTheme) {
      case ThemeConfig.themeBlue:
        return BlueTheme().light();
      default:
        return BlueTheme().light();
    }
  }

  static ThemeData getAppDarkTheme(ThemeConfig appTheme) {
    switch (appTheme) {
      case ThemeConfig.themeBlue:
        return BlueTheme().dark();
      default:
        return BlueTheme().dark();
    }
  }
}

extension ResponsiveExtension on GetInterface {
  bool get isMobile => Get.width < 600 || (Get.width < 900 && isLandscape);
  bool get isTablet => Get.width >= 600  && !isMobile;
  bool get isPortrait => Get.width < Get.height;
  bool get isLandscape => Get.width > Get.height;
}