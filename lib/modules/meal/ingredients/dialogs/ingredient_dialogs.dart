import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../meal_controller.dart';
import '../../../../widgets/searchable_dropdown.dart';
import '../../../../widgets/multi_select_dropdown.dart';
import '../../../../widgets/centered_dropdown.dart';
import '../../../../config/dropdown_data.dart';
import '../../../../config/dietary_preferences.dart';


class IngredientDialogs {
  static void showAddIngredientDialog(BuildContext context,
      MealController controller) {
    controller.clearIngredientForm();
    int dietaryCategory = 0;
    List<dynamic> selectedVitamins = [];
    List<dynamic> selectedMinerals = [];

    // State variables for section expansion
    bool isBasicExpanded = true; // Changed from false to true
    bool isNutritionExpanded = false;
    bool isFatBreakdownExpanded = false;
    bool isAdditionalExpanded = false;

    Get.dialog<void>(
      Dialog.fullscreen(
        backgroundColor: context.theme.colorScheme.surface,
        child: StatefulBuilder(
          builder: (context, setDialogState) =>
              Scaffold(
                backgroundColor: context.theme.colorScheme.surface,
                appBar: AppBar(
                  backgroundColor: context.theme.colorScheme.surfaceContainer,
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () => Get.back<void>(),
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: context.theme.colorScheme.outline.withValues(
                          alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 22,
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      size: 24,
                      color: context.theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Add New Ingredient',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: context.theme.colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          'Tap sections to expand and fill details',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: context.theme.colorScheme.onSurface
                                .withValues(
                                alpha: 0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              toolbarHeight: 80,
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.theme.colorScheme.surfaceContainer,
                    context.theme.colorScheme.surface,
                  ],
                  stops: const [0.0, 0.3],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                child: Obx(() =>
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Information Section
                        _buildCollapsibleFormSection(
                          context: context,
                          title: 'Basic Information',
                          subtitle: 'Essential ingredient details',
                          icon: Icons.info_outline_rounded,
                          iconColor: context.theme.colorScheme.primary,
                          isExpanded: isBasicExpanded,
                          isRequired: true,
                          onToggle: () =>
                              setDialogState(() =>
                              isBasicExpanded = !isBasicExpanded),
                          children: [
                            _buildRequiredFieldIndicator(context),
                            const SizedBox(height: 20),
                            IngredientValidatedTextField(
                              controller.nameController,
                              'Ingredient Name',
                              context,
                              isRequired: true,
                              errorText: controller.nameError.value,
                              onChanged: controller.validateName,
                            ),
                            const SizedBox(height: 20),
                            IngredientValidatedTextField(
                              controller.descriptionController,
                              'Description',
                              context,
                              maxLines: 3,
                              errorText: controller.descriptionError.value,
                              onChanged: controller.validateDescription,
                            ),
                            const SizedBox(height: 20),
                            IngredientValidatedTextField(
                              controller.categoryController,
                              'Category',
                              context,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Nutritional Information Section
                        _buildCollapsibleFormSection(
                          context: context,
                          title: 'Nutritional Information',
                          subtitle: 'Per 100g serving size',
                          icon: Icons.analytics_outlined,
                          iconColor: Colors.green,
                          isExpanded: isNutritionExpanded,
                          onToggle: () =>
                              setDialogState(() =>
                              isNutritionExpanded = !isNutritionExpanded),
                          children: [
                            _buildNutrientRow(
                              context,
                              [
                                _buildNutrientField(
                                  context,
                                  controller.caloriesController,
                                  'Calories',
                                  'kcal',
                                  controller.caloriesError.value,
                                  controller.validateCalories,
                                ),
                                _buildNutrientField(
                                  context,
                                  controller.proteinController,
                                  'Protein',
                                  'g',
                                  controller.proteinError.value,
                                      (value) =>
                                      controller.validateNutrient(
                                          value, controller.proteinError,
                                          'Protein'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildNutrientRow(
                              context,
                              [
                                _buildNutrientField(
                                  context,
                                  controller.carbsController,
                                  'Carbs',
                                  'g',
                                  controller.carbsError.value,
                                      (value) =>
                                      controller.validateNutrient(
                                          value, controller.carbsError,
                                          'Carbs'),
                                ),
                                _buildNutrientField(
                                  context,
                                  controller.fatController,
                                  'Fat',
                                  'g',
                                  controller.fatError.value,
                                      (value) =>
                                      controller.validateNutrient(
                                          value, controller.fatError, 'Fat'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildNutrientRow(
                              context,
                              [
                                _buildNutrientField(
                                  context,
                                  controller.fiberController,
                                  'Fiber',
                                  'g',
                                  null,
                                  null,
                                ),
                                _buildNutrientField(
                                  context,
                                  controller.sugarController,
                                  'Sugar',
                                  'g',
                                  null,
                                  null,
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Fat Breakdown Section
                        _buildCollapsibleFormSection(
                          context: context,
                          title: 'Fat Breakdown',
                          subtitle: 'Detailed fat composition per 100g',
                          icon: Icons.pie_chart_outline_rounded,
                          iconColor: Colors.orange,
                          isExpanded: isFatBreakdownExpanded,
                          onToggle: () =>
                              setDialogState(() =>
                              isFatBreakdownExpanded = !isFatBreakdownExpanded),
                          children: [
                            _buildNutrientRow(
                              context,
                              [
                                _buildNutrientField(
                                  context,
                                  controller.saturatedFatController,
                                  'Saturated Fat',
                                  'g',
                                  null,
                                  null,
                                ),
                                _buildNutrientField(
                                  context,
                                  controller.monoFatController,
                                  'Monounsaturated',
                                  'g',
                                  null,
                                  null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildNutrientField(
                              context,
                              controller.polyFatController,
                              'Polyunsaturated Fat',
                              'g',
                              null,
                              null,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Additional Information Section
                        _buildCollapsibleFormSection(
                          context: context,
                          title: 'Additional Information',
                          subtitle: 'Vitamins, minerals, and dietary preferences',
                          icon: Icons.more_horiz_rounded,
                          iconColor: Colors.purple,
                          isExpanded: isAdditionalExpanded,
                          onToggle: () =>
                              setDialogState(() =>
                              isAdditionalExpanded = !isAdditionalExpanded),
                          children: [
                            StatefulBuilder(
                              builder: (context, setState) =>
                                  TypedMultiSelectDropdown(
                                    dropdownType: DropdownType.vitamins,
                                    selectedValues: selectedVitamins,
                                    label: 'Vitamins',
                                    hint: 'Select vitamins present',
                                    onChanged: (selected) {
                                      setState(() =>
                                        selectedVitamins = selected);
                                      final vitaminMap = <String, dynamic>{};
                                      for (final vitamin in selected) {
                                        final item = DropdownDataManager
                                            .findItemByValue(
                                            DropdownDataManager.vitamins,
                                            vitamin
                                        );
                                        if (item != null) {
                                          vitaminMap[item.label] = 0.0;
                                        }
                                      }
                                      controller.vitaminsController.text =
                                      vitaminMap.isEmpty ? '' : jsonEncode(
                                          vitaminMap);
                                    },
                                  ),
                            ),
                            const SizedBox(height: 20),
                            StatefulBuilder(
                              builder: (context, setState) =>
                                  TypedMultiSelectDropdown(
                                    dropdownType: DropdownType.minerals,
                                    selectedValues: selectedMinerals,
                                    label: 'Minerals',
                                    hint: 'Select minerals present',
                                    onChanged: (selected) {
                                      setState(() =>
                                        selectedMinerals = selected);
                                      final mineralMap = <String, dynamic>{};
                                      for (final mineral in selected) {
                                        final item = DropdownDataManager
                                            .findItemByValue(
                                            DropdownDataManager.minerals,
                                            mineral
                                        );
                                        if (item != null) {
                                          mineralMap[item.label] = 0.0;
                                        }
                                      }
                                      controller.mineralsController.text =
                                      mineralMap.isEmpty ? '' : jsonEncode(
                                          mineralMap);
                                    },
                                  ),
                            ),
                            const SizedBox(height: 20),
                            StatefulBuilder(
                              builder: (context, setState) =>
                                  TypedSearchableDropdown(
                                    dropdownType: DropdownType
                                        .dietaryCategories,
                                    value: dietaryCategory,
                                    label: 'Dietary Category',
                                    hint: 'Select dietary classification',
                                    onChanged: (value) =>
                                        setState(() =>
                                        dietaryCategory =
                                            (value as int?) ?? 0),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    )),
              ),
            ),
            floatingActionButton: Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton.extended(
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
                backgroundColor: context.theme.colorScheme.onSurface,
                foregroundColor: context.theme.colorScheme.onPrimary,
                elevation: 6,
                icon: const Icon(Icons.check_rounded, size: 22),
                label: const Text(
                  'Save Ingredient',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation
                .centerFloat,
          ),
        ),
      ),
    );
  }

  // Helper method to build collapsible form sections
  static Widget _buildCollapsibleFormSection({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
    bool isRequired = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpanded
              ? iconColor.withValues(alpha: 0.3)
              : context.theme.colorScheme.outline.withValues(alpha: 0.08),
          width: isExpanded ? 2 : 1,
        ),
        // Simplified shadow during animation for better performance
        boxShadow: isExpanded ? [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(
                            alpha: isExpanded ? 0.2 : 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: iconColor.withValues(alpha: isExpanded
                              ? 0.4
                              : 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 28,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: context.theme.colorScheme.onSurface,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              if (isRequired)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'Required',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: context.theme.colorScheme.onSurface
                                  .withValues(alpha: 0.65),
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      // Reduced from 300ms
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.expand_more_rounded,
                          size: 24,
                          color: context.theme.colorScheme.onSurface.withValues(
                              alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                // Optimized animation for better performance
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  // Reduced from 400ms
                  curve: Curves.easeOut,
                  // Changed curve for smoother animation
                  height: isExpanded ? null : 0,
                  child: isExpanded
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Divider(
                        color: iconColor.withValues(alpha: 0.2),
                        thickness: 1,
                      ),
                      const SizedBox(height: 24),
                      ...children,
                    ],
                  )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build nutrient rows
  static Widget _buildNutrientRow(BuildContext context, List<Widget> children) {
    return Row(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          Expanded(child: children[i]),
          if (i < children.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }

  // Helper method to build individual nutrient fields
  static Widget _buildNutrientField(BuildContext context,
      TextEditingController controller,
      String label,
      String unit,
      String? errorText,
      void Function(String)? onChanged,) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: MealController.getNumberInputFormatters(),
      style: TextStyle(
        color: context.theme.colorScheme.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
        suffixStyle: TextStyle(
          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelStyle: TextStyle(
          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: context.theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: context.theme.colorScheme.primary,
            width: 2.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2.5),
          borderRadius: BorderRadius.circular(16),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }


  // Helper method to build required field indicator
  static Widget _buildRequiredFieldIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 16,
            color: Colors.red.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            'Fields marked with * are required',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  static void showEditIngredientDialog(BuildContext context,
      MealController controller, dynamic ingredient) {
    controller.setupIngredientForm(ingredient);
    int dietaryCategory = (ingredient['dietaryCategory'] as int?) ?? 0;
    bool isActive = (ingredient['isActive'] as bool?) ?? true;

    // Parse existing vitamins and minerals
    List<dynamic> selectedVitamins = _parseSelectedItems(
        ingredient['vitamins'], DropdownDataManager.vitamins);
    List<dynamic> selectedMinerals = _parseSelectedItems(
        ingredient['minerals'], DropdownDataManager.minerals);

    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        child: Container(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.8,
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) =>
                  Column(
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

                      IngredientSectionTitle(context, 'Basic Information'),
                      const SizedBox(height: 12),
                      IngredientTextField(
                          controller.nameController, 'Ingredient Name',
                          context),
                      const SizedBox(height: 12),
                      IngredientTextField(
                          controller.descriptionController, 'Description',
                          context, maxLines: 3),
                      const SizedBox(height: 12),
                      IngredientTextField(
                          controller.categoryController, 'Category', context),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text('Active Status',
                              style: TextStyle(fontSize: 16, color: context
                                  .theme.colorScheme.onSurface)),
                          const SizedBox(width: 16),
                          Switch(
                            value: isActive,
                            onChanged: (value) =>
                                setState(() => isActive = value),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      IngredientSectionTitle(
                          context, 'Nutritional Information (per 100g)'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: IngredientTextField(
                              controller.caloriesController,
                              'Calories (per 100g)',
                              context, keyboardType: TextInputType.numberWithOptions(decimal: true))),
                          const SizedBox(width: 12),
                          Expanded(child: IngredientTextField(
                              controller.proteinController,
                              'Protein (g per 100g)',
                              context, keyboardType: TextInputType.numberWithOptions(decimal: true))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: IngredientTextField(
                              controller.carbsController, 'Carbs (g per 100g)',
                              context,
                              keyboardType: TextInputType.numberWithOptions(decimal: true))),
                          const SizedBox(width: 12),
                          Expanded(child: IngredientTextField(
                              controller.fatController, 'Fat (g per 100g)',
                              context,
                              keyboardType: TextInputType.numberWithOptions(decimal: true))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: IngredientTextField(
                              controller.fiberController, 'Fiber (g per 100g)',
                              context,
                              keyboardType: TextInputType.numberWithOptions(decimal: true))),
                          const SizedBox(width: 12),
                          Expanded(child: IngredientTextField(
                              controller.sugarController, 'Sugar (g per 100g)',
                              context,
                              keyboardType: TextInputType.numberWithOptions(decimal: true))),
                        ],
                      ),
                      const SizedBox(height: 24),

                      IngredientSectionTitle(
                          context, 'Fat Breakdown (per 100g)'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: IngredientTextField(
                              controller.saturatedFatController,
                              'Saturated (g per 100g)', context,
                              keyboardType: TextInputType.numberWithOptions(decimal: true))),
                          const SizedBox(width: 12),
                          Expanded(child: IngredientTextField(
                              controller.monoFatController,
                              'Monounsaturated (g per 100g)', context,
                              keyboardType: TextInputType.numberWithOptions(decimal: true))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      IngredientTextField(
                          controller.polyFatController,
                          'Polyunsaturated (g per 100g)',
                          context, keyboardType: TextInputType.numberWithOptions(decimal: true)),
                      const SizedBox(height: 24),

                      IngredientSectionTitle(context, 'Additional Information'),
                      const SizedBox(height: 12),
                      TypedMultiSelectDropdown(
                        dropdownType: DropdownType.vitamins,
                        selectedValues: selectedVitamins,
                        label: 'Vitamins (per 100g)',
                        hint: 'Select vitamins',
                        onChanged: (selected) {
                          setState(() => selectedVitamins = selected);
                          final vitaminMap = <String, dynamic>{};
                          for (final vitamin in selected) {
                            final item = DropdownDataManager.findItemByValue(
                                DropdownDataManager.vitamins,
                                vitamin
                            );
                            if (item != null) {
                              vitaminMap[item.label] = 0.0;
                            }
                          }
                          controller.vitaminsController.text =
                          vitaminMap.isEmpty ? '' : jsonEncode(vitaminMap);
                        },
                      ),
                      const SizedBox(height: 12),
                      TypedMultiSelectDropdown(
                        dropdownType: DropdownType.minerals,
                        selectedValues: selectedMinerals,
                        label: 'Minerals (per 100g)',
                        hint: 'Select minerals',
                        onChanged: (selected) {
                          setState(() => selectedMinerals = selected);
                          final mineralMap = <String, dynamic>{};
                          for (final mineral in selected) {
                            final item = DropdownDataManager.findItemByValue(
                                DropdownDataManager.minerals,
                                mineral
                            );
                            if (item != null) {
                              mineralMap[item.label] = 0.0;
                            }
                          }
                          controller.mineralsController.text =
                          mineralMap.isEmpty ? '' : jsonEncode(mineralMap);
                        },
                      ),
                      const SizedBox(height: 12),
                      TypedSearchableDropdown(
                        dropdownType: DropdownType.dietaryCategories,
                        value: dietaryCategory,
                        label: 'Dietary Category',
                        hint: 'Select dietary category',
                        onChanged: (value) =>
                            setState(() =>
                            dietaryCategory = (value as int?) ?? 0),
                      ),
                      const SizedBox(height: 32),

                      IngredientDialogActions(context, () {
                        if (controller.nameController.text.isEmpty) {
                          Get.snackbar('Error', 'Ingredient name is required');
                          return;
                        }

                        final data = controller.createIngredientData(
                            dietaryCategory);
                        data['isActive'] = isActive;

                        final ingredientId = (ingredient['ingredientId'] as String?) ??
                            '';
                        controller.updateIngredient(ingredientId, data).then((
                            success) {
                          if (success) {
                            Get.back<void>();
                            Get.snackbar(
                                'Success', 'Ingredient updated successfully');
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

  static void showDeleteConfirmation(BuildContext context, dynamic ingredient,
      MealController controller) {
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

  static void showDeleteAllConfirmation(BuildContext context,
      MealController controller) {
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
                  Icons.delete_sweep_rounded,
                  size: 32,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Delete All Ingredients',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete ALL ingredients? This action cannot be undone.',
                style: TextStyle(
                  fontSize: 16,
                  color: context.theme.colorScheme.onSurface.withValues(
                      alpha: 0.8),
                  height: 1.4,
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
                      onPressed: () async {
                        Get.back<void>(); // Close dialog first

                        if (controller.ingredients.isEmpty) return;

                        final ingredientCount = controller.ingredients.length;
                        bool allDeleted = true;

                        // Delete all ingredients
                        final ingredientIds = controller.ingredients.map((
                            ingredient) =>
                        ingredient['ingredientId']?.toString() ?? '').toList();
                        for (final ingredientId in ingredientIds) {
                          if (ingredientId.isNotEmpty) {
                            try {
                              final success = await controller.deleteIngredient(
                                  ingredientId);
                              if (!success) {
                                allDeleted = false;
                                break;
                              }
                            } catch (e) {
                              allDeleted = false;
                              break;
                            }
                          }
                        }

                        if (allDeleted) {
                          Get.snackbar('Success',
                              'All $ingredientCount ingredients deleted successfully');
                        } else {
                          Get.snackbar(
                              'Error', 'Some ingredients could not be deleted');
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Delete All'),
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

  static void showIngredientDetails(BuildContext context, dynamic ingredient) {
    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: context.theme.colorScheme.surface,
        child: Container(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.8,
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 800),
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
                    color: context.theme.colorScheme.onSurface.withValues(
                        alpha: 0.8),
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
                IngredientNutrientInfo(context, 'Calories',
                    '${((ingredient['calories'] as num?) ?? 0).toInt()}'),
                IngredientNutrientInfo(context, 'Protein',
                    '${((ingredient['protein'] as num?) ?? 0).toInt()}g'),
                IngredientNutrientInfo(context, 'Carbohydrates',
                    '${((ingredient['carbohydrates'] as num?) ?? 0).toInt()}g'),
                IngredientNutrientInfo(context, 'Fat',
                    '${((ingredient['fat'] as num?) ?? 0).toInt()}g'),
                IngredientNutrientInfo(context, 'Fiber',
                    '${((ingredient['fiber'] as num?) ?? 0).toInt()}g'),
                IngredientNutrientInfo(context, 'Sugar',
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
                    IngredientNutrientInfo(context, 'Saturated Fat',
                        '${(fatBreakdown['Saturated'] as num?)?.toInt() ??
                            0}g'),
                    IngredientNutrientInfo(context, 'Monounsaturated Fat',
                        '${(fatBreakdown['Monounsaturated'] as num?)?.toInt() ??
                            0}g'),
                    IngredientNutrientInfo(context, 'Polyunsaturated Fat',
                        '${(fatBreakdown['Polyunsaturated'] as num?)?.toInt() ??
                            0}g'),
                  ];
                })(),
                // Add Vitamins Section
                const SizedBox(height: 24),
                ...(() {
                  Map<String, dynamic> vitamins = {};
                  try {
                    final vitaminsStr = ingredient['vitamins'] as String?;
                    if (vitaminsStr != null && vitaminsStr.isNotEmpty) {
                      final decoded = jsonDecode(vitaminsStr);
                      if (decoded is Map<String, dynamic>) {
                        vitamins = decoded;
                      }
                    }
                  } catch (e) {
                    // Ignore JSON parsing errors
                  }

                  if (vitamins.isEmpty) {
                    return [Container()];
                  }

                  return [
                    Text(
                      'Vitamins',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: vitamins.keys.map((key) =>
                          Chip(
                            label: Text(key),
                            backgroundColor: context.theme.colorScheme
                                .primaryContainer,
                            labelStyle: TextStyle(
                              color: context.theme.colorScheme
                                  .onPrimaryContainer,
                              fontSize: 12,
                            ),
                          )
                      ).toList(),
                    ),
                  ];
                })(),

                // Add Minerals Section
                const SizedBox(height: 24),
                ...(() {
                  Map<String, dynamic> minerals = {};
                  try {
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

                  if (minerals.isEmpty) {
                    return [Container()];
                  }

                  return [
                    Text(
                      'Minerals',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: minerals.keys.map((key) =>
                          Chip(
                            label: Text(key),
                            backgroundColor: context.theme.colorScheme
                                .secondaryContainer,
                            labelStyle: TextStyle(
                              color: context.theme.colorScheme
                                  .onSecondaryContainer,
                              fontSize: 12,
                            ),
                          )
                      ).toList(),
                    ),
                  ];
                })(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to parse JSON keys safely and return dropdown values
  static List<dynamic> _parseSelectedItems(dynamic jsonData,
      List<DropdownItem> availableItems) {
    try {
      if (jsonData == null) return [];
      final jsonString = jsonData.toString();
      if (jsonString.isEmpty) return [];
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        final selectedLabels = decoded.keys.toList();
        return availableItems
            .where((item) => selectedLabels.contains(item.label))
            .map((item) => item.value)
            .toList();
      }
    } catch (e) {
      // Ignore JSON parsing errors
    }
    return [];
  }


}

// Helper widgets

class IngredientFormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const IngredientFormSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
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
}

class IngredientValidatedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final BuildContext context;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final void Function(String)? onChanged;
  final bool isRequired;

  const IngredientValidatedTextField(this.controller,
      this.label,
      this.context, {
        super.key,
        this.maxLines = 1,
        this.keyboardType,
        this.inputFormatters,
        this.errorText,
        this.onChanged,
        this.isRequired = false,
      });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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
        errorText: errorText != null && errorText!.isNotEmpty
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
    );
  }
}

class IngredientTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final BuildContext context;
  final int maxLines;
  final TextInputType? keyboardType;

  const IngredientTextField(this.controller,
      this.label,
      this.context, {
        super.key,
        this.maxLines = 1,
        this.keyboardType,
      });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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
    );
  }
}

class IngredientMultiSelectField extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<String> selectedItems;
  final void Function(List<String>) onSelectionChanged;
  final BuildContext context;

  const IngredientMultiSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.selectedItems,
    required this.onSelectionChanged,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label and Add Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: context.theme.colorScheme.onSurface.withValues(
                            alpha: 0.7),
                        fontSize: 16,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showSelectionDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Selected Items Display
                if (selectedItems.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedItems.map((item) {
                      return Chip(
                        label: Text(
                          item,
                          style: const TextStyle(fontSize: 12),
                        ),
                        onDeleted: () {
                          final newSelection = selectedItems
                              .where((selectedItem) => selectedItem != item)
                              .toList();
                          onSelectionChanged(newSelection);
                        },
                        deleteIcon: const Icon(Icons.close, size: 16),
                        backgroundColor: context.theme.colorScheme
                            .primaryContainer,
                        labelStyle: TextStyle(
                          color: context.theme.colorScheme.onPrimaryContainer,
                        ),
                        deleteIconColor: context.theme.colorScheme
                            .onPrimaryContainer,
                      );
                    }).toList(),
                  )
                else
                  Text(
                    'No items selected',
                    style: TextStyle(
                      color: context.theme.colorScheme.onSurface.withValues(
                          alpha: 0.5),
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSelectionDialog(BuildContext context) {
    final availableItems = options.where((option) =>
    !selectedItems.contains(option)).toList();

    if (availableItems.isEmpty) {
      Get.snackbar('Info', 'All items have been selected');
      return;
    }

    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.8,
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select $label',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableItems.length,
                  itemBuilder: (context, index) {
                    final item = availableItems[index];
                    return CheckboxListTile(
                      title: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.theme.colorScheme.onSurface,
                        ),
                      ),
                      value: false,
                      // Always false since these are available items
                      onChanged: (value) {
                        if (value == true) {
                          final newSelection = [...selectedItems, item];
                          onSelectionChanged(newSelection);
                          Get.back<void>(); // Close dialog after selection
                        }
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back<void>(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        // Select all available items
                        final newSelection = [
                          ...selectedItems,
                          ...availableItems
                        ];
                        onSelectionChanged(newSelection);
                        Get.back<void>();
                      },
                      child: const Text('Select All'),
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
}

class IngredientDietaryDropdown extends StatelessWidget {
  final BuildContext context;
  final int value;
  final void Function(int?) onChanged;

  const IngredientDietaryDropdown({
    super.key,
    required this.context,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
      child: CenteredDropdown<int>(
        value: value,
        items: _buildSimpleDietaryCategoryItems(),
        onChanged: onChanged,
        labelText: 'Dietary Category',
        hintText: 'Select dietary category',
        enabled: true,
      ),
    );
  }



  List<DropdownMenuItem<int>> _buildSimpleDietaryCategoryItems() {
    final dietaryCategories = DietaryPreferences.getLabelMap();
    
    return dietaryCategories.entries.map((entry) {
      return DropdownMenuItem<int>(
        value: entry.key,
        child: Text(entry.value),
      );
    }).toList();
  }
}

Widget IngredientSectionTitle(BuildContext context, String title) {
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

Widget IngredientDialogActions(BuildContext context, VoidCallback onSave) {
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              side: BorderSide(
                color: context.theme.colorScheme.outline.withValues(alpha: 0.5),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget IngredientNutrientInfo(BuildContext context, String label,
    String value) {
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