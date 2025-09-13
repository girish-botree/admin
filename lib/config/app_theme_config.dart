import 'package:admin/themes/yellow_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../themes/blue_theme.dart';
import '../themes/green_theme.dart';

enum ThemeConfig {
  themeBlue,
  themeYellow,
  themeGreen,
}

class ThemeUtil {

  static ThemeData getAppLightTheme(ThemeConfig appTheme) {
    switch (appTheme) {
      case ThemeConfig.themeBlue:
        return BlueTheme().light();
      case ThemeConfig.themeYellow:
        return YellowTheme().light();
      case ThemeConfig.themeGreen:
        return MaterialTheme(ThemeData().textTheme).light();
    }
  }

  static ThemeData getAppDarkTheme(ThemeConfig appTheme) {
    switch (appTheme) {
      case ThemeConfig.themeBlue:
        return BlueTheme().dark();
      case ThemeConfig.themeYellow:
        return YellowTheme().dark();
      case ThemeConfig.themeGreen:
        return MaterialTheme(ThemeData().textTheme).dark();
    }
  }
}

extension ResponsiveExtension on GetInterface {
  bool get isMobile => Get.width < 600 || (Get.width < 900 && isLandscape);
  bool get isTablet => Get.width >= 600  && !isMobile;
  bool get isPortrait => Get.width < Get.height;
  bool get isLandscape => Get.width > Get.height;
}