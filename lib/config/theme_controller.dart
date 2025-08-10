import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _storage = GetStorage();
  final _key = 'theme_mode';
  final _fontSizeKey = 'font_size';

  Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  RxString fontSize = 'medium'.obs;

  @override
  void onInit() {
    super.onInit();
    loadThemeMode();
    loadFontSize();
  }

  void loadThemeMode() {
    final savedTheme = _storage.read<int>(_key);
    if (savedTheme != null) {
      themeMode.value = ThemeMode.values[savedTheme];
      Get.changeThemeMode(themeMode.value);
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
}