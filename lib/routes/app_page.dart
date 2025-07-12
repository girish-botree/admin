import 'package:admin/modules/login/login_binding.dart';
import 'package:admin/modules/login/login_view.dart';
import 'package:get/get.dart';
import '../language/language.dart';
import '../language/language_binding.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
        name: AppRoutes.splash,
        page: () => const Splash(),
        binding: SplashBinding()),
    GetPage(
        name: AppRoutes.language,
        page: () => Language(),
        binding: LanguageBinding()),
    GetPage(
        name: AppRoutes.login,
        page: () => const LoginView(),
        binding: LoginBinding()),
  ];
}