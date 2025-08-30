import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_text.dart';
import '../../../utils/responsive.dart';
import '../meal_plan_model.dart';
import '../meal_plan_assignment_model.dart';
import '../plan_controller.dart';
import 'meal_plan_form_dialog.dart';

class MealCategorySection extends StatelessWidget {
  final MealCategory category;
  final List<MealPlan> mealPlans;
  final String title;
  final IconData icon;
  final Color color;

  const MealCategorySection({
    Key? key,
    required this.category,
    required this.mealPlans,
    required this.title,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppText.semiBold(
                    title,
                    color: theme.colorScheme.onSurface,
                    size: Responsive.getSubtitleTextSize(context),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppText.caption(
                    '${mealPlans.length} ${mealPlans.length == 1 ? 'meal' : 'meals'}',
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: mealPlans.isEmpty
                ? _buildEmptyState(context, theme)
                : _buildMealList(context, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant_menu_outlined,
              size: 32,
              color: color.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          AppText.medium(
            'No $title meals planned',
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          AppText.caption(
            'Add some delicious $title meals to your plan',
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMealList(BuildContext context, ThemeData theme) {
    return Column(
      children: mealPlans.map((plan) => _buildMealCard(context, theme, plan)).toList(),
    );
  }

  Widget _buildMealCard(BuildContext context, ThemeData theme, MealPlan plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final controller = Get.find<PlanController>();
            if (plan.id != null && plan.id!.isNotEmpty) {
              controller.getMealPlanDetails(plan.id!);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Meal Image or Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    image: plan.imageUrl != null && plan.imageUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(plan.imageUrl!),
                            fit: BoxFit.cover,
                            onError: (_, __) {},
                          )
                        : null,
                  ),
                  child: plan.imageUrl == null || plan.imageUrl!.isEmpty
                      ? Icon(
                          _getFoodIcon(plan.foodType),
                          color: color,
                          size: 24,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                
                // Meal Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.semiBold(
                        plan.name,
                        color: theme.colorScheme.onSurface,
                        size: Responsive.getBodyTextSize(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      AppText.body2(
                        plan.description,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      // Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: color.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 12, color: color),
                            const SizedBox(width: 4),
                            AppText.caption(
                              title,
                              color: color,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Actions Menu
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  color: theme.colorScheme.surface,
                  onSelected: (value) {
                    final controller = Get.find<PlanController>();
                    if (value == 'view') {
                      if (plan.id != null && plan.id!.isNotEmpty) {
                        controller.getMealPlanDetails(plan.id!);
                      }
                    } else if (value == 'edit') {
                      controller.prepareEditAssignmentForm(plan);
                      Get.dialog<void>(const MealPlanFormDialog(isEdit: true));
                    } else if (value == 'delete') {
                      _showDeleteDialog(context, plan, controller);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.visibility_rounded,
                              size: 14,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'View Details',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              size: 14,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Edit Meal',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
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
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.delete_rounded,
                              size: 14,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Delete Meal',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getFoodIcon(FoodType? foodType) {
    switch (foodType) {
      case FoodType.vegan:
        return Icons.spa;
      case FoodType.vegetarian:
        return Icons.eco;
      case FoodType.eggitarian:
        return Icons.egg;
      case FoodType.nonVegetarian:
        return Icons.restaurant;
      case FoodType.other:
        return Icons.more_horiz;
      default:
        return Icons.restaurant_menu;
    }
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
              AppText.h5(
                'Delete Meal',
                color: context.theme.colorScheme.onSurface,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              AppText.body1(
                'Are you sure you want to delete "${plan.name}" from your meal plan?',
                color: context.theme.colorScheme.onSurface.withValues(alpha: 0.8),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              AppText.caption(
                'This action cannot be undone.',
                color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: context.theme.colorScheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      child: AppText.medium(
                        'Cancel',
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        if (plan.id != null && plan.id!.isNotEmpty) {
                          Get.back<void>(); // Close dialog first
                          await controller.deleteMealPlan(plan.id!);
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: AppText.medium(
                        'Delete',
                        color: Colors.white,
                      ),
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
