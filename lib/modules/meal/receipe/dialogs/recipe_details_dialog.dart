import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../meal_controller.dart';

class RecipeDetailsDialog {
  static void show(BuildContext context, dynamic recipe) {
    // Observables
    final RxList<dynamic> recipeIngredients = <dynamic>[].obs;
    final RxString ingredientsError = ''.obs;
    final RxBool isLoadingIngredients = true.obs;
    final Rx<Map<String, dynamic>?> nutritionData = Rx<Map<String, dynamic>?>(
        null);
    final RxBool isIngredientsExpanded = true.obs;
    final RxBool isNutritionExpanded = true.obs;
    final RxBool isStepsExpanded = true.obs;

    final controller = Get.find<MealController>();

    // Data fetch for recipe details
    void fetchRecipeIngredients() async {
      ingredientsError.value = '';
      isLoadingIngredients.value = true;
      recipeIngredients.clear();

      try {
        final recipeId = recipe['recipeId']?.toString();
        if (recipeId == null || recipeId.isEmpty) {
          throw Exception('Recipe ID is null or empty');
        }

        final recipeResponse = await controller.getRecipeById(recipeId);
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
          // Update the recipe with the full details
          recipe = recipeData;

          if (recipeData['ingredients'] != null) {
            final ingredientsList = recipeData['ingredients'];
            if (ingredientsList is List) {
              recipeIngredients.value = List<dynamic>.from(ingredientsList);
            } else {
              recipeIngredients.value = [];
            }
          } else {
            recipeIngredients.value = [];
          }

          // Nutrition per serving
          if (recipeData['nutritionPerServing'] != null) {
            nutritionData.value =
            Map<String, dynamic>.from(recipeData['nutritionPerServing'] as Map);
          }
        } else {
          recipeIngredients.value = [];
        }
      } catch (e) {
        ingredientsError.value = 'Failed to load recipe details: $e';
      } finally {
        isLoadingIngredients.value = false;
      }
    }

    fetchRecipeIngredients();

    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.95,
          constraints: BoxConstraints(
            maxWidth: 900,
            maxHeight: MediaQuery
                .of(context)
                .size
                .height * 0.9,
          ),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hero image section + overlays
                RecipeHeroSection(recipe: recipe),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (recipe['description']
                            ?.toString()
                            .isNotEmpty == true) ...[
                          RecipeDescriptionSection(recipe: recipe),
                          const SizedBox(height: 24),
                        ],

                        RecipeIngredientsDetails(
                          recipeIngredients: recipeIngredients,
                          ingredientsError: ingredientsError,
                          isLoadingIngredients: isLoadingIngredients,
                          isIngredientsExpanded: isIngredientsExpanded,
                          onRetry: fetchRecipeIngredients,
                        ),

                        const SizedBox(height: 24),

                        RecipeNutritionDetails(
                          nutritionData: nutritionData,
                          isNutritionExpanded: isNutritionExpanded,
                          recipeIngredients: recipeIngredients,
                        ),

                        const SizedBox(height: 24),

                        // Recipe Steps/Preparation Section
                        if (recipe['description']
                            ?.toString()
                            .isNotEmpty == true) ...[
                          RecipePreparationSteps(
                            recipe: recipe,
                            isStepsExpanded: isStepsExpanded,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildPlaceholderImage(BuildContext context, dynamic recipe) {
    final color = Colors.primaries[recipe['name']
        .toString()
        .length % Colors.primaries.length];
    final imageUrl = recipe['imageUrl']?.toString();

    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('data:image/') || _isBase64String(imageUrl)) {
        try {
          String base64String = imageUrl;
          if (imageUrl.startsWith('data:image/')) {
            base64String = imageUrl.split(',')[1];
          }

          final bytes = base64Decode(base64String);
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackImage(context, color);
            },
          );
        } catch (e) {
          return _buildFallbackImage(context, color);
        }
      } else {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackImage(context, color);
          },
        );
      }
    } else {
      return _buildFallbackImage(context, color);
    }
  }

  static Widget _buildFallbackImage(BuildContext context, Color color) {
    return Container(
      color: color.withValues(alpha: 0.7),
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 80,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  static bool _isBase64String(String str) {
    try {
      final cleanStr = str.replaceAll(RegExp(r'\s+'), '');
      if (cleanStr.length % 4 != 0) return false;
      base64Decode(cleanStr);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class RecipeHeroSection extends StatelessWidget {
  final dynamic recipe;

  const RecipeHeroSection({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RecipeDetailsDialog._buildPlaceholderImage(context, recipe),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
                stops: const [0.3, 1.0],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['name']?.toString() ?? 'Unnamed Recipe',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickInfoChip(
                          context,
                          Icons.people_outline,
                          '${recipe['servings'] ?? 1} servings',
                        ),
                        const SizedBox(width: 8),
                        if (recipe['cuisine']
                            ?.toString()
                            .isNotEmpty == true)
                          _buildQuickInfoChip(
                            context,
                            Icons.public,
                            recipe['cuisine']?.toString() ?? '',
                          ),
                        const SizedBox(width: 8),
                        if (recipe['dietaryCategory'] != null &&
                            recipe['dietaryCategory'] != 0)
                          _buildQuickInfoChip(
                            context,
                            Icons.eco,
                            _getDietaryLabel(recipe['dietaryCategory'] as int),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => Get.back<void>(),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoChip(BuildContext context, IconData icon, String text,
      {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color?.withValues(alpha: 0.9) ??
            Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
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
}

class RecipeDescriptionSection extends StatelessWidget {
  final dynamic recipe;

  const RecipeDescriptionSection({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  Icons.description, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            recipe['description']?.toString() ?? '',
            style: TextStyle(
              fontSize: 16,
              color: context.theme.colorScheme.onSurface,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

class RecipeIngredientsDetails extends StatelessWidget {
  final RxList<dynamic> recipeIngredients;
  final RxString ingredientsError;
  final RxBool isLoadingIngredients;
  final RxBool isIngredientsExpanded;
  final VoidCallback onRetry;

  const RecipeIngredientsDetails({
    super.key,
    required this.recipeIngredients,
    required this.ingredientsError,
    required this.isLoadingIngredients,
    required this.isIngredientsExpanded,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  Icons.restaurant_menu, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() =>
                  Text(
                    'Ingredients${recipeIngredients.isNotEmpty
                        ? ' (${recipeIngredients.length})'
                        : ''}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: context.theme.colorScheme.onSurface,
                    ),
                  )),
            ),
            Obx(() =>
                IconButton(
                  onPressed: () => isIngredientsExpanded.toggle(),
                  icon: AnimatedRotation(
                    turns: isIngredientsExpanded.value ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: context.theme.colorScheme.primary,
                    ),
                  ),
                )),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() =>
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: isIngredientsExpanded.value
                  ? _buildIngredientsContent(context)
                  : _buildIngredientsPreview(context),
            )),
      ],
    );
  }

  Widget _buildIngredientsPreview(BuildContext context) {
    return Obx(() {
      if (isLoadingIngredients.value) {
        return _buildLoadingCard(context, 'Loading ingredients...');
      }

      if (ingredientsError.value.isNotEmpty) {
        return _buildErrorCard(context, ingredientsError.value, onRetry);
      }

      if (recipeIngredients.isEmpty) {
        return _buildEmptyCard(context, 'No ingredients added yet',
            Icons.restaurant_menu_outlined);
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.primaryContainer.withValues(
              alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: context.theme.colorScheme.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Preview',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              recipeIngredients.take(3).map((ing) =>
              ing['name']?.toString() ?? 'Unknown').join(', ') +
                  (recipeIngredients.length > 3 ? ', and ${recipeIngredients
                      .length - 3} more...' : ''),
              style: TextStyle(
                fontSize: 16,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to view all ingredients',
              style: TextStyle(
                fontSize: 12,
                color: context.theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildIngredientsContent(BuildContext context) {
    return Obx(() {
      if (isLoadingIngredients.value) {
        return _buildLoadingCard(context, 'Loading detailed ingredients...');
      }

      if (ingredientsError.value.isNotEmpty) {
        return _buildErrorCard(context, ingredientsError.value, onRetry);
      }

      if (recipeIngredients.isEmpty) {
        return _buildEmptyCard(
            context, 'No ingredients added to this recipe yet',
            Icons.restaurant_menu_outlined);
      }

      return Column(
        children: recipeIngredients.map((ingredient) =>
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: context.theme.colorScheme.outline.withValues(
                        alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.theme.colorScheme.primary,
                          context.theme.colorScheme.primary.withValues(
                              alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.eco, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ingredient['name']?.toString() ??
                              'Unknown Ingredient',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: context.theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${ingredient['quantity'] ?? 0}${ingredient['unit'] ?? 'g'}',
                            style: TextStyle(
                              color: context.theme.colorScheme
                                  .onSecondaryContainer,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
      );
    });
  }

  Widget _buildLoadingCard(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: context.theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                  context.theme.colorScheme.primary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.8),
                fontSize: 16,
              ),
            ),
          ),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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

  Widget _buildEmptyCard(BuildContext context, String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.amber[700]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.amber[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class RecipeNutritionDetails extends StatelessWidget {
  final Rx<Map<String, dynamic>?> nutritionData;
  final RxBool isNutritionExpanded;
  final RxList<dynamic> recipeIngredients;

  const RecipeNutritionDetails({
    super.key,
    required this.nutritionData,
    required this.isNutritionExpanded,
    required this.recipeIngredients,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final nutrition = nutritionData.value;
      if (nutrition == null) return const SizedBox.shrink();

      final hasNutritionData = (nutrition['calories'] as num? ?? 0) > 0 ||
          (nutrition['protein'] as num? ?? 0) > 0 ||
          (nutrition['carbohydrates'] as num? ?? 0) > 0 ||
          (nutrition['fat'] as num? ?? 0) > 0;

      if (!hasNutritionData) {
        return _buildNutritionPlaceholder(context);
      }

      return Column(
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
                    Icons.analytics, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Nutrition (Per Serving)',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => isNutritionExpanded.toggle(),
                icon: Obx(() =>
                    AnimatedRotation(
                      turns: isNutritionExpanded.value ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: context.theme.colorScheme.primary,
                      ),
                    )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() =>
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child: isNutritionExpanded.value
                    ? _buildExpandedNutritionContent(context, nutrition)
                    : _buildNutritionPreview(context, nutrition),
              )),
        ],
      );
    });
  }

  Widget _buildNutritionPreview(BuildContext context,
      Map<String, dynamic> nutrition) {
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
            color: context.theme.colorScheme.tertiary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildNutritionCircle(context, 'Calories',
                  '${nutrition['calories']?.toStringAsFixed(0) ?? '0'}', 'kcal',
                  Colors.orange)),
              Expanded(child: _buildNutritionCircle(context, 'Protein',
                  '${nutrition['protein']?.toStringAsFixed(1) ?? '0'}', 'g',
                  Colors.red)),
              Expanded(child: _buildNutritionCircle(context, 'Carbs',
                  '${nutrition['carbohydrates']?.toStringAsFixed(1) ?? '0'}',
                  'g', Colors.blue)),
              Expanded(child: _buildNutritionCircle(context, 'Fat',
                  '${nutrition['fat']?.toStringAsFixed(1) ?? '0'}', 'g',
                  Colors.green)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Tap to view detailed nutrition breakdown',
            style: TextStyle(
              fontSize: 12,
              color: context.theme.colorScheme.tertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCircle(BuildContext context, String label, String value,
      String unit, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 8,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: context.theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedNutritionContent(BuildContext context,
      Map<String, dynamic> nutrition) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: context.theme.colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Macronutrients
          _buildNutritionSection(
            context: context,
            title: 'Macronutrients',
            icon: Icons.pie_chart_rounded,
            color: Colors.purple,
            content: Column(
              children: [
                _buildNutritionItem(
                  context: context,
                  label: 'Calories',
                  value: '${nutrition['calories']?.toStringAsFixed(0) ?? '0'}',
                  unit: 'kcal',
                  color: Colors.orange,
                ),
                _buildNutritionItem(
                  context: context,
                  label: 'Protein',
                  value: '${nutrition['protein']?.toStringAsFixed(1) ?? '0'}',
                  unit: 'g',
                  color: Colors.red,
                ),
                _buildNutritionItem(
                  context: context,
                  label: 'Carbohydrates',
                  value: '${nutrition['carbohydrates']?.toStringAsFixed(1) ??
                      '0'}',
                  unit: 'g',
                  color: Colors.blue,
                ),
                _buildNutritionItem(
                  context: context,
                  label: 'Fat',
                  value: '${nutrition['fat']?.toStringAsFixed(1) ?? '0'}',
                  unit: 'g',
                  color: Colors.green,
                ),
                _buildNutritionItem(
                  context: context,
                  label: 'Fiber',
                  value: '${nutrition['fiber']?.toStringAsFixed(1) ?? '0'}',
                  unit: 'g',
                  color: Colors.brown,
                ),
                _buildNutritionItem(
                  context: context,
                  label: 'Sugar',
                  value: '${nutrition['sugar']?.toStringAsFixed(1) ?? '0'}',
                  unit: 'g',
                  color: Colors.pink,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Fat Breakdown
          if (nutrition['fatBreakdown'] is Map &&
              (nutrition['fatBreakdown'] as Map).isNotEmpty)
            _buildNutritionSection(
              context: context,
              title: 'Fat Breakdown',
              icon: Icons.opacity,
              color: Colors.green,
              content: Column(
                children: [
                  for (var entry in (nutrition['fatBreakdown'] as Map).entries)
                    _buildNutritionItem(
                      context: context,
                      label: _formatFatLabel(entry.key.toString()),
                      value: '${(entry.value as num?)?.toStringAsFixed(1) ??
                          '0'}',
                      unit: 'g',
                      color: Colors.green.shade700,
                    ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Vitamins
          if (nutrition['vitamins'] is Map &&
              (nutrition['vitamins'] as Map).isNotEmpty)
            _buildNutritionSection(
              context: context,
              title: 'Vitamins',
              icon: Icons.local_pharmacy_rounded,
              color: Colors.orange,
              content: Column(
                children: [
                  for (var entry in (nutrition['vitamins'] as Map).entries)
                    _buildNutritionItem(
                      context: context,
                      label: _formatVitaminLabel(entry.key.toString()),
                      value: '${(entry.value as num?)?.toStringAsFixed(1) ??
                          '0'}',
                      unit: 'mg',
                      color: Colors.orange.shade700,
                    ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Minerals
          if (nutrition['minerals'] is Map &&
              (nutrition['minerals'] as Map).isNotEmpty)
            _buildNutritionSection(
              context: context,
              title: 'Minerals',
              icon: Icons.bolt_rounded,
              color: Colors.blue,
              content: Column(
                children: [
                  for (var entry in (nutrition['minerals'] as Map).entries)
                    _buildNutritionItem(
                      context: context,
                      label: _formatMineralLabel(entry.key.toString()),
                      value: '${(entry.value as num?)?.toStringAsFixed(1) ??
                          '0'}',
                      unit: 'mg',
                      color: Colors.blue.shade700,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNutritionSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildNutritionItem({
    required BuildContext context,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    final numValue = double.tryParse(value) ?? 0.0;
    if (numValue <= 0) return const SizedBox.shrink(); // Don't show zero values

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
          const SizedBox(width: 8),
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
            '$value $unit',
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

  String _formatFatLabel(String key) {
    switch (key.toLowerCase()) {
      case 'saturated':
        return 'Saturated Fat';
      case 'monounsaturated':
        return 'Monounsaturated Fat';
      case 'polyunsaturated':
        return 'Polyunsaturated Fat';
      case 'trans':
        return 'Trans Fat';
      case 'omega3':
        return 'Omega-3 Fatty Acids';
      case 'omega6':
        return 'Omega-6 Fatty Acids';
      default:
        return key;
    }
  }

  Widget _buildNutritionPlaceholder(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.analytics_outlined, size: 48, color: Colors.amber[700]),
          const SizedBox(height: 16),
          Text(
            'Nutrition Coming Soon!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.amber[700],
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            if (recipeIngredients.isEmpty) {
              return Text(
                'Add ingredients to this recipe to unlock detailed nutrition analysis',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.amber[600],
                ),
                textAlign: TextAlign.center,
              );
            } else {
              return Text(
                'Nutrition data is being calculated based on ingredients',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.amber[600],
                ),
                textAlign: TextAlign.center,
              );
            }
          }),
        ],
      ),
    );
  }
}

class RecipePreparationSteps extends StatelessWidget {
  final dynamic recipe;
  final RxBool isStepsExpanded;

  const RecipePreparationSteps({
    super.key,
    required this.recipe,
    required this.isStepsExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final String description = recipe['description']?.toString() ?? '';

    final List<String> steps = _extractSteps(description);

    return Column(
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
                  Icons.format_list_numbered_rounded,
                  color: Colors.white,
                  size: 20
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Preparation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Obx(() =>
                IconButton(
                  onPressed: () => isStepsExpanded.toggle(),
                  icon: AnimatedRotation(
                    turns: isStepsExpanded.value ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: context.theme.colorScheme.primary,
                    ),
                  ),
                )),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() =>
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: isStepsExpanded.value
                  ? _buildStepsContent(context, steps)
                  : _buildStepsPreview(context, steps),
            )),
      ],
    );
  }

  Widget _buildStepsContent(BuildContext context, List<String> steps) {
    if (steps.isEmpty) {
      return _buildEmptyCard(context);
    }

    return Column(
      children: List.generate(
        steps.length,
            (index) =>
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.theme.colorScheme.outline.withValues(
                      alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        steps[index],
                        style: TextStyle(
                          fontSize: 16,
                          color: context.theme.colorScheme.onSurface,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildStepsPreview(BuildContext context, List<String> steps) {
    if (steps.isEmpty) {
      return _buildEmptyCard(context);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.primaryContainer.withValues(
            alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: context.theme.colorScheme.primary.withValues(alpha: 0.2)
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Preview',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            steps.isNotEmpty
                ? '${steps.length} step${steps.length > 1
                ? 's'
                : ''} to prepare this recipe'
                : 'No preparation steps available',
            style: TextStyle(
              fontSize: 16,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to view all steps',
            style: TextStyle(
              fontSize: 12,
              color: context.theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.format_list_numbered_outlined, size: 48,
              color: Colors.amber[700]),
          const SizedBox(height: 16),
          Text(
            'No preparation steps available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.amber[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<String> _extractSteps(String description) {
    if (description.isEmpty) {
      return [];
    }

    return description.split('\n');
  }
}