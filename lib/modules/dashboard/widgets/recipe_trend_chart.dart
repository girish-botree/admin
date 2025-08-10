import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../../config/app_text.dart';
import '../../../design_system/app_spacing.dart';
import '../models/dashboard_stats.dart';

class RecipeTrendChart extends StatefulWidget {
  final DashboardStats stats;

  const RecipeTrendChart({
    super.key,
    required this.stats,
  });

  @override
  State<RecipeTrendChart> createState() => _RecipeTrendChartState();
}

class _RecipeTrendChartState extends State<RecipeTrendChart>
    with TickerProviderStateMixin {
  int touchedSpotIndex = -1;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_animation, _pulseAnimation]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4C51BF).withValues(
                    alpha: 0.12 * _pulseAnimation.value),
                blurRadius: 32,
                offset: const Offset(0, 16),
                spreadRadius: 2,
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
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  height: 300,
                  child: _buildLineChart(context),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildMetrics(context),
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4C51BF), Color(0xFF667eea)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4C51BF).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.trending_up_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.semiBold(
                'Recipe Trends',
                size: 20,
                color: context.theme.colorScheme.onSurface,
              ),
              AppText(
                'Weekly activity overview',
                size: 12,
                color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.7),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF10B981).withValues(alpha: 0.1),
                const Color(0xFF059669).withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              AppText(
                '+12% this week',
                size: 11,
                color: const Color(0xFF10B981),
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: _buildLineBars(),
        titlesData: _buildTitlesData(context),
        borderData: FlBorderData(show: false),
        gridData: _buildGridData(context),
        backgroundColor: Colors.transparent,
        lineTouchData: _buildLineTouchData(),
        minY: 0,
        maxY: _getMaxY() * 1.1,
        clipData: const FlClipData.all(),
      ),
    );
  }

  List<LineChartBarData> _buildLineBars() {
    final trendData = _generateTrendData();

    return [
      LineChartBarData(
        spots: trendData
            .asMap()
            .entries
            .map((entry) =>
            FlSpot(
              entry.key.toDouble(),
              entry.value * _animation.value,
            ))
            .toList(),
        gradient: const LinearGradient(
          colors: [Color(0xFF4C51BF), Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: touchedSpotIndex == index ? 6 : 4,
              color: Colors.white,
              strokeWidth: touchedSpotIndex == index ? 3 : 2,
              strokeColor: const Color(0xFF4C51BF),
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4C51BF).withValues(alpha: 0.1),
              const Color(0xFF667eea).withValues(alpha: 0.05),
              Colors.transparent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        shadow: Shadow(
          color: const Color(0xFF4C51BF).withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ),
    ];
  }

  List<double> _generateTrendData() {
    // Generate sample trend data based on current stats
    final base = widget.stats.totalRecipes.toDouble();
    return [
      base * 0.6,
      base * 0.8,
      base * 0.7,
      base * 0.9,
      base * 1.0,
      base * 1.2,
      base * 1.1,
    ];
  }

  FlTitlesData _buildTitlesData(BuildContext context) {
    const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < weekDays.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: AppText(
                  weekDays[index],
                  size: 11,
                  color: touchedSpotIndex == index
                      ? context.theme.colorScheme.onSurface
                      : context.theme.colorScheme.onSurface.withValues(
                      alpha: 0.6),
                  fontWeight: touchedSpotIndex == index
                      ? FontWeight.w600
                      : FontWeight.w500,
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
              padding: const EdgeInsets.only(right: 8),
              child: AppText(
                value.toInt().toString(),
                size: 10,
                color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.6),
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
          color: context.theme.colorScheme.surfaceContainerLowest.withValues(
              alpha: 0.4),
          strokeWidth: 1,
          dashArray: [3, 3],
        );
      },
    );
  }

  LineTouchData _buildLineTouchData() {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (touchedSpot) => const Color(0xFF2D3748),
        tooltipRoundedRadius: 16,
        tooltipPadding: const EdgeInsets.all(12),
        tooltipMargin: 8,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            const weekDays = [
              'Monday',
              'Tuesday',
              'Wednesday',
              'Thursday',
              'Friday',
              'Saturday',
              'Sunday'
            ];
            final dayName = spot.x.toInt() < weekDays.length ? weekDays[spot.x
                .toInt()] : '';

            return LineTooltipItem(
              '$dayName\n${spot.y.toInt()} recipes',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.4,
              ),
            );
          }).toList();
        },
      ),
      touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
        setState(() {
          if (!event.isInterestedForInteractions ||
              response == null ||
              response.lineBarSpots == null ||
              response.lineBarSpots!.isEmpty) {
            touchedSpotIndex = -1;
            return;
          }
          touchedSpotIndex = response.lineBarSpots!.first.spotIndex;
        });
      },
    );
  }

  Widget _buildMetrics(BuildContext context) {
    final metrics = [
      _MetricData(
          'Peak Day', 'Friday', Icons.calendar_today, const Color(0xFF10B981)),
      _MetricData(
          'Avg/Day', '${(widget.stats.totalRecipes / 7).toStringAsFixed(1)}',
          Icons.bar_chart, const Color(0xFF4C51BF)),
      _MetricData('Growth', '+12%', Icons.trending_up, const Color(0xFFEF4444)),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(
          color: context.theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: metrics
            .asMap()
            .entries
            .map((entry) {
          final metric = entry.value;
          return Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: metric.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    metric.icon,
                    size: 16,
                    color: metric.color,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText.semiBold(
                      metric.value,
                      size: 14,
                      color: context.theme.colorScheme.onSurface,
                    ),
                    AppText(
                      metric.title,
                      size: 10,
                      color: context.theme.colorScheme.onSurface.withValues(
                          alpha: 0.7),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  double _getMaxY() {
    final trendData = _generateTrendData();
    final maxValue = trendData.reduce((a, b) => a > b ? a : b);
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

class _MetricData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _MetricData(this.title, this.value, this.icon, this.color);
}