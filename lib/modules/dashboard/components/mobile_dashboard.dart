import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_text.dart';
import '../../../widgets/shimmer_animation.dart';
import '../dashboard_controller.dart';
import '../models/dashboard_stats.dart';

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
      color: context.theme.colorScheme.primary,
      backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
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
      backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
      clipBehavior: Clip.hardEdge,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.theme.colorScheme.primary,
                context.theme.colorScheme.secondary,
                context.theme.colorScheme.tertiary,
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
                      color: context.theme.colorScheme.surfaceContainerLowest
                          .withAlpha(51),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.theme.colorScheme.surfaceContainerLowest
                            .withAlpha(77),
                      ),
                    ),
                    child: AppText(
                      '✨ Dashboard',
                      color: context.theme.colorScheme.onSurface,
                      size: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppText.h2(
                    'recipes'.tr,
                    color: context.theme.colorScheme.surfaceContainerLowest,
                  ),
                  const SizedBox(height: 6),
                  AppText(
                    'Track your culinary journey',
                    color: context.theme.colorScheme.onSurfaceVariant,
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
          margin: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Obx(() =>
              IconButton(
                onPressed: controller.isCurrentlyRefreshing ? null : () =>
                    controller.refreshData(),
                icon: controller.isCurrentlyRefreshing
                    ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.theme.colorScheme.primary,
                    ),
                  ),
                )
                    : Icon(
                  Icons.refresh_rounded,
                  color: context.theme.colorScheme.primary,
                  size: 28,
                ),
                tooltip: 'Refresh Data',
              )),
        ),
      ],
    );
  }

  Widget _buildMobileShimmerLoading(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header shimmer
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          elevation: 0,
          backgroundColor: context.theme.colorScheme.surfaceContainerLow,
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
                color: context.theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: context.theme.colorScheme.error,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            AppText.h4(
              'error'.tr,
              color: context.theme.colorScheme.onSurface,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            AppText(
              error ?? 'no_data'.tr,
              color: context.theme.colorScheme.onSurfaceVariant,
              size: 14,
              textAlign: TextAlign.center,
              height: 1.4,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.isCurrentlyRefreshing ? null : () =>
                  controller.refreshData(),
              icon: controller.isCurrentlyRefreshing
                  ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.theme.colorScheme.onPrimary,
                  ),
                ),
              )
                  : const Icon(Icons.refresh_rounded),
              label: Text('try_again'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.theme.colorScheme.primary,
                foregroundColor: context.theme.colorScheme.onPrimary,
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
                color: context.theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.analytics_outlined,
                color: context.theme.colorScheme.onSurfaceVariant,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            AppText.h4(
              'no_data'.tr,
              color: context.theme.colorScheme.onSurface,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            AppText(
              'dashboard_data'.tr,
              color: context.theme.colorScheme.onSurfaceVariant,
              size: 14,
              textAlign: TextAlign.center,
              height: 1.4,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.isCurrentlyRefreshing ? null : () =>
                  controller.refreshData(),
              icon: controller.isCurrentlyRefreshing
                  ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.theme.colorScheme.onPrimary,
                  ),
                ),
              )
                  : const Icon(Icons.refresh_rounded),
              label: Text('refresh'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.theme.colorScheme.primary,
                foregroundColor: context.theme.colorScheme.onPrimary,
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
