import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_text.dart';
import '../../../widgets/searchable_dropdown.dart';
import '../../../widgets/multi_select_dropdown.dart';
import '../../../config/dropdown_data.dart';
import '../plan_controller.dart';
import '../meal_plan_assignment_model.dart'
    show MealPeriod, MealCategory, BmiCategory;

class MealPlanFormDialog extends StatelessWidget {
  final bool isEdit;
  final DateTime? selectedDate;
  
  const MealPlanFormDialog({
    super.key,
    this.isEdit = false,
    this.selectedDate,
  });

  // Cache for recipe icons to avoid recalculating
  static final Map<String, String> _iconCache = <String, String>{};
  
  // Helper method to get recipe icon based on category or type
  String _getRecipeIcon(dynamic recipe) {
    if (recipe is Map<String, dynamic>) {
      final recipeId = recipe['recipeId']?.toString() ?? '';
      
      // Check cache first for performance
      if (_iconCache.containsKey(recipeId)) {
        return _iconCache[recipeId]!;
      }
      
      final name = recipe['name']?.toString().toLowerCase() ?? '';
      String icon;

      // Try to determine icon based on recipe name keywords
      if (name.contains('breakfast') || name.contains('cereal') ||
          name.contains('oats')) {
        icon = '🥣';
      } else if (name.contains('salad')) {
        icon = '🥗';
      } else if (name.contains('soup')) {
        icon = '🍲';
      } else if (name.contains('chicken') || name.contains('meat')) {
        icon = '🍗';
      } else if (name.contains('fish') || name.contains('salmon')) {
        icon = '🐟';
      } else if (name.contains('vegetable') || name.contains('veggie')) {
        icon = '🥬';
      } else if (name.contains('pasta') || name.contains('noodle')) {
        icon = '🍝';
      } else if (name.contains('rice')) {
        icon = '🍚';
      } else if (name.contains('dessert') || name.contains('cake') ||
          name.contains('sweet')) {
        icon = '🍰';
      } else if (name.contains('drink') || name.contains('smoothie') ||
          name.contains('juice')) {
        icon = '🥤';
      } else {
        icon = '🍽️'; // Default icon
      }
      
      // Cache the result
      if (recipeId.isNotEmpty) {
        _iconCache[recipeId] = icon;
      }
      
      return icon;
    }

    // Default icon
    return '🍽️';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlanController>();
    final theme = Theme.of(context);
    final screenSize = MediaQuery
        .of(context)
        .size;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenSize.width > 600 ? 40 : 16,
        vertical: 24,
      ),
      child: Container(
        width: screenSize.width > 600 ? 560 : double.infinity,
        constraints: BoxConstraints(
          maxHeight: screenSize.height * 0.85,
          maxWidth: 600,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Obx(() =>
        controller.showDietTypeSelection.value
            ? _buildDietTypeSelection(context, controller, theme)
            : _buildMealPlanForm(context, controller, theme),
        ),
      ),
    );
  }

  Widget _buildDietTypeSelection(BuildContext context,
      PlanController controller, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppText.h5(
                  'Choose Diet Type',
                  color: theme.colorScheme.onSurface,
                ),
              ),
              IconButton(
                onPressed: () => Get.back<void>(),
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Selected Date Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withAlpha(140),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withAlpha(50),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.caption(
                        'Planning meals for',
                        color: theme.colorScheme.onPrimaryContainer.withAlpha(
                            200),
                      ),
                      AppText.semiBold(
                        _formatDate(selectedDate ??
                            controller.selectedCalendarDate.value),
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          AppText.semiBold(
            'Select your preferred diet type:',
            color: theme.colorScheme.onSurface,
            size: 16,
          ),
          const SizedBox(height: 16),

          // Diet Type Options
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDietTypeCard(
                    context,
                    theme,
                    'Vegan',
                    'Completely plant-based meals',
                    Icons.spa,
                    const Color(0xFF009688),
                    MealCategory.vegan,
                    controller,
                  ),
                  const SizedBox(height: 12),
                  _buildDietTypeCard(
                    context,
                    theme,
                    'Vegetarian',
                    'Plant-based meals with dairy',
                    Icons.eco,
                    const Color(0xFF4CAF50),
                    MealCategory.vegetarian,
                    controller,
                  ),
                  const SizedBox(height: 12),
                  _buildDietTypeCard(
                    context,
                    theme,
                    'Eggitarian',
                    'Plant-based with dairy and eggs',
                    Icons.egg,
                    const Color(0xFFFFC107),
                    MealCategory.eggitarian,
                    controller,
                  ),
                  const SizedBox(height: 12),
                  _buildDietTypeCard(
                    context,
                    theme,
                    'Non-Vegetarian',
                    'Includes meat, poultry, and seafood',
                    Icons.restaurant,
                    const Color(0xFFFF9800),
                    MealCategory.nonVegetarian,
                    controller,
                  ),
                  const SizedBox(height: 12),
                  _buildDietTypeCard(
                    context,
                    theme,
                    'Other',
                    'Other dietary preferences',
                    Icons.more_horiz,
                    const Color(0xFF9E9E9E),
                    MealCategory.other,
                    controller,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Continue Button
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back<void>(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: AppText.medium(
                    'Cancel',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Obx(() =>
                    FilledButton.icon(
                      onPressed: controller.selectedDietType.value != null
                          ? () => controller.proceedToMealSelection()
                          : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward, size: 20),
                      label: AppText.medium(
                        'Continue',
                        color: theme.colorScheme.onPrimary,
                      ),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDietTypeCard(BuildContext context,
      ThemeData theme,
      String title,
      String description,
      IconData icon,
      Color color,
      MealCategory category,
      PlanController controller,) {
    return Obx(() =>
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.selectedDietType.value = category,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: controller.selectedDietType.value == category
                    ? color.withAlpha(25)
                    : theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: controller.selectedDietType.value == category
                      ? color
                      : theme.colorScheme.outline.withAlpha(50),
                  width: controller.selectedDietType.value == category ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.semiBold(
                          title,
                          color: theme.colorScheme.onSurface,
                          size: 16,
                        ),
                        const SizedBox(height: 4),
                        AppText.body2(
                          description,
                          color: theme.colorScheme.onSurface.withAlpha(140),
                        ),
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: controller.selectedDietType.value == category
                        ? Container(
                      key: ValueKey(category),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    )
                        : const SizedBox(width: 28, height: 28),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildMealPlanForm(BuildContext context, PlanController controller,
      ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: controller.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  onPressed: () =>
                  controller.showDietTypeSelection.value = true,
                  icon: Icon(
                      Icons.arrow_back, color: theme.colorScheme.onSurface),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppText.h5(
                    'Plan Your Meals',
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back<void>(),
                  icon: Icon(
                    Icons.close,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Selected Date and Diet Type
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.event,
                          color: theme.colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: AppText.caption(
                            _formatDate(selectedDate ??
                                controller.selectedCalendarDate.value),
                            color: theme.colorScheme.primary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() =>
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getDietColor(controller.selectedDietType
                              .value).withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getDietIcon(controller.selectedDietType.value),
                              color: _getDietColor(
                                  controller.selectedDietType.value),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: AppText.caption(
                                _getDietLabel(
                                    controller.selectedDietType.value),
                                color: _getDietColor(
                                    controller.selectedDietType.value),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // BMI Category Selection using new dropdown
            AppText.semiBold(
                'BMI Category', color: theme.colorScheme.onSurface),
            const SizedBox(height: 8),
            Obx(() =>
                TypedSearchableDropdown(
                  dropdownType: DropdownType.bmiCategories,
                  value: _bmiCategoryToString(
                      controller.selectedBmiCategory.value),
                  label: 'BMI Category',
                  hint: 'Select BMI category',
                  onChanged: (value) {
                    final category = _stringToBmiCategory(value as String?);
                    if (category != null) {
                      controller.selectedBmiCategory.value = category;
                    }
                  },
                )),
            const SizedBox(height: 20),

            // Meal Sections
            AppText.semiBold(
              'Select Meals',
              color: theme.colorScheme.onSurface,
              size: 18,
            ),
            const SizedBox(height: 16),

            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMealSection(
                      context,
                      controller,
                      theme,
                      'Breakfast',
                      MealPeriod.breakfast,
                      Icons.wb_sunny,
                      const Color(0xFFFF9800),
                    ),
                    const SizedBox(height: 16),
                    _buildMealSection(
                      context,
                      controller,
                      theme,
                      'Lunch',
                      MealPeriod.lunch,
                      Icons.lunch_dining,
                      const Color(0xFF4CAF50),
                    ),
                    const SizedBox(height: 16),
                    _buildMealSection(
                      context,
                      controller,
                      theme,
                      'Dinner',
                      MealPeriod.dinner,
                      Icons.dinner_dining,
                      const Color(0xFF2196F3),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back<void>(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: AppText.medium(
                      'Cancel',
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Obx(() =>
                      FilledButton.icon(
                        onPressed: ((controller.hasSelectedMeals() || controller.hasSelectedMultipleMeals()) &&
                            !controller.isLoading.value)
                            ? () => controller.createEnhancedMealPlans()
                            : null,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: controller.isLoading.value
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                            : const Icon(Icons.restaurant_menu, size: 20),
                        label: AppText.medium(
                          controller.isLoading.value
                              ? 'Creating...'
                              : 'Create Plans',
                          color: theme.colorScheme.onPrimary,
                        ),
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(BuildContext context,
      PlanController controller,
      ThemeData theme,
      String title,
      MealPeriod period,
      IconData icon,
      Color color,) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withAlpha(76),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(50),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                AppText.semiBold(
                  title,
                  color: theme.colorScheme.onSurface,
                  size: 16,
                ),
              ],
            ),
          ),

          // Recipe Selection using multi-select dropdown
          Padding(
            padding: const EdgeInsets.all(16),
            child: _MultiRecipeDropdownWidget(
              period: period,
              controller: controller,
              getRecipeIcon: _getRecipeIcon,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getDietLabel(MealCategory? category) {
    switch (category) {
      case MealCategory.vegetarian:
        return 'Vegetarian';
      case MealCategory.nonVegetarian:
        return 'Non-Vegetarian';
      case MealCategory.vegan:
        return 'Vegan';
      case MealCategory.eggitarian:
        return 'Eggitarian';
      case MealCategory.other:
        return 'Other';
      default:
        return 'Unknown';
    }
  }

  IconData _getDietIcon(MealCategory? category) {
    switch (category) {
      case MealCategory.vegetarian:
        return Icons.eco;
      case MealCategory.nonVegetarian:
        return Icons.restaurant;
      case MealCategory.vegan:
        return Icons.spa;
      case MealCategory.eggitarian:
        return Icons.egg;
      case MealCategory.other:
        return Icons.more_horiz;
      default:
        return Icons.help;
    }
  }

  Color _getDietColor(MealCategory? category) {
    switch (category) {
      case MealCategory.vegetarian:
        return const Color(0xFF4CAF50);
      case MealCategory.nonVegetarian:
        return const Color(0xFFFF9800);
      case MealCategory.vegan:
        return const Color(0xFF009688);
      case MealCategory.eggitarian:
        return const Color(0xFFFFC107);
      case MealCategory.other:
        return const Color(0xFF9E9E9E);
      default:
        return Colors.grey;
    }
  }

  // Helper method removed as it's unused

  // Helper methods for BMI category conversion
  String? _bmiCategoryToString(BmiCategory? category) {
    if (category == null) return null;
    switch (category) {
      case BmiCategory.underweight:
        return 'underweight';
      case BmiCategory.normal:
        return 'normal';
      case BmiCategory.overweight:
        return 'overweight';
      case BmiCategory.obese:
        return 'obese';
    }
  }

  BmiCategory? _stringToBmiCategory(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'underweight':
        return BmiCategory.underweight;
      case 'normal':
        return BmiCategory.normal;
      case 'overweight':
        return BmiCategory.overweight;
      case 'obese':
        return BmiCategory.obese;
      default:
        return null;
    }
  }
}

// Performance optimization: Extract recipe dropdown to separate widget to reduce rebuilds
class _MultiRecipeDropdownWidget extends StatelessWidget {
  final MealPeriod period;
  final dynamic controller; // PlanController
  final String Function(dynamic) getRecipeIcon;
  
  const _MultiRecipeDropdownWidget({
    required this.period,
    required this.controller,
    required this.getRecipeIcon,
  });
  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final filteredRecipes = controller.getFilteredRecipes() as List<dynamic>;
      final selectedRecipeIds = controller.getSelectedRecipeIdsForPeriod(period) as List<String>;

      // Convert recipes to DropdownItem format for MultiSelectDropdown
      final recipeItems = filteredRecipes.map<DropdownItem>((dynamic recipe) {
        final recipeName = recipe['name']?.toString() ?? 'Unknown Recipe';
        final recipeDescription = recipe['description']?.toString() ?? '';
        return DropdownItem(
          value: recipe['recipeId']?.toString() ?? '',
          label: recipeName,
          description: recipeDescription.length > 60
              ? '${recipeDescription.substring(0, 60)}...'
              : recipeDescription,
          icon: getRecipeIcon(recipe),
        );
      }).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MultiSelectDropdown(
            items: recipeItems,
            selectedValues: selectedRecipeIds,
            hint: 'Select recipes for ${_getPeriodName(period)}',
            label: 'Recipes',
            showSearch: true,
            showDescriptions: true,
            showIcons: false,
            maxHeight: 550, // Enhanced: Larger dropdown size
            maxSelections: 5, // Allow up to 5 recipes per meal period
            onChanged: (values) {
              final stringValues = values.cast<String>();
              controller.setSelectedRecipeIdsForPeriod(period, stringValues);
            },
          ),
        ],
      );
    });
  }
  
  String _getPeriodName(MealPeriod period) {
    switch (period) {
      case MealPeriod.breakfast:
        return 'Breakfast';
      case MealPeriod.lunch:
        return 'Lunch';
      case MealPeriod.dinner:
        return 'Dinner';
      case MealPeriod.snack:
        return 'Snack';
    }
  }
}