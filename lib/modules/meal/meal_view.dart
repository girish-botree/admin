import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'meal_controller.dart';
import '../../utils/responsive.dart';
import 'components/mobile_meal.dart';
import 'components/tablet_meal.dart';
import 'components/web_meal.dart';

class MealView extends GetView<MealController> {
  const MealView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized when used as a nested component
    Get.put(MealController(), permanent: false);

    return const Responsive(
      mobile: MobileMeal(),
      tablet: TabletMeal(),
      web: WebMeal(),
    );
  }
}