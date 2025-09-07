import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../meal_controller.dart';
import 'package:admin/utils/image_base64_util.dart';
import '../dialogs/recipe_dialog.dart';

class RecipeDetailScreen extends StatelessWidget {
  final dynamic recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MealController>();

    // Observables for dynamic content
    final RxList<dynamic> recipeIngredients = <dynamic>[].obs;
    final RxString ingredientsError = ''.obs;
    final RxBool isLoadingIngredients = true.obs;
    final Rx<Map<String, dynamic>?> nutritionData = Rx<Map<String, dynamic>?>(
        null);

    // Fetch recipe details
    void fetchRecipeDetails() async {
      try {
        final recipeId = recipe['recipeId']?.toString();
        if (recipeId == null || recipeId.isEmpty) {
          throw Exception('Recipe ID is null or empty');
        }

        final recipeResponse = await controller.getRecipeDetails(recipeId);
        dynamic recipeData;

        if (recipeResponse is Map<String, dynamic>) {
          if (recipeResponse.containsKey('data')) {
            recipeData = recipeResponse['data'];
          } else {
            recipeData = recipeResponse;
          }
        } else {
          recipeData = recipeResponse;
        }

        if (recipeData != null) {
          // Update ingredients
          if (recipeData['ingredients'] != null) {
            final ingredientsList = recipeData['ingredients'];
            if (ingredientsList is List) {
              recipeIngredients.value = List<dynamic>.from(ingredientsList);
            }
          }

          // Update nutrition data
          if (recipeData['nutritionPerServing'] != null) {
            final apiNutrition = recipeData['nutritionPerServing'] as Map<
                String,
                dynamic>;
            final normalizedNutrition = <String, dynamic>{
              'calories': apiNutrition['totalCalories'] ?? 0,
              'protein': apiNutrition['totalProtein'] ?? 0,
              'carbohydrates': apiNutrition['totalCarbohydrates'] ?? 0,
              'fat': apiNutrition['totalFat'] ?? 0,
              'fiber': apiNutrition['totalFiber'] ?? 0,
              'sugar': apiNutrition['totalSugar'] ?? 0,
              'vitamins': apiNutrition['vitamins'] ?? {},
              'minerals': apiNutrition['minerals'] ?? {},
              'fatBreakdown': apiNutrition['fatBreakdown'] ?? {},
            };
            nutritionData.value = normalizedNutrition;
          }
        }
      } catch (e) {
        ingredientsError.value = 'Failed to load recipe details: $e';
      } finally {
        isLoadingIngredients.value = false;
      }
    }

