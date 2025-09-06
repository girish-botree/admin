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

    // State variables for collapsible sections
    bool isBasicExpanded = true;
    bool isNutritionExpanded = false;
    bool isFatBreakdownExpanded = false;
    bool isAdditionalExpanded = false;

    // Helper function to calculate total composition, including fat breakdown
    double calculateTotalComposition() {
      double protein = double.tryParse(controller.proteinController.text) ??
          0.0;
      double carbs = double.tryParse(controller.carbsController.text) ?? 0.0;
      double fiber = double.tryParse(controller.fiberController.text) ?? 0.0;
      double sugar = double.tryParse(controller.sugarController.text) ?? 0.0;
      double saturated = double.tryParse(
          controller.saturatedFatController.text) ?? 0.0;
      double mono = double.tryParse(controller.monoFatController.text) ?? 0.0;
      double poly = double.tryParse(controller.polyFatController.text) ?? 0.0;
      // For composition, we count all macro components: protein, carbs, fiber, sugar, and fat breakdown
      return protein + carbs + fiber + sugar + saturated + mono + poly;
    }

    // Helper function to calculate total fat breakdown
    double calculateTotalFatBreakdown() {
      double saturated = double.tryParse(
          controller.saturatedFatController.text) ?? 0.0;
      double mono = double.tryParse(controller.monoFatController.text) ?? 0.0;
      double poly = double.tryParse(controller.polyFatController.text) ?? 0.0;
      return saturated + mono + poly;
    }

    // Helper function to check if adding more would exceed limit
    bool wouldExceedLimit(String currentValue, String newValue,
        String fieldName) {
      double current = double.tryParse(currentValue) ?? 0.0;
      double proposed = double.tryParse(newValue) ?? 0.0;

      // Calculate total without the current field
      double protein = double.tryParse(controller.proteinController.text) ??
          0.0;
      double carbs = double.tryParse(controller.carbsController.text) ?? 0.0;
      double fiber = double.tryParse(controller.fiberController.text) ?? 0.0;
      double sugar = double.tryParse(controller.sugarController.text) ?? 0.0;
      double fat = double.tryParse(controller.fatController.text) ?? 0.0;
      double saturated = double.tryParse(
          controller.saturatedFatController.text) ?? 0.0;
      double mono = double.tryParse(controller.monoFatController.text) ?? 0.0;
      double poly = double.tryParse(controller.polyFatController.text) ?? 0.0;

      // For each field, subtract its current value and add the proposed value
      switch (fieldName) {
        case 'protein':
          return (carbs + fiber + sugar + fat + saturated + mono + poly -
              protein + proposed) > 100.0;
        case 'carbs':
          return (protein + fiber + sugar + fat + saturated + mono + poly -
              carbs + proposed) > 100.0;
        case 'fat':
          return (protein + carbs + fiber + sugar + saturated + mono + poly -
              fat + proposed) > 100.0;
        case 'fiber':
          return (protein + carbs + sugar + fat + saturated + mono + poly -
              fiber + proposed) > 100.0;
        case 'sugar':
          return (protein + carbs + fiber + fat + saturated + mono + poly -
              sugar + proposed) > 100.0;
        case 'saturated':
          return (protein + carbs + fiber + sugar + fat + mono + poly -
              saturated + proposed) > 100.0;
        case 'mono':
          return (protein + carbs + fiber + sugar + fat + saturated + poly -
              mono + proposed) > 100.0;
        case 'poly':
          return (protein + carbs + fiber + sugar + fat + saturated + mono -
              poly + proposed) > 100.0;
        default:
          return false;
      }
    }

    // Helper function to check if fat breakdown exceeds total fat
    bool wouldFatBreakdownExceedTotalFat(String currentValue, String newValue,
        String fatType) {
      double proposed = double.tryParse(newValue) ?? 0.0;
      double totalFat = double.tryParse(controller.fatController.text) ?? 0.0;

      double saturated = double.tryParse(
          controller.saturatedFatController.text) ?? 0.0;
      double mono = double.tryParse(controller.monoFatController.text) ?? 0.0;
      double poly = double.tryParse(controller.polyFatController.text) ?? 0.0;

      // Subtract current fat type and add proposed value
      switch (fatType) {
        case 'saturated':
          return (mono + poly + proposed) > totalFat;
        case 'mono':
          return (saturated + poly + proposed) > totalFat;
        case 'poly':
          return (saturated + mono + proposed) > totalFat;
        default:
          return false;
      }
    }

    Get.dialog<void>(
      Dialog.fullscreen(
        backgroundColor: context.theme.colorScheme.surface,
        child: StatefulBuilder(
          builder: (context, setDialogState) =>
              Scaffold(
                backgroundColor: context.theme.colorScheme.surface,
                appBar: AppBar(
                  backgroundColor: context.theme.colorScheme.surface,
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () => Get.back<void>(),
                    icon: const Icon(Icons.close_rounded, size: 24),
                  ),
                  title: const Text(
                    'Add New Ingredient',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  centerTitle: false,
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  // Better scroll performance
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information Section - Always visible
                      Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline_rounded,
                                      color: context.theme.colorScheme.primary),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Basic Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Required',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Obx(() =>
                                  _buildSimpleTextField(
                                    controller.nameController,
                                    'Ingredient Name *',
                                    context,
                                    errorText: controller.nameError.value,
                                    onChanged: controller.validateName,
                                  )),
                              const SizedBox(height: 16),
                              Obx(() =>
                                  _buildSimpleTextField(
                                    controller.descriptionController,
                                    'Description',
                                    context,
                                    maxLines: 3,
                                    errorText: controller.descriptionError
                                        .value,
                                    onChanged: controller.validateDescription,
                                  )),
                              const SizedBox(height: 16),
                              _buildSimpleTextField(
                                controller.categoryController,
                                'Category',
                                context,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Nutritional Information Section - Collapsible
                      Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.analytics_outlined,
                                  color: Colors.green),
                              title: const Text(
                                'Nutritional Information',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: const Text('Per 100g serving size'),
                              trailing: Icon(
                                isNutritionExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                              ),
                              onTap: () =>
                                  setDialogState(() =>
                                  isNutritionExpanded = !isNutritionExpanded),
                            ),
                            if (isNutritionExpanded) ...[
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    // Composition Progress Meter
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: context.theme.colorScheme
                                            .surfaceContainerLowest,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: context.theme.colorScheme
                                              .outline.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.pie_chart_rounded,
                                                size: 20,
                                                color: context.theme.colorScheme
                                                    .primary,
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'Composition Meter',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const Spacer(),
                                              Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: calculateTotalComposition() >
                                                      100
                                                      ? Colors.red.withOpacity(
                                                      0.1)
                                                      : Colors.green
                                                      .withOpacity(0.1),
                                                  borderRadius: BorderRadius
                                                      .circular(6),
                                                ),
                                                child: Text(
                                                  '${calculateTotalComposition()
                                                      .toStringAsFixed(
                                                      1)}g / 100g',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: calculateTotalComposition() >
                                                        100
                                                        ? Colors.red
                                                        : Colors.green,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          LinearProgressIndicator(
                                            value: (calculateTotalComposition() /
                                                100).clamp(0.0, 1.0),
                                            backgroundColor: context.theme
                                                .colorScheme.outline
                                                .withOpacity(0.2),
                                            valueColor: AlwaysStoppedAnimation<
                                                Color>(
                                              calculateTotalComposition() > 100
                                                  ? Colors.red
                                                  : context.theme.colorScheme
                                                  .primary,
                                            ),
                                            minHeight: 8,
                                          ),
                                          const SizedBox(height: 8),
                                          if (calculateTotalComposition() > 100)
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.warning_rounded,
                                                  size: 16,
                                                  color: Colors.red,
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    'Total composition exceeds 100g. Please adjust values.',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.red,
                                                      fontWeight: FontWeight
                                                          .w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          else
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle_rounded,
                                                  size: 16,
                                                  color: Colors.green,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Remaining: ${(100 -
                                                      calculateTotalComposition())
                                                      .toStringAsFixed(1)}g',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Obx(() =>
                                              _buildNutrientField(
                                                context,
                                                controller.caloriesController,
                                                'Calories',
                                                'kcal',
                                                controller.caloriesError.value,
                                                controller.validateCalories,
                                              )),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Obx(() =>
                                              _buildNutrientField(
                                                context,
                                                controller.proteinController,
                                                'Protein',
                                                'g',
                                                controller.proteinError.value,
                                                    (value) {
                                                  if (wouldExceedLimit(
                                                      controller
                                                          .proteinController
                                                          .text, value,
                                                      'protein')) {
                                                    controller.proteinError
                                                        .value =
                                                    'Would exceed 100g total';
                                                  } else {
                                                    controller.validateNutrient(
                                                        value,
                                                        controller.proteinError,
                                                        'Protein');
                                                  }
                                                  setDialogState(() {}); // Update progress meter
                                                },
                                              )),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Obx(() =>
                                              _buildNutrientField(
                                                context,
                                                controller.carbsController,
                                                'Carbs',
                                                'g',
                                                controller.carbsError.value,
                                                    (value) {
                                                  if (wouldExceedLimit(
                                                      controller.carbsController
                                                          .text, value,
                                                      'carbs')) {
                                                    controller.carbsError
                                                        .value =
                                                    'Would exceed 100g total';
                                                  } else {
                                                    controller.validateNutrient(
                                                        value,
                                                        controller.carbsError,
                                                        'Carbs');
                                                  }
                                                  setDialogState(() {}); // Update progress meter
                                                },
                                              )),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Obx(() =>
                                              _buildNutrientField(
                                                context,
                                                controller.fatController,
                                                'Fat',
                                                'g',
                                                controller.fatError.value,
                                                    (value) {
                                                  if (wouldExceedLimit(
                                                      controller.fatController
                                                          .text, value,
                                                      'fat')) {
                                                    controller.fatError.value =
                                                    'Would exceed 100g total';
                                                  } else {
                                                    controller.validateNutrient(
                                                        value,
                                                        controller.fatError,
                                                        'Fat');
                                                  }
                                                  setDialogState(() {}); // Update progress meter
                                                },
                                              )),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildNutrientField(
                                            context,
                                            controller.fiberController,
                                            'Fiber',
                                            'g',
                                            null,
                                                (value) {
                                              setDialogState(() {}); // Update progress meter
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildNutrientField(
                                            context,
                                            controller.sugarController,
                                            'Sugar',
                                            'g',
                                            null,
                                                (value) {
                                              setDialogState(() {}); // Update progress meter
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Fat Breakdown Section - Now collapsible
                      Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.pie_chart_outline_rounded,
                                  color: Colors.orange),
                              title: const Text(
                                'Fat Breakdown',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: const Text('Per 100g serving'),
                              trailing: Icon(
                                isFatBreakdownExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                              ),
                              onTap: () =>
                                  setDialogState(() =>
                                  isFatBreakdownExpanded =
                                  !isFatBreakdownExpanded),
                            ),
                            if (isFatBreakdownExpanded) ...[
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    // Fat Breakdown Meter
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: context.theme.colorScheme
                                            .surfaceContainerLowest,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: context.theme.colorScheme
                                              .outline.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.donut_small_rounded,
                                                size: 20,
                                                color: Colors.orange,
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'Fat Breakdown Meter',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const Spacer(),
                                              Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: calculateTotalFatBreakdown() >
                                                      (double.tryParse(
                                                          controller
                                                              .fatController
                                                              .text) ?? 0.0)
                                                      ? Colors.red.withOpacity(
                                                      0.1)
                                                      : Colors.orange
                                                      .withOpacity(0.1),
                                                  borderRadius: BorderRadius
                                                      .circular(6),
                                                ),
                                                child: Text(
                                                  '${calculateTotalFatBreakdown()
                                                      .toStringAsFixed(
                                                      1)}g / ${(double.tryParse(
                                                      controller.fatController
                                                          .text) ?? 0.0)
                                                      .toStringAsFixed(1)}g',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: calculateTotalFatBreakdown() >
                                                        (double.tryParse(
                                                            controller
                                                                .fatController
                                                                .text) ?? 0.0)
                                                        ? Colors.red
                                                        : Colors.orange,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          LinearProgressIndicator(
                                            value: (double.tryParse(
                                                controller.fatController
                                                    .text) ?? 0.0) > 0
                                                ? (calculateTotalFatBreakdown() /
                                                (double.tryParse(
                                                    controller.fatController
                                                        .text) ?? 1.0)).clamp(
                                                0.0, 1.0)
                                                : 0.0,
                                            backgroundColor: context.theme
                                                .colorScheme.outline
                                                .withOpacity(0.2),
                                            valueColor: AlwaysStoppedAnimation<
                                                Color>(
                                              calculateTotalFatBreakdown() >
                                                  (double.tryParse(
                                                      controller.fatController
                                                          .text) ?? 0.0)
                                                  ? Colors.red
                                                  : Colors.orange,
                                            ),
                                            minHeight: 6,
                                          ),
                                          const SizedBox(height: 8),
                                          if (calculateTotalFatBreakdown() >
                                              (double.tryParse(
                                                  controller.fatController
                                                      .text) ?? 0.0))
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.warning_rounded,
                                                  size: 14,
                                                  color: Colors.red,
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    'Fat breakdown exceeds total fat amount.',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.red,
                                                      fontWeight: FontWeight
                                                          .w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          else
                                            if ((double.tryParse(
                                                controller.fatController
                                                    .text) ?? 0.0) > 0)
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.check_circle_rounded,
                                                    size: 14,
                                                    color: Colors.green,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Remaining: ${((double
                                                        .tryParse(controller
                                                        .fatController.text) ??
                                                        0.0) -
                                                        calculateTotalFatBreakdown())
                                                        .toStringAsFixed(1)}g',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.green,
                                                      fontWeight: FontWeight
                                                          .w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildNutrientField(
                                            context,
                                            controller.saturatedFatController,
                                            'Saturated',
                                            'g',
                                            null,
                                                (value) {
                                              if (wouldExceedLimit(controller
                                                  .saturatedFatController.text,
                                                  value, 'saturated')) {
                                                // Show composition error in snackbar instead of field error
                                                if ((double.tryParse(value) ??
                                                    0.0) > 0) {
                                                  Get.snackbar(
                                                    'Composition Limit',
                                                    'Adding this would exceed 100g total composition.',
                                                    backgroundColor: Colors
                                                        .orange.withOpacity(
                                                        0.8),
                                                    colorText: Colors.white,
                                                    duration: Duration(
                                                        seconds: 2),
                                                  );
                                                }
                                              } else
                                              if (wouldFatBreakdownExceedTotalFat(
                                                  controller
                                                      .saturatedFatController
                                                      .text, value,
                                                  'saturated')) {
                                                Get.snackbar(
                                                  'Fat Breakdown Error',
                                                  'Saturated fat cannot exceed total fat amount.',
                                                  backgroundColor: Colors.red
                                                      .withOpacity(0.8),
                                                  colorText: Colors.white,
                                                  duration: Duration(
                                                      seconds: 2),
                                                );
                                              }
                                              setDialogState(() {}); // Update progress meters
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildNutrientField(
                                            context,
                                            controller.monoFatController,
                                            'Mono',
                                            'g',
                                            null,
                                                (value) {
                                              if (wouldExceedLimit(
                                                  controller.monoFatController
                                                      .text, value, 'mono')) {
                                                if ((double.tryParse(value) ??
                                                    0.0) > 0) {
                                                  Get.snackbar(
                                                    'Composition Limit',
                                                    'Adding this would exceed 100g total composition.',
                                                    backgroundColor: Colors
                                                        .orange.withOpacity(
                                                        0.8),
                                                    colorText: Colors.white,
                                                    duration: Duration(
                                                        seconds: 2),
                                                  );
                                                }
                                              } else
                                              if (wouldFatBreakdownExceedTotalFat(
                                                  controller.monoFatController
                                                      .text, value, 'mono')) {
                                                Get.snackbar(
                                                  'Fat Breakdown Error',
                                                  'Monounsaturated fat cannot exceed total fat amount.',
                                                  backgroundColor: Colors.red
                                                      .withOpacity(0.8),
                                                  colorText: Colors.white,
                                                  duration: Duration(
                                                      seconds: 2),
                                                );
                                              }
                                              setDialogState(() {}); // Update progress meters
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildNutrientField(
                                      context,
                                      controller.polyFatController,
                                      'Polyunsaturated Fat',
                                      'g',
                                      null,
                                          (value) {
                                        if (wouldExceedLimit(
                                            controller.polyFatController.text,
                                            value, 'poly')) {
                                          if ((double.tryParse(value) ?? 0.0) >
                                              0) {
                                            Get.snackbar(
                                              'Composition Limit',
                                              'Adding this would exceed 100g total composition.',
                                              backgroundColor: Colors.orange
                                                  .withOpacity(0.8),
                                              colorText: Colors.white,
                                              duration: Duration(seconds: 2),
                                            );
                                          }
                                        } else
                                        if (wouldFatBreakdownExceedTotalFat(
                                            controller.polyFatController.text,
                                            value, 'poly')) {
                                          Get.snackbar(
                                            'Fat Breakdown Error',
                                            'Polyunsaturated fat cannot exceed total fat amount.',
                                            backgroundColor: Colors.red
                                                .withOpacity(0.8),
                                            colorText: Colors.white,
                                            duration: Duration(seconds: 2),
                                          );
                                        }
                                        setDialogState(() {}); // Update progress meters
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Additional Information Section - Now collapsible
                      Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.more_horiz_rounded,
                                  color: Colors.purple),
                              title: const Text(
                                'Additional Information',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: const Text(
                                  'Vitamins, minerals & dietary info'),
                              trailing: Icon(
                                isAdditionalExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                              ),
                              onTap: () =>
                                  setDialogState(() =>
                                  isAdditionalExpanded = !isAdditionalExpanded),
                            ),
                            if (isAdditionalExpanded) ...[
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    TypedMultiSelectDropdown(
                                      dropdownType: DropdownType.vitamins,
                                      selectedValues: selectedVitamins,
                                      label: 'Vitamins',
                                      hint: 'Select vitamins present',
                                      onChanged: (selected) {
                                        setDialogState(() =>
                                        selectedVitamins = selected);
                                        final vitaminMap = <String, dynamic>{};
                                        for (final vitamin in selected) {
                                          final item = DropdownDataManager
                                              .findItemByValue(
                                              DropdownDataManager.vitamins,
                                              vitamin);
                                          if (item != null) {
                                            vitaminMap[item.label] = 0.0;
                                          }
                                        }
                                        controller.vitaminsController.text =
                                        vitaminMap.isEmpty ? '' : jsonEncode(
                                            vitaminMap);
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TypedMultiSelectDropdown(
                                      dropdownType: DropdownType.minerals,
                                      selectedValues: selectedMinerals,
                                      label: 'Minerals',
                                      hint: 'Select minerals present',
                                      onChanged: (selected) {
                                        setDialogState(() =>
                                        selectedMinerals = selected);
                                        final mineralMap = <String, dynamic>{};
                                        for (final mineral in selected) {
                                          final item = DropdownDataManager
                                              .findItemByValue(
                                              DropdownDataManager.minerals,
                                              mineral);
                                          if (item != null) {
                                            mineralMap[item.label] = 0.0;
                                          }
                                        }
                                        controller.mineralsController.text =
                                        mineralMap.isEmpty ? '' : jsonEncode(
                                            mineralMap);
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TypedSearchableDropdown(
                                      dropdownType: DropdownType
                                          .dietaryCategories,
                                      value: dietaryCategory,
                                      label: 'Dietary Category',
                                      hint: 'Select dietary classification',
                                      onChanged: (value) =>
                                          setDialogState(() =>
                                          dietaryCategory =
                                              (value as int?) ?? 0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: () {
                    // Check composition limit first
                    if (calculateTotalComposition() > 100.0) {
                      Get.snackbar(
                        'Validation Error',
                        'Total ingredient composition cannot exceed 100g. Current total: ${calculateTotalComposition()
                            .toStringAsFixed(1)}g',
                        backgroundColor: Colors.red.withOpacity(0.8),
                        colorText: Colors.white,
                        icon: const Icon(Icons.warning, color: Colors.white),
                      );
                      return;
                    }

                    // Check fat breakdown consistency
                    double totalFat = double.tryParse(
                        controller.fatController.text) ?? 0.0;
                    double fatBreakdown = calculateTotalFatBreakdown();
                    if (fatBreakdown > totalFat) {
                      Get.snackbar(
                        'Validation Error',
                        'Fat breakdown (${fatBreakdown.toStringAsFixed(
                            1)}g) cannot exceed total fat (${totalFat
                            .toStringAsFixed(1)}g)',
                        backgroundColor: Colors.red.withOpacity(0.8),
                        colorText: Colors.white,
                        icon: const Icon(Icons.warning, color: Colors.white),
                      );
                      return;
                    }

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
                  backgroundColor: (calculateTotalComposition() > 100.0 ||
                      calculateTotalFatBreakdown() >
                          (double.tryParse(controller.fatController.text) ??
                              0.0))
                      ? Colors.grey
                      : context.theme.colorScheme.onSurface,
                  foregroundColor: (calculateTotalComposition() > 100.0 ||
                      calculateTotalFatBreakdown() >
                          (double.tryParse(controller.fatController.text) ??
                              0.0))
                      ? Colors.grey.shade600
                      : context.theme.colorScheme.surfaceContainerLowest,
                  icon: Icon((calculateTotalComposition() > 100.0 ||
                      calculateTotalFatBreakdown() >
                          (double.tryParse(controller.fatController.text) ??
                              0.0))
                      ? Icons.block_rounded
                      : Icons.check_rounded),
                  label: Text((calculateTotalComposition() > 100.0 ||
                      calculateTotalFatBreakdown() >
                          (double.tryParse(controller.fatController.text) ??
                              0.0))
                      ? 'Invalid Composition'
                      : 'Save Ingredient'),
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation
                    .centerFloat,
              ),
        ),
      ),
    );
  }

  // Simplified text field builder for better performance
  static Widget _buildSimpleTextField(TextEditingController controller,
      String label,
      BuildContext context, {
        int maxLines = 1,
        String? errorText,
        void Function(String)? onChanged,
      }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: context.theme.colorScheme.onSurface),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText?.isNotEmpty == true ? errorText : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: context.theme.colorScheme.outline.withOpacity(0.5),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: context.theme.colorScheme.outline.withOpacity(0.4),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: context.theme.colorScheme.primary.withOpacity(0.8),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.red.withOpacity(0.8),
            width: 1,
          ),
        ),
        filled: true,
        fillColor: context.theme.colorScheme.surface.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 12),
      ),
    );
  }

  // Simplified nutrient field for better performance
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
      style: TextStyle(color: context.theme.colorScheme.onSurface),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
        errorText: errorText?.isNotEmpty == true ? errorText : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: context.theme.colorScheme.outline.withOpacity(0.5),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: context.theme.colorScheme.outline.withOpacity(0.4),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: context.theme.colorScheme.primary.withOpacity(0.8),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.red.withOpacity(0.8),
            width: 1,
          ),
        ),
        filled: true,
        fillColor: context.theme.colorScheme.surface.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 12),
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