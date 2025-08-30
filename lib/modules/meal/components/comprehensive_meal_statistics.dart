import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text.dart';
import '../meal_controller.dart';
import '../../plan/plan_controller.dart';
import '../../plan/meal_plan_model.dart';
import '../../plan/meal_plan_assignment_model.dart';

class ComprehensiveMealStatistics extends StatelessWidget {
  const ComprehensiveMealStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    // Get both controllers
    final mealController = Get.find<MealController>();
    final planController = Get.put(PlanController());

    return Obx(() {
      if (mealController.isLoading.value) {
        return const _StatisticsLoadingWidget();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's Plan Section
          _buildTodaysPlan(context, planController),
          const SizedBox(height: 20),

          // Weekly Overview
          _buildWeeklyOverview(context, planController),
          const SizedBox(height: 20),

          // Quick Stats Cards
          _buildQuickStats(context, mealController, planController),
          const SizedBox(height: 20),

          // Detailed Statistics
          _buildDetailedStatistics(context, mealController),
        ],
      );
    });
  }

  Widget _buildTodaysPlan(BuildContext context, PlanController planController) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: context.theme.colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.today,
                  color: context.theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                AppText.semiBold(
                  'Today\'s Meal Plan',
                  color: context.theme.colorScheme.onSurface,
                  size: 16,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Get.toNamed<void>('/plan'),
                  child: AppText.medium(
                    'View All',
                    color: context.theme.colorScheme.primary,
                    size: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() => _buildTodaysMeals(context, planController)),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysMeals(BuildContext context,
      PlanController planController) {
    final breakfastPlans = planController.getMealPlansForPeriod(
        MealPeriod.breakfast);
    final lunchPlans = planController.getMealPlansForPeriod(MealPeriod.lunch);
    final dinnerPlans = planController.getMealPlansForPeriod(MealPeriod.dinner);

    if (breakfastPlans.isEmpty && lunchPlans.isEmpty && dinnerPlans.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
            const SizedBox(width: 8),
            AppText.regular(
              'No meals planned for today',
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 14,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (breakfastPlans.isNotEmpty) _buildMealPeriodSection(
            context, 'Breakfast', breakfastPlans, Icons.wb_sunny),
        if (lunchPlans.isNotEmpty) _buildMealPeriodSection(
            context, 'Lunch', lunchPlans, Icons.lunch_dining),
        if (dinnerPlans.isNotEmpty) _buildMealPeriodSection(
            context, 'Dinner', dinnerPlans, Icons.dinner_dining),
      ],
    );
  }

  Widget _buildMealPeriodSection(BuildContext context, String period,
      List<MealPlan> plans, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: context.theme.colorScheme.primary),
              const SizedBox(width: 6),
              AppText.semiBold(
                period,
                color: context.theme.colorScheme.onSurface,
                size: 14,
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...plans.map((plan) =>
              Padding(
                padding: const EdgeInsets.only(left: 22, bottom: 4),
                child: AppText.regular(
                  plan.name,
                  color: context.theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  size: 13,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildWeeklyOverview(BuildContext context,
      PlanController planController) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: context.theme.colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_view_week,
                  color: context.theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                AppText.semiBold(
                  'Weekly Planning Overview',
                  color: context.theme.colorScheme.onSurface,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => _buildWeeklyData(context, planController)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyData(BuildContext context, PlanController planController) {
    final weeklyData = _getWeeklyData(planController);

    if (weeklyData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
            const SizedBox(width: 8),
            AppText.regular(
              'No meal plans for this week',
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 14,
            ),
          ],
        ),
      );
    }

    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weeklyData.length,
        itemBuilder: (context, index) {
          final entry = weeklyData.entries.elementAt(index);
          final isToday = _isToday(entry.key);

          return Container(
            width: 70,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isToday
                  ? context.theme.colorScheme.primary.withValues(alpha: 0.1)
                  : context.theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
              border: isToday
                  ? Border.all(
                  color: context.theme.colorScheme.primary, width: 2)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText.semiBold(
                  _getDayName(entry.key),
                  color: isToday
                      ? context.theme.colorScheme.primary
                      : context.theme.colorScheme.onSurface,
                  size: 12,
                ),
                const SizedBox(height: 4),
                AppText.h4(
                  '${entry.value}',
                  color: isToday
                      ? context.theme.colorScheme.primary
                      : context.theme.colorScheme.onSurface,
                ),
                const SizedBox(height: 2),
                AppText.regular(
                  'meals',
                  color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 10,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, MealController mealController,
      PlanController planController) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total Recipes',
            value: mealController.recipes.length.toString(),
            icon: Icons.restaurant_menu,
            color: AppColor.chartColors[0],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Ingredients',
            value: mealController.ingredients.length.toString(),
            icon: Icons.eco,
            color: AppColor.chartColors[1],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() =>
              _StatCard(
                title: 'Today\'s Meals',
                value: _getTodaysMealCount(planController).toString(),
                icon: Icons.today,
                color: AppColor.chartColors[2],
              )),
        ),
      ],
    );
  }

  Widget _buildDetailedStatistics(BuildContext context,
      MealController mealController) {
    return Column(
      children: [
        // Cuisine Distribution
        _CuisineDistribution(recipes: mealController.recipes),
        const SizedBox(height: 16),

        // Nutritional Overview
        _NutritionalOverview(ingredients: mealController.ingredients),
        const SizedBox(height: 16),

        // Category Distribution
        _CategoryDistribution(ingredients: mealController.ingredients),
      ],
    );
  }

  Map<DateTime, int> _getWeeklyData(PlanController planController) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weeklyData = <DateTime, int>{};

    // Initialize week with 0 meals
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      weeklyData[DateTime(day.year, day.month, day.day)] = 0;
    }

    // Count meal assignments for the week
    for (final assignment in planController.mealPlanAssignments) {
      final assignmentDate = DateTime(
        assignment.mealDate.year,
        assignment.mealDate.month,
        assignment.mealDate.day,
      );

      if (weeklyData.containsKey(assignmentDate)) {
        weeklyData[assignmentDate] = weeklyData[assignmentDate]! + 1;
      }
    }

    return weeklyData;
  }

  int _getTodaysMealCount(PlanController planController) {
    final today = DateTime.now();
    return planController.mealPlanAssignments.where((assignment) {
      return assignment.mealDate.year == today.year &&
          assignment.mealDate.month == today.month &&
          assignment.mealDate.day == today.day;
    }).length;
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.day == today.day &&
        date.month == today.month &&
        date.year == today.year;
  }

  String _getDayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: AppText.regular(
                  title,
                  color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          AppText.semiBold(
            value,
            color: color,
            size: 16,
          ),
        ],
      ),
    );
  }
}

