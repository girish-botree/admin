import 'package:get/get.dart';
import '../plan/plan_controller.dart';
import '../home/home_controller.dart';
import '../dashboard/dashboard_controller.dart';
import '../meal/meal_controller.dart';
import 'main_layout_controller.dart';

class MainLayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainLayoutController>(() => MainLayoutController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<PlanController>(() => PlanController());
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<MealController>(() => MealController());
  }
}