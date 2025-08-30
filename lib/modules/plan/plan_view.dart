import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../config/app_colors.dart';
import '../../config/app_text.dart';
import '../../utils/responsive.dart';
import '../../widgets/custom_displays.dart';
import 'plan_controller.dart';
import 'plan_constants.dart';
import 'meal_plan_model.dart';
import 'meal_plan_assignment_model.dart';
import 'widgets/meal_plan_form_dialog.dart';
import 'widgets/meal_plan_loading.dart';
import 'widgets/plan_statistics_widget.dart';

class PlanView extends GetView<PlanController> {
  const PlanView({super.key});

  // Constants for better maintainability
  static const double _defaultPadding = 16.0;
  static const double _cardBorderRadius = 12.0;
  static const double _spacingMedium = 16.0;
  static const double _spacingLarge = 24.0;


  @override
  Widget build(BuildContext context) {
    // Remove this line - controller should be initialized elsewhere
    // Get.put(PlanController());
    return Scaffold(
      appBar: AppBar(
        title: AppText.bold(
          PlanConstants.mealPlans,
          color: context.theme.colorScheme.onSurface,
          size: 20,
        ),
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () async {
              // Force refresh with cache clearing
              controller.clearCaches();
              await controller.getMealPlans();
              await controller.getMealPlansByDate();
            },
            icon: Icon(Icons.refresh, color: context.theme.colorScheme.onSurface),
            tooltip: 'Refresh',
          ),
          // SettingsWidget(),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const MealPlanLoading();
        }


        return RefreshIndicator(
          onRefresh: () async {
            controller.clearCaches();
            await controller.getMealPlans();
            await controller.getMealPlansByDate();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(_defaultPadding),
            child: Column(
              children: [
                // Calendar Widget
                _buildCalendarWidget(context),
                const SizedBox(height: _spacingLarge),
                
                // Selected Date Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppText.semiBold(
                        'Meal Plans for ${_formatDate(
                            controller.selectedCalendarDate.value)}',
                        color: context.theme.colorScheme.onSurface,
                        size: Responsive.getSubtitleTextSize(context),
                      ),
                    ),
                    if (!_hasNoMealsForDay())
                      IconButton(
                        onPressed: () => _showDeleteAllConfirmation(context),
                        icon: const Icon(
                          Icons.delete_sweep,
                          color: Colors.red,
                          size: 24,
                        ),
                        tooltip: 'Delete all meals for this day',
                      ),
                  ],
                ),
                const SizedBox(height: _spacingMedium),
                
                // Check if any meals exist for the day
                _hasNoMealsForDay()
                    ? const EmptyStateWidget(
                  icon: Icons.restaurant_menu_outlined,
                  title: 'No meal plans found',
                  subtitle: 'Create your first meal plan for this date',
                )
                    : _buildCombinedView(),
                const SizedBox(height: _spacingLarge),
                const PlanStatisticsWidget(),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: context.theme.colorScheme.onSurface,
        child: const Icon(Icons.add, color: AppColor.white),
      ),
    );
  }

  Widget _buildCalendarWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
      ),
      child: TableCalendar<DateTime>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: controller.focusedDay.value,
        selectedDayPredicate: (day) {
          return isSameDay(controller.selectedCalendarDate.value, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          controller.updateSelectedDate(selectedDay);
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          selectedDecoration: BoxDecoration(
            color: context.theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: context.theme.colorScheme.primary.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            color: context.theme.colorScheme.onSurface,
            fontSize: Responsive.getSubtitleTextSize(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showCreateDialog() {
    controller.clearForm();
    Get.dialog<void>(const MealPlanFormDialog());
  }

  void _showDeleteAllConfirmation(BuildContext context) {
    Get.dialog<void>(
      AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.red,
              size: 24,
            ),
            SizedBox(width: 8),
            Text('Delete All Meals'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete all meals for ${_formatDate(
              controller.selectedCalendarDate
                  .value)}?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
                              onPressed: () => Get.back<void>(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back<void>(); // Close dialog first
              await controller.deleteAllMealPlansForDate(
                  controller.selectedCalendarDate.value);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
  
  bool _hasNoMealsForDay() {
    final breakfastPlans = controller.getMealPlansForPeriod(
        MealPeriod.breakfast);
    final lunchPlans = controller.getMealPlansForPeriod(MealPeriod.lunch);
    final dinnerPlans = controller.getMealPlansForPeriod(MealPeriod.dinner);
    return breakfastPlans.isEmpty && lunchPlans.isEmpty && dinnerPlans.isEmpty;
  }

  Widget _buildCombinedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Get.theme.colorScheme.primary.withValues(alpha: 0.1),
                Get.theme.colorScheme.primary.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Get.theme.colorScheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.category,
                  color: Get.theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.semiBold(
                      'Meal Categories & Schedule',
                      color: Get.theme.colorScheme.onSurface,
                      size: 16,
                    ),
                    AppText.caption(
                      'Organized by meal categories with time breakdown',
                      color: Get.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.schedule,
                  color: Get.theme.colorScheme.primary,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
        
        // Category-based sections with time period breakdown
        _buildCategorySection(
          category: MealCategory.vegan,
          title: 'Vegan',
          icon: Icons.spa,
          color: const Color(0xFF009688),
        ),
        _buildCategorySection(
          category: MealCategory.vegetarian,
          title: 'Vegetarian',
          icon: Icons.eco,
          color: const Color(0xFF4CAF50),
        ),
        _buildCategorySection(
          category: MealCategory.eggitarian,
          title: 'Eggitarian',
          icon: Icons.egg,
          color: const Color(0xFFFFC107),
        ),
        _buildCategorySection(
          category: MealCategory.nonVegetarian,
          title: 'Non-Vegetarian',
          icon: Icons.restaurant,
          color: const Color(0xFFFF9800),
        ),
        _buildCategorySection(
          category: MealCategory.other,
          title: 'Other',
          icon: Icons.more_horiz,
          color: const Color(0xFF9E9E9E),
        ),
      ],
    );
  }



  Widget _buildCategorySection({
    required MealCategory category,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    // Get all meal plan assignments for this category
    final categoryAssignments = controller.mealPlanAssignments.where((assignment) {
      return assignment.category == category;
    }).toList();

    // Group assignments by time period
    final mealsByTime = <MealPeriod, List<MealPlan>>{};
    for (final period in MealPeriod.values) {
      mealsByTime[period] = [];
    }

    // Fill the time periods with meals from this category
    for (final assignment in categoryAssignments) {
      // Check if this recipe is already added to this time period to prevent duplicates
      final periodMeals = mealsByTime[assignment.period] ?? [];
      final existingMealById = periodMeals.where((meal) => meal.id == assignment.id).isNotEmpty;
      
      // Also check by recipe name to prevent same recipe with different assignment IDs
      final existingMealByRecipe = periodMeals.where((meal) => 
          meal.name.isNotEmpty && 
          assignment.recipeName?.isNotEmpty == true && 
          meal.name == assignment.recipeName
      ).isNotEmpty;
      
      // Skip if this exact meal assignment or recipe is already added
      if (existingMealById || existingMealByRecipe) {
        continue;
      }
      
      // Get meal plan details for this assignment
      String recipeName = assignment.recipeName ?? '';
      String recipeDescription = assignment.recipeDescription ?? '';
      String? recipeImageUrl = assignment.recipeImageUrl;

      if (recipeName.isEmpty) {
        // Try to find recipe details from the recipes list
        try {
          final recipe = controller.recipes.firstWhere(
            (r) => r is Map<String, dynamic> && r['recipeId'] == assignment.recipeId,
            orElse: () => null,
          );
          if (recipe != null && recipe is Map<String, dynamic>) {
            recipeName = recipe['name']?.toString() ?? 'Unknown Recipe';
            recipeDescription = recipe['description']?.toString() ?? 'No description available';
            recipeImageUrl = recipe['imageUrl']?.toString();
          }
        } catch (e) {
          // Handle error silently
        }
      }

      if (recipeName.isEmpty) {
        recipeName = 'Unknown Recipe';
      }
      if (recipeDescription.isEmpty) {
        recipeDescription = 'No description available';
      }

      // Create MealPlan from assignment data
      final mealPlan = MealPlan(
        id: assignment.id,
        name: recipeName,
        description: recipeDescription,
        imageUrl: recipeImageUrl,
        isActive: true,
        foodType: _mapCategoryToFoodType(category),
      );

      mealsByTime[assignment.period]?.add(mealPlan);
    }

    // Calculate total meals in this category
    final totalMeals = mealsByTime.values.fold<int>(0, (sum, meals) => sum + meals.length);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.bold(
                        title,
                        color: Get.theme.colorScheme.onSurface,
                        size: 18,
                      ),
                      AppText.caption(
                        '$totalMeals ${totalMeals == 1 ? 'meal' : 'meals'} planned',
                        color: Get.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
                // Time period distribution indicator
                Row(
                  children: MealPeriod.values.map((period) {
                    final periodMeals = mealsByTime[period] ?? [];
                    if (periodMeals.isEmpty) return const SizedBox.shrink();
                    
                    return Container(
                      margin: const EdgeInsets.only(left: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getTimePeriodColor(period),
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          // Time Period Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: totalMeals == 0
                ? _buildEmptyCategorySlot(title, color)
                : _buildTimePeriods(mealsByTime, color),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCategorySlot(String title, Color color) {
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
            color: Get.theme.colorScheme.onSurface.withValues(alpha: 0.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          AppText.caption(
            'Add some delicious $title meals to your plan',
            color: Get.theme.colorScheme.onSurface.withValues(alpha: 0.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimePeriods(
    Map<MealPeriod, List<MealPlan>> mealsByTime,
    Color categoryColor,
  ) {
    final nonEmptyPeriods = mealsByTime.entries
        .where((entry) => entry.value.isNotEmpty)
        .toList();
    
    if (nonEmptyPeriods.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      children: nonEmptyPeriods.map((entry) {
        final period = entry.key;
        final meals = entry.value;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getTimePeriodColor(period).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Period Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getTimePeriodColor(period).withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getTimePeriodIcon(period),
                      color: _getTimePeriodColor(period),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    AppText.semiBold(
                      _getTimePeriodName(period),
                      color: Get.theme.colorScheme.onSurface,
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getTimePeriodColor(period).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppText.caption(
                        '${meals.length}',
                        color: _getTimePeriodColor(period),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Meals in this time period
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: meals.map((plan) => _buildCompactMealCard(plan, categoryColor)).toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Helper method to map MealCategory to FoodType
  FoodType _mapCategoryToFoodType(MealCategory category) {
    switch (category) {
      case MealCategory.vegan:
        return FoodType.vegan;
      case MealCategory.vegetarian:
        return FoodType.vegetarian;
      case MealCategory.eggitarian:
        return FoodType.eggitarian;
      case MealCategory.nonVegetarian:
        return FoodType.nonVegetarian;
      case MealCategory.other:
        return FoodType.other;
    }
  }

  // Helper methods for time period styling
  Color _getTimePeriodColor(MealPeriod period) {
    switch (period) {
      case MealPeriod.breakfast:
        return const Color(0xFFFF9800);
      case MealPeriod.lunch:
        return const Color(0xFF4CAF50);
      case MealPeriod.dinner:
        return const Color(0xFF2196F3);
      case MealPeriod.snack:
        return const Color(0xFF9C27B0);
    }
  }

  IconData _getTimePeriodIcon(MealPeriod period) {
    switch (period) {
      case MealPeriod.breakfast:
        return Icons.wb_sunny;
      case MealPeriod.lunch:
        return Icons.lunch_dining;
      case MealPeriod.dinner:
        return Icons.dinner_dining;
      case MealPeriod.snack:
        return Icons.cookie;
    }
  }

  String _getTimePeriodName(MealPeriod period) {
    switch (period) {
      case MealPeriod.breakfast:
        return 'Breakfast';
      case MealPeriod.lunch:
        return 'Lunch';
      case MealPeriod.dinner:
        return 'Dinner';
      case MealPeriod.snack:
        return 'Snack';
    }
  }

  

  Widget _buildCompactMealCard(MealPlan plan, Color categoryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Get.theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (plan.id != null && plan.id!.isNotEmpty) {
              controller.getMealPlanDetails(plan.id!);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              // Meal Image or Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
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
                        _getFoodTypeIcon(plan.foodType),
                        color: categoryColor,
                        size: 20,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              
              // Meal Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.medium(
                      plan.name,
                      color: Get.theme.colorScheme.onSurface,
                      size: 14,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    AppText.caption(
                      plan.description,
                      color: Get.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Actions Menu
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                iconSize: 18,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                color: Get.theme.colorScheme.surface,
                onSelected: (value) {
                  if (value == 'view') {
                    if (plan.id != null && plan.id!.isNotEmpty) {
                      controller.getMealPlanDetails(plan.id!);
                    }
                  } else if (value == 'edit') {
                    controller.prepareEditAssignmentForm(plan);
                    Get.dialog<void>(const MealPlanFormDialog(isEdit: true));
                  } else if (value == 'delete') {
                    _showDeleteDialog(Get.context!, plan);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_rounded, size: 16, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text('View Details', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text('Edit Meal', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_rounded, size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        const Text('Delete Meal', style: TextStyle(fontSize: 14, color: Colors.red)),
                      ],
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

  IconData _getFoodTypeIcon(FoodType? foodType) {
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



  void _showDeleteDialog(BuildContext context, MealPlan plan) {
    Get.dialog<void>(
      AlertDialog(
        title: const Text('Delete Meal'),
        content: Text('Are you sure you want to delete "${plan.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (plan.id != null && plan.id!.isNotEmpty) {
                Get.back<void>();
                await controller.deleteMealPlan(plan.id!);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }


}