class _CuisineDistribution extends StatelessWidget {
  final List<dynamic> recipes;

  const _CuisineDistribution({required this.recipes});

  @override
  Widget build(BuildContext context) {
    final cuisineStats = _getCuisineStats();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.semiBold(
            'Cuisine Distribution',
            color: context.theme.colorScheme.onSurface,
            size: 14,
          ),
          const SizedBox(height: 12),
          if (cuisineStats.isEmpty)
            AppText.regular(
              'No cuisine data available',
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 12,
            )
          else
            ...cuisineStats.entries.take(5).map((entry) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColor.chartColors[cuisineStats.keys
                              .toList()
                              .indexOf(entry.key) %
                              AppColor.chartColors.length],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppText.regular(
                          entry.key.isEmpty ? 'Other' : entry.key,
                          color: context.theme.colorScheme.onSurface,
                          size: 12,
                        ),
                      ),
                      AppText.semiBold(
                        '${entry.value}',
                        color: context.theme.colorScheme.onSurface,
                        size: 12,
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Map<String, int> _getCuisineStats() {
    final stats = <String, int>{};
    for (final recipe in recipes) {
      final cuisine = (recipe['cuisine'] as String?) ?? 'Other';
      stats[cuisine] = (stats[cuisine] ?? 0) + 1;
    }
    return Map.fromEntries(stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)));
  }
}

