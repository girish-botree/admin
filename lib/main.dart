import 'package:admin/config/app_theme_config.dart';
import 'package:admin/config/app_translations.dart';
import 'package:admin/language/language_controller.dart';
import 'package:admin/routes/app_page.dart';
import 'package:admin/widgets/loading_widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AppTranslations.load();
  Get.put(LanguageController());
  runApp(const MyApp());
  configLoading();
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: Get.find<LanguageController>().locale.value,
      fallbackLocale: const Locale('en', 'US'),
      title: 'Flutter Demo',
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      theme: ThemeUtil.getAppLightTheme(ThemeConfig.themeBlue),
      darkTheme: ThemeUtil.getAppDarkTheme(ThemeConfig.themeBlue),
      translations: AppTranslations(),
    );
  }
}