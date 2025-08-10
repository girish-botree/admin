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

      // Debug information
      print('PlanStatisticsWidget - Total assignments: ${controller
          .mealPlanAssignments.length}');
      print('PlanStatisticsWidget - Total meal plans: ${controller.mealPlans
          .length}');

      final selectedDateCount = _getSelectedDatePlanCount();
      print(
          'PlanStatisticsWidget - Selected date plan count: $selectedDateCount');

      // Debug: Print selected date and assignment details
      print('PlanStatisticsWidget - Selected date: ${controller
          .selectedCalendarDate.value}');
      print('PlanStatisticsWidget - Assignment dates:');
      for (var assignment in controller.mealPlanAssignments) {
        print('  - Assignment ID: ${assignment.id}, Date: ${assignment
            .mealDate}, Period: ${assignment.period}');
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
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Plans',
                      value: controller.mealPlans.length.toString(),
                      icon: Icons.restaurant,
                      color: AppColor.chartColors[0],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: "Selected Date's Plans",
                      value: selectedDateCount.toString(),
                      icon: Icons.today,
                      color: AppColor.chartColors[1],
                    ),
                  ),
                ],
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
              const SizedBox(height: 16),

              // Weekly Planning Overview
              _WeeklyPlanningOverview(
                assignments: controller.mealPlanAssignments,
                selectedDate: controller.selectedCalendarDate.value,
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
                  size: Responsive.getCaptionTextSize(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppText.semiBold(
            value,
            color: color,
            size: Responsive.getTitleTextSize(context),
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
              const SizedBox(width: 8),
              Expanded(
                child: _PeriodCard(
                  period: 'Lunch',
                  count: periodStats['lunch'] ?? 0,
                  icon: Icons.lunch_dining,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
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
      ),
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
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
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
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(entry.key),
                          borderRadius: BorderRadius.circular(2),
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
      ),
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
      case MealCategory.nonVegetarian:
        return Colors.red;
    }
  }

  String _formatCategoryName(MealCategory category) {
    switch (category) {
      case MealCategory.vegan:
        return 'Vegan';
      case MealCategory.vegetarian:
        return 'Vegetarian';
      case MealCategory.nonVegetarian:
        return 'Non-Veg';
    }
  }
}

class _BmiCategoryDistribution extends StatelessWidget {
  final List<MealPlanAssignment> assignments;

  const _BmiCategoryDistribution({required this.assignments});

  @override
  Widget build(BuildContext context) {
    final bmiStats = _getBmiStats();

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
      ),
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

class _WeeklyPlanningOverview extends StatelessWidget {
  final List<MealPlanAssignment> assignments;
  final DateTime selectedDate;

  const _WeeklyPlanningOverview({
    required this.assignments,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final weeklyData = _getWeeklyData();

    // Debug information
    print('WeeklyPlanningOverview - Selected date: $selectedDate');
    print('WeeklyPlanningOverview - Total assignments: ${assignments.length}');
    print('WeeklyPlanningOverview - Weekly data: $weeklyData');

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
            'Weekly Planning Overview',
            color: context.theme.colorScheme.onSurface,
            size: Responsive.getBodyTextSize(context),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weeklyData.entries.map((entry) {
              final isToday = _isToday(entry.key);
              final isSelected = _isSameDay(entry.key, selectedDate);

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.theme.colorScheme.primary.withValues(alpha: 0.2)
                        : isToday
                        ? context.theme.colorScheme.secondary.withValues(alpha: 0.1)
                        : context.theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(6),
                    border: isSelected
                        ? Border.all(color: context.theme.colorScheme.primary)
                        : null,
                  ),
                  child: Column(
                    children: [
                      AppText.regular(
                        _getDayName(entry.key),
                        color: context.theme.colorScheme.onSurface.withValues(alpha: 
                            0.7),
                        size: Responsive.getCaptionTextSize(context),
                      ),
                      const SizedBox(height: 4),
                      AppText.semiBold(
                        entry.value.toString(),
                        color: isSelected
                            ? context.theme.colorScheme.primary
                            : context.theme.colorScheme.onSurface,
                        size: Responsive.getBodyTextSize(context),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Center(
            child: AppText.regular(
              'Meals planned per day this week',
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: Responsive.getCaptionTextSize(context),
            ),
          ),
        ],
      ),
    );
  }

  Map<DateTime, int> _getWeeklyData() {
    final startOfWeek = selectedDate.subtract(
        Duration(days: selectedDate.weekday - 1));
    final weeklyData = <DateTime, int>{};

    // Initialize all days of the week with 0 (normalized dates without time)
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final normalizedDay = DateTime(day.year, day.month, day.day);
      weeklyData[normalizedDay] = 0;
    }

    // Count assignments for each day
    for (final assignment in assignments) {
      final assignmentDate = DateTime(
        assignment.mealDate.year,
        assignment.mealDate.month,
        assignment.mealDate.day,
      );

      // Check if this assignment date falls within our week
      if (weeklyData.containsKey(assignmentDate)) {
        weeklyData[assignmentDate] = weeklyData[assignmentDate]! + 1;
      }
    }

    return weeklyData;
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.day == today.day &&
        date.month == today.month &&
        date.year == today.year;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.day == date2.day &&
        date1.month == date2.month &&
        date1.year == date2.year;
  }

  String _getDayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
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
              height: 100,
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