class _NutritionalOverview extends StatelessWidget {
  final List<dynamic> ingredients;

  const _NutritionalOverview({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    final nutritionStats = _getNutritionStats();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.semiBold(
            'Nutritional Overview (Average per Ingredient)',
            color: context.theme.colorScheme.onSurface,
            size: 14,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _NutrientCard(
                  label: 'Calories',
                  value: nutritionStats['avgCalories']?.toStringAsFixed(0) ??
                      '0',
                  unit: 'kcal',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NutrientCard(
                  label: 'Protein',
                  value: nutritionStats['avgProtein']?.toStringAsFixed(1) ??
                      '0',
                  unit: 'g',
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _NutrientCard(
                  label: 'Carbs',
                  value: nutritionStats['avgCarbs']?.toStringAsFixed(1) ?? '0',
                  unit: 'g',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NutrientCard(
                  label: 'Fat',
                  value: nutritionStats['avgFat']?.toStringAsFixed(1) ?? '0',
                  unit: 'g',
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, double> _getNutritionStats() {
    if (ingredients.isEmpty) return {};

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final ingredient in ingredients) {
      totalCalories += (ingredient['calories'] as num?)?.toDouble() ?? 0;
      totalProtein += (ingredient['protein'] as num?)?.toDouble() ?? 0;
      totalCarbs += (ingredient['carbohydrates'] as num?)?.toDouble() ?? 0;
      totalFat += (ingredient['fat'] as num?)?.toDouble() ?? 0;
    }

    final count = ingredients.length;
    return {
      'avgCalories': totalCalories / count,
      'avgProtein': totalProtein / count,
      'avgCarbs': totalCarbs / count,
      'avgFat': totalFat / count,
    };
  }
}

class _NutrientCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _NutrientCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          AppText.regular(
            label,
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
            size: 10,
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AppText.semiBold(
                value,
                color: color,
                size: 14,
              ),
              const SizedBox(width: 2),
              AppText.regular(
                unit,
                color: color,
                size: 9,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryDistribution extends StatelessWidget {
  final List<dynamic> ingredients;

  const _CategoryDistribution({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    final categoryStats = _getCategoryStats();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.semiBold(
            'Ingredient Categories',
            color: context.theme.colorScheme.onSurface,
            size: 14,
          ),
          const SizedBox(height: 12),
          if (categoryStats.isEmpty)
            AppText.regular(
              'No category data available',
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 12,
            )
          else
            ...categoryStats.entries.take(4).map((entry) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColor.chartColors[categoryStats.keys
                              .toList().indexOf(entry.key) %
                              AppColor.chartColors.length],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppText.regular(
                          entry.key.isEmpty ? 'Other' : entry.key,
                          color: context.theme.colorScheme.onSurface,
                          size: 12,
                        ),
                      ),
                      AppText.semiBold(
                        '${entry.value}',
                        color: context.theme.colorScheme.onSurface,
                        size: 12,
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Map<String, int> _getCategoryStats() {
    final stats = <String, int>{};
    for (final ingredient in ingredients) {
      final category = (ingredient['category'] as String?) ?? 'Other';
      stats[category] = (stats[category] ?? 0) + 1;
    }
    return Map.fromEntries(stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)));
  }
}

class _StatisticsLoadingWidget extends StatelessWidget {
  const _StatisticsLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Loading cards
        Row(
          children: [
            Expanded(child: _loadingCard(context)),
            const SizedBox(width: 12),
            Expanded(child: _loadingCard(context)),
            const SizedBox(width: 12),
            Expanded(child: _loadingCard(context)),
          ],
        ),
        const SizedBox(height: 20),
        _loadingCard(context, height: 150),
        const SizedBox(height: 20),
        _loadingCard(context, height: 200),
      ],
    );
  }

  Widget _loadingCard(BuildContext context, {double? height}) {
    return Container(
      height: height ?? 80,
      decoration: BoxDecoration(
        color: context.theme.colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}