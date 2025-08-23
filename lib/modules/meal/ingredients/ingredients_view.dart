import 'dart:convert';

import 'package:admin/config/app_config.dart';
import 'package:admin/utils/responsive.dart';
import '../meal_controller.dart';
import 'package:flutter/services.dart';

class IngredientsView extends GetView<MealController> {
  const IngredientsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MealController());
    
    return SafeArea(
      child: Scaffold(
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        appBar: _buildModernAppBar(context),
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

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      title: Text(
        'Ingredients',
        style: TextStyle(
          fontSize: Responsive.getTitleTextSize(context),
          fontWeight: FontWeight.w600,
          color: context.theme.colorScheme.onSurface,
          letterSpacing: -0.5,
        ),
      ),
      leading: IconButton(
        onPressed: () => Get.back<void>(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: context.theme.colorScheme.onSurface,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Obx(() =>
                Text(
                  '${controller.ingredients.length} items',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.theme.colorScheme.primary,
                  ),
                )),
          ),
        ),
      ],
    );
  }

  Widget _buildModernFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddIngredientDialog(context),
      backgroundColor: context.theme.colorScheme.primary,
      foregroundColor: context.theme.colorScheme.onPrimary,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Add Ingredient',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
  
  Widget _buildErrorState(BuildContext context, MealController controller) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.errorContainer.withValues(
              alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: context.theme.colorScheme.error.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: context.theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data not found, try restarting the app',
              style: TextStyle(
                fontSize: 16,
                color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => controller.fetchIngredients(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.theme.colorScheme.primary.withValues(alpha: 0.2),
                    context.theme.colorScheme.primary.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.eco_rounded,
                size: 64,
                color: context.theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No ingredients yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start building your ingredient library\nby adding your first ingredient',
              style: TextStyle(
                fontSize: 16,
                color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showAddIngredientDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add First Ingredient'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildIngredientGrid(BuildContext context, MealController controller) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 121),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = _getCrossAxisCount(
                  constraints.crossAxisExtent);

              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.0, // Square format
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final ingredient = controller.ingredients[index];
                    return _buildCompactIngredientCard(context, ingredient);
                  },
                  childCount: controller.ingredients.length,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  int _getCrossAxisCount(double width) {
    if (width > 1200) return 7; // More columns for larger screens
    if (width > 900) return 5;
    if (width > 700) return 4;
    if (width > 500) return 3;
    if (width > 300) return 2;
    return 1; // Minimum 1 column to prevent overflow
  }

  Widget _buildCompactIngredientCard(BuildContext context, dynamic ingredient) {
    final colors = [
      Colors.deepPurple,
      Colors.indigo,
      Colors.teal,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
      Colors.amber,
      Colors.green,
    ];
    final color = colors[ingredient['name']
        .toString()
        .length % colors.length];

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 200 + (ingredient['name']
          .toString()
          .length % 3) * 30),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: () => _showIngredientDetails(context, ingredient),
            child: Container(
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: context.theme.colorScheme.shadow.withValues(
                        alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Compact header
                    Container(
                      height: 50, // Reduced height for square format
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.8),
                            color.withValues(alpha: 0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Simple background pattern
                          Positioned(
                            right: -10,
                            top: -10,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),

                          // Compact icon
                          Positioned(
                            left: 10,
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                _getIngredientIcon(
                                    ingredient['category'] as String?),
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // Compact menu
                          Positioned(
                            right: 6,
                            top: 6,
                            child: _buildCompactPopupMenu(context, ingredient),
                          ),
                        ],
                      ),
                    ),

                    // Compact content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12), // Reduced padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Name - single line
                            Text(
                              (ingredient['name'] as String?) ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 13, // Reduced font size
                                fontWeight: FontWeight.w700,
                                color: context.theme.colorScheme.onSurface,
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4), // Reduced spacing

                            // Category badge - smaller
                            if ((ingredient['category'] as String?)
                                ?.isNotEmpty == true)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  ingredient['category'] as String,
                                  style: TextStyle(
                                    fontSize: 7, // Reduced font size
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                ),
                              ),

                            const Spacer(),

                            // Compact nutrition - horizontal layout
                            _buildCompactNutrientDisplay(
                                context, ingredient, color),
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
      },
    );
  }

  IconData _getIngredientIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'vegetable':
      case 'vegetables':
        return Icons.local_florist_rounded;
      case 'fruit':
      case 'fruits':
        return Icons.apple_rounded;
      case 'meat':
      case 'protein':
        return Icons.set_meal_rounded;
      case 'dairy':
        return Icons.emoji_food_beverage_rounded;
      case 'grain':
      case 'grains':
        return Icons.grain_rounded;
      case 'spice':
      case 'spices':
        return Icons.scatter_plot_rounded;
      case 'oil':
      case 'oils':
        return Icons.opacity_rounded;
      case 'nut':
      case 'nuts':
        return Icons.circle_rounded;
      case 'seafood':
      case 'fish':
        return Icons.set_meal_outlined;
      default:
        return Icons.eco_rounded;
    }
  }

  Widget _buildCompactPopupMenu(BuildContext context, dynamic ingredient) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.more_vert_rounded,
          size: 14,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        color: context.theme.colorScheme.surface,
        onSelected: (value) {
          switch (value) {
            case 'edit':
              _showEditIngredientDialog(context, ingredient);
              break;
            case 'delete':
              _showDeleteConfirmation(context, ingredient);
              break;
          }
        },
        itemBuilder: (context) =>
        [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_rounded, size: 16, color: Colors.blue),
                SizedBox(width: 8),
                Text('Edit', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_rounded, size: 16, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete',
                    style: TextStyle(fontSize: 13, color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactNutrientDisplay(BuildContext context, dynamic ingredient,
      Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(6), // Reduced padding
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainer.withValues(
            alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCompactNutrientItem(
            context,
            Icons.local_fire_department_rounded,
            '${((ingredient['calories'] as num?) ?? 0).toInt()}',
            Colors.orange,
          ),
          _buildCompactNutrientItem(
            context,
            Icons.fitness_center_rounded,
            '${((ingredient['protein'] as num?) ?? 0).toInt()}g',
            Colors.red,
          ),
          _buildCompactNutrientItem(
            context,
            Icons.grain_rounded,
            '${((ingredient['carbohydrates'] as num?) ?? 0).toInt()}g',
            Colors.blue,
          ),
          _buildCompactNutrientItem(
            context,
            Icons.opacity_rounded,
            '${((ingredient['fat'] as num?) ?? 0).toInt()}g',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactNutrientItem(BuildContext context, IconData icon,
      String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color.withValues(alpha: 0.7)),
        // Reduced icon size
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 9, // Reduced font size
            fontWeight: FontWeight.w600,
            color: context.theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroChip(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color.withValues(alpha: 0.8)),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  void _showAddIngredientDialog(BuildContext context) {
    controller.clearIngredientForm();
    int dietaryCategory = 0;

    Get.dialog<void>(
      Dialog.fullscreen(
        backgroundColor: context.theme.colorScheme.surface,
        child: Scaffold(
          backgroundColor: context.theme.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Get.back<void>(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
            ),
            title: Text(
              'Add New Ingredient',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: FilledButton.icon(
                  onPressed: () {
                    if (controller.validateIngredientForm()) {
                      final data = controller.createIngredientData(
                          dietaryCategory);
                      controller.createIngredient(data).then((success) {
                        if (success) {
                          Get.back<void>();
                          Get.snackbar(
                              'Success', 'Ingredient created successfully');
                        }
                      });
                    }
                  },
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Save'),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModernSection(
                  context,
                  'Basic Information',
                  Icons.info_outline_rounded,
                  [
                    _buildValidatedTextField(
                      controller.nameController,
                      'Ingredient Name',
                      context,
                      isRequired: true,
                      errorText: controller.nameError.value,
                      onChanged: controller.validateName,
                    ),
                    const SizedBox(height: 16),
                    _buildValidatedTextField(
                      controller.descriptionController,
                      'Description',
                      context,
                      maxLines: 3,
                      errorText: controller.descriptionError.value,
                      onChanged: controller.validateDescription,
                    ),
                    const SizedBox(height: 16),
                    _buildValidatedTextField(
                      controller.categoryController,
                      'Category',
                      context,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                _buildModernSection(
                  context,
                  'Nutritional Information',
                  Icons.analytics_outlined,
                  [
                    Row(
                      children: [
                        Expanded(
                          child: _buildValidatedTextField(
                            controller.caloriesController,
                            'Calories',
                            context,
                            keyboardType: TextInputType.number,
                            inputFormatters: MealController
                                .getIntegerInputFormatters(),
                            errorText: controller.caloriesError.value,
                            onChanged: controller.validateCalories,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildValidatedTextField(
                            controller.proteinController,
                            'Protein (g)',
                            context,
                            keyboardType: TextInputType.number,
                            inputFormatters: MealController
                                .getNumberInputFormatters(),
                            errorText: controller.proteinError.value,
                            onChanged: (value) =>
                                controller.validateNutrient(
                                    value, controller.proteinError, 'Protein'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildValidatedTextField(
                            controller.carbsController,
                            'Carbs (g)',
                            context,
                            keyboardType: TextInputType.number,
                            inputFormatters: MealController
                                .getNumberInputFormatters(),
                            errorText: controller.carbsError.value,
                            onChanged: (value) =>
                                controller.validateNutrient(
                                    value, controller.carbsError, 'Carbs'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildValidatedTextField(
                            controller.fatController,
                            'Fat (g)',
                            context,
                            keyboardType: TextInputType.number,
                            inputFormatters: MealController
                                .getNumberInputFormatters(),
                            errorText: controller.fatError.value,
                            onChanged: (value) =>
                                controller.validateNutrient(
                                    value, controller.fatError, 'Fat'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildValidatedTextField(
                            controller.fiberController,
                            'Fiber (g)',
                            context,
                            keyboardType: TextInputType.number,
                            inputFormatters: MealController
                                .getNumberInputFormatters(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildValidatedTextField(
                            controller.sugarController,
                            'Sugar (g)',
                            context,
                            keyboardType: TextInputType.number,
                            inputFormatters: MealController
                                .getNumberInputFormatters(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                _buildModernSection(
                  context,
                  'Fat Breakdown',
                  Icons.pie_chart_outline_rounded,
                  [
                    Row(
                      children: [
                        Expanded(
                          child: _buildValidatedTextField(
                            controller.saturatedFatController,
                            'Saturated (g)',
                            context,
                            keyboardType: TextInputType.number,
                            inputFormatters: MealController
                                .getNumberInputFormatters(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildValidatedTextField(
                            controller.monoFatController,
                            'Monounsaturated (g)',
                            context,
                            keyboardType: TextInputType.number,
                            inputFormatters: MealController
                                .getNumberInputFormatters(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildValidatedTextField(
                      controller.polyFatController,
                      'Polyunsaturated (g)',
                      context,
                      keyboardType: TextInputType.number,
                      inputFormatters: MealController
                          .getNumberInputFormatters(),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                _buildModernSection(
                  context,
                  'Additional Information',
                  Icons.more_horiz_rounded,
                  [
                    _buildValidatedTextField(
                      controller.vitaminsController,
                      'Vitamins (JSON format)',
                      context,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildValidatedTextField(
                      controller.mineralsController,
                      'Minerals (JSON format)',
                      context,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildModernDietaryDropdown(
                        context, dietaryCategory, (value) =>
                    dietaryCategory = value ?? 0),
                  ],
                ),

                const SizedBox(height: 100), // Bottom padding for scrolling
              ],
            )),
          ),
        ),
      ),
    );
  }

  // Removed obsolete _buildModernNutrientChips and _buildCompactNutrientChip methods.

  Widget _buildModernSection(BuildContext context, String title, IconData icon,
      List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.primary.withValues(
                      alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: context.theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  /// Modern dietary dropdown for Material 3 design in add dialog
  Widget _buildModernDietaryDropdown(BuildContext context, int value,
      void Function(int?) onChanged) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(
        labelText: 'Dietary Category',
        labelStyle: TextStyle(
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: context.theme.colorScheme.outline.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: context.theme.colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: context.theme.colorScheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
      ),
      style: TextStyle(color: context.theme.colorScheme.onSurface),
      dropdownColor: context.theme.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      icon: Icon(Icons.arrow_drop_down_rounded,
          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.8)),
      items: const [
        DropdownMenuItem(value: 0, child: Text('Regular')),
        DropdownMenuItem(value: 1, child: Text('Vegetarian')),
        DropdownMenuItem(value: 2, child: Text('Vegan')),
        DropdownMenuItem(value: 3, child: Text('Gluten-Free')),
        DropdownMenuItem(value: 4, child: Text('Dairy-Free')),
        DropdownMenuItem(value: 5, child: Text('Keto')),
        DropdownMenuItem(value: 6, child: Text('Paleo')),
      ],
      onChanged: onChanged,
    );
  }

  void _showEditIngredientDialog(BuildContext context, dynamic ingredient) {
    controller.setupIngredientForm(ingredient);
    int dietaryCategory = (ingredient['dietaryCategory'] as int?) ?? 0;
    bool isActive = (ingredient['isActive'] as bool?) ?? true;
    
    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Ingredient',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: context.theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle(context, 'Basic Information'),
                  const SizedBox(height: 12),
                  _buildTextField(controller.nameController, 'Ingredient Name', context),
                  const SizedBox(height: 12),
                  _buildTextField(controller.descriptionController, 'Description', context, maxLines: 3),
                  const SizedBox(height: 12),
                  _buildTextField(controller.categoryController, 'Category', context),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Active Status', style: TextStyle(fontSize: 16, color: context.theme.colorScheme.onSurface)),
                      const SizedBox(width: 16),
                      Switch(
                        value: isActive,
                        onChanged: (value) => setState(() => isActive = value),
                        activeColor: context.theme.colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle(context, 'Nutritional Information'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(controller.caloriesController, 'Calories', context, keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(controller.proteinController, 'Protein (g)', context, keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(controller.carbsController, 'Carbs (g)', context, keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(controller.fatController, 'Fat (g)', context, keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(controller.fiberController, 'Fiber (g)', context, keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(controller.sugarController, 'Sugar (g)', context, keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle(context, 'Fat Breakdown'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(controller.saturatedFatController, 'Saturated (g)', context, keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(controller.monoFatController, 'Monounsaturated (g)', context, keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(controller.polyFatController, 'Polyunsaturated (g)', context, keyboardType: TextInputType.number),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle(context, 'Additional Information'),
                  const SizedBox(height: 12),
                  _buildTextField(controller.vitaminsController, 'Vitamins (JSON format)', context, maxLines: 3),
                  const SizedBox(height: 12),
                  _buildTextField(controller.mineralsController, 'Minerals (JSON format)', context, maxLines: 3),
                  const SizedBox(height: 12),
                  _buildDietaryDropdown(context, dietaryCategory, (value) => setState(() => dietaryCategory = value ?? 0)),
                  const SizedBox(height: 32),
                  
                  _buildDialogActions(context, () {
                    if (controller.nameController.text.isEmpty) {
                      Get.snackbar('Error', 'Ingredient name is required');
                      return;
                    }
                    
                    final data = controller.createIngredientData(dietaryCategory);
                    data['isActive'] = isActive;

                    final ingredientId = (ingredient['ingredientId'] as String?) ??
                        '';
                    controller.updateIngredient(ingredientId, data).then((
                        success) {
                      if (success) {
                        Get.back<void>();
                        Get.snackbar('Success', 'Ingredient updated successfully');
                      }
                    });
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildValidatedTextField(
    TextEditingController textController,
    String label,
    BuildContext context, {
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
    void Function(String)? onChanged,
    bool isRequired = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: textController,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: TextStyle(
          color: context.theme.colorScheme.onSurface,
          fontSize: 16,
        ),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          labelStyle: TextStyle(
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: context.theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: context.theme.colorScheme.primary,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          errorText: errorText != null && errorText.isNotEmpty
              ? errorText
              : null,
          errorStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: context.theme.colorScheme.surfaceContainerLowest,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 16 : 14,
          ),
          suffixIcon: isRequired
              ? Icon(
            Icons.star,
            size: 12,
            color: Colors.red.withValues(alpha: 0.6),
          )
              : null,
        ),
      ),
    );
  }
  
  Widget _buildTextField(
    TextEditingController textController,
    String label,
    BuildContext context, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: textController,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(
          color: context.theme.colorScheme.onSurface,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: context.theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: context.theme.colorScheme.primary,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: context.theme.colorScheme.surfaceContainerLowest,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 16 : 14,
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: context.theme.colorScheme.onSurface,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildDietaryDropdown(BuildContext context, int value,
      void Function(int?) onChanged) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<int>(
        value: value,
        decoration: InputDecoration(
          labelText: 'Dietary Category',
          labelStyle: TextStyle(
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: context.theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: context.theme.colorScheme.primary,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: context.theme.colorScheme.surfaceContainerLowest,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
        ),
        style: TextStyle(
          color: context.theme.colorScheme.onSurface,
          fontSize: 16,
        ),
        dropdownColor: context.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        icon: Icon(
          Icons.arrow_drop_down_rounded,
          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.8),
        ),
        items: const [
          DropdownMenuItem(value: 0, child: Text('Regular')),
          DropdownMenuItem(value: 1, child: Text('Vegetarian')),
          DropdownMenuItem(value: 2, child: Text('Vegan')),
          DropdownMenuItem(value: 3, child: Text('Gluten-Free')),
          DropdownMenuItem(value: 4, child: Text('Dairy-Free')),
          DropdownMenuItem(value: 5, child: Text('Keto')),
          DropdownMenuItem(value: 6, child: Text('Paleo')),
        ],
        onChanged: onChanged,
      ),
    );
  }
  
  Widget _buildDialogActions(BuildContext context, VoidCallback onSave) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Get.back<void>(),
              icon: const Icon(Icons.close_rounded),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: BorderSide(
                  color: context.theme.colorScheme.outline.withValues(
                      alpha: 0.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, dynamic ingredient) {
    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: context.theme.colorScheme.surface,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 32,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Delete Ingredient',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete "${(ingredient['name'] as String?) ??
                    (ingredient['ingredientName'] as String?) ?? 'Unknown'}"?',
                style: TextStyle(
                  fontSize: 16,
                  color: context.theme.colorScheme.onSurface.withValues(
                      alpha: 0.8),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  fontSize: 14,
                  color: context.theme.colorScheme.onSurface.withValues(
                      alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back<void>(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(
                          color: context.theme.colorScheme.outline.withValues(
                              alpha: 0.5),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final ingredientId = (ingredient['ingredientId'] as String?) ??
                            '';
                        controller.deleteIngredient(ingredientId).then((
                            success) {
                          if (success) {
                            Get.back<void>();
                            Get.snackbar(
                                'Success', 'Ingredient deleted successfully');
                          }
                        });
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showIngredientDetails(BuildContext context, dynamic ingredient) {
    // Implementation for ingredient details dialog
    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: context.theme.colorScheme.surface,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (ingredient['name'] as String?) ?? 'Unknown Ingredient',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  (ingredient['description'] as String?) ??
                      'No description available',
                  style: TextStyle(
                    fontSize: 16,
                    color: context.theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Nutritional Information (per 100g)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                _buildNutrientInfo(context, 'Calories',
                    '${((ingredient['calories'] as num?) ?? 0).toInt()}'),
                _buildNutrientInfo(context, 'Protein',
                    '${((ingredient['protein'] as num?) ?? 0).toInt()}g'),
                _buildNutrientInfo(context, 'Carbohydrates',
                    '${((ingredient['carbohydrates'] as num?) ?? 0).toInt()}g'),
                _buildNutrientInfo(
                    context, 'Fat',
                    '${((ingredient['fat'] as num?) ?? 0).toInt()}g'),
                _buildNutrientInfo(
                    context, 'Fiber',
                    '${((ingredient['fiber'] as num?) ?? 0).toInt()}g'),
                _buildNutrientInfo(
                    context, 'Sugar',
                    '${((ingredient['sugar'] as num?) ?? 0).toInt()}g'),
                const SizedBox(height: 24),
                ...(() {
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
                  return [
                    _buildNutrientInfo(context, 'Saturated Fat',
                        '${(fatBreakdown['Saturated'] as num?)?.toInt() ??
                            0}g'),
                    _buildNutrientInfo(context, 'Monounsaturated Fat',
                        '${(fatBreakdown['Monounsaturated'] as num?)?.toInt() ??
                            0}g'),
                    _buildNutrientInfo(context, 'Polyunsaturated Fat',
                        '${(fatBreakdown['Polyunsaturated'] as num?)?.toInt() ??
                            0}g'),
                  ];
                })(),
              ],
            
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildNutrientInfo(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.0, // Square format
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              return _ShimmerIngredientCard();
            },
          );
        },
      ),
    );
  }
}

class _ShimmerIngredientCard extends StatefulWidget {
  @override
  _ShimmerIngredientCardState createState() => _ShimmerIngredientCardState();
}

class _ShimmerIngredientCardState extends State<_ShimmerIngredientCard>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOutSine,
    ));
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          color: context.theme.colorScheme.surfaceContainerLowest,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildShimmerContainer(100, 16, borderRadius: 8),
                    ),
                    const SizedBox(width: 8),
                    _buildShimmerContainer(24, 24, borderRadius: 12),
                  ],
                ),
                const SizedBox(height: 8),
                _buildShimmerContainer(120, 14, borderRadius: 6),
                const SizedBox(height: 6),
                Divider(height: 10,
                    color: context.theme.colorScheme.outline.withValues(alpha: 0.3)),
                const SizedBox(height: 4),
                _buildShimmerNutrientChips(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerNutrientChips() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildShimmerChip()),
            const SizedBox(width: 4),
            Expanded(child: _buildShimmerChip()),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(child: _buildShimmerChip()),
            const SizedBox(width: 4),
            Expanded(child: _buildShimmerChip()),
          ],
        ),
      ],
    );
  }

  Widget _buildShimmerChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildShimmerContainer(20, 8, borderRadius: 4),
          const SizedBox(height: 2),
          _buildShimmerContainer(30, 10, borderRadius: 4),
        ],
      ),
    );
  }

  Widget _buildShimmerContainer(double width, double height,
      {double borderRadius = 4}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment(_shimmerAnimation.value - 1, 0),
          end: Alignment(_shimmerAnimation.value, 0),
          colors: const [
            Color(0xFFEBEBF4),
            Color(0xFFF4F4F4),
            Color(0xFFEBEBF4),
          ],
          stops: const [0.1, 0.3, 0.4],
        ),
      ),
    );
  }
}