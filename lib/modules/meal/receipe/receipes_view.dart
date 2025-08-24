import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../meal_controller.dart';
import 'widgets/recipe_card.dart';
import 'widgets/recipe_shimmer.dart';
import 'dialogs/recipe_dialog.dart';
import '../shared/widgets/common_widgets.dart';
import 'dialogs/recipe_details_dialog.dart';

class ReceipesView extends GetView<MealController> {
  const ReceipesView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        appBar: _buildAppBar(context, controller),
        body: Obx(() {
          if (controller.isLoading.value) {
            return _buildShimmerLoading(context);
          }

          if (controller.error.value.isNotEmpty) {
            return _buildErrorState(context, controller);
          }

          if (controller.recipes.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildRecipeGrid(context, controller);
        }),
        floatingActionButton: _buildModernFAB(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context,
      MealController controller) {
    return ModernAppBar(
      title: 'Recipes',
      itemCount: controller.recipes.length,
      itemLabel: 'recipes',
      showDeleteAll: true,
      onDeleteAll: () =>
          RecipeDialogs.showDeleteAllConfirmation(context, controller),
    );
  }

  Widget _buildModernFAB(BuildContext context) {
    return ModernFAB(
      label: 'Add Recipe',
      onPressed: () => RecipeDialogs.showAddRecipeDialog(context, controller),
    );
  }

  Widget _buildErrorState(BuildContext context, MealController controller) {
    return ErrorStateWidget(
      title: 'Something went wrong',
      subtitle: 'Unable to load recipes. Please try again.',
      onRetry: () => controller.fetchRecipes(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyStateWidget(
      title: 'No recipes yet',
      subtitle: 'Start creating delicious recipes\nfor your meal plans',
      icon: Icons.restaurant_menu_rounded,
      buttonLabel: 'Create First Recipe',
      onButtonPressed: () =>
          RecipeDialogs.showAddRecipeDialog(context, controller),
    );
  }

  Widget _buildRecipeGrid(BuildContext context, MealController controller) {
    final recipeCards = controller.recipes.map((recipe) =>
        RecipeCard(
          recipe: recipe,
          onTap: () => RecipeDetailsDialog.show(context, recipe),
          onEdit: () =>
              RecipeDialogs.showEditRecipeDialog(context, controller, recipe),
          onDelete: () =>
              RecipeDialogs.showDeleteConfirmation(context, recipe, controller),
        )
    ).toList();

    return ResponsiveGrid(
      children: recipeCards,
      getCrossAxisCount: _getCrossAxisCount,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
    );
  }

  int _getCrossAxisCount(double width) {
    if (width > 1400) return 5;
    if (width > 1100) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    if (width > 300) return 2;
    return 1;
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return RecipeShimmerGrid(
      getCrossAxisCount: _getCrossAxisCount,
    );
  }
}