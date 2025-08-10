import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../../config/app_text.dart';
import '../../../design_system/app_spacing.dart';
import '../models/dashboard_stats.dart';

class IngredientUsageRadar extends StatefulWidget {
  final DashboardStats stats;

  const IngredientUsageRadar({
    super.key,
    required this.stats,
  });

  @override
  State<IngredientUsageRadar> createState() => _IngredientUsageRadarState();
}

class _IngredientUsageRadarState extends State<IngredientUsageRadar>
    with TickerProviderStateMixin {
  int selectedIndex = -1;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _shimmerController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_animation, _shimmerAnimation]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF059669).withValues(
                    alpha: 0.1 * _shimmerAnimation.value),
                blurRadius: 40,
                offset: const Offset(0, 20),
                spreadRadius: 3,
              ),
              BoxShadow(
                color: context.theme.colorScheme.shadow.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  height: 350,
                  child: _buildRadarChart(context),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildLegendGrid(context),
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
              colors: [Color(0xFF059669), Color(0xFF10B981)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF059669).withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.radar_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.semiBold(
                'Ingredient Usage',
                size: 20,
                color: context.theme.colorScheme.onSurface,
              ),
              AppText(
                'Category distribution analysis',
                size: 12,
                color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.7),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF3B82F6).withValues(alpha: 0.1),
                const Color(0xFF1D4ED8).withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            border: Border.all(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              AppText(
                'Smart Analysis',
                size: 11,
                color: const Color(0xFF3B82F6),
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRadarChart(BuildContext context) {
    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        tickCount: 5,
        ticksTextStyle: TextStyle(
          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        radarBackgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        gridBorderData: BorderSide(
          color: context.theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        radarBorderData: BorderSide(
          color: context.theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 2,
        ),
        titleTextStyle: TextStyle(
          color: context.theme.colorScheme.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        titlePositionPercentageOffset: 0.15,
        dataSets: _buildRadarDataSets(),
        getTitle: (index, angle) => _getRadarTitle(index),
      ),
    );
  }

  List<RadarDataSet> _buildRadarDataSets() {
    final categories = _getIngredientCategories();

    return [
      RadarDataSet(
        fillColor: const Color(0xFF059669).withValues(
            alpha: 0.15 * _animation.value),
        borderColor: const Color(0xFF059669),
        entryRadius: 4,
        borderWidth: 2.5,
        dataEntries: categories
            .asMap()
            .entries
            .map((entry) =>
            RadarEntry(value: entry.value.usage * _animation.value))
            .toList(),
      ),
    ];
  }

  RadarChartTitle _getRadarTitle(int index) {
    final categories = _getIngredientCategories();
    if (index < categories.length) {
      return RadarChartTitle(
        text: categories[index].name,
        angle: 0,
      );
    }
    return RadarChartTitle(text: '', angle: 0);
  }

  List<_CategoryData> _getIngredientCategories() {
    // Generate sample ingredient category data
    final totalIngredients = widget.stats.totalIngredients.toDouble();
    return [
      _CategoryData('Proteins', (totalIngredients * 0.25).roundToDouble(),
          const Color(0xFFEF4444), Icons.set_meal_rounded),
      _CategoryData('Vegetables', (totalIngredients * 0.35).roundToDouble(),
          const Color(0xFF10B981), Icons.eco_rounded),
      _CategoryData('Grains', (totalIngredients * 0.20).roundToDouble(),
          const Color(0xFFF59E0B), Icons.grain_rounded),
      _CategoryData('Dairy', (totalIngredients * 0.15).roundToDouble(),
          const Color(0xFF3B82F6), Icons.local_drink_rounded),
      _CategoryData('Spices', (totalIngredients * 0.05).roundToDouble(),
          const Color(0xFF8B5CF6), Icons.grass_rounded),
    ];
  }

  Widget _buildLegendGrid(BuildContext context) {
    final categories = _getIngredientCategories();
    final totalUsage = categories.fold<double>(
        0, (sum, cat) => sum + cat.usage);

    // Check if we're on mobile for responsive design
    final isMobile = MediaQuery
        .of(context)
        .size
        .width < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.theme.colorScheme.surfaceContainerLowest,
            context.theme.colorScheme.surfaceContainerLowest.withValues(
                alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(
          color: context.theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                size: isMobile ? 18 : 16,
                color: context.theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              AppText.semiBold(
                'Category Breakdown',
                size: isMobile ? 16 : 14,
                color: context.theme.colorScheme.onSurface,
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : AppSpacing.md),

          // Mobile: Use vertical list instead of grid
          if (isMobile) ...[
            Column(
              children: categories
                  .asMap()
                  .entries
                  .map((entry) {
                final index = entry.key;
                final category = entry.value;
                final percentage = totalUsage > 0 ? (category.usage /
                    totalUsage * 100) : 0;
                final isSelected = selectedIndex == index;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = selectedIndex == index ? -1 : index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? category.color.withValues(alpha: 0.1)
                            : context.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        border: Border.all(
                          color: isSelected
                              ? category.color
                              : context.theme.colorScheme.outline.withValues(
                              alpha: 0.2),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: category.color.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ] : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: category.color.withValues(
                                  alpha: isSelected ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              category.icon,
                              size: 20,
                              color: category.color,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText.semiBold(
                                  category.name,
                                  size: 16,
                                  color: context.theme.colorScheme.onSurface,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    AppText(
                                      '${category.usage.toInt()} items',
                                      size: 14,
                                      color: context.theme.colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: category.color.withValues(
                                            alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: AppText(
                                        '${(totalUsage > 0 ? (category.usage /
                                            totalUsage * 100) : 0)
                                            .toStringAsFixed(1)}%',
                                        size: 12,
                                        color: category.color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ]

          // Tablet/Desktop: Use grid layout
          else
            ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final percentage = totalUsage > 0 ? (category.usage /
                      totalUsage * 100) : 0;
                  final isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = selectedIndex == index ? -1 : index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? category.color.withValues(alpha: 0.1)
                            : context.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        border: Border.all(
                          color: isSelected
                              ? category.color
                              : context.theme.colorScheme.outline.withValues(
                              alpha: 0.2),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: category.color.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ] : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: category.color.withValues(
                                  alpha: isSelected ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              category.icon,
                              size: 16,
                              color: category.color,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Flexible(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppText.semiBold(
                                      '${category.usage.toInt()}',
                                      size: 14,
                                      color: context.theme.colorScheme
                                          .onSurface,
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AppText(
                                            category.name,
                                            size: 9,
                                            color: context.theme.colorScheme
                                                .onSurface.withValues(
                                                alpha: 0.7),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        AppText(
                                          '${percentage.toStringAsFixed(0)}%',
                                          size: 8,
                                          color: category.color,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ]
        ],
      ),
    );
  }
}

class _CategoryData {
  final String name;
  final double usage;
  final Color color;
  final IconData icon;

  _CategoryData(this.name, this.usage, this.color, this.icon);
}