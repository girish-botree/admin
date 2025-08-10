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
                          AppText.medium(
                            plan.name,
                            color: theme.colorScheme.onSurface,
                            size: Responsive.getBodyTextSize(context),
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
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
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
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal Plan'),
        content: Text('Are you sure you want to delete "${plan.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.deleteMealPlan(plan.id!);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}