    // Initialize data fetch
    fetchRecipeDetails();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero image section with app bar
          SliverAppBar(
            expandedHeight: 400,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: context.theme.colorScheme.surface,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    RecipeDialogs.showEditRecipeDialog(
                        context, controller, recipe);
                  },
                  icon: const Icon(Icons.edit_rounded, color: Colors.white),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Recipe image
                  _buildRecipeImage(context),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                  // Recipe title and quick info
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe['name']?.toString() ?? 'Unnamed Recipe',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 8,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildInfoChip(
                              Icons.people_outline_rounded,
                              '${recipe['servings'] ?? 1} servings',
                              Colors.blue,
                            ),
                            if (recipe['cuisine']
                                ?.toString()
                                .isNotEmpty == true)
                              _buildInfoChip(
                                Icons.public_rounded,
                                recipe['cuisine']?.toString() ?? '',
                                Colors.green,
                              ),
                            if (recipe['dietaryCategory'] != null &&
                                recipe['dietaryCategory'] != 0)
                              _buildInfoChip(
                                Icons.eco_rounded,
                                _getDietaryLabel(
                                    recipe['dietaryCategory'] as int),
                                Colors.orange,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content section
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Handle indicator
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.onSurface.withValues(
                          alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Content sections
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Description section
                        if (recipe['description']
                            ?.toString()
                            .isNotEmpty == true)
                          _buildDescriptionSection(context),

                        const SizedBox(height: 32),

                        // Quick nutrition overview
                        Obx(() =>
                            _buildNutritionOverview(context, nutritionData
                                .value)),

                        const SizedBox(height: 32),

                        // Ingredients section
                        _buildIngredientsSection(
                          context,
                          recipeIngredients,
                          ingredientsError,
                          isLoadingIngredients,
                          fetchRecipeDetails,
                        ),

                        const SizedBox(height: 32),

                        // Detailed nutrition
                        Obx(() =>
                            _buildDetailedNutrition(context, nutritionData
                                .value)),

                        const SizedBox(height: 32),

                        // Preparation steps
                        if (recipe['instructions']
                            ?.toString()
                            .isNotEmpty == true)
                          _buildPreparationSection(context),

                        const SizedBox(height: 100), // Bottom padding for FAB
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          RecipeDialogs.showEditRecipeDialog(context, controller, recipe);
        },
        backgroundColor: context.theme.colorScheme.primaryContainer,
        foregroundColor: context.theme.colorScheme.onPrimaryContainer,
        icon: const Icon(Icons.edit_rounded),
        label: const Text('Edit Recipe'),
      ),
    );
  }

  Widget _buildRecipeImage(BuildContext context) {
    final imageUrl = recipe['imageUrl']?.toString();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ImageBase64Util.buildImage(
        imageUrl,
        fit: BoxFit.cover,
        errorWidget: _buildFallbackImage(context),
      );
    }
    return _buildFallbackImage(context);
  }

  Widget _buildFallbackImage(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.theme.colorScheme.primaryContainer,
            context.theme.colorScheme.secondaryContainer,
            context.theme.colorScheme.tertiaryContainer,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 120,
          color: context.theme.colorScheme.onPrimaryContainer.withValues(
              alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.theme.colorScheme.outline.withValues(alpha: 0.1),
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
                  color: context.theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                    Icons.description_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'About this recipe',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            recipe['description']?.toString() ?? '',
            style: TextStyle(
              fontSize: 16,
              color: context.theme.colorScheme.onSurface,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionOverview(BuildContext context,
      Map<String, dynamic>? nutrition) {
    if (nutrition == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
            context.theme.colorScheme.tertiaryContainer.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.theme.colorScheme.tertiary.withValues(alpha: 0.2),
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
                  color: context.theme.colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                    Icons.analytics_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Nutrition per serving',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildNutrientCard(
                  context,
                  'Calories',
                  '${nutrition['calories']?.toStringAsFixed(0) ?? '0'}',
                  'kcal',
                  Colors.orange,
                  Icons.local_fire_department_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNutrientCard(
                  context,
                  'Protein',
                  '${nutrition['protein']?.toStringAsFixed(1) ?? '0'}',
                  'g',
                  Colors.red,
                  Icons.fitness_center_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNutrientCard(
                  context,
                  'Carbs',
                  '${nutrition['carbohydrates']?.toStringAsFixed(1) ?? '0'}',
                  'g',
                  Colors.blue,
                  Icons.grain_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNutrientCard(
                  context,
                  'Fat',
                  '${nutrition['fat']?.toStringAsFixed(1) ?? '0'}',
                  'g',
                  Colors.green,
                  Icons.opacity_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientCard(BuildContext context,
      String label,
      String value,
      String unit,
      Color color,
      IconData icon,) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            '$value $unit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection(BuildContext context,
      RxList<dynamic> recipeIngredients,
      RxString ingredientsError,
      RxBool isLoadingIngredients,
      VoidCallback onRetry,) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.theme.colorScheme.outline.withValues(alpha: 0.1),
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
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                    Icons.inventory_2_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Obx(() =>
                  Text(
                    'Ingredients${recipeIngredients.isNotEmpty
                        ? ' (${recipeIngredients.length})'
                        : ''}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (isLoadingIngredients.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (ingredientsError.value.isNotEmpty) {
              return _buildErrorCard(context, ingredientsError.value, onRetry);
            }

            if (recipeIngredients.isEmpty) {
              return _buildEmptyCard(context, 'No ingredients added yet');
            }

            return Column(
              children: recipeIngredients.map((ingredient) =>
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withValues(
                          alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                              Icons.eco_rounded, color: Colors.green, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            ingredient['name']?.toString() ??
                                'Unknown Ingredient',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${(ingredient['quantity'] as num?)
                                ?.toStringAsFixed(0) ?? '0'}g',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailedNutrition(BuildContext context,
      Map<String, dynamic>? nutrition) {
    if (nutrition == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.theme.colorScheme.outline.withValues(alpha: 0.1),
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
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                    Icons.health_and_safety_rounded, color: Colors.white,
                    size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Detailed nutrition',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNutrientRow(context, 'Fiber',
              '${nutrition['fiber']?.toStringAsFixed(1) ?? '0'}g',
              Colors.brown),
          _buildNutrientRow(context, 'Sugar',
              '${nutrition['sugar']?.toStringAsFixed(1) ?? '0'}g', Colors.pink),

          // Vitamins and minerals
          if (nutrition['vitamins'] is Map &&
              (nutrition['vitamins'] as Map).isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Vitamins',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...((nutrition['vitamins'] as Map).entries.map((entry) =>
                _buildNutrientRow(
                    context, _formatVitaminLabel(entry.key.toString()),
                    '${(entry.value as num?)?.toStringAsFixed(1) ?? '0'}mg',
                    Colors.orange))),
          ],

          if (nutrition['minerals'] is Map &&
              (nutrition['minerals'] as Map).isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Minerals',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...((nutrition['minerals'] as Map).entries.map((entry) =>
                _buildNutrientRow(
                    context, _formatMineralLabel(entry.key.toString()),
                    '${(entry.value as num?)?.toStringAsFixed(1) ?? '0'}mg',
                    Colors.blue))),
          ],
        ],
      ),
    );
  }

  Widget _buildNutrientRow(BuildContext context, String label, String value,
      Color color) {
    final numValue = double.tryParse(
        value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    // Remove the condition that hides zero values
    // if (numValue <= 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreparationSection(BuildContext context) {
    final instructions = recipe['instructions']?.toString() ?? '';
    final steps = instructions.split('\n').where((step) =>
    step
        .trim()
        .isNotEmpty).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.theme.colorScheme.outline.withValues(alpha: 0.1),
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
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                    Icons.format_list_numbered_rounded, color: Colors.white,
                    size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Preparation steps (${steps.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (index) =>
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.indigo,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        steps[index].trim(),
                        style: TextStyle(
                          fontSize: 16,
                          color: context.theme.colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error,
      VoidCallback onRetry) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 32),
          const SizedBox(height: 12),
          Text(
            error,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline, color: Colors.amber, size: 32),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: Colors.amber),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getDietaryLabel(int category) {
    switch (category) {
      case 0:
        return 'Vegan';
      case 1:
        return 'Vegetarian';
      case 2:
        return 'Eggitarian';
      case 3:
        return 'Non-Vegetarian';
      case 4:
        return 'Other';
      default:
        return 'Regular';
    }
  }

  String _formatVitaminLabel(String key) {
    switch (key.toLowerCase()) {
      case 'a':
        return 'Vitamin A';
      case 'c':
        return 'Vitamin C';
      case 'd':
        return 'Vitamin D';
      case 'e':
        return 'Vitamin E';
      case 'k':
        return 'Vitamin K';
      case 'b1':
        return 'Vitamin B1 (Thiamin)';
      case 'b2':
        return 'Vitamin B2 (Riboflavin)';
      case 'b3':
        return 'Vitamin B3 (Niacin)';
      case 'b5':
        return 'Vitamin B5 (Pantothenic Acid)';
      case 'b6':
        return 'Vitamin B6 (Pyridoxine)';
      case 'b7':
        return 'Vitamin B7 (Biotin)';
      case 'b9':
        return 'Vitamin B9 (Folate)';
      case 'b12':
        return 'Vitamin B12 (Cobalamin)';
      default:
        return 'Vitamin $key';
    }
  }

  String _formatMineralLabel(String key) {
    switch (key.toLowerCase()) {
      case 'ca':
        return 'Calcium';
      case 'fe':
        return 'Iron';
      case 'mg':
        return 'Magnesium';
      case 'p':
        return 'Phosphorus';
      case 'k':
        return 'Potassium';
      case 'na':
        return 'Sodium';
      case 'zn':
        return 'Zinc';
      case 'cu':
        return 'Copper';
      case 'mn':
        return 'Manganese';
      case 'se':
        return 'Selenium';
      default:
        return key;
    }
  }
}