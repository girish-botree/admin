import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../meal_controller.dart';
import 'package:admin/utils/image_base64_util.dart';
import '../dialogs/ingredient_dialogs.dart';

class IngredientDetailScreen extends StatelessWidget {
  final dynamic ingredient;

  const IngredientDetailScreen({super.key, required this.ingredient});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MealController>();

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
                    IngredientDialogs.showEditIngredientDialog(
                        context, controller, ingredient);
                  },
                  icon: const Icon(Icons.edit_rounded, color: Colors.white),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Ingredient image
                  _buildIngredientImage(context),
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
                  // Ingredient title and quick info
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ingredient['name']?.toString() ??
                              'Unknown Ingredient',
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
                              Icons.local_fire_department_rounded,
                              '${ingredient['calories'] ?? 0} cal',
                              Colors.orange,
                            ),
                            if (ingredient['category']
                                ?.toString()
                                .isNotEmpty == true)
                              _buildInfoChip(
                                Icons.category_rounded,
                                ingredient['category']?.toString() ?? '',
                                Colors.green,
                              ),
                            if (ingredient['dietaryCategory'] != null &&
                                ingredient['dietaryCategory'] != 0)
                              _buildInfoChip(
                                Icons.eco_rounded,
                                _getDietaryLabel(
                                    ingredient['dietaryCategory'] as int),
                                Colors.blue,
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
                        if (ingredient['description']
                            ?.toString()
                            .isNotEmpty == true)
                          _buildDescriptionSection(context),

                        const SizedBox(height: 32),

                        // Macronutrient overview
                        _buildMacronutrientOverview(context),

                        const SizedBox(height: 32),

                        // Detailed nutrition
                        _buildDetailedNutrition(context),

                        const SizedBox(height: 32),

                        // Fat breakdown
                        _buildFatBreakdown(context),

                        const SizedBox(height: 32),

                        // Micronutrients
                        _buildMicronutrients(context),

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
          IngredientDialogs.showEditIngredientDialog(
              context, controller, ingredient);
        },
        backgroundColor: context.theme.colorScheme.primaryContainer,
        foregroundColor: context.theme.colorScheme.onPrimaryContainer,
        icon: const Icon(Icons.edit_rounded),
        label: const Text('Edit Ingredient'),
      ),
    );
  }

  Widget _buildIngredientImage(BuildContext context) {
    final imageUrl = ingredient['imageUrl']?.toString();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ImageBase64Util.buildImage(
        imageUrl,
        fit: BoxFit.cover,
        errorWidget: const SizedBox.shrink(),
      );
    }
    return const SizedBox.shrink();
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
                'About this ingredient',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ingredient['description']?.toString() ?? 'No description available',
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

  Widget _buildMacronutrientOverview(BuildContext context) {
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
                'Macronutrients per 100g',
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
                  '${ingredient['calories'] ?? 0}',
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
                  '${ingredient['protein'] ?? 0}',
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
                  '${ingredient['carbohydrates'] ?? 0}',
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
                  '${ingredient['fat'] ?? 0}',
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

  Widget _buildDetailedNutrition(BuildContext context) {
    final fiber = (ingredient['fiber'] as num?) ?? 0;
    final sugar = (ingredient['sugar'] as num?) ?? 0;

    if (fiber == 0 && sugar == 0) {
      return const SizedBox.shrink();
    }

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
                'Additional nutrition',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (fiber > 0)
            _buildNutrientRow(context, 'Fiber', '${fiber}g', Colors.brown),
          if (sugar > 0)
            _buildNutrientRow(context, 'Sugar', '${sugar}g', Colors.pink),
        ],
      ),
    );
  }

  Widget _buildFatBreakdown(BuildContext context) {
    Map<String, dynamic> fatBreakdown = {};
    try {
      final fatBreakdownStr = ingredient['fatBreakdown'] as String?;
      if (fatBreakdownStr != null && fatBreakdownStr.isNotEmpty) {
        final decoded = jsonDecode(fatBreakdownStr);
        if (decoded is Map<String, dynamic>) {
          fatBreakdown = decoded;
        }
      }
    } catch (e) {
      // Ignore JSON parsing errors
    }

    if (fatBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

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
                    Icons.pie_chart_outline_rounded, color: Colors.white,
                    size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Fat breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final entry in fatBreakdown.entries)
            if (entry.value is num && (entry.value as num) > 0)
              _buildNutrientRow(
                context,
                _formatFatLabel(entry.key),
                '${(entry.value as num).toStringAsFixed(1)}g',
                Colors.green.shade700,
              ),
        ],
      ),
    );
  }

  Widget _buildMicronutrients(BuildContext context) {
    Map<String, dynamic> vitamins = {};
    Map<String, dynamic> minerals = {};

    try {
      final vitaminsStr = ingredient['vitamins'] as String?;
      if (vitaminsStr != null && vitaminsStr.isNotEmpty) {
        final decoded = jsonDecode(vitaminsStr);
        if (decoded is Map<String, dynamic>) {
          vitamins = decoded;
        }
      }

      final mineralsStr = ingredient['minerals'] as String?;
      if (mineralsStr != null && mineralsStr.isNotEmpty) {
        final decoded = jsonDecode(mineralsStr);
        if (decoded is Map<String, dynamic>) {
          minerals = decoded;
        }
      }
    } catch (e) {
      // Ignore JSON parsing errors
    }

    if (vitamins.isEmpty && minerals.isEmpty) {
      return const SizedBox.shrink();
    }

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
                    Icons.local_pharmacy_rounded, color: Colors.white,
                    size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Micronutrients',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (vitamins.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vitamins',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final key in vitamins.keys)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.spa_rounded, size: 14,
                                color: Colors.orange),
                            const SizedBox(width: 4),
                            Text(
                              key,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),

          if (minerals.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Minerals',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final key in minerals.keys)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                                Icons.bolt_rounded, size: 14,
                                color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(
                              key,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(BuildContext context, String label, String value,
      Color color) {
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
      default:
        return key;
    }
  }
}