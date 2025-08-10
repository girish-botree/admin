import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_config.dart';
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
        IconButton(
          onPressed: () {
            controller.fetchRecipes();
            controller.fetchIngredients();
          },
          icon: Icon(Icons.refresh, color: context.theme.colorScheme.onSurface),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildMobileBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          AppText(
            'Manage your meals and recipes',
            color: context.theme.colorScheme.onSurface,
            size: 18,
          ),
          const SizedBox(height: 24),

          // Main Content - Vertical layout for mobile
          // Recipes Card
          _buildMobileCard(
            context: context,
            onTap: () => _navigateToRecipes(context),
            icon: Icons.restaurant_menu,
            title: 'Recipes',
            subtitle: 'Manage your cooking recipes',
            gradient: LinearGradient(
              colors: [Colors.blue.shade100, Colors.blue.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),

          const SizedBox(height: 16),

          // Ingredients Card
          _buildMobileCard(
            context: context,
            onTap: () => _navigateToIngredients(context),
            icon: Icons.shopping_basket,
            title: 'Ingredients',
            subtitle: 'Manage your food ingredients',
            gradient: LinearGradient(
              colors: [Colors.green.shade100, Colors.green.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),

          const SizedBox(height: 16), // Bottom padding

          // Meal Statistics - only recipes and ingredients
          const MealStatisticsWidget(),
        ],
      ),
    );
  }

  Widget _buildMobileCard({
    required BuildContext context,
    required VoidCallback onTap,
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
  }) {
    return Container(
      width: double.infinity,
      height: 150,
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: gradient,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: context.theme.colorScheme.primary,
                    size: 48,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText.semiBold(
                          title,
                          color: context.theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(height: 8),
                        AppText(
                          subtitle,
                          color: context.theme.colorScheme.onSurface,
                          size: 14,
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
