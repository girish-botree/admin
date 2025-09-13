import 'package:admin/config/app_translations.dart';
import 'package:admin/config/theme_controller.dart';
import 'package:admin/themes/enhanced_theme_config.dart';

import 'package:admin/language/language_controller.dart';
import 'package:admin/routes/app_page.dart';
import 'package:admin/widgets/loading_widgets.dart';
import 'package:admin/network_service/dio_network_service.dart';
import 'package:admin/config/auth_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

// Import for FFI (non-mobile platforms)
import 'package:sqflite_common_ffi/sqflite_ffi.dart' if (dart.library.html) 'dart:html';

import 'firebase_options.dart';
import 'package:flutter/material.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize appropriate SQLite implementation based on platform
  if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
    // For desktop platforms (Windows, macOS, Linux)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AppTranslations.load();
  Get.put(LanguageController());
  Get.put(ThemeController());


  // Verify languages are properly loaded
  final langController = Get.find<LanguageController>();
  await langController.verifyLanguages();

  // Initialize the AuthService
  Get.put(AuthService());

  // Initialize the network service
  NetworkService.initialize();

  // Apply green theme
  Get.find<ThemeController>().setGreenTheme();
  
  runApp(const MyApp());
  configLoading();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = Get.find<ThemeController>();
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        locale: Get
            .find<LanguageController>()
            .locale
            .value,
        fallbackLocale: const Locale('en', 'US'),
        title: 'Admin App',
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        theme: themeController.isGreenTheme
            ? EnhancedThemeConfig.greenTheme
            : EnhancedThemeConfig.lightTheme,
        darkTheme: kIsWeb ? null : EnhancedThemeConfig.darkTheme,
        themeMode: themeController.themeMode.value,
        translations: AppTranslations(),
        builder: (context, child) {
          // EasyLoading.init() removed - no overscreen loading
          return child ?? Container();
        },
      );
    });
  }
}