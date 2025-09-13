import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

enum AppTheme { light, dark, green }

class ThemeController extends GetxController {
  final _storage = GetStorage();
  final _key = 'theme_mode';
  final _themeKey = 'app_theme';
  final _fontSizeKey = 'font_size';

  Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  Rx<AppTheme> appTheme = AppTheme.light.obs;
  RxString fontSize = 'medium'.obs;

  @override
  void onInit() {
    super.onInit();
    loadThemeMode();
    loadAppTheme();
    loadFontSize();
  }

  void loadThemeMode() {
    final savedTheme = _storage.read<int>(_key);
    if (savedTheme != null) {
      themeMode.value = ThemeMode.values[savedTheme];
      Get.changeThemeMode(themeMode.value);
    }
  }

  void loadAppTheme() {
    final savedAppTheme = _storage.read<String>(_themeKey);
    if (savedAppTheme != null) {
      appTheme.value = AppTheme.values.firstWhere(
        (theme) => theme.toString() == savedAppTheme,
        orElse: () => AppTheme.light,
      );
    }
  }

  void loadFontSize() {
    final savedFontSize = _storage.read<String>(_fontSizeKey);
    if (savedFontSize != null) {
      fontSize.value = savedFontSize;
    }
  }

  void changeThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    _storage.write(_key, mode.index);
  }

  void changeAppTheme(AppTheme theme) {
    appTheme.value = theme;
    _storage.write(_themeKey, theme.toString());
  }

  void setGreenTheme() {
    appTheme.value = AppTheme.green;
    _storage.write(_themeKey, AppTheme.green.toString());
  }

  void changeFontSize(String size) {
    fontSize.value = size;
    _storage.write(_fontSizeKey, size);
  }

  double get fontSizeMultiplier {
    switch (fontSize.value) {
      case 'small':
        return 0.85;
      case 'large':
        return 1.15;
      default: // medium
        return 1.0;
    }
  }

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  bool get isLightMode => themeMode.value == ThemeMode.light;

  bool get isGreenTheme => appTheme.value == AppTheme.green;
}