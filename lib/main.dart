import 'package:admin/config/app_theme_config.dart';
import 'package:admin/config/app_translations.dart';
import 'package:admin/config/theme_controller.dart';

import 'package:admin/language/language_controller.dart';
import 'package:admin/routes/app_page.dart';
import 'package:admin/widgets/loading_widgets.dart';
import 'package:admin/network_service/dio_network_service.dart';
import 'package:admin/config/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        theme: ThemeUtil.getAppLightTheme(ThemeConfig.themeBlue),
        darkTheme: kIsWeb ? null : ThemeUtil.getAppDarkTheme(
            ThemeConfig.themeBlue),
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