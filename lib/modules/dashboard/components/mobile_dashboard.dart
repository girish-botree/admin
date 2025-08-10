import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_text.dart';
import '../../../widgets/shimmer_animation.dart';
import '../dashboard_controller.dart';
import '../models/dashboard_stats.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/dashboard_pie_chart.dart';
import '../widgets/dashboard_bar_chart.dart';
import '../widgets/recipe_trend_chart.dart';
import '../widgets/ingredient_usage_radar.dart';

class MobileDashboard extends GetView<DashboardController> {
  const MobileDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: controller.obx(
        (DashboardStats? stats) => _buildMobileContent(context, stats!),
        onLoading: _buildMobileShimmerLoading(context),
        onError: (String? error) => _buildMobileErrorState(context, error),
        onEmpty: _buildMobileEmptyState(context),
      ),
    );
  }

  Widget _buildMobileContent(BuildContext context, DashboardStats stats) {
    return RefreshIndicator(
      onRefresh: () => controller.refreshData(),
      color: const Color(0xFF2563EB),
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      child: CustomScrollView(
        slivers: [
          _buildMobileHeader(context),
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Recipe Trend Chart
                RecipeTrendChart(stats: stats),
                const SizedBox(height: 24),
                // Ingredient Usage Radar
                IngredientUsageRadar(stats: stats),
                const SizedBox(height: 100), // Bottom padding
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2563EB),
                Color(0xFF7C3AED),
                Color(0xFFDB2777),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const AppText(
                      '✨ Dashboard',
                      color: Colors.white,
                      size: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const AppText.h2(
                    'Recipe Analytics',
                    color: Colors.white,
                  ),
                  const SizedBox(height: 6),
                  AppText(
                    'Track your culinary journey',
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            onPressed: () => controller.refreshData(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            tooltip: 'Refresh Data',
          ),
        ),
      ],
    );
  }

  Widget _buildMobileShimmerLoading(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header shimmer
        const SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          elevation: 0,
          backgroundColor: Color(0xFFE5E7EB),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(20.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Charts shimmer
              const ShimmerAnimation(
                width: double.infinity,
                height: 320,
                borderRadius: 16,
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileErrorState(BuildContext context, String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFDC2626),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const AppText.h4(
              'Something went wrong',
              color: Color(0xFF111827),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            AppText(
              error ?? 'Unable to load dashboard data. Please try again.',
              color: const Color(0xFF6B7280),
              size: 14,
              textAlign: TextAlign.center,
              height: 1.4,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.refreshData(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.analytics_outlined,
                color: Color(0xFF6B7280),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const AppText.h4(
              'No Data Available',
              color: Color(0xFF111827),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const AppText(
              'Dashboard data will appear here when available',
              color: Color(0xFF6B7280),
              size: 14,
              textAlign: TextAlign.center,
              height: 1.4,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.refreshData(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
