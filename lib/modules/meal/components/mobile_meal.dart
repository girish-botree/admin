import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_config.dart';
import '../../../gen/assets.gen.dart';
import '../meal_controller.dart';
import '../ingredients/ingredients_view.dart';
import '../receipe/receipes_view.dart';
import 'meal_statistics_widget.dart';

class MobileMeal extends GetView<MealController> {
  const MobileMeal({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: context.theme.colorScheme.surface,
        appBar: _buildMobileAppBar(context),
        body: _buildMobileBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    return AppBar(
      title: AppText.semiBold(
        'Meal Management',
        color: context.theme.colorScheme.onSurface,
        size: 20,
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {
              controller.fetchRecipes();
              controller.fetchIngredients();
            },
            icon: Icon(
              Icons.refresh_rounded,
              color: context.theme.colorScheme.primary,
            ),
            tooltip: 'Refresh',
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBody(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.theme.colorScheme.surface,
            context.theme.colorScheme.surface.withOpacity(0.8),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            AppText.semiBold(
              'Quick Actions',
              color: context.theme.colorScheme.onSurface,
              size: 20,
            ),
            const SizedBox(height: 16),

            // Main Content - Enhanced Cards
            // Recipes Card
            _buildEnhancedCard(
              context: context,
              onTap: () => _navigateToRecipes(context),
              svgAsset: Assets.icons.icRecipe,
              title: 'Recipes',
              subtitle: 'Discover & manage your cooking recipes',
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6366F1),
                  Color(0xFF8B5CF6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              accentColor: const Color(0xFF6366F1),
            ),

            const SizedBox(height: 20),

            // Ingredients Card
            _buildEnhancedCard(
              context: context,
              onTap: () => _navigateToIngredients(context),
              svgAsset: Assets.icons.icIngredient,
              title: 'Ingredients',
              subtitle: 'Track & organize your food ingredients',
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF10B981),
                  Color(0xFF059669),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              accentColor: const Color(0xFF10B981),
            ),

            const SizedBox(height: 32),

            // Statistics Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: context.theme.shadowColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: context.theme.colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.primary.withOpacity(
                              0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.analytics_rounded,
                          color: context.theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      AppText.semiBold(
                        'Statistics',
                        color: context.theme.colorScheme.onSurface,
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const MealStatisticsWidget(),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedCard({
    required BuildContext context,
    required VoidCallback onTap,
    required SvgGenImage svgAsset,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required Color accentColor,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Container(
            height: 160,
            child: Material(
              borderRadius: BorderRadius.circular(24),
              elevation: 0,
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: gradient,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        top: -30,
                        right: -30,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -20,
                        left: -20,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: svgAsset.svg(
                                width: 32,
                                height: 32,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppText.semiBold(
                                    title,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  const SizedBox(height: 8),
                                  AppText(
                                    subtitle,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white.withOpacity(0.8),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToRecipes(BuildContext context) {
    if (!controller.isLoading.value) {
      controller.fetchRecipes();
    }
    Get.to<void>(() => const ReceipesView(), transition: Transition.rightToLeftWithFade);
  }

  void _navigateToIngredients(BuildContext context) {
    if (!controller.isLoading.value) {
      controller.fetchIngredients();
    }
    Get.to<void>(() => const IngredientsView(), transition: Transition.rightToLeftWithFade);
  }
}
