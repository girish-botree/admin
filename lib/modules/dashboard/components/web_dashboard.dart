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

class WebDashboard extends GetView<DashboardController> {
  const WebDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: controller.obx(
            (state) => _buildWebDashboard(context, state!),
        onLoading: _buildWebShimmerLoading(context),
        onError: (error) => _buildWebErrorState(context, error),
      ),
    );
  }

  Widget _buildWebDashboard(BuildContext context, DashboardStats stats) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildWebHeroSection(context),
          _buildWebMainContent(context, stats),
        ],
      ),
    );
  }

  Widget _buildWebHeroSection(BuildContext context) {
    return Container(
      height: 280,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2563EB),
            Color(0xFF7C3AED),
            Color(0xFFDB2777),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/images/grid-pattern.png'),
                  fit: BoxFit.cover,
                  opacity: 0.1,
                ),
              ),
            ),
          ),
          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                      '✨ ' + 'dashboard'.tr,
                      color: Colors.white,
                      size: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppText.semiBold(
                    'welcome_recipes'.tr,
                    color: Colors.white,
                    size: 48,
                    textAlign: TextAlign.center,
                    height: 1.2,
                  ),
                  const SizedBox(height: 16),
                  AppText(
                    'Track your recipes, ingredients, and meal plans with beautiful insights',
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 18,
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebMainContent(BuildContext context, DashboardStats stats) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      margin: const EdgeInsets.symmetric(horizontal: 48.0),
      child: Column(
        children: [
          const SizedBox(height: 60),
          // Analytics Charts Row
          Row(
            children: [
              Expanded(
                child: RecipeTrendChart(stats: stats),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: IngredientUsageRadar(stats: stats),
              ),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildWebShimmerLoading(BuildContext context) {
    return Column(
      children: [
        // Hero section shimmer
        Container(
          height: 280,
          color: const Color(0xFFE5E7EB),
        ),

        Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          margin: const EdgeInsets.symmetric(horizontal: 48.0),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Single chart shimmer (centered)
              Center(
                child: ShimmerAnimation(
                  width: 700,
                  height: 500,
                  borderRadius: 20,
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebErrorState(BuildContext context, String? error) {
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
            AppText.semiBold(
              'error'.tr,
              color: const Color(0xFF111827),
              size: 24,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            AppText(
              error ?? 'no_data'.tr,
              color: const Color(0xFF6B7280),
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