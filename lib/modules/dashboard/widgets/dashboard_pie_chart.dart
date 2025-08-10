import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../../config/app_text.dart';
import '../../../design_system/app_spacing.dart';
import '../models/dashboard_stats.dart';

class DashboardPieChart extends StatefulWidget {
  final DashboardStats stats;

  const DashboardPieChart({
    super.key,
    required this.stats,
  });

  @override
  State<DashboardPieChart> createState() => _DashboardPieChartState();
}

class _DashboardPieChartState extends State<DashboardPieChart>
    with TickerProviderStateMixin {
  int touchedIndex = -1;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667eea).withValues(alpha: 0.1),
                blurRadius: 32,
                offset: const Offset(0, 16),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: context.theme.colorScheme.shadow.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl),
                  child: _buildHeader(context),
                ),
                const SizedBox(height: AppSpacing.lg),
                Flexible(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: _buildPieChart(),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl),
                  child: _buildLegend(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667eea).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.pie_chart_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppText.semiBold(
            'Data Distribution',
            size: 20,
            color: context.theme.colorScheme.onSurface,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            border: Border.all(
              color: const Color(0xFF667eea).withValues(alpha: 0.1),
            ),
          ),
          child: AppText(
            'Interactive',
            size: 10,
            color: const Color(0xFF667eea),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: _buildSections(),
        centerSpaceRadius: 40,
        sectionsSpace: 2,
        startDegreeOffset: -90,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  response == null ||
                  response.touchedSection == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex = response.touchedSection!.touchedSectionIndex;
            });
          },
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final data = [
      _ChartData(
        'Recipes',
        widget.stats.totalRecipes.toDouble(),
        const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        Icons.restaurant_menu_rounded,
      ),
      _ChartData(
        'Ingredients',
        widget.stats.totalIngredients.toDouble(),
        const LinearGradient(
          colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        Icons.eco_rounded,
      ),
      _ChartData(
        'Plans',
        widget.stats.totalMealPlans.toDouble(),
        const LinearGradient(
          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        Icons.calendar_today_rounded,
      ),
    ];

    return data
        .asMap()
        .entries
        .map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = index == touchedIndex;
      final radius = isTouched ? 90.0 * _animation.value : 75.0 *
          _animation.value;

      return PieChartSectionData(
        value: item.value,
        title: isTouched ? '${item.value.toInt()}' : '',
        color: item.gradient.colors.first,
        radius: radius,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        titlePositionPercentageOffset: 0.6,
        badgeWidget: isTouched
            ? Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            item.icon,
            size: 16,
            color: item.gradient.colors.first,
          ),
        )
            : null,
        badgePositionPercentageOffset: 1.2,
      );
    }).toList();
  }

  Widget _buildLegend(BuildContext context) {
    final data = [
      _ChartData(
        'Recipes',
        widget.stats.totalRecipes.toDouble(),
        const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        Icons.restaurant_menu_rounded,
      ),
      _ChartData(
        'Ingredients',
        widget.stats.totalIngredients.toDouble(),
        const LinearGradient(
          colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
        ),
        Icons.eco_rounded,
      ),
      _ChartData(
        'Plans',
        widget.stats.totalMealPlans.toDouble(),
        const LinearGradient(
          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
        ),
        Icons.calendar_today_rounded,
      ),
    ];

    final total = widget.stats.totalRecipes +
        widget.stats.totalIngredients +
        widget.stats.totalMealPlans;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(
          color: context.theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: data
            .asMap()
            .entries
            .map((entry) {
          final index = entry.key;
          final item = entry.value;
          final percentage = total > 0 ? (item.value / total * 100) : 0;

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: touchedIndex == index
                    ? item.gradient.colors.first.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                    decoration: BoxDecoration(
                      gradient: item.gradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: item.gradient.colors.first.withValues(alpha: 0.3),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  AppText.semiBold(
                    '${item.value.toInt()}',
                    size: 16,
                    color: context.theme.colorScheme.onSurface,
                  ),
                  AppText(
                    item.title,
                    size: 10,
                    color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    textAlign: TextAlign.center,
                  ),
                  AppText(
                    '${percentage.toStringAsFixed(0)}%',
                    size: 9,
                    color: item.gradient.colors.first,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ChartData {
  final String title;
  final double value;
  final LinearGradient gradient;
  final IconData icon;

  _ChartData(this.title, this.value, this.gradient, this.icon);
}