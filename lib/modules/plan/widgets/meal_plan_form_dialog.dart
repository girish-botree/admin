import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_text.dart';
import '../plan_controller.dart';
import '../meal_plan_assignment_model.dart'
    show MealPeriod, MealCategory, BmiCategory;

class MealPlanFormDialog extends StatelessWidget {
  final bool isEdit;
  
  const MealPlanFormDialog({
    super.key,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlanController>();
    final theme = Theme.of(context);
    
    return Dialog(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              AppText.h4(
                isEdit ? 'Edit Meal Plan' : 'Create Meal Plan',
                color: theme.colorScheme.onSurface,
              ),
              const SizedBox(height: 24),
              
              // Recipe dropdown
              AppText.medium('Recipe', color: theme.colorScheme.onSurface),
              const SizedBox(height: 8),
              Obx(() {
                final selectedValue = controller.selectedRecipeId.value;
                final hasValidSelection = controller.recipes.isNotEmpty && 
                    selectedValue.isNotEmpty &&
                    controller.recipes.any((recipe) => recipe['recipeId']?.toString() == selectedValue);

                // Auto-select first recipe if no valid selection and recipes exist
                String? displayValue;
                if (hasValidSelection) {
                  displayValue = selectedValue;
                } else if (controller.recipes.isNotEmpty) {
                  displayValue =
                      controller.recipes.first['recipeId']?.toString();
                  // Auto-set the controller value to the first recipe
                  if (displayValue != null) {
                    controller.selectedRecipeId.value = displayValue;
                  }
                }

                return DropdownButtonFormField<String>(
                  value: displayValue,
                  validator: (value) =>
                  value?.isEmpty == true
                      ? 'Recipe is required'
                      : null,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: theme.colorScheme.onSurface),
                    ),
                  ),
                  dropdownColor: theme.colorScheme.surfaceContainerLowest,
                  isExpanded: true,
                  items: controller.recipes.map<DropdownMenuItem<String>>((
                      recipe) {
                    return DropdownMenuItem<String>(
                      value: recipe['recipeId']?.toString(),
                      child: AppText.medium(
                        recipe['name']?.toString() ?? 'Unknown Recipe',
                        color: theme.colorScheme.onSurface,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => controller.selectedRecipeId.value = value ?? '',
                );
              }),
              const SizedBox(height: 16),
              
              // Meal Date field
              Obx(() => InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: controller.selectedMealDate.value,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    controller.selectedMealDate.value = date;
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: theme.colorScheme.onSurface),
                      const SizedBox(width: 12),
                      AppText.medium(
                        '${controller.selectedMealDate.value.day}/${controller.selectedMealDate.value.month}/${controller.selectedMealDate.value.year}',
                        color: theme.colorScheme.onSurface,
                      ),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 16),
              
              // Period radio buttons
              AppText.medium('Meal Period', color: theme.colorScheme.onSurface),
              const SizedBox(height: 8),
              Obx(() => Column(
                children: [
                  RadioListTile<MealPeriod>(
                    title: AppText.medium('Breakfast', color: theme.colorScheme.onSurface),
                    value: MealPeriod.breakfast,
                    groupValue: controller.selectedPeriod.value,
                    onChanged: (value) => controller.selectedPeriod.value = value!,
                    activeColor: theme.colorScheme.onSurface,
                  ),
                  RadioListTile<MealPeriod>(
                    title: AppText.medium('Lunch', color: theme.colorScheme.onSurface),
                    value: MealPeriod.lunch,
                    groupValue: controller.selectedPeriod.value,
                    onChanged: (value) => controller.selectedPeriod.value = value!,
                    activeColor: theme.colorScheme.onSurface,
                  ),
                  RadioListTile<MealPeriod>(
                    title: AppText.medium('Dinner', color: theme.colorScheme.onSurface),
                    value: MealPeriod.dinner,
                    groupValue: controller.selectedPeriod.value,
                    onChanged: (value) => controller.selectedPeriod.value = value!,
                    activeColor: theme.colorScheme.onSurface,
                  ),
                ],
              )),
              const SizedBox(height: 16),
              
              // Category dropdown
              AppText.medium('Category', color: theme.colorScheme.onSurface),
              const SizedBox(height: 8),
              Obx(() => DropdownButtonFormField<MealCategory>(
                value: controller.selectedCategory.value,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.colorScheme.onSurface),
                  ),
                ),
                dropdownColor: theme.colorScheme.surfaceContainerLowest,
                isExpanded: true,
                items: MealCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: AppText.medium(
                      category == MealCategory.nonVegetarian 
                          ? 'Non Vegetarian' 
                          : category.name.toUpperCase(),
                      color: theme.colorScheme.onSurface,
                    ),
                  );
                }).toList(),
                onChanged: (value) => controller.selectedCategory.value = value!,
              )),
              const SizedBox(height: 16),

              // BMI Category dropdown
              AppText.medium(
                  'BMI Category', color: theme.colorScheme.onSurface),
              const SizedBox(height: 8),
              Obx(() =>
                  DropdownButtonFormField<BmiCategory>(
                    value: controller.selectedBmiCategory.value,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.colorScheme
                            .onSurface.withValues(alpha: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.colorScheme
                            .onSurface.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.colorScheme
                            .onSurface),
                      ),
                    ),
                    dropdownColor: theme.colorScheme.surfaceContainerLowest,
                    isExpanded: true,
                    items: BmiCategory.values.map((bmiCategory) {
                      return DropdownMenuItem(
                        value: bmiCategory,
                        child: AppText.medium(
                          bmiCategory.name.toUpperCase(),
                          color: theme.colorScheme.onSurface,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                    controller.selectedBmiCategory.value = value!,
                  )),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      if (isEdit) {
                        controller.clearAssignmentForm();
                      } else {
                        controller.clearAssignmentForm();
                      }
                      Get.back<void>();
                    },
                    child: AppText.medium(
                      'Cancel',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (isEdit) {
                        await controller.updateMealPlanAssignment();
                      } else {
                        await controller.createMealPlan();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.onSurface,
                      foregroundColor: theme.colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    
                    ),
                    child: AppText.medium(
                      isEdit ? 'Update' : 'Create',
                      color: theme.colorScheme.surface,
                    ),
                  ),
                ],
              ),
      
            ],
          ),
        ),
        )),
    );
  }
}