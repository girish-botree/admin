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
    return SafeArea(
      child: Scaffold(
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            // Search bar
            ModernSearchBar(
              controller: controller.ingredientSearchController,
              hintText: 'Search ingredients, categories...',
              onChanged: (value) {
                // Explicitly update the search query
                controller.ingredientSearchQuery.value = value;
                controller.updateFilteredIngredients();
              },
              onClear: () {
                controller.ingredientSearchController.clear();
                controller.ingredientSearchQuery.value = '';
                controller.updateFilteredIngredients();
              },
            ),

            // Sort and filter bar
            Obx(() =>
                SortFilterBar(
                  sortBy: controller.ingredientSortBy.value,
                  sortAscending: controller.sortAscending.value,
                  sortOptions: const ['name', 'calories', 'protein', 'carbs'],
                  sortLabels: const {
                    'name': 'Name',
                    'calories': 'Calories',
                    'protein': 'Protein',
                    'carbs': 'Carbs',
                  },
                  onFilterTap: () => controller.toggleFilterVisibility(),
                  onSortChanged: (value) =>
                  controller.ingredientSortBy.value = value,
                  onSortOrderToggle: () =>
                  controller.sortAscending.value =
                  !controller.sortAscending.value,
                  hasActiveFilters: _hasActiveFilters(),
                )),

            // Filter panel
            Obx(() =>
                FilterPanel(
                  isVisible: controller.showFilters.value,
                  categoryOptions: controller.availableIngredientCategories,
                  selectedCategory: controller.selectedIngredientCategory.value,
                  onCategoryChanged: (value) =>
                  controller.selectedIngredientCategory.value = value,
                  calorieRange: controller.calorieRange.value,
                  onCalorieRangeChanged: (values) =>
                  controller.calorieRange.value = values,
                  proteinRange: controller.proteinRange.value,
                  onProteinRangeChanged: (values) =>
                  controller.proteinRange.value = values,
                  onReset: () => controller.resetFilters(),
                )),

            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.refreshData();
                },
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return _buildShimmerLoading(context);
                  }

                  if (controller.error.value.isNotEmpty) {
                    return _buildErrorState(context);
                  }

                  if (controller.ingredients.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  if (controller.filteredIngredients.isEmpty) {
                    return _buildNoResultsState(context);
                  }

                  return _buildIngredientGrid(context);
                }),
              ),
            ),
          ],
        ),
        floatingActionButton: _buildModernFAB(context),
      ),
    );
  }

  bool _hasActiveFilters() {
    return controller.selectedIngredientCategory.value != 'All' ||
        controller.calorieRange.value.start != 0 ||
        controller.calorieRange.value.end != 1000 ||
        controller.proteinRange.value.start != 0 ||
        controller.proteinRange.value.end != 100;
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Obx(() =>
          StandardAppBar.withCount(
            title: 'Ingredients',
            itemCount: controller.filteredIngredients.length,
            itemLabel: 'items',
            showDeleteAll: true,
            onDeleteAll: () =>
                IngredientDialogs.showDeleteAllConfirmation(
                    context, controller),
            showRefresh: true,
            isLoading: controller.isLoading.value,
            onRefresh: () async {
              await controller.refreshData();
            },
          )),
    );
  }

  Widget _buildModernFAB(BuildContext context) {
    return ModernFAB(
      label: 'Add Ingredient',
      onPressed: () =>
          IngredientDialogs.showAddIngredientDialog(context, controller),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return ErrorStateWidget(
      title: 'Something went wrong',
      subtitle: 'Data not found, try restarting the app',
      onRetry: () => controller.refreshData(),
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

  Widget _buildNoResultsState(BuildContext context) {
    return NoResultsWidget(
      title: 'No ingredients found',
      subtitle: 'Try adjusting your search or filters\nto find what you\'re looking for',
      icon: Icons.search_rounded,
      onReset: () {
        controller.ingredientSearchController.clear();
        controller.ingredientSearchQuery.value = '';
        controller.resetFilters();
        controller.updateFilteredIngredients();
      },
    );
  }

  Widget _buildIngredientGrid(BuildContext context) {
    final ingredientCards = controller.filteredIngredients.map((ingredient) =>
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
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