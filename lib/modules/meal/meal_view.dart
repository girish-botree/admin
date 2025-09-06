import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'meal_controller.dart';
import '../../config/app_text.dart';
import '../../utils/responsive.dart';
import 'components/mobile_meal.dart';
import 'components/tablet_meal.dart';
import 'components/web_meal.dart';

class MealView extends GetView<MealController> {
  const MealView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.bold(
          'Meals',
          color: context.theme.colorScheme.onSurface,
          size: 20,
        ),
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        elevation: 0,
        centerTitle: false,
        actions: [
          Obx(() =>
              IconButton(
                onPressed: controller.isLoading.value ? null : () async {
                  try {
                    await controller.refreshData();
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      'Failed to refresh data. Please try again.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Get.theme.colorScheme.error,
                      colorText: Get.theme.colorScheme.onError,
                    );
                  }
                },
                icon: controller.isLoading.value
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.theme.colorScheme.onSurface,
                  ),
                )
                    : Icon(
                  Icons.refresh_rounded,
                  color: context.theme.colorScheme.onSurface,
                ),
                tooltip: 'Refresh',
              )),
        ],
      ),
      body: const Responsive(
        mobile: MobileMeal(),
        tablet: TabletMeal(),
        web: WebMeal(),
      ),
    );
  }
}