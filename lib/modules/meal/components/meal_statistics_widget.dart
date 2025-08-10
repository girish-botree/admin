import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text.dart';
import '../meal_controller.dart';

class MealStatisticsWidget extends GetView<MealController> {
  const MealStatisticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const _StatisticsLoadingWidget();
      }

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: context.theme.colorScheme.surfaceContainerLowest,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: context.theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  AppText.h5(
                    'Meal Statistics',
                    color: context.theme.colorScheme.onSurface,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Quick Stats Row
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Recipes',
                      value: controller.recipes.length.toString(),
                      icon: Icons.restaurant_menu,
                      color: AppColor.chartColors[0],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'Total Ingredients',
                      value: controller.ingredients.length.toString(),
                      icon: Icons.eco,
                      color: AppColor.chartColors[2],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Cuisine Distribution
              _CuisineDistribution(recipes: controller.recipes),
              const SizedBox(height: 16),

              // Nutritional Overview
              _NutritionalOverview(ingredients: controller.ingredients),
              const SizedBox(height: 16),

              // Category Distribution
              _CategoryDistribution(ingredients: controller.ingredients),
            ],
          ),
        ),
      );
    });
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
      padding: const EdgeInsets.all(16),
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
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: AppText.regular(
                  title,
                  color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppText.h4(
            value,
            color: color,
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
      padding: const EdgeInsets.all(12),
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
            size: 11,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AppText.semiBold(
                value,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 2),
              AppText.regular(
                unit,
                color: color,
                size: 10,
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: context.theme.colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.onSurface.withValues(alpha: 
                          0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.onSurface.withValues(alpha: 
                          0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.theme.colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}