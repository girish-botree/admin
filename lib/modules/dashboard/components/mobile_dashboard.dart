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
    // Refresh data when surface becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onSurface();
    });

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.theme.colorScheme.surfaceContainerLowest.withOpacity(0.3),
            context.theme.colorScheme.surfaceContainerLowest.withOpacity(0.2),
            context.theme.colorScheme.surfaceContainerLowest.withOpacity(0.1),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildMobileAppBar(context),
        body: controller.obx(
              (DashboardStats? stats) => _buildMobileContent(context, stats!),
          onLoading: _buildMobileShimmerLoading(context),
          onError: (String? error) => _buildMobileErrorState(context, error),
          onEmpty: _buildMobileEmptyState(context),
        ),
      ),
    );
  }

  void _onSurface() {
    // Refresh data when surface becomes active
    if (!controller.isCurrentlyRefreshing) {
      controller.refreshData();
    }
  }

  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    return AppBar(
      title: AppText.bold(
        'Analytics Dashboard',
        color: context.theme.colorScheme.onSurface,
        size: 20,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: context.theme.colorScheme.onSurface,
      centerTitle: false,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainerLowest.withOpacity(
                0.1),
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
              color: context.theme.colorScheme.onSurface,
              size: 28,
                  ),
            tooltip: 'Refresh Data',
          )),
        ),
      ],
    );
  }

  Widget _buildMobileContent(BuildContext context, DashboardStats stats) {
    return RefreshIndicator(
      onRefresh: () => controller.refreshData(),
      color: context.theme.colorScheme.primary,
      backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
      strokeWidth: 2.5,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Recipe Trend Chart
            RecipeTrendChart(stats: stats),
            const SizedBox(height: 24),
            // Ingredient Usage Radar
            IngredientUsageRadar(stats: stats),
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildMobileShimmerLoading(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Charts shimmer
          ShimmerAnimation(
            width: double.infinity,
            height: 320,
            borderRadius: 16,
          ),
        ],
      ),
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
