import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text.dart';
import '../meal_plan_model.dart';
import '../plan_controller.dart';
import '../plan_constants.dart';
import 'meal_plan_form_dialog.dart';

class MealPlanCard extends StatelessWidget {
  final MealPlan mealPlan;
  
  const MealPlanCard({
    Key? key,
    required this.mealPlan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlanController>();
    
    return Card(
      color: context.theme.colorScheme.surfaceContainerLowest,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and status
            Row(
              children: [
                Expanded(
                  child: AppText.h6(
                    mealPlan.name,
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: mealPlan.isActive ? AppColor.successContainer : AppColor.warningContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppText.caption(
                    mealPlan.isActive ? PlanConstants.active : PlanConstants.inactive,
                    color: mealPlan.isActive ? AppColor.success : AppColor.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Description
            AppText.body2(
              mealPlan.description,
              color: AppColor.outline,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            
            // Price
            if (mealPlan.price != null) ...[
              AppText.h6(
                '\$${mealPlan.price!.toStringAsFixed(2)}',
                color: AppColor.success,
              ),
              const SizedBox(height: 12),
            ],
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditDialog(controller),
                  icon: const Icon(Icons.edit, size: 16),
                  label: AppText.caption(PlanConstants.edit),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColor.info,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showDeleteDialog(controller),
                  icon: const Icon(Icons.delete, size: 16),
                  label: AppText.caption(PlanConstants.delete),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColor.error,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(PlanController controller) {
    controller.prepareEditForm(mealPlan);
    Get.dialog<void>(const MealPlanFormDialog(isEdit: true));
  }

  void _showDeleteDialog(PlanController controller) {
    Get.defaultDialog<void>(
      title: PlanConstants.deleteMealPlan,
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      content: Column(
        children: [
          AppText.body1(
            PlanConstants.confirmDelete,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          AppText.caption(
            PlanConstants.deleteWarning,
            color: AppColor.error,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      textCancel: PlanConstants.cancel,
      textConfirm: PlanConstants.delete,
      confirmTextColor: AppColor.white,
      buttonColor: AppColor.error,
      cancelTextColor: AppColor.outline,
      onConfirm: () {
        if (mealPlan.id != null) {
          controller.deleteMealPlan(mealPlan.id!);
        }
        Get.back<void>();
      },
    );
  }
}