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

      return Column(
        children: [
          // Main stats grid
          _buildStatsGrid(context),
          const SizedBox(height: 24),

          // Distribution cards
          _buildDistributionCards(context),
        ],
      );
    });
  }

  Widget _buildStatsGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : (screenWidth < 900 ? 3 : 4);
    final childAspectRatio = screenWidth < 600 ? 1.2 : 1.4;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount.clamp(2, 2),
      // Keep it as 2 for better layout
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _ModernStatCard(
          title: 'Recipes',
          value: controller.recipes.length.toString(),
          icon: Icons.restaurant_menu_outlined,
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        _ModernStatCard(
          title: 'Ingredients',
          value: controller.ingredients.length.toString(),
          icon: Icons.eco_outlined,
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ],
    );
  }

  Widget _buildDistributionCards(BuildContext context) {
    return Column(
      children: [
        _ModernDistributionCard(
          title: 'Cuisine Types',
          icon: Icons.public_outlined,
          child: _CuisineDistribution(recipes: controller.recipes),
        ),
        const SizedBox(height: 16),
        _ModernDistributionCard(
          title: 'Nutrition Overview',
          icon: Icons.analytics_outlined,
          child: _NutritionalOverview(ingredients: controller.ingredients),
        ),
      ],
    );
  }
}

class _ModernStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const _ModernStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: AppText(
                    value,
                    color: Colors.white,
                    size: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                AppText(
                  title,
                  color: Colors.white.withOpacity(0.9),
                  size: 12,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernDistributionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _ModernDistributionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.theme.shadowColor.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: context.theme.colorScheme.outline.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: context.theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppText(
                    title,
                    color: context.theme.colorScheme.onSurface,
                    size: 18,
                    fontWeight: FontWeight.w600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
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

    if (cuisineStats.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: cuisineStats.entries.take(4).map((entry) {
        final index = cuisineStats.keys.toList().indexOf(entry.key);
        final percentage = recipes.isNotEmpty ? (entry.value / recipes.length *
            100).round() : 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getGradientColors(index),
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        entry.key.isEmpty ? 'Other' : entry.key,
                        color: context.theme.colorScheme.onSurface,
                        size: 14,
                        fontWeight: FontWeight.w500,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        '$percentage% of recipes',
                        color: context.theme.colorScheme.onSurface.withOpacity(
                            0.6),
                        size: 11,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppText(
                    '${entry.value}',
                    color: context.theme.colorScheme.primary,
                    size: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: 48,
            color: context.theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          AppText(
            'No cuisine data available',
            color: context.theme.colorScheme.onSurface.withOpacity(0.6),
            size: 14,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors(int index) {
    const gradients = [
      [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      [Color(0xFF10B981), Color(0xFF059669)],
      [Color(0xFFF59E0B), Color(0xFFEF4444)],
      [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    ];
    return gradients[index % gradients.length];
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

    if (nutritionStats.isEmpty) {
      return _buildEmptyState(context);
    }

    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final crossAxisCount = screenWidth < 400
        ? 2
        : 2; // Keep 2 columns for better readability
    final childAspectRatio = screenWidth < 400 ? 1.6 : 1.8;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _NutrientCard(
          label: 'Calories',
          value: nutritionStats['avgCalories']?.toStringAsFixed(0) ?? '0',
          unit: 'kcal',
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
          ),
        ),
        _NutrientCard(
          label: 'Protein',
          value: nutritionStats['avgProtein']?.toStringAsFixed(1) ?? '0',
          unit: 'g',
          gradient: const LinearGradient(
            colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          ),
        ),
        _NutrientCard(
          label: 'Carbs',
          value: nutritionStats['avgCarbs']?.toStringAsFixed(1) ?? '0',
          unit: 'g',
          gradient: const LinearGradient(
            colors: [Color(0xFF45B7D1), Color(0xFF2196F3)],
          ),
        ),
        _NutrientCard(
          label: 'Fat',
          value: nutritionStats['avgFat']?.toStringAsFixed(1) ?? '0',
          unit: 'g',
          gradient: const LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFFF9800)],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 48,
            color: context.theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          AppText(
            'No nutrition data available',
            color: context.theme.colorScheme.onSurface.withOpacity(0.6),
            size: 14,
            textAlign: TextAlign.center,
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
  final Gradient gradient;

  const _NutrientCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              label,
              color: Colors.white.withOpacity(0.9),
              size: 11,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: AppText(
                      value,
                      color: Colors.white,
                      size: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                AppText(
                  unit,
                  color: Colors.white.withOpacity(0.8),
                  size: 10,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatisticsLoadingWidget extends StatelessWidget {
  const _StatisticsLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Loading skeleton for stats grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: List.generate(2, (index) => _buildLoadingSkeleton(context)),
        ),
        const SizedBox(height: 24),

        // Loading skeleton for distribution cards
        ...[1, 2].map((index) =>
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 180,
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: context.theme.colorScheme.outline.withOpacity(0.08),
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )),
      ],
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.theme.colorScheme.outline.withOpacity(0.08),
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}