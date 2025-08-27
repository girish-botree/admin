import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_text.dart';
import '../../../utils/responsive.dart';
import '../meal_plan_model.dart';
import '../plan_controller.dart';
import 'meal_plan_form_dialog.dart';

class MealSection extends StatelessWidget {
  final String title;
  final List<MealPlan> mealPlans;
  final IconData icon;
  final Color? borderColor;

  const MealSection({
    Key? key,
    required this.title,
    required this.mealPlans,
    required this.icon,
    this.borderColor,
  }) : super(key: key);

  Widget _getFoodTypeIcon(FoodType? foodType, ThemeData theme) {
    if (foodType == null) return const SizedBox.shrink();

    IconData iconData;
    Color iconColor;

    switch (foodType) {
      case FoodType.vegan:
        iconData = Icons.grass;
        iconColor = Colors.green;
        break;
      case FoodType.vegetarian:
        iconData = Icons.eco;
        iconColor = Colors.lightGreen;
        break;
      case FoodType.eggitarian:
        iconData = Icons.egg;
        iconColor = Colors.orange;
        break;
      case FoodType.nonVegetarian:
        iconData = Icons.restaurant;
        iconColor = Colors.red;
        break;
      case FoodType.other:
        iconData = Icons.more_horiz;
        iconColor = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 12,
            color: iconColor,
          ),
          const SizedBox(width: 4),
          AppText(
            foodType.displayName,
            color: iconColor,
            size: 10,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.onSurface, size: 20),
              const SizedBox(width: 8),
              AppText.semiBold(title, color: theme.colorScheme.onSurface,
                  size: Responsive.getSubtitleTextSize(context)),
            ],
          ),
          const SizedBox(height: 12),
          if (mealPlans.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: AppText(
                  'Nothing planned for $title',
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: Responsive.getBodyTextSize(context),
                ),
              ),
            )
          else
            ...mealPlans.map((plan) => GestureDetector(
              onTap: () {
                // Get controller and call getMealPlanDetails with assignment ID
                final controller = Get.find<PlanController>();
                if (plan.id != null && plan.id!.isNotEmpty) {
                  controller.getMealPlanDetails(plan.id!);
                } else {
                  // Show snackbar if no ID available
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(
                        'No details available for this meal plan')),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AppText.medium(
                                  plan.name,
                                  color: theme.colorScheme.onSurface,
                                  size: Responsive.getBodyTextSize(context),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _getFoodTypeIcon(plan.foodType, theme),
                            ],
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            plan.description,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            size: Responsive.getCaptionTextSize(context),
                          ),
                        ],
                      ),
                    ),
                    if (plan.price != null)
                      AppText.medium(
                        '\$${plan.price!.toStringAsFixed(2)}',
                        color: theme.colorScheme.primary,
                        size: Responsive.getBodyTextSize(context),
                      ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 8,
                      color: theme.colorScheme.surface,
                      onSelected: (value) {
                        final controller = Get.find<PlanController>();
                        if (value == 'edit') {
                          controller.prepareEditAssignmentForm(plan);
                          Get.dialog<void>(const MealPlanFormDialog(isEdit: true));
                        } else if (value == 'delete') {
                          _showDeleteDialog(context, plan, controller);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.edit_rounded, size: 14,
                                    color: Colors.blue),
                              ),
                              const SizedBox(width: 12),
                              const Text('Edit Plan', style: TextStyle(
                                  fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                    Icons.delete_rounded, size: 14,
                                    color: Colors.red),
                              ),
                              const SizedBox(width: 12),
                              const Text('Delete Plan',
                                  style: TextStyle(color: Colors.red,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
        ],
      ),
    );
  }



  void _showDeleteDialog(BuildContext context, MealPlan plan, PlanController controller) {
    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: context.theme.colorScheme.surface,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 32,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Delete Meal Plan',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete "${plan.name}"?',
                style: TextStyle(
                  fontSize: 16,
                  color: context.theme.colorScheme.onSurface.withValues(
                      alpha: 0.8),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  fontSize: 14,
                  color: context.theme.colorScheme.onSurface.withValues(
                      alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back<void>(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(
                          color: context.theme.colorScheme.outline.withValues(
                              alpha: 0.5),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        if (plan.id != null && plan.id!.isNotEmpty) {
                          try {
                            print(
                                'Attempting to delete meal plan with ID: ${plan
                                    .id}');
                            print('Meal plan name: ${plan.name}');
                            Get.back<void>(); // Close dialog first
                            await controller.deleteMealPlan(plan.id!);
                            print('Delete operation completed');
                          } catch (e) {
                            print('Delete operation failed: $e');
                            Get.snackbar(
                              'Error',
                              'Failed to delete meal plan: ${e.toString()}',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 5),
                            );
                          }
                        } else {
                          print(
                              'Cannot delete meal plan - ID is null or empty: ${plan
                                  .id}');
                          Get.back<void>();
                          Get.snackbar(
                            'Error',
                            'Cannot delete meal plan: Invalid ID (${plan.id})',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 5),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}