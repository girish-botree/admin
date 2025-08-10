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

class TabletDashboard extends GetView<DashboardController> {
  const TabletDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: controller.obx(
        (DashboardStats? stats) => _buildTabletContent(context, stats!),
        onLoading: _buildTabletShimmerLoading(context),
        onError: (String? error) => _buildTabletErrorState(context, error),
        onEmpty: _buildTabletEmptyState(context),
      ),
    );
  }

  Widget _buildTabletContent(BuildContext context, DashboardStats stats) {
    return RefreshIndicator(
      onRefresh: () => controller.refreshData(),
      color: const Color(0xFF2563EB),
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      child: CustomScrollView(
        slivers: [
          _buildTabletHeader(context),
          SliverPadding(
            padding: const EdgeInsets.all(32.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildTabletMainContent(context, stats),
                const SizedBox(height: 60),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
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
              stops: [0.0, 0.6, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: AppText(
                      '✨ Analytics Dashboard',
                      color: Colors.white,
                      size: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppText.h1(
                    'Recipe Analytics Hub',
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    'Comprehensive insights into your culinary data and trends',
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 18,
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
          margin: const EdgeInsets.only(right: 16.0),
          child: IconButton(
            onPressed: () => controller.refreshData(),
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            tooltip: 'Refresh Data',
          ),
        ),
      ],
    );
  }

  Widget _buildTabletMainContent(BuildContext context, DashboardStats stats) {
    return Column(
      children: [
        const SizedBox(height: 40),
        RecipeTrendChart(stats: stats),
        const SizedBox(height: 32),
        IngredientUsageRadar(stats: stats),
      ],
    );
  }

  Widget _buildTabletShimmerLoading(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header shimmer
        SliverAppBar(
          expandedHeight: 240,
          floating: false,
          pinned: true,
          elevation: 0,
          backgroundColor: const Color(0xFFE5E7EB),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(32.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 40),

              // Single chart shimmer (centered)
              Center(
                child: ShimmerAnimation(
                  width: 600,
                  height: 500,
                  borderRadius: 20,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletErrorState(BuildContext context, String? error) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: const Color(0xFFDC2626),
                size: 48,
              ),
            ),
            const SizedBox(height: 32),
            AppText.h3(
              'Something went wrong',
              color: const Color(0xFF111827),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            AppText(
              error ?? 'Unable to load dashboard data. Please try again.',
              color: const Color(0xFF6B7280),
              size: 16,
              textAlign: TextAlign.center,
              height: 1.5,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => controller.refreshData(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletEmptyState(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.analytics_outlined,
                color: const Color(0xFF6B7280),
                size: 48,
              ),
            ),
            const SizedBox(height: 32),
            AppText.h3(
              'No Data Available',
              color: const Color(0xFF111827),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            AppText(
              'Dashboard data will appear here when available',
              color: const Color(0xFF6B7280),
              size: 16,
              textAlign: TextAlign.center,
              height: 1.5,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => controller.refreshData(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
