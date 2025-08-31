import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text.dart';
import '../../../utils/responsive.dart';
import '../plan_controller.dart';
import '../meal_plan_assignment_model.dart';

class PlanStatisticsWidget extends GetView<PlanController> {
  const PlanStatisticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const _StatisticsLoadingWidget();
      }

      final selectedDateCount = _getSelectedDatePlanCount();

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
                    Icons.analytics_outlined,
                    color: context.theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  AppText.semiBold(
                    'Meal Plan Statistics',
                    color: context.theme.colorScheme.onSurface,
                    size: Responsive.getSubtitleTextSize(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Quick Stats Row
              _StatCard(
                title: "Selected Date's Plans",
                value: selectedDateCount.toString(),
                icon: Icons.today,
                color: AppColor.chartColors[1],
              ),
              const SizedBox(height: 16),

              // Meal Period Distribution
              _MealPeriodDistribution(
                assignments: controller.mealPlanAssignments,
              ),
              const SizedBox(height: 16),

              // Category & BMI Distribution
              Row(
                children: [
                  Expanded(
                    child: _CategoryDistribution(
                      assignments: controller.mealPlanAssignments,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _BmiCategoryDistribution(
                      assignments: controller.mealPlanAssignments,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  int _getSelectedDatePlanCount() {
    final selectedDate = controller.selectedCalendarDate.value;
    final normalizedSelected = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day);

    return controller.mealPlanAssignments.where((assignment) {
      final assignmentDate = DateTime(
          assignment.mealDate.year,
          assignment.mealDate.month,
          assignment.mealDate.day
      );
      return assignmentDate == normalizedSelected;
    }).length;
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
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.regular(
                  title,
                  color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  size: Responsive.getCaptionTextSize(context),
                ),
                const SizedBox(height: 2),
                AppText.semiBold(
                  value,
                  color: context.theme.colorScheme.onSurface,
                  size: Responsive.getTitleTextSize(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MealPeriodDistribution extends StatelessWidget {
  final List<MealPlanAssignment> assignments;

  const _MealPeriodDistribution({required this.assignments});

  @override
  Widget build(BuildContext context) {
    final periodStats = _getPeriodStats();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.semiBold(
          'Meal Period Distribution',
          color: context.theme.colorScheme.onSurface,
          size: Responsive.getBodyTextSize(context),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PeriodCard(
                period: 'Breakfast',
                count: periodStats['breakfast'] ?? 0,
                icon: Icons.wb_sunny,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _PeriodCard(
                period: 'Lunch',
                count: periodStats['lunch'] ?? 0,
                icon: Icons.lunch_dining,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _PeriodCard(
                period: 'Dinner',
                count: periodStats['dinner'] ?? 0,
                icon: Icons.dinner_dining,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Map<String, int> _getPeriodStats() {
    final stats = <String, int>{
      'breakfast': 0,
      'lunch': 0,
      'dinner': 0,
    };

    for (final assignment in assignments) {
      switch (assignment.period) {
        case MealPeriod.breakfast:
          stats['breakfast'] = stats['breakfast']! + 1;
          break;
        case MealPeriod.lunch:
          stats['lunch'] = stats['lunch']! + 1;
          break;
        case MealPeriod.dinner:
          stats['dinner'] = stats['dinner']! + 1;
          break;
        case MealPeriod.snack:
        // Can add snack handling if needed
          break;
      }
    }

    return stats;
  }
}

class _PeriodCard extends StatelessWidget {
  final String period;
  final int count;
  final IconData icon;
  final Color color;

  const _PeriodCard({
    required this.period,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          AppText.semiBold(
            count.toString(),
            color: color,
            size: Responsive.getSubtitleTextSize(context),
          ),
          const SizedBox(height: 2),
          AppText.regular(
            period,
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
            size: Responsive.getCaptionTextSize(context),
          ),
        ],
      ),
    );
  }
}

class _CategoryDistribution extends StatelessWidget {
  final List<MealPlanAssignment> assignments;

  const _CategoryDistribution({required this.assignments});

  @override
  Widget build(BuildContext context) {
    final categoryStats = _getCategoryStats();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.semiBold(
          'Meal Categories',
          color: context.theme.colorScheme.onSurface,
          size: Responsive.getBodyTextSize(context),
        ),
        const SizedBox(height: 12),
        if (categoryStats.isEmpty)
          AppText.regular(
            'No category data',
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
            size: Responsive.getCaptionTextSize(context),
          )
        else
          ...categoryStats.entries.map((entry) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(entry.key),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText.regular(
                        _formatCategoryName(entry.key),
                        color: context.theme.colorScheme.onSurface,
                        size: Responsive.getCaptionTextSize(context),
                      ),
                    ),
                    AppText.semiBold(
                      '${entry.value}',
                      color: context.theme.colorScheme.onSurface,
                      size: Responsive.getCaptionTextSize(context),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  Map<MealCategory, int> _getCategoryStats() {
    final stats = <MealCategory, int>{};
    for (final assignment in assignments) {
      stats[assignment.category] = (stats[assignment.category] ?? 0) + 1;
    }
    return stats;
  }

  Color _getCategoryColor(MealCategory category) {
    switch (category) {
      case MealCategory.vegan:
        return Colors.green;
      case MealCategory.vegetarian:
        return Colors.lightGreen;
      case MealCategory.eggitarian:
        return Colors.orange;
      case MealCategory.nonVegetarian:
        return Colors.red;
      case MealCategory.other:
        return Colors.grey;
    }
  }

  String _formatCategoryName(MealCategory category) {
    switch (category) {
      case MealCategory.vegan:
        return 'Vegan';
      case MealCategory.vegetarian:
        return 'Vegetarian';
      case MealCategory.eggitarian:
        return 'Eggitarian';
      case MealCategory.nonVegetarian:
        return 'Non-Veg';
      case MealCategory.other:
        return 'Other';
    }
  }
}

class _BmiCategoryDistribution extends StatelessWidget {
  final List<MealPlanAssignment> assignments;

  const _BmiCategoryDistribution({required this.assignments});

  @override
  Widget build(BuildContext context) {
    final bmiStats = _getBmiStats();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.semiBold(
          'BMI Categories',
          color: context.theme.colorScheme.onSurface,
          size: Responsive.getBodyTextSize(context),
        ),
        const SizedBox(height: 12),
        if (bmiStats.isEmpty)
          AppText.regular(
            'No BMI data',
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
            size: Responsive.getCaptionTextSize(context),
          )
        else
          ...bmiStats.entries.map((entry) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _getBmiCategoryColor(entry.key),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText.regular(
                        _formatBmiCategoryName(entry.key),
                        color: context.theme.colorScheme.onSurface,
                        size: Responsive.getCaptionTextSize(context),
                      ),
                    ),
                    AppText.semiBold(
                      '${entry.value}',
                      color: context.theme.colorScheme.onSurface,
                      size: Responsive.getCaptionTextSize(context),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  Map<BmiCategory, int> _getBmiStats() {
    final stats = <BmiCategory, int>{};
    for (final assignment in assignments) {
      stats[assignment.bmiCategory] = (stats[assignment.bmiCategory] ?? 0) + 1;
    }
    return stats;
  }

  Color _getBmiCategoryColor(BmiCategory category) {
    switch (category) {
      case BmiCategory.underweight:
        return Colors.blue;
      case BmiCategory.normal:
        return Colors.green;
      case BmiCategory.overweight:
        return Colors.orange;
      case BmiCategory.obese:
        return Colors.red;
    }
  }

  String _formatBmiCategoryName(BmiCategory category) {
    switch (category) {
      case BmiCategory.underweight:
        return 'Underweight';
      case BmiCategory.normal:
        return 'Normal';
      case BmiCategory.overweight:
        return 'Overweight';
      case BmiCategory.obese:
        return 'Obese';
    }
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
                  width: 140,
                  height: 16,
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.onSurface.withValues(
                          alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.onSurface.withValues(
                          alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}