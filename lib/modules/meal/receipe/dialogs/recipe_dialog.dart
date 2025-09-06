import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:admin/utils/image_base64_util.dart';
import '../../meal_controller.dart';
import '../../../../widgets/searchable_dropdown.dart';
import '../../../../widgets/multi_select_dropdown.dart';
import '../../../../config/dropdown_data.dart';

class RecipeDialogs {
  static void showAddRecipeDialog(BuildContext context,
      MealController controller) {
    controller.clearRecipeForm();
    int dietaryCategory = 0;
    final List<dynamic> ingredients = [];
    File? image;
    bool isDialogActive = true;

    // State variables for vitamins and minerals - moved outside StatefulBuilder
    List<dynamic> selectedVitamins = [];
    List<dynamic> selectedMinerals = [];
    String selectedCuisine = '';

    // Simplified state variables for better performance
    bool isBasicExpanded = true;
    bool isDetailsExpanded = false;
    bool isNutritionExpanded = false;
    bool isIngredientsExpanded = false;
    bool isImageExpanded = false;

    Get.dialog<void>(
      Dialog.fullscreen(
        child: Material(
          child: Container(
            color: context.theme.colorScheme.surface,
            child: StatefulBuilder(
              builder: (dialogContext, setDialogState) {
                if (!isDialogActive) return Container();

                return Scaffold(
                  backgroundColor: dialogContext.theme.colorScheme.surface,
                  appBar: AppBar(
                    backgroundColor: dialogContext.theme.colorScheme.surface,
                    elevation: 0,
                    leading: IconButton(
                      onPressed: () {
                        isDialogActive = false;
                        Get.back<void>();
                      },
                      icon: const Icon(Icons.close_rounded, size: 24),
                    ),
                    title: const Text(
                      'Create New Recipe',
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
                                        color: dialogContext.theme.colorScheme
                                            .primary),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Basic Information',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                              6),
                                        ),
                                        child: const FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'Required',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Obx(() =>
                                    RecipeValidatedTextField(
                                      controller.nameController,
                                      'Recipe Name *',
                                      dialogContext,
                                      isRequired: true,
                                      errorText: controller.nameError.value,
                                      onChanged: controller.validateName,
                                      prefixIcon: Icons.restaurant_menu,
                                    )),
                                const SizedBox(height: 16),
                                Obx(() =>
                                    RecipeValidatedTextField(
                                      controller.descriptionController,
                                      'Description',
                                      dialogContext,
                                      maxLines: 3,
                                      errorText: controller.descriptionError
                                          .value,
                                      onChanged: controller.validateDescription,
                                      prefixIcon: Icons.description_outlined,
                                    )),
                                const SizedBox(height: 16),
                                RecipeTextField(
                                  controller.instructionsController,
                                  'Preparation Instructions',
                                  dialogContext,
                                  maxLines: 5,
                                  prefixIcon: Icons
                                      .format_list_numbered_rounded,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Recipe Details Section - Now collapsible
                        Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.tune_rounded,
                                    color: Colors.green),
                                title: const Text(
                                  'Recipe Details',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: const Text(
                                    'Servings, cuisine & dietary info'),
                                trailing: Icon(
                                  isDetailsExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),
                                onTap: () =>
                                    setDialogState(() =>
                                    isDetailsExpanded = !isDetailsExpanded),
                              ),
                              if (isDetailsExpanded) ...[
                                const Divider(height: 1),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Obx(() =>
                                                RecipeValidatedTextField(
                                                  controller.servingsController,
                                                  'Servings *',
                                                  dialogContext,
                                                  keyboardType: TextInputType
                                                      .number,
                                                  inputFormatters: MealController
                                                      .getIntegerInputFormatters(),
                                                  isRequired: true,
                                                  errorText: controller
                                                      .servingsError
                                                      .value,
                                                  onChanged: controller
                                                      .validateServings,
                                                  prefixIcon: Icons
                                                      .people_outline,
                                                )),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: TypedSearchableDropdown(
                                              dropdownType: DropdownType
                                                  .cuisines,
                                              value: selectedCuisine.isNotEmpty
                                                  ? selectedCuisine
                                                  : null,
                                              label: 'Cuisine',
                                              hint: 'Select cuisine',
                                              onChanged: (dynamic newValue) {
                                                setDialogState(() =>
                                                selectedCuisine =
                                                    newValue as String? ?? '');
                                                controller.cuisineController
                                                    .text = selectedCuisine;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      RecipeDietaryDropdown(
                                          dialogContext,
                                          dietaryCategory,
                                              (value) =>
                                              setDialogState(() =>
                                              dietaryCategory = value ?? 0)
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Nutrition Information Section - New
                        Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.health_and_safety_outlined,
                                    color: Colors.blue),
                                title: const Text(
                                  'Nutrition Information',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: const Text(
                                    'Calories, macros & micronutrients'),
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
                                  child: RecipeNutritionSection(
                                    controller: controller,
                                    selectedVitamins: selectedVitamins,
                                    selectedMinerals: selectedMinerals,
                                    onVitaminsChanged: (List<dynamic> v) {
                                      selectedVitamins = v;
                                    },
                                    onMineralsChanged: (List<dynamic> m) {
                                      selectedMinerals = m;
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Ingredients Section - Collapsible
                        Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.inventory_2_outlined,
                                    color: Colors.orange),
                                title: const Text(
                                  'Ingredients',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text('${ingredients
                                    .length} ingredient${ingredients.length == 1
                                    ? ''
                                    : 's'} added'),
                                trailing: Icon(
                                  isIngredientsExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),
                                onTap: () =>
                                    setDialogState(() =>
                                    isIngredientsExpanded =
                                    !isIngredientsExpanded),
                              ),
                              if (isIngredientsExpanded) ...[
                                const Divider(height: 1),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: RecipeIngredientsSection(
                                    ingredients: ingredients,
                                    controller: controller,
                                    onIngredientsChanged: () =>
                                        setDialogState(() {}),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Image Section - Now collapsible
                        Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.image_outlined,
                                    color: Colors.purple),
                                title: const Text(
                                  'Recipe Image',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(image != null
                                    ? 'Image selected'
                                    : 'Optional photo'),
                                trailing: Icon(
                                  isImageExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),
                                onTap: () =>
                                    setDialogState(() =>
                                    isImageExpanded = !isImageExpanded),
                              ),
                              if (isImageExpanded) ...[
                                const Divider(height: 1),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: RecipeImageSection(
                                    image: image,
                                    onImageChanged: (File? newImage) =>
                                        setDialogState(() => image = newImage),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  floatingActionButton: Obx(() {
                    final hasValidationError =
                        controller.nameError.value.isNotEmpty ||
                        controller.descriptionError.value.isNotEmpty ||
                        controller.servingsError.value.isNotEmpty ||
                        controller.caloriesError.value.isNotEmpty ||
                        controller.proteinError.value.isNotEmpty ||
                        controller.carbsError.value.isNotEmpty ||
                        controller.fatError.value.isNotEmpty ||
                        controller.fiberError.value.isNotEmpty ||
                            controller.sugarError.value.isNotEmpty;

                    return FloatingActionButton.extended(
                      onPressed: () async {
                        if (controller.validateRecipeForm()) {
                          final data = controller.createRecipeData(
                              dietaryCategory, ingredients);

                          // Fill cuisine
                          data['cuisine'] = selectedCuisine;

                          // Fill vitamins and minerals
                          if (controller.vitaminsController.text.isNotEmpty) {
                            data['vitamins'] =
                                controller.vitaminsController.text;
                          }
                          if (controller.mineralsController.text.isNotEmpty) {
                            data['minerals'] =
                                controller.mineralsController.text;
                          }

                          if (image != null) {
                            try {
                              final base64String = await ImageBase64Util
                                  .processImageForUpload(image!);
                              data['imageUrl'] = base64String;
                            } catch (e) {
                              Get.snackbar('Error',
                                  'Failed to process image: ${e.toString()}');
                              return;
                            }
                          }
                          controller.createRecipe(data).then((success) {
                            if (success) {
                              isDialogActive = false;
                              Get.back<void>();
                              Get.snackbar(
                                  'Success', 'Recipe created successfully');
                            }
                          });
                        }
                      },
                      backgroundColor: hasValidationError
                          ? Colors.grey
                          : dialogContext.theme.colorScheme.onSurface,
                      foregroundColor: hasValidationError
                          ? Colors.grey.shade600
                          : dialogContext.theme.colorScheme.onPrimary,
                      icon: Icon(
                        hasValidationError
                            ? Icons.block_rounded
                            : Icons.check_rounded,
                      ),
                      label: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Text(
                          hasValidationError
                              ? 'Fix Errors'
                              : 'Save Recipe',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    );
                  }),
                  floatingActionButtonLocation: FloatingActionButtonLocation
                      .centerFloat,
                );
              },
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      isDialogActive = false;
      // Clear all form data and reset state when dialog is closed
      controller.clearRecipeForm();
      ingredients.clear();
      selectedVitamins.clear();
      selectedMinerals.clear();
      selectedCuisine = '';
      image = null;
      dietaryCategory = 0;
      // Reset expansion states to default
      isBasicExpanded = true;
      isDetailsExpanded = false;
      isNutritionExpanded = false;
      isIngredientsExpanded = false;
      isImageExpanded = false;
    });
  }

  // Helper method to build collapsible recipe form sections
  static Widget _buildCollapsibleRecipeSection({
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
          Flexible(
            child: Text(
              'Fields marked with * are required',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.red.shade700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static void showEditRecipeDialog(BuildContext context,
      MealController controller, dynamic recipe) {
    controller.setupRecipeForm(recipe);
    int dietaryCategory = (recipe['dietaryCategory'] as int?) ?? 0;
    final List<dynamic> ingredients = recipe['ingredients'] != null ? List<
        dynamic>.from(recipe['ingredients'] as List) : [];
    File? image = null;
    bool isDialogActive = true;

    // Setup nutrition controllers with existing data
    controller.caloriesController.text = '${recipe['calories'] ?? 0}';
    controller.proteinController.text = '${recipe['protein'] ?? 0}';
    controller.carbsController.text = '${recipe['carbohydrates'] ?? 0}';
    controller.fatController.text = '${recipe['fat'] ?? 0}';
    controller.fiberController.text = '${recipe['fiber'] ?? 0}';
    controller.sugarController.text = '${recipe['sugar'] ?? 0}';
    controller.vitaminsController.text = recipe['vitamins']?.toString() ?? '';
    controller.mineralsController.text = recipe['minerals']?.toString() ?? '';
    // Parse fatBreakdown if it exists
    String fatBreakdownText = '';
    try {
      if (recipe['fatBreakdown'] != null) {
        fatBreakdownText = recipe['fatBreakdown'].toString();
      }
    } catch (e) {
      fatBreakdownText = '';
    }

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
          child: StatefulBuilder(
            builder: (dialogContext, setState) {
              if (!isDialogActive) return Container(); // Safety check

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Recipe',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: dialogContext.theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Obx(() =>
                        RecipeValidatedTextField(
                            controller.nameController, 'Recipe Name',
                            dialogContext, isRequired: true,
                            errorText: controller.nameError.value,
                            onChanged: controller.validateName)),
                    const SizedBox(height: 16),
                    Obx(() =>
                        RecipeValidatedTextField(
                        controller.descriptionController, 'Description',
                        dialogContext, maxLines: 3,
                        errorText: controller.descriptionError.value,
                        onChanged: controller.validateDescription)),
                    const SizedBox(height: 16),
                    RecipeTextField(
                      controller.instructionsController,
                      'Preparation Instructions',
                      dialogContext,
                      maxLines: 5,
                      prefixIcon: Icons.format_list_numbered_rounded,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: Obx(() =>
                            RecipeValidatedTextField(
                              controller.servingsController, 'Servings',
                              dialogContext, keyboardType: TextInputType.number,
                              errorText: controller.servingsError.value,
                              onChanged: controller.validateServings,
                              prefixIcon: Icons.people_outline,
                            ))),
                        const SizedBox(width: 16),
                        Expanded(child: RecipeTextField(
                          controller.cuisineController,
                          'Cuisine',
                          dialogContext,
                          prefixIcon: Icons.public_outlined,
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),

                    RecipeDietaryDropdown(
                        dialogContext, dietaryCategory, (value) =>
                        setState(() => dietaryCategory = value ?? 0)),
                    const SizedBox(height: 24),

                    // Nutrition Information Section
                    Text(
                      'Nutrition Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: dialogContext.theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RecipeNutritionSection(
                      controller: controller,
                      selectedVitamins: const [],
                      // Default empty for edit dialog
                      selectedMinerals: const [],
                      // Default empty for edit dialog
                      onVitaminsChanged: (List<dynamic> v) {
                        // Handle in edit dialog if needed
                      },
                      onMineralsChanged: (List<dynamic> m) {
                        // Handle in edit dialog if needed
                      },
                    ),
                    const SizedBox(height: 24),

                    RecipeIngredientsSection(
                        ingredients: ingredients,
                        controller: controller,
                        onIngredientsChanged: () => setState(() {})),
                    const SizedBox(height: 24),

                    // Image handling section
                    RecipeEditImageSection(
                      recipe: recipe,
                      image: image,
                      onImageChanged: (newImage) =>
                          setState(() {
                            image = newImage;
                          }),
                    ),
                    const SizedBox(height: 32),

                    RecipeDialogActions(dialogContext, () async {
                      if (controller.nameController.text.isEmpty) {
                        Get.snackbar('Error', 'Recipe name is required');
                        return;
                      }

                      final data = controller.createRecipeData(dietaryCategory,
                          ingredients);

                      if (image != null) {
                        try {
                          final base64String = await ImageBase64Util
                              .processImageForUpload(image!);
                          data['imageUrl'] = base64String;
                        } catch (e) {
                          Get.snackbar('Error',
                              'Failed to process image: ${e.toString()}');
                          return;
                        }
                      }
                      data['recipeId'] = recipe['recipeId'];
                      data['isActive'] = recipe['isActive'] ?? true;
                      data['createdBy'] = recipe['createdBy'];
                      data['createdOn'] = recipe['createdOn'];

                      controller.updateRecipe(
                          recipe['recipeId']?.toString() ?? '', data).then((
                          success) {
                        if (success) {
                          isDialogActive = false;
                          Get.back<void>();
                          Get.snackbar(
                              'Success', 'Recipe updated successfully');
                        }
                      });
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    ).whenComplete(() {
      isDialogActive = false;
    });
  }

  static void showDeleteConfirmation(BuildContext context, dynamic recipe,
      MealController controller) {
    Get.dialog<void>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        title: Text('Delete Recipe',
            style: TextStyle(color: context.theme.colorScheme.onSurface)),
        content: Text(
          'Are you sure you want to delete "${recipe['name'] != null
              ? recipe['name'].toString()
              : 'this recipe'}"?',
          style: TextStyle(
              color: context.theme.colorScheme.onSurface.withValues(
                  alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            style: TextButton.styleFrom(
              foregroundColor: context.theme.colorScheme.onSurface.withValues(
                  alpha: 0.8),
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final recipeId = recipe['recipeId'];
              final recipeIdString = recipeId != null
                  ? recipeId.toString()
                  : '';
              controller
                  .deleteRecipe(recipeIdString)
                  .then((success) {
                if (success) {
                  Get.back<void>();
                  Get.snackbar('Success', 'Recipe deleted successfully');
                }
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: context.theme.colorScheme.onSurface,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  static void showDeleteAllConfirmation(BuildContext context,
      MealController controller) {
    Get.dialog<void>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        title: Text('Delete All Recipes',
            style: TextStyle(color: context.theme.colorScheme.onSurface)),
        content: Text(
          'Are you sure you want to delete ALL recipes? This action cannot be undone.',
          style: TextStyle(
              color: context.theme.colorScheme.onSurface.withValues(
                  alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            style: TextButton.styleFrom(
              foregroundColor: context.theme.colorScheme.onSurface.withValues(
                  alpha: 0.8),
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Delete all recipes one by one
              Get.back<void>(); // Close dialog first

              if (controller.recipes.isEmpty) return;

              final recipeCount = controller.recipes.length;
              bool allDeleted = true;

              // Delete all recipes
              final recipeIds = controller.recipes.map((
                  recipe) => recipe['recipeId']?.toString() ?? '').toList();
              for (final recipeId in recipeIds) {
                if (recipeId.isNotEmpty) {
                  final success = await controller.deleteRecipe(recipeId);
                  if (!success) {
                    allDeleted = false;
                    break;
                  }
                }
              }

              if (allDeleted) {
                Get.snackbar(
                    'Success', 'All $recipeCount recipes deleted successfully');
              } else {
                Get.snackbar('Error', 'Some recipes could not be deleted');
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

// Supporting widgets for the dialogs

// Simplified RecipeImageSection for better performance
class RecipeImageSection extends StatelessWidget {
  final File? image;
  final void Function(File?) onImageChanged;

  const RecipeImageSection({
    super.key,
    this.image,
    required this.onImageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (image != null)
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () => onImageChanged(null),
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined,
                    size: 32,
                    color: Colors.grey.withOpacity(0.6)),
                const SizedBox(height: 8),
                Text(
                  'Add Recipe Photo',
                  style: TextStyle(
                    color: Colors.grey.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    _pickImage(ImageSource.gallery, onImageChanged),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Gallery'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera, onImageChanged),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Camera'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Future<void> _pickImage(ImageSource source,
      void Function(File?) callback) async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (photo != null) {
      callback(File(photo.path));
    }
  }
}

class RecipeBasicInfoSection extends StatelessWidget {
  final MealController controller;

  const RecipeBasicInfoSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: context.theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        Obx(() =>
            RecipeValidatedTextField(
          controller.nameController,
          'Recipe Name',
          context,
          isRequired: true,
          errorText: controller.nameError.value,
          onChanged: controller.validateName,
          prefixIcon: Icons.restaurant_menu,
        )),
        const SizedBox(height: 16),

        Obx(() =>
            RecipeValidatedTextField(
          controller.descriptionController,
          'Description',
          context,
          maxLines: 3,
          errorText: controller.descriptionError.value,
          onChanged: controller.validateDescription,
          prefixIcon: Icons.description_outlined,
        )),
      ],
    );
  }
}

class RecipeDetailsSection extends StatelessWidget {
  final MealController controller;
  final int dietaryCategory;
  final void Function(int?) onDietaryCategoryChanged;

  const RecipeDetailsSection({
    super.key,
    required this.controller,
    required this.dietaryCategory,
    required this.onDietaryCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recipe Details',
          style: context.theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Obx(() =>
                  RecipeValidatedTextField(
                controller.servingsController,
                'Servings',
                context,
                keyboardType: TextInputType.number,
                inputFormatters: MealController.getIntegerInputFormatters(),
                isRequired: true,
                errorText: controller.servingsError.value,
                onChanged: controller.validateServings,
                prefixIcon: Icons.people_outline,
              )),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: RecipeTextField(
                controller.cuisineController,
                'Cuisine',
                context,
                prefixIcon: Icons.public_outlined,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Dietary Category Card
        Card(
          elevation: 0,
          color: context.theme.colorScheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.eco_outlined,
                      color: context.theme.colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Dietary Category',
                      style: context.theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                RecipeDietaryDropdown(
                    context, dietaryCategory, onDietaryCategoryChanged),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RecipeIngredientsSection extends StatelessWidget {
  final List<dynamic> ingredients;
  final MealController controller;
  final VoidCallback onIngredientsChanged;

  const RecipeIngredientsSection({
    super.key,
    required this.ingredients,
    required this.controller,
    required this.onIngredientsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recipe Ingredients',
              style: context.theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () =>
                  _showSimpleAddIngredientDialog(
                      context, ingredients, onIngredientsChanged, controller),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (ingredients.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 32,
                  color: context.theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(height: 8),
                Text(
                  'No ingredients added yet',
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    color: context.theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add ingredients to make your recipe complete',
                  style: context.theme.textTheme.bodySmall?.copyWith(
                    color: context.theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ingredients.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final ingredient = ingredients[index];
              return Card(
                elevation: 1,
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: context.theme.colorScheme.primary
                        .withOpacity(0.1),
                    child: Icon(
                      Icons.eco,
                      color: context.theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    // Display ingredientName from ingredient array if available
                    ingredient['ingredientName']?.toString() ??
                        'Ingredient ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    'Amount: ${ingredient['quantity'] ?? 0}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '#${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.theme.colorScheme.onSurface
                              .withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          ingredients.removeAt(index);
                          onIngredientsChanged();
                        },
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Remove ingredient',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  // Simplified ingredient dialog for better performance
  void _showSimpleAddIngredientDialog(BuildContext context,
      List<dynamic> ingredients,
      VoidCallback onIngredientsChanged, MealController controller) {
    final Map<dynamic, Map<String, dynamic>> selectedIngredients = {};

    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.9,
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (dialogContext, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(Icons.add_shopping_cart_rounded,
                          color: dialogContext.theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Add Ingredients',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back<void>(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Content
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (controller.ingredients.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 48,
                                    color: Colors.grey),
                                SizedBox(height: 16),
                                Text('No ingredients available'),
                                Text('Please add ingredients first',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: controller.ingredients.length,
                          itemBuilder: (context, index) {
                            final ingredient = controller.ingredients[index];
                            final isSelected = selectedIngredients.containsKey(
                                ingredient);

                            return Card(
                              margin: const EdgeInsets.all(8),
                              child: ListTile(
                                leading: Checkbox(
                                  value: isSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedIngredients[ingredient] = {
                                          'quantity': 100,
                                          'unit': 'g'
                                        };
                                      } else {
                                        selectedIngredients.remove(ingredient);
                                      }
                                    });
                                  },
                                ),
                                title: Text(
                                  ingredient['name']?.toString() ??
                                      'Unknown Ingredient',
                                ),
                                subtitle: Text(
                                  '${ingredient['calories'] ?? 0} cal/100g',
                                ),
                                trailing: isSelected
                                    ? SizedBox(
                                  width: 100,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          decoration: const InputDecoration(
                                            isDense: true,
                                            border: OutlineInputBorder(),
                                                ),
                                                controller: TextEditingController(
                                                    text: selectedIngredients[ingredient]!['quantity']
                                                        .toString()),
                                                onChanged: (value) {
                                                  final quantity = int.tryParse(
                                                      value) ?? 100;
                                                  selectedIngredients[ingredient]!['quantity'] =
                                                      quantity;
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Text('g'),
                                          ],
                                        ),
                                )
                                    : null,
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back<void>(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedIngredients.isEmpty ? null : () {
                            // Add selected ingredients
                            for (final entry in selectedIngredients.entries) {
                              final ingredient = entry.key;
                              final quantityData = entry.value;

                              ingredients.add({
                                'ingredientId': ingredient['ingredientId'] ??
                                    ingredient['id'],
                                'quantity': quantityData['quantity'],
                              });
                            }

                            onIngredientsChanged();
                            Get.back<void>();
                            Get.snackbar('Success', 'Added ${selectedIngredients
                                .length} ingredient(s)');
                          },
                          child: Text(
                            selectedIngredients.isEmpty
                                ? 'Select Ingredients'
                                : 'Add ${selectedIngredients
                                .length} Ingredient(s)',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class RecipeEditImageSection extends StatelessWidget {
  final dynamic recipe;
  final File? image;
  final void Function(File?) onImageChanged;

  const RecipeEditImageSection({
    super.key,
    required this.recipe,
    required this.image,
    required this.onImageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recipe Image (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        // Show existing image if available
        if (recipe['imageUrl'] != null && recipe['imageUrl']
            .toString()
            .isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Image:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                    maxWidth: 320, maxHeight: 180),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.theme.colorScheme.primary.withValues(
                        alpha: 0.15),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildPlaceholderImage(context, recipe),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),

        Text(
          image == null ? (recipe['imageUrl'] != null &&
              recipe['imageUrl']
                  .toString()
                  .isNotEmpty
              ? 'Replace Image:'
              : 'Select an image from your gallery or take a photo')
              : 'New Image Selected:',
          style: TextStyle(
            fontSize: 12,
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _pickImage(ImageSource.gallery, (pickedImage) =>
                      onImageChanged(pickedImage));
                },
                icon: const Icon(Icons.photo_library, size: 18),
                label: const Text(
                  'Gallery',
                  style: TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.theme.colorScheme.primaryContainer,
                  foregroundColor: context.theme.colorScheme.onPrimaryContainer,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _pickImage(ImageSource.camera, (pickedImage) =>
                      onImageChanged(pickedImage));
                },
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text(
                  'Camera',
                  style: TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.theme.colorScheme.secondaryContainer,
                  foregroundColor: context.theme.colorScheme
                      .onSecondaryContainer,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 10),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (image != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Image Preview:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.theme.colorScheme.onSurface,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => onImageChanged(null),
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Remove'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                    maxWidth: 320, maxHeight: 180),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.theme.colorScheme.primary.withValues(
                        alpha: 0.15),
                  ),
                  color: Colors.black12,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: image != null
                      ? Image.file(
                    image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
                  )
                      : Center(
                    child: Icon(
                      Icons.image,
                      size: 48,
                      color: context.theme.colorScheme.onSurface.withValues(
                          alpha: 0.2),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPlaceholderImage(BuildContext context, dynamic recipe) {
    final imageUrl = recipe['imageUrl']?.toString();
    return ImageBase64Util.buildImage(
      imageUrl,
      fit: BoxFit.cover,
      errorWidget: _buildFallbackImage(context),
    );
  }

  Widget _buildFallbackImage(BuildContext context) {
    return Container(
      color: Colors.grey.withValues(alpha: 0.3),
      child: const Center(
        child: Icon(Icons.restaurant, size: 48, color: Colors.grey),
      ),
    );
  }

  bool _isBase64String(String str) {
    try {
      final cleanStr = str.replaceAll(RegExp(r'\s+'), '');
      if (cleanStr.length % 4 != 0) return false;
      base64Decode(cleanStr);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _pickImage(ImageSource source, void Function(File?) callback) async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (photo != null) {
      callback(File(photo.path));
    }
  }
}

// Helper widgets

// Helper widgets - Simplified for better performance

class RecipeValidatedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final BuildContext context;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final void Function(String)? onChanged;
  final bool isRequired;
  final IconData? prefixIcon;

  const RecipeValidatedTextField(this.controller, this.label, this.context, {
    super.key,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.errorText,
    this.onChanged,
    this.isRequired = false,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    try {
      controller.text; // Test if controller is valid
    } catch (e) {
      return Container(); // Return empty container if controller is disposed
    }

    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(color: context.theme.colorScheme.onSurface),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon,
            color: context.theme.colorScheme.onSurface.withOpacity(0.7))
            : null,
        errorText: errorText?.isNotEmpty == true ? errorText : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: context.theme.colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: context.theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: context.theme.colorScheme.primary.withOpacity(0.6),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.red.withOpacity(0.6),
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
}

class RecipeTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final BuildContext context;
  final int maxLines;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final void Function(String)? onChanged;

  const RecipeTextField(this.controller,
      this.label,
      this.context, {
        super.key,
        this.maxLines = 1,
        this.keyboardType,
        this.prefixIcon,
        this.onChanged,
      });

  @override
  Widget build(BuildContext context) {
    try {
      controller.text;
    } catch (e) {
      return Container();
    }

    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: context.theme.colorScheme.onSurface),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            color: context.theme.colorScheme.onSurface.withOpacity(0.7)),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon,
            color: context.theme.colorScheme.onSurface.withOpacity(0.7))
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: context.theme.colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: context.theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: context.theme.colorScheme.primary.withOpacity(0.6),
            width: 2,
          ),
        ),
        filled: true,
        fillColor: context.theme.colorScheme.surface.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 12),
      ),
    );
  }
}

class RecipeDietaryDropdown extends StatelessWidget {
  final BuildContext context;
  final int value;
  final void Function(int?) onChanged;

  const RecipeDietaryDropdown(this.context, this.value, this.onChanged,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return TypedSearchableDropdown(
      dropdownType: DropdownType.dietaryCategories,
      value: value,
      label: 'Dietary Category',
      hint: 'Select dietary category',
      onChanged: (dynamic newValue) => onChanged(newValue as int?),
    );
  }
}

class RecipeNutritionSection extends StatelessWidget {
  final MealController controller;
  final List<dynamic> selectedVitamins;
  final List<dynamic> selectedMinerals;
  final void Function(List<dynamic>) onVitaminsChanged;
  final void Function(List<dynamic>) onMineralsChanged;

  const RecipeNutritionSection({
    super.key,
    required this.controller,
    required this.selectedVitamins,
    required this.selectedMinerals,
    required this.onVitaminsChanged,
    required this.onMineralsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              // Composition Progress Meter - Fixed to use controller's reactive values
              Obx(() {
                final totalComposition = controller.totalComposition;
                final isOverLimit = totalComposition > 100.0;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isOverLimit
                          ? Colors.red.withOpacity(0.3)
                          : context.theme.colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.pie_chart_rounded,
                            size: 20,
                            color: isOverLimit
                                ? Colors.red
                                : context.theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Flexible(
                            child: Text(
                              'Nutrition Composition',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isOverLimit
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${totalComposition.toStringAsFixed(1)}g / 100g',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isOverLimit ? Colors.red : Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: (totalComposition / 100).clamp(0.0, 1.0),
                        backgroundColor: context.theme.colorScheme.outline
                            .withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOverLimit ? Colors.red : context.theme.colorScheme
                              .primary,
                        ),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 8),
                      if (isOverLimit)
                        const Row(
                          children: [
                            Icon(Icons.warning_rounded, size: 16,
                                color: Colors.red),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Total composition exceeds 100g. Please adjust values.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 16,
                                color: Colors.green),
                            const SizedBox(width: 6),
                            Text(
                              'Remaining: ${(100 - totalComposition)
                                  .toStringAsFixed(1)}g',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Calories field (required)
              Obx(() =>
                  RecipeValidatedTextField(
                    controller.caloriesController,
                    'Calories (kcal) *',
                    context,
                    keyboardType: TextInputType.number,
                    inputFormatters: MealController.getIntegerInputFormatters(),
                    isRequired: true,
                    errorText: controller.caloriesError.value,
                    onChanged: controller.validateCalories,
                    prefixIcon: Icons.local_fire_department_outlined,
                  )),
              const SizedBox(height: 12),

              // Macronutrients row 1: Protein & Carbohydrates
              Row(
                children: [
                  Expanded(
                    child: Obx(() =>
                        RecipeValidatedTextField(
                          controller.proteinController,
                          'Protein (g)',
                          context,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: MealController
                              .getNumberInputFormatters(),
                          errorText: controller.proteinError.value,
                          onChanged: (value) {
                            controller.validateNutrient(
                                value, controller.proteinError, 'Protein');
                            controller.validateNutritionComposition();
                            // Update the observable value for reactive calculation
                            controller.proteinValue.value =
                                double.tryParse(value) ?? 0.0;
                          },
                          prefixIcon: Icons.fitness_center_outlined,
                        )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() =>
                        RecipeValidatedTextField(
                          controller.carbsController,
                          'Carbs (g)',
                          context,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: MealController
                              .getNumberInputFormatters(),
                          errorText: controller.carbsError.value,
                          onChanged: (value) {
                            controller.validateNutrient(
                                value, controller.carbsError, 'Carbohydrates');
                            controller.validateNutritionComposition();
                            controller.carbsValue.value =
                                double.tryParse(value) ?? 0.0;
                          },
                          prefixIcon: Icons.grain_outlined,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Macronutrients row 2: Fat & Fiber
              Row(
                children: [
                  Expanded(
                    child: Obx(() =>
                        RecipeValidatedTextField(
                          controller.fatController,
                          'Fat (g)',
                          context,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: MealController
                              .getNumberInputFormatters(),
                          errorText: controller.fatError.value,
                          onChanged: (value) {
                            controller.validateNutrient(
                                value, controller.fatError, 'Fat');
                            controller.validateNutritionComposition();
                            controller.fatValue.value =
                                double.tryParse(value) ?? 0.0;
                          },
                          prefixIcon: Icons.opacity_outlined,
                        )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() =>
                        RecipeValidatedTextField(
                          controller.fiberController,
                          'Fiber (g)',
                          context,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: MealController
                              .getNumberInputFormatters(),
                          errorText: controller.fiberError.value,
                          onChanged: (value) {
                            controller.validateNutrient(
                                value, controller.fiberError, 'Fiber');
                            controller.validateNutritionComposition();
                            controller.fiberValue.value =
                                double.tryParse(value) ?? 0.0;
                          },
                          prefixIcon: Icons.grass_outlined,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Sugar field
              Row(
                children: [
                  Expanded(
                    child: Obx(() =>
                        RecipeValidatedTextField(
                          controller.sugarController,
                          'Sugar (g)',
                          context,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: MealController
                              .getNumberInputFormatters(),
                          errorText: controller.sugarError.value,
                          onChanged: (value) {
                            controller.validateNutrient(
                                value, controller.sugarError, 'Sugar');
                            controller.validateNutritionComposition();
                            controller.sugarValue.value =
                                double.tryParse(value) ?? 0.0;
                          },
                          prefixIcon: Icons.cake_outlined,
                        )),
                  ),
                  const Expanded(child: SizedBox()), // Empty space for symmetry
                ],
              ),
              const SizedBox(height: 16),

              // Micronutrients section
              TypedMultiSelectDropdown(
                dropdownType: DropdownType.vitamins,
                selectedValues: selectedVitamins,
                label: 'Vitamins',
                hint: 'Select vitamins present',
                onChanged: (List<dynamic> selected) {
                  onVitaminsChanged(selected);
                  final vitaminMap = <String, dynamic>{};
                  for (final vitamin in selected) {
                    final item = DropdownDataManager.findItemByValue(
                        DropdownDataManager.vitamins, vitamin);
                    if (item != null) {
                      vitaminMap[item.label] = 0.0;
                    }
                  }
                  controller.vitaminsController.text = vitaminMap.isEmpty
                      ? ''
                      : jsonEncode(vitaminMap);
                },
              ),
              const SizedBox(height: 12),
              TypedMultiSelectDropdown(
                dropdownType: DropdownType.minerals,
                selectedValues: selectedMinerals,
                label: 'Minerals',
                hint: 'Select minerals present',
                onChanged: (List<dynamic> selected) {
                  onMineralsChanged(selected);
                  final mineralMap = <String, dynamic>{};
                  for (final mineral in selected) {
                    final item = DropdownDataManager.findItemByValue(
                        DropdownDataManager.minerals, mineral);
                    if (item != null) {
                      mineralMap[item.label] = 0.0;
                    }
                  }
                  controller.mineralsController.text = mineralMap.isEmpty
                      ? ''
                      : jsonEncode(mineralMap);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class RecipeDialogActions extends StatelessWidget {
  final BuildContext context;
  final VoidCallback onSave;

  const RecipeDialogActions(this.context, this.onSave, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Get.back<void>(),
          style: TextButton.styleFrom(
            foregroundColor: context.theme.colorScheme.onSurface.withValues(
                alpha: 0.8),
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.theme.colorScheme.onSurface,
            foregroundColor: context.theme.colorScheme.surfaceContainerLowest,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}