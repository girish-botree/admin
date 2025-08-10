import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/responsive.dart';
import '../plan_controller.dart';
import 'meal_plan_card.dart';

class ResponsiveMealPlanGrid extends StatelessWidget {
  const ResponsiveMealPlanGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlanController>();
    
    return Obx(() {
      final mealPlans = controller.mealPlans;
      
      return Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getCrossAxisCount(context),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: _getChildAspectRatio(context),
          ),
          itemCount: mealPlans.length,
          itemBuilder: (context, index) {
            return MealPlanCard(mealPlan: mealPlans[index]);
          },
        ),
      );
    });
  }

  int _getCrossAxisCount(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return 3;
    } else if (Responsive.isTablet(context)) {
      return 2;
    } else {
      return 1;
    }
  }

  double _getChildAspectRatio(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return 1.2;
    } else if (Responsive.isTablet(context)) {
      return 1.1;
    } else {
      return 1.3;
    }
  }
}