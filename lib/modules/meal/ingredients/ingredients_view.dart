import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../meal_controller.dart';
import 'widgets/ingredient_card.dart';
import 'widgets/ingredient_shimmer.dart';
import 'dialogs/ingredient_dialogs.dart';
import '../shared/widgets/common_widgets.dart';

class IngredientsView extends GetView<MealController> {
  const IngredientsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MealController());

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

          if (controller.ingredients.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildIngredientGrid(context, controller);
        }),
        floatingActionButton: _buildModernFAB(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context,
      MealController controller) {
    return ModernAppBar(
      title: 'Ingredients',
      itemCount: controller.ingredients.length,
      itemLabel: 'items',
      showDeleteAll: true,
      onDeleteAll: () =>
          IngredientDialogs.showDeleteAllConfirmation(context, controller),
    );
  }

  Widget _buildModernFAB(BuildContext context) {
    return ModernFAB(
      label: 'Add Ingredient',
      onPressed: () =>
          IngredientDialogs.showAddIngredientDialog(context, controller),
    );
  }

  Widget _buildErrorState(BuildContext context, MealController controller) {
    return ErrorStateWidget(
      title: 'Something went wrong',
      subtitle: 'Data not found, try restarting the app',
      onRetry: () => controller.fetchIngredients(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyStateWidget(
      title: 'No ingredients yet',
      subtitle: 'Start building your ingredient library\nby adding your first ingredient',
      icon: Icons.eco_rounded,
      buttonLabel: 'Add First Ingredient',
      onButtonPressed: () =>
          IngredientDialogs.showAddIngredientDialog(context, controller),
    );
  }

  Widget _buildIngredientGrid(BuildContext context, MealController controller) {
    final ingredientCards = controller.ingredients.map((ingredient) =>
        IngredientCard(
          ingredient: ingredient,
          onTap: () =>
              IngredientDialogs.showIngredientDetails(context, ingredient),
          onEdit: () =>
              IngredientDialogs.showEditIngredientDialog(
                  context, controller, ingredient),
          onDelete: () =>
              IngredientDialogs.showDeleteConfirmation(
                  context, ingredient, controller),
        )
    ).toList();

    return ResponsiveGrid(
      children: ingredientCards,
      getCrossAxisCount: _getCrossAxisCount,
    );
  }

  int _getCrossAxisCount(double width) {
    if (width > 1200) return 7;
    if (width > 900) return 5;
    if (width > 700) return 4;
    if (width > 500) return 3;
    if (width > 300) return 2;
    return 1;
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return IngredientShimmerGrid(
      getCrossAxisCount: _getCrossAxisCount,
    );
  }
}