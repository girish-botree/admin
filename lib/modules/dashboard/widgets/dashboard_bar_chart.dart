import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../../config/app_text.dart';
import '../../../design_system/app_spacing.dart';
import '../models/dashboard_stats.dart';

class DashboardBarChart extends StatefulWidget {
  final DashboardStats stats;

  const DashboardBarChart({
    super.key,
    required this.stats,
  });

  @override
  State<DashboardBarChart> createState() => _DashboardBarChartState();
}

class _DashboardBarChartState extends State<DashboardBarChart>
    with TickerProviderStateMixin {
  int touchedIndex = -1;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_animation, _glowAnimation]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFf093fb).withValues(alpha: 
                    0.08 * _glowAnimation.value),
                blurRadius: 32,
                offset: const Offset(0, 16),
                spreadRadius: 4,
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
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  height: 280,
                  child: _buildBarChart(context),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFf093fb).withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.bar_chart_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        AppText.semiBold(
          'Statistics Overview',
          size: 20,
          color: context.theme.colorScheme.onSurface,
        ),
      ],
    );
  }

  Widget _buildBarChart(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: _buildBarGroups(context),
        titlesData: _buildTitlesData(context),
        borderData: FlBorderData(show: false),
        gridData: _buildGridData(context),
        backgroundColor: Colors.transparent,
        barTouchData: _buildBarTouchData(),
        maxY: _getMaxY() * 1.2,
        minY: 0,
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(BuildContext context) {
    final data = [
      _BarData(
        'Recipes',
        widget.stats.totalRecipes.toDouble(),
        const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        Icons.restaurant_menu_rounded,
      ),
      _BarData(
        'Ingredients',
        widget.stats.totalIngredients.toDouble(),
        const LinearGradient(
          colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        Icons.eco_rounded,
      ),
      _BarData(
        'Plans',
        widget.stats.totalMealPlans.toDouble(),
        const LinearGradient(
          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
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
      final animatedValue = item.value * _animation.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: animatedValue,
            gradient: item.gradient,
            width: isTouched ? 40 : 32,
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY() * 1.2,
              color: context.theme.colorScheme.surfaceContainerLowest,
            ),
            rodStackItems: isTouched ? [
              BarChartRodStackItem(
                0,
                animatedValue,
                item.gradient.colors.first,
                BorderSide(
                  color: context.theme.colorScheme.surface,
                  width: 2,
                ),
              ),
            ] : [],
          ),
        ],
        showingTooltipIndicators: isTouched ? [0] : [],
      );
    }).toList();
  }

  FlTitlesData _buildTitlesData(BuildContext context) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 70,
          getTitlesWidget: (value, meta) {
            final data = [
              _BarData('Recipes', 0, const LinearGradient(colors: []),
                  Icons.restaurant_menu_rounded),
              _BarData('Ingredients', 0, const LinearGradient(colors: []),
                  Icons.eco_rounded),
              _BarData('Plans', 0, const LinearGradient(colors: []),
                  Icons.calendar_today_rounded),
            ];

            if (value.toInt() >= 0 && value.toInt() < data.length) {
              final item = data[value.toInt()];
              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: SizedBox(
                  width: 60,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: touchedIndex == value.toInt()
                              ? const Color(0xFF667eea).withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                              AppBorderRadius.sm),
                        ),
                        child: Icon(
                          item.icon,
                          size: 16,
                          color: touchedIndex == value.toInt()
                              ? const Color(0xFF667eea)
                              : context.theme.colorScheme.onSurface.withValues(alpha: 
                              0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: AppText(
                          item.title,
                          size: 12,
                          color: touchedIndex == value.toInt()
                              ? context.theme.colorScheme.onSurface
                              : context.theme.colorScheme.onSurface.withValues(alpha: 
                              0.7),
                          fontWeight: touchedIndex == value.toInt()
                              ? FontWeight.w600
                              : FontWeight.w500,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          interval: _getInterval(),
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: AppText(
                value.toInt().toString(),
                size: 11,
                color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  FlGridData _buildGridData(BuildContext context) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: _getInterval(),
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: context.theme.colorScheme.surfaceContainerLowest.withValues(alpha: 
              0.5),
          strokeWidth: 1,
          dashArray: [4, 4],
        );
      },
    );
  }

  BarTouchData _buildBarTouchData() {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (group) => const Color(0xFF2D3748),
        tooltipRoundedRadius: 16,
        tooltipPadding: const EdgeInsets.all(AppSpacing.md),
        tooltipMargin: 8,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final data = [
            'Recipes',
            'Ingredients',
            'Meal Plans',
          ];

          if (group.x >= 0 && group.x < data.length) {
            return BarTooltipItem(
              '${data[group.x]}\n${rod.toY.toInt()} items',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.4,
              ),
            );
          }
          return null;
        },
      ),
      touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
        setState(() {
          if (!event.isInterestedForInteractions ||
              response == null ||
              response.spot == null) {
            touchedIndex = -1;
            return;
          }
          touchedIndex = response.spot!.touchedBarGroupIndex;
        });
      },
    );
  }

  double _getMaxY() {
    final values = [
      widget.stats.totalRecipes.toDouble(),
      widget.stats.totalIngredients.toDouble(),
      widget.stats.totalMealPlans.toDouble(),
    ];
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    return maxValue > 0 ? maxValue : 10;
  }

  double _getInterval() {
    final maxY = _getMaxY();
    if (maxY <= 10) return 2;
    if (maxY <= 50) return 10;
    if (maxY <= 100) return 20;
    return (maxY / 5).ceilToDouble();
  }
}

class _BarData {
  final String title;
  final double value;
  final LinearGradient gradient;
  final IconData icon;

  _BarData(this.title, this.value, this.gradient, this.icon);
}