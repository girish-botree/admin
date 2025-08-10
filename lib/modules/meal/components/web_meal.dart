import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_config.dart';
import '../../../utils/responsive.dart';
import '../meal_controller.dart';
import '../ingredients/ingredients_view.dart';
import '../receipe/receipes_view.dart';
import 'meal_statistics_widget.dart';

class WebMeal extends GetView<MealController> {
  const WebMeal({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _buildWebAppBar(context),
        body: _buildWebBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildWebAppBar(BuildContext context) {
    return AppBar(
      title: AppText.semiBold(
        'Meal Management System',
        color: context.theme.colorScheme.onSurface,
        size: Responsive.getLargeHeadingTextSize(context),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      actions: [
        TextButton.icon(
          onPressed: () {
            controller.fetchRecipes();
            controller.fetchIngredients();
          },
          icon: Icon(Icons.refresh, color: context.theme.colorScheme.primary),
          label: AppText(
            'Refresh',
            color: context.theme.colorScheme.primary,
            size: Responsive.getButtonTextSize(context),
          ),
        ),
        const SizedBox(width: 16),
        TextButton.icon(
          onPressed: () {
            // TODO: Implement export functionality
          },
          icon: Icon(Icons.download, color: context.theme.colorScheme.primary),
          label: AppText(
            'Export',
            color: context.theme.colorScheme.primary,
            size: Responsive.getButtonTextSize(context),
          ),
        ),
        const SizedBox(width: 32),
      ],
    );
  }

  Widget _buildWebBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section
          _buildHeroSection(context),
          
          const SizedBox(height: 48),
          
          // Main Content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Panel - Main Cards
              Expanded(
                flex: 4,
                child: _buildMainContent(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.theme.colorScheme.primaryContainer,
            context.theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.semiBold(
                  'Comprehensive Meal Management',
                  color: context.theme.colorScheme.onPrimaryContainer,
                  size: Responsive.responsiveTextSize(
                      context, mobile: 28, tablet: 32, web: 42),
                ),
                const SizedBox(height: 16),
                AppText(
                  'Manage recipes, ingredients, and nutritional data with powerful tools designed for efficiency and scalability.',
                  color: context.theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                  size: Responsive.responsiveTextSize(
                      context, mobile: 16, tablet: 18, web: 22),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Obx(() => _buildHeroStats(context)),
              ],
            ),
          ),
          const SizedBox(width: 48),
          Icon(
            Icons.restaurant,
            size: 120,
            color: context.theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStats(BuildContext context) {
    return Row(
      children: [
        _buildHeroStatItem(
          context: context,
          value: controller.recipes.length.toString(),
          label: 'Recipes',
          icon: Icons.restaurant_menu,
        ),
        const SizedBox(width: 32),
        _buildHeroStatItem(
          context: context,
          value: controller.ingredients.length.toString(),
          label: 'Ingredients',
          icon: Icons.eco,
        ),
        const SizedBox(width: 32),
        _buildHeroStatItem(
          context: context,
          value: '${(controller.recipes.length + controller.ingredients.length)}',
          label: 'Total Items',
          icon: Icons.inventory,
        ),
      ],
    );
  }

  Widget _buildHeroStatItem({
    required BuildContext context,
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: context.theme.colorScheme.onPrimaryContainer,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.semiBold(
                value,
                color: context.theme.colorScheme.onPrimaryContainer,
                size: Responsive.responsiveTextSize(
                    context, mobile: 18, tablet: 20, web: 24),
              ),
              AppText(
                label,
                color: context.theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                size: Responsive.getCaptionTextSize(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.semiBold(
          'Management Areas',
          color: context.theme.colorScheme.onSurface,
          size: Responsive.getHeadingTextSize(context),
        ),
        const SizedBox(height: 24),

        // Main Cards Row
        Row(
          children: [
            // Recipes Card
            Expanded(
              child: _buildWebCard(
                context: context,
                onTap: () => _navigateToRecipes(context),
                icon: Icons.restaurant_menu,
                title: 'Recipe Management',
                subtitle: 'Create, edit, and organize cooking recipes with detailed ingredients and instructions',
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.blue.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                stats: controller.recipes.length,
                statsLabel: 'recipes',
              ),
            ),
            
            const SizedBox(width: 24),

            // Ingredients Card
            Expanded(
              child: _buildWebCard(
                context: context,
                onTap: () => _navigateToIngredients(context),
                icon: Icons.shopping_basket,
                title: 'Ingredient Management',
                subtitle: 'Manage food ingredients with comprehensive nutritional data and categorization',
                gradient: LinearGradient(
                  colors: [Colors.green.shade100, Colors.green.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                stats: controller.ingredients.length,
                statsLabel: 'ingredients',
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Statistics Widget - recipes and ingredients only
        const MealStatisticsWidget(),
      ],
    );
  }

  Widget _buildWebCard({
    required BuildContext context,
    required VoidCallback onTap,
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required int stats,
    required String statsLabel,
  }) {
    return Container(
      height: 320,
      child: Material(
        borderRadius: BorderRadius.circular(20),
        elevation: 4,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: gradient,
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        icon,
                        color: context.theme.colorScheme.primary,
                        size: 48,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AppText(
                          '$stats $statsLabel',
                          color: context.theme.colorScheme.onSurface,
                          size: Responsive.getCaptionTextSize(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  AppText.semiBold(
                    title,
                    color: context.theme.colorScheme.primary,
                    size: Responsive.getHeadingTextSize(context),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  AppText(
                    subtitle,
                    color: context.theme.colorScheme.onSurface,
                    size: Responsive.getBodyTextSize(context),
                    maxLines: 3,
                  ),
                  
                  const Spacer(),
                  
                  // Action Button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          'Manage',
                          color: Colors.white,
                          size: Responsive.getButtonTextSize(context),
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 16,
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
