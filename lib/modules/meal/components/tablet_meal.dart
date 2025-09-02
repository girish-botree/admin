import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_config.dart';
import '../meal_controller.dart';
import '../ingredients/ingredients_view.dart';
import '../receipe/receipes_view.dart';
import '../../../routes/app_routes.dart';

class TabletMeal extends GetView<MealController> {
  const TabletMeal({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: context.theme.colorScheme.surface,
        appBar: _buildTabletAppBar(context),
        body: _buildTabletBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildTabletAppBar(BuildContext context) {
    return AppBar(
      title: AppText.bold(
        'Meal Management',
        color: context.theme.colorScheme.onSurface,
        size: 20,
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: false,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Obx(() =>
              IconButton(
                onPressed: controller.isLoading.value ? null : _handleRefresh,
                icon: controller.isLoading.value
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
                tooltip: 'Refresh',
              )),
        ),
        IconButton(
          icon: Icon(
            Icons.analytics_rounded,
            color: context.theme.colorScheme.primary,
            size: 28,
          ),
          onPressed: () {
            Get.toNamed(AppRoutes.mealStatistics);
          },
        ),
      ],
    );
  }

  Widget _buildTabletBody(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Quick Actions'),
            const SizedBox(height: 20),
            _buildActionCards(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return AppText.semiBold(
      title,
      color: context.theme.colorScheme.onSurface,
      size: 30,
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildRecipeCard(context),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildIngredientCard(context),
        ),
      ],
    );
  }

  Widget _buildRecipeCard(BuildContext context) {
    return MealCard(
      onTap: () => _navigateToRecipes(context),
      iconData: Icons.restaurant_menu,
      title: 'Recipes',
      subtitle: 'Discover & manage your cooking recipes',
      titleSize: 28,
      subtitleSize: 20,
      gradientColors: _CardColors
          .recipes(context)
          .gradient
          .colors,
    );
  }

  Widget _buildIngredientCard(BuildContext context) {
    return MealCard(
      onTap: () => _navigateToIngredients(context),
      iconData: Icons.inventory_2,
      title: 'Ingredients',
      subtitle: 'Track & organize your food ingredients',
      titleSize: 28,
      subtitleSize: 20,
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

  const _CardColors({
    required this.primary,
    required this.secondary,
    required this.gradient,
  });

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

  factory _CardColors.ingredients(BuildContext context) {
    final theme = Theme.of(context);
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

class MealCard extends StatelessWidget {
  final VoidCallback onTap;
  final IconData iconData;
  final String title;
  final String subtitle;
  final double titleSize;
  final double subtitleSize;
  final List<Color> gradientColors;

  const MealCard({
    super.key,
    required this.onTap,
    required this.iconData,
    required this.title,
    required this.subtitle,
    this.titleSize = 24,
    this.subtitleSize = 16,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      iconData,
                      color: Colors.white,
                      size: 32,
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
                          size: titleSize,
                        ),
                        const SizedBox(height: 8),
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
                    size: 24,
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
