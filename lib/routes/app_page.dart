import 'package:admin/modules/login/login_binding.dart';
import 'package:admin/modules/login/login_view.dart';
import 'package:admin/modules/home/home_binding.dart';
import 'package:admin/modules/home/home_view.dart';
import 'package:admin/modules/meal/meal_binding.dart';
import 'package:admin/modules/meal/meal_view.dart';
import 'package:admin/modules/main_layout/main_layout_binding.dart';
import 'package:admin/modules/main_layout/main_layout_view.dart';
import 'package:admin/modules/plan/plan_binding.dart';
import 'package:admin/modules/plan/plan_view.dart';
import 'package:admin/modules/plan/meal_plan_detail_view.dart';
import 'package:admin/modules/dashboard/dashboard_binding.dart';
import 'package:admin/modules/dashboard/dashboard_view.dart';
import 'package:admin/modules/delivery_persons/manage_delivery_persons/delivery_person_binding.dart';
import 'package:admin/modules/delivery_persons/manage_delivery_persons/delivery_person_view.dart';

import 'package:admin/config/auth_middleware.dart';
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
    GetPage<void>(
        name: AppRoutes.splash,
        page: () => const Splash(),
        binding: SplashBinding()),
    GetPage<void>(
        name: AppRoutes.language,
        page: () => Language(),
        binding: LanguageBinding()),
    GetPage<void>(
        name: AppRoutes.login,
        page: () => const LoginView(),
        binding: LoginBinding()),
    GetPage<void>(
        name: AppRoutes.home,
        page: () =>  HomeView(),
        binding: HomeBinding(),
        middlewares: [AuthMiddleware()]),
    GetPage<void>(
        name: AppRoutes.meal, 
        page: () => const MealView(),
        binding: MealBinding(),
        middlewares: [AuthMiddleware()]),
    GetPage<void>(
        name: AppRoutes.mainLayout,
        page: () => const MainLayoutView(),
        binding: MainLayoutBinding(),
        middlewares: [AuthMiddleware()]),
    GetPage<void>(
        name: AppRoutes.plan,
        page:()=> const PlanView(),
        binding: PlanBinding(),
        middlewares: [AuthMiddleware()]),
    GetPage<void>(
        name: AppRoutes.mealPlanDetail,
        page: () => MealPlanDetailView(selectedDate: Get.arguments as DateTime? ?? DateTime.now()),
        binding: PlanBinding(),
        middlewares: [AuthMiddleware()]),
    GetPage<void>(
        name: AppRoutes.dashboard,
        page: () => DashboardView(),
        binding: DashboardBinding(),
        middlewares: [AuthMiddleware()]),
    GetPage<void>(
        name: AppRoutes.deliveryPersons,
        page: () => const DeliveryPersonView(),
        binding: DeliveryPersonBinding(),
        middlewares: [AuthMiddleware()]),

  ];
}