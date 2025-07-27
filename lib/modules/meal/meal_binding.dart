import 'package:admin/config/app_config.dart';
import 'package:admin/modules/meal/meal_controller.dart';

class MealBinding extends Bindings{
  @override
  void dependencies() {
    Get.put(MealController());
  }
}