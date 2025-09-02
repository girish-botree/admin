import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_config.dart';
import '../../../widgets/loading_widgets.dart';
import '../../../routes/app_routes.dart';

import '../meal_controller.dart';
import '../ingredients/ingredients_view.dart';
import '../receipe/receipes_view.dart';

class WebMeal extends GetView<MealController> {
  const WebMeal({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: context.theme.colorScheme.surface,
        appBar: _buildWebAppBar(context),
        body: _buildWebBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildWebAppBar(BuildContext context) {
    return AppBar(
      title: AppText.bold(
        'Meal Management Dashboard',
        color: context.theme.colorScheme.onSurface,
        size: 20,
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: false,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Obx(() =>
              IconButton(
                onPressed: controller.isLoading.value ? null : _handleRefresh,
                icon: controller.isLoading.value
                    ? StandardLoadingWidget.circular(
                        size: 26,
                      )
                    : Icon(
                        Icons.refresh_rounded,
                        color: context.theme.colorScheme.primary,
                        size: 30,
                      ),
                tooltip: 'Refresh',
              )),
        ),
        Container(
          margin: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => Get.toNamed(AppRoutes.mealStatistics),
            icon: Icon(
              Icons.analytics_rounded,
              color: context.theme.colorScheme.primary,
              size: 30,
            ),
            tooltip: 'Statistics',
          ),
        ),
      ],
    );
  }

  Widget _buildWebBody(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Quick Actions'),
            const SizedBox(height: 24),
            _buildActionCards(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return AppText.semiBold(
      title,
      color: context.theme.colorScheme.onSurface,
      size: 36,
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildRecipeCard(context),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildIngredientCard(context),
        ),
      ],
    );
  }

  Widget _buildRecipeCard(BuildContext context) {
    return WebMealCard(
      onTap: () => _navigateToRecipes(context),
      iconData: Icons.restaurant_menu,
      title: 'Recipes',
      subtitle: 'Discover & manage your cooking recipes',
      titleSize: 32,
      subtitleSize: 22,
      gradientColors: _CardColors
          .recipes(context)
          .gradient
          .colors,
    );
  }

  Widget _buildIngredientCard(BuildContext context) {
    return WebMealCard(
      onTap: () => _navigateToIngredients(context),
      iconData: Icons.inventory_2,
      title: 'Ingredients',
      subtitle: 'Track & organize your food ingredients',
      titleSize: 32,
      subtitleSize: 22,
      gradientColors: _CardColors
          .ingredients(context)
          .gradient
          .colors,
    );
  }

  Future<void> _handleRefresh() async {
    try {
      await Future.wait([
        controller.fetchRecipes(),
        controller.fetchIngredients(),
      ]);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh data. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  void _navigateToRecipes(BuildContext context) async {
    if (!controller.isLoading.value) {
      controller.fetchRecipes();
    }

    await Get.to<void>(
          () => const ReceipesView(),
      transition: Transition.rightToLeftWithFade,
    );
  }

  void _navigateToIngredients(BuildContext context) async {
    if (!controller.isLoading.value) {
      controller.fetchIngredients();
    }

    await Get.to<void>(
          () => const IngredientsView(),
      transition: Transition.rightToLeftWithFade,
    );
  }
}

class _CardColors {
  final Color primary;
  final Color secondary;
  final Gradient gradient;

  _CardColors({
    required this.primary,
    required this.secondary,
    required this.gradient,
  });

  /// Recipes card color set, uses primary/secondary theme colors.
  factory _CardColors.recipes(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary.withValues(alpha: 0.7);
    final secondary = theme.colorScheme.secondary.withValues(alpha: 0.6);
    return _CardColors(
      primary: primary,
      secondary: secondary,
      gradient: LinearGradient(
        colors: [primary, secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  /// Ingredients card color set, uses tertiary surface colors or similar.
  factory _CardColors.ingredients(BuildContext context) {
    final theme = Theme.of(context);
    // Fallbacks if theme extensions missing
    final primary = theme.colorScheme.tertiary.withValues(alpha: 0.7);
    final secondary = theme.colorScheme.tertiaryContainer.withValues(
        alpha: 0.8);
    return _CardColors(
      primary: primary,
      secondary: secondary,
      gradient: LinearGradient(
        colors: [primary, secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}

class WebMealCard extends StatelessWidget {
  final VoidCallback onTap;
  final IconData iconData;
  final String title;
  final String subtitle;
  final double titleSize;
  final double subtitleSize;
  final List<Color> gradientColors;

  const WebMealCard({
    super.key,
    required this.onTap,
    required this.iconData,
    required this.title,
    required this.subtitle,
    this.titleSize = 28,
    this.subtitleSize = 18,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      child: Material(
        borderRadius: BorderRadius.circular(28),
        elevation: 0,
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      iconData,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText.semiBold(
                          title,
                          color: Colors.white,
                          size: titleSize,
                        ),
                        const SizedBox(height: 10),
                        AppText(
                          subtitle,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: subtitleSize,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
