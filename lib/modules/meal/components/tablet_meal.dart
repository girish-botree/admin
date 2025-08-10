import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_config.dart';
import '../meal_controller.dart';
import '../ingredients/ingredients_view.dart';
import '../receipe/receipes_view.dart';
import 'meal_statistics_widget.dart';

class TabletMeal extends GetView<MealController> {
  const TabletMeal({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _buildTabletAppBar(context),
        body: _buildTabletBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildTabletAppBar(BuildContext context) {
    return AppBar(
      title: AppText.semiBold(
        'Meal Management',
        color: context.theme.colorScheme.onSurface,
        size: 22,
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          onPressed: () {
            controller.fetchRecipes();
            controller.fetchIngredients();
          },
          icon: Icon(Icons.refresh, color: context.theme.colorScheme.onSurface),
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTabletBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildTabletHeader(context),
          
          const SizedBox(height: 32),

          // Main Content - Horizontal layout for tablet
          SizedBox(
            height: 400,
            child: Row(
              children: [
                // Recipes Card
                Expanded(
                  child: _buildTabletCard(
                    context: context,
                    onTap: () => _navigateToRecipes(context),
                    icon: Icons.restaurant_menu,
                    title: 'Recipes',
                    subtitle: 'Manage your cooking recipes and meal preparations',
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade100, Colors.blue.shade200],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                
                const SizedBox(width: 24),

                // Ingredients Card
                Expanded(
                  child: _buildTabletCard(
                    context: context,
                    onTap: () => _navigateToIngredients(context),
                    icon: Icons.shopping_basket,
                    title: 'Ingredients',
                    subtitle: 'Manage your food ingredients and nutritional data',
                    gradient: LinearGradient(
                      colors: [Colors.green.shade100, Colors.green.shade200],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Statistics Widget - recipes and ingredients only
          const MealStatisticsWidget(),
        ],
      ),
    );
  }

  Widget _buildTabletHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.semiBold(
          'Meal Management System',
          color: context.theme.colorScheme.onSurface,
          size: 28,
        ),
        const SizedBox(height: 8),
        AppText(
          'Manage your recipes and ingredients efficiently',
          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
          size: 16,
        ),
      ],
    );
  }

  Widget _buildTabletCard({
    required BuildContext context,
    required VoidCallback onTap,
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
  }) {
    return Container(
      height: double.infinity,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: context.theme.colorScheme.primary,
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  AppText.semiBold(
                    title,
                    color: context.theme.colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  AppText(
                    subtitle,
                    color: context.theme.colorScheme.onSurface,
                    size: 16,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quick stats
                  Obx(() => _buildQuickStats(context, title)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, String type) {
    final count = type == 'Recipes' 
        ? controller.recipes.length 
        : controller.ingredients.length;
        
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            type == 'Recipes' ? Icons.restaurant_menu : Icons.eco,
            color: context.theme.colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          AppText(
            '$count items',
            color: context.theme.colorScheme.onSurface,
            size: 14,
            fontWeight: FontWeight.w500,
          ),
        ],
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
