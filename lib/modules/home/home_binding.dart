import 'package:get/get.dart';
import 'home_controller.dart';
import '../meal/meal_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<MealController>(() => MealController());
  }
} 