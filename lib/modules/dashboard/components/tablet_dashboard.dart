import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_text.dart';
import '../../../widgets/shimmer_animation.dart';
import '../dashboard_controller.dart';
import '../models/dashboard_stats.dart';

import '../widgets/recipe_trend_chart.dart';
import '../widgets/ingredient_usage_radar.dart';

class TabletDashboard extends GetView<DashboardController> {
  const TabletDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .onSurface,
      body: Container(
        decoration: BoxDecoration(
          color: Theme
              .of(context)
              .colorScheme
              .surfaceContainerLowest,
        ),
        child: controller.obx(
              (DashboardStats? stats) => _buildTabletContent(context, stats!),
          onLoading: _buildTabletShimmerLoading(context),
          onError: (String? error) => _buildTabletErrorState(context, error),
          onEmpty: _buildTabletEmptyState(context),
        ),
      ),
    );
  }

  Widget _buildTabletContent(BuildContext context, DashboardStats stats) {
    return RefreshIndicator(
      onRefresh: () => controller.refreshData(),
      color: Theme
          .of(context)
          .colorScheme
          .primary,
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .surfaceContainerLowest,
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.error,
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
                      color: Theme
                          .of(
                        context,
                      ).colorScheme.onSurface.withAlpha(50),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(100)),
                    ),
                    child: AppText(
                      '✨ Analytics Dashboard',
                      color: Theme
                          .of(context)
                          .colorScheme
                          .onPrimary,
                      size: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppText.h1(
                    'recipes'.tr,
                    color: Theme
                        .of(context)
                        .colorScheme
                        .onPrimary,
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    'track_recipes'.tr,
                    color: Theme
                        .of(context)
                        .colorScheme
                        .onPrimary
                        .withAlpha(230),
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
                color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
                ),
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: Theme
                    .of(context)
                    .colorScheme
                    .onPrimary,
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
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
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
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Theme.of(context).colorScheme.onErrorContainer,
                size: 48,
              ),
            ),
            const SizedBox(height: 32),
            AppText.h3(
              'error'.tr,
              color: Theme.of(context).colorScheme.onSurface,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            AppText(
              error ?? 'no_data'.tr,
              color: Theme.of(context).colorScheme.onSurface,
              size: 16,
              textAlign: TextAlign.center,
              height: 1.5,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => controller.refreshData(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text('try_again'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.analytics_outlined,
                color: Theme
                    .of(context)
                    .colorScheme
                    .onSurface,
                size: 48,
              ),
            ),
            const SizedBox(height: 32),
            AppText.h3(
              'no_data'.tr,
              color: Theme.of(context).colorScheme.onSurface,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            AppText(
              'dashboard_data'.tr,
              color: Theme.of(context).colorScheme.onSurface,
              size: 16,
              textAlign: TextAlign.center,
              height: 1.5,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => controller.refreshData(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text('refresh'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
