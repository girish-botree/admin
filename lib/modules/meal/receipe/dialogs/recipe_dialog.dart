import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../meal_controller.dart';
import '../../../../widgets/searchable_dropdown.dart';
import '../../../../config/dropdown_data.dart';

class RecipeDialogs {
  static void showAddRecipeDialog(BuildContext context,
      MealController controller) {
    controller.clearRecipeForm();
    int dietaryCategory = 0;
    final List<dynamic> ingredients = [];
    File? image;
    bool isDialogActive = true;

    Get.dialog<void>(
      Dialog.fullscreen(
        child: Material(
          child: Container(
            color: context.theme.colorScheme.surfaceContainerLowest,
            child: StatefulBuilder(
              builder: (dialogContext, setState) {
                if (!isDialogActive) return Container();

                return Scaffold(
                  backgroundColor: dialogContext.theme.colorScheme
                      .surfaceContainerLowest,
                  appBar: AppBar(
                    backgroundColor: dialogContext.theme.colorScheme
                        .surfaceContainerLowest,
                    elevation: 0,
                    leading: IconButton(
                      onPressed: () {
                        isDialogActive = false;
                        Get.back<void>();
                      },
                      icon: Icon(
                        Icons.close,
                        color: dialogContext.theme.colorScheme.onSurface,
                      ),
                    ),
                    title: Text(
                      'Create Recipe',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: dialogContext.theme.colorScheme.onSurface,
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (controller.validateRecipeForm()) {
                              final data = controller.createRecipeData(
                                  dietaryCategory, ingredients);
                              if (image != null) {
                                try {
                                  final bytes = await image!.readAsBytes();
                                  final base64String = base64Encode(bytes);
                                  data['imageUrl'] = base64String;
                                } catch (e) {
                                  Get.snackbar(
                                      'Error', 'Failed to process image');
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: dialogContext.theme.colorScheme
                                .onSurface,
                            foregroundColor: dialogContext.theme.colorScheme
                                .surfaceContainerLowest,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Save Recipe'),
                        ),
                      ),
                    ],
                  ),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Image Section
                        RecipeImageSection(
                          image: image,
                          onImageChanged: (File? newImage) =>
                              setState(() => image = newImage),
                        ),

                        const SizedBox(height: 32),

                        // Basic Information Section
                        RecipeBasicInfoSection(controller: controller),

                        const SizedBox(height: 24),

                        // Recipe Details Section
                        RecipeDetailsSection(
                          controller: controller,
                          dietaryCategory: dietaryCategory,
                          onDietaryCategoryChanged: (value) =>
                              setState(() => dietaryCategory = value ?? 0),
                        ),

                        const SizedBox(height: 24),

                        // Ingredients Section
                        RecipeIngredientsSection(
                          ingredients: ingredients,
                          controller: controller,
                          onIngredientsChanged: () => setState(() {}),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      isDialogActive = false;
    });
  }

  static void showEditRecipeDialog(BuildContext context,
      MealController controller, dynamic recipe) {
    controller.setupRecipeForm(recipe);
    int dietaryCategory = (recipe['dietaryCategory'] as int?) ?? 0;
    final List<dynamic> ingredients = recipe['ingredients'] != null ? List<
        dynamic>.from(recipe['ingredients'] as List) : [];
    File? image = null;
    bool isDialogActive = true;

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
                        Expanded(child: RecipeCuisineDropdown(
                          dialogContext,
                          controller.cuisineController.text,
                              (String? value) {
                            controller.cuisineController.text = value ?? '';
                          },
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),

                    RecipeDietaryDropdown(
                        dialogContext, dietaryCategory, (value) =>
                        setState(() => dietaryCategory = value ?? 0)),
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
                          final bytes = await image!.readAsBytes();
                          final base64String = base64Encode(bytes);
                          data['imageUrl'] = base64String;
                        } catch (e) {
                          Get.snackbar('Error', 'Failed to process image');
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

class RecipeImageSection extends StatelessWidget {
  final File? image;
  final Function(File?) onImageChanged;

  const RecipeImageSection({
    super.key,
    this.image,
    required this.onImageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: context.theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: image != null
                ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
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
                  child: IconButton.filledTonal(
                    onPressed: () => onImageChanged(null),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: context.theme.colorScheme.onSurface
                          .withOpacity(0.7),
                      foregroundColor: context.theme.colorScheme
                          .surfaceContainerLowest,
                    ),
                  ),
                ),
              ],
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 64,
                  color: context.theme.colorScheme.onSurface.withValues(
                      alpha: 0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'Add Recipe Photo',
                  style: context.theme.textTheme.titleMedium?.copyWith(
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Make your recipe more appealing with a photo',
                  style: context.theme.textTheme.bodySmall?.copyWith(
                    color: context.theme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Image Action Buttons
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _pickImage(ImageSource.gallery, onImageChanged),
                  icon: Icon(Icons.photo_library_outlined,
                      color: context.theme.colorScheme.onSurface),
                  label: Text('Gallery', style: TextStyle(
                      color: context.theme.colorScheme.onSurface)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: context.theme.colorScheme.onSurface.withValues(
                            alpha: 0.3)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _pickImage(ImageSource.camera, onImageChanged),
                  icon: Icon(Icons.camera_alt_outlined,
                      color: context.theme.colorScheme.onSurface),
                  label: Text('Camera', style: TextStyle(
                      color: context.theme.colorScheme.onSurface)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: context.theme.colorScheme.onSurface.withValues(
                            alpha: 0.3)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, Function(File?) callback) async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: source);
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
  final Function(int?) onDietaryCategoryChanged;

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
              child: RecipeCuisineDropdown(
                context,
                controller.cuisineController.text,
                    (String? value) {
                  controller.cuisineController.text = value ?? '';
                },
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
    return Card(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      color: context.theme.colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ingredients',
                      style: context.theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    if (ingredients.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.onSurface
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${ingredients.length}',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      _showAddIngredientDialog(
                      context, ingredients, onIngredientsChanged, controller),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.theme.colorScheme.onSurface,
                    foregroundColor: context.theme.colorScheme
                        .surfaceContainerLowest,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (ingredients.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.onSurface.withValues(
                      alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.theme.colorScheme.onSurface.withValues(
                        alpha: 0.2),
                    style: BorderStyle.solid,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 32,
                      color: context.theme.colorScheme.onSurface.withValues(
                          alpha: 0.6),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No ingredients added yet',
                      style: context.theme.textTheme.bodyMedium?.copyWith(
                        color: context.theme.colorScheme.onSurface.withValues(
                            alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add ingredients to make your recipe complete',
                      style: context.theme.textTheme.bodySmall?.copyWith(
                        color: context.theme.colorScheme.onSurface.withValues(
                            alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: ingredients
                    .asMap()
                    .entries
                    .map<Widget>((entry) {
                  final index = entry.key;
                  final ingredient = entry.value;

                  return Card(
                    key: ValueKey('ingredient_$index'),
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 1,
                    color: context.theme.colorScheme.surfaceContainerLowest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: context.theme.colorScheme.onSurface.withValues(
                            alpha: 0.1),
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: context.theme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        child: Icon(
                          Icons.eco,
                          color: context.theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        ingredient['ingredientName']?.toString() ??
                            ingredient['name']?.toString() ??
                            'Ingredient ${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: context.theme.colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        '${ingredient['quantity'] ?? 0}g',
                        style: TextStyle(
                            color: context.theme.colorScheme.onSurface
                                .withValues(alpha: 0.7)),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '#${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              ingredients.removeAt(index);
                              onIngredientsChanged();
                            },
                            icon: const Icon(Icons.delete_outline),
                            color: context.theme.colorScheme.onSurface,
                            tooltip: 'Remove ingredient',
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddIngredientDialog(BuildContext context, List<dynamic> ingredients,
      VoidCallback onIngredientsChanged, MealController controller) {
    // Selected ingredients with their quantities
    final Map<dynamic, int> selectedIngredients = {};

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        child: Container(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.8,
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (dialogContext, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Ingredients',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: dialogContext.theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Available ingredients section
                  Text(
                    'Available Ingredients:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: dialogContext.theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Ingredients list
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: dialogContext.theme.colorScheme.onSurface
                              .withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (controller.ingredients.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 48,
                                  color: dialogContext.theme.colorScheme
                                      .onSurface.withValues(alpha: 0.6),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No ingredients available',
                                  style: TextStyle(
                                    color: dialogContext.theme.colorScheme
                                        .onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
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
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              elevation: 0,
                              color: isSelected
                                  ? dialogContext.theme.colorScheme
                                  .primaryContainer.withValues(alpha: 0.5)
                                  : dialogContext.theme.colorScheme.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isSelected
                                      ? dialogContext.theme.colorScheme.primary
                                      : dialogContext.theme.colorScheme
                                      .onSurface.withValues(alpha: 0.15),
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                dense: true,
                                leading: Checkbox(
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedIngredients[ingredient] = 100;
                                      } else {
                                        selectedIngredients.remove(ingredient);
                                      }
                                    });
                                  },
                                ),
                                title: Text(
                                  ingredient['name']?.toString() ??
                                      ingredient['ingredientName']
                                          ?.toString() ??
                                      'Unknown Ingredient',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: dialogContext.theme.colorScheme
                                        .onSurface,
                                  ),
                                ),
                                subtitle: Text(
                                  '${ingredient['calories'] ?? 0} cal/100g',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: dialogContext.theme.colorScheme
                                        .onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                                trailing: isSelected
                                    ? SizedBox(
                                  width: 70,
                                  height: 32,
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                    decoration: InputDecoration(
                                      suffixText: 'g',
                                      suffixStyle: TextStyle(fontSize: 10,
                                          color: dialogContext.theme.colorScheme
                                              .onSurface.withValues(
                                              alpha: 0.6)),
                                      contentPadding: const EdgeInsets
                                          .symmetric(
                                          horizontal: 8, vertical: 4),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide(
                                            color: dialogContext.theme
                                                .colorScheme.primary),
                                      ),
                                      isDense: true,
                                    ),
                                    controller: TextEditingController(
                                      text: selectedIngredients[ingredient]
                                          .toString(),
                                    ),
                                    onChanged: (value) {
                                      final quantity = int.tryParse(value) ??
                                          100;
                                      selectedIngredients[ingredient] =
                                          quantity;
                                    },
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

                  // Selected ingredients summary
                  if (selectedIngredients.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: dialogContext.theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: dialogContext.theme.colorScheme.primary
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected (${selectedIngredients.length})',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: dialogContext.theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: selectedIngredients.entries.map((entry) {
                              final ingredient = entry.key;
                              final quantity = entry.value;
                              final name = ingredient['name']?.toString() ??
                                  ingredient['ingredientName']?.toString() ??
                                  'Unknown';

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: dialogContext.theme.colorScheme
                                      .primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: dialogContext.theme.colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${quantity}g',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: dialogContext.theme.colorScheme
                                            .onPrimary.withValues(alpha: 0.8),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedIngredients.remove(
                                              ingredient);
                                        });
                                      },
                                      child: Icon(
                                        Icons.close,
                                        size: 14,
                                        color: dialogContext.theme.colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back<void>(),
                        style: TextButton.styleFrom(
                          foregroundColor: dialogContext.theme.colorScheme
                              .onSurface
                              .withValues(alpha: 0.8),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: selectedIngredients.isEmpty ? null : () {
                          // Add selected ingredients to the recipe
                          for (final entry in selectedIngredients.entries) {
                            final ingredient = entry.key;
                            final quantity = entry.value;

                            // Check if ingredient is already added to avoid duplicates
                            final existingIndex = ingredients.indexWhere((
                                existing) =>
                            (existing['ingredientId']?.toString() ?? '') ==
                                (ingredient['ingredientId']?.toString() ??
                                    '') ||
                                (existing['name']?.toString() ?? '') ==
                                    (ingredient['name']?.toString() ?? ''));

                            if (existingIndex >= 0) {
                              // Update existing ingredient quantity
                              ingredients[existingIndex]['quantity'] = quantity;
                            } else {
                              // Add new ingredient
                              ingredients.add({
                                'ingredientId': ingredient['ingredientId'] ??
                                    ingredient['id'],
                                'ingredientName': ingredient['name'] ??
                                    ingredient['ingredientName'] ??
                                    'Unknown Ingredient',
                                'name': ingredient['name'] ??
                                    ingredient['ingredientName'] ??
                                    'Unknown Ingredient',
                                'quantity': quantity,
                              });
                            }
                          }

                          // Force UI update
                          onIngredientsChanged();

                          Get.back<void>();

                          // Show success message
                          Get.snackbar(
                            'Success',
                            'Added ${selectedIngredients
                                .length} ingredient${selectedIngredients
                                .length == 1 ? '' : 's'}',
                            duration: const Duration(seconds: 2),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: dialogContext.theme.colorScheme
                              .onSurface,
                          foregroundColor: dialogContext.theme.colorScheme
                              .surfaceContainerLowest,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: Text('Add ${selectedIngredients
                            .length} Ingredient${selectedIngredients.length == 1
                            ? ''
                            : 's'}'),
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
  final Function(File?) onImageChanged;

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
                    color: context.theme.colorScheme.primary.withOpacity(0.15),
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
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.theme.colorScheme.primaryContainer,
                  foregroundColor: context.theme.colorScheme.onPrimaryContainer,
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
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.theme.colorScheme.secondaryContainer,
                  foregroundColor: context.theme.colorScheme
                      .onSecondaryContainer,
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
                    color: context.theme.colorScheme.primary.withOpacity(0.15),
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
                      color: context.theme.colorScheme.onSurface.withOpacity(
                          0.2),
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
    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('data:image/') || _isBase64String(imageUrl)) {
        try {
          String base64String = imageUrl;
          if (imageUrl.startsWith('data:image/')) {
            base64String = imageUrl.split(',')[1];
          }
          final bytes = base64Decode(base64String);
          return Image.memory(bytes, fit: BoxFit.cover);
        } catch (e) {
          return _buildFallbackImage(context);
        }
      } else {
        return Image.network(imageUrl, fit: BoxFit.cover);
      }
    } else {
      return _buildFallbackImage(context);
    }
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

  Future<void> _pickImage(ImageSource source, Function(File?) callback) async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: source);
    if (photo != null) {
      callback(File(photo.path));
    }
  }
}

// Helper widgets

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

  const RecipeValidatedTextField(this.controller,
      this.label,
      this.context, {
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
      controller.text;
    } catch (e) {
      return Container();
    }

    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(color: context.theme.colorScheme.onSurface),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        labelStyle: TextStyle(
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon,
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7))
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: context.theme.colorScheme.onSurface.withValues(
                  alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: context.theme.colorScheme.onSurface, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: context.theme.colorScheme.onSurface, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: context.theme.colorScheme.onSurface, width: 2),
        ),
        errorText: errorText != null && errorText!.isNotEmpty
            ? errorText
            : null,
        errorStyle: TextStyle(color: context.theme.colorScheme.onSurface),
        filled: true,
        fillColor: context.theme.colorScheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
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

  const RecipeTextField(this.controller,
      this.label,
      this.context, {
        super.key,
        this.maxLines = 1,
        this.keyboardType,
        this.prefixIcon,
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
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon,
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7))
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: context.theme.colorScheme.onSurface.withValues(
                  alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: context.theme.colorScheme.onSurface, width: 2),
        ),
        filled: true,
        fillColor: context.theme.colorScheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
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

class RecipeCuisineDropdown extends StatelessWidget {
  final BuildContext context;
  final String value;
  final void Function(String?) onChanged;

  const RecipeCuisineDropdown(this.context, this.value, this.onChanged,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return SearchableDropdown<String>(
      items: _getCuisineItems(),
      value: value.isNotEmpty ? value : null,
      label: 'Cuisine',
      hint: 'Select cuisine type',
      prefixIcon: Icon(Icons.public_outlined),
      onChanged: onChanged,
    );
  }

  List<DropdownItem> _getCuisineItems() {
    final cuisines = [
      {
        'name': 'Italian',
        'icon': '🇮🇹',
        'desc': 'Pasta, pizza, and Mediterranean flavors'
      },
      {
        'name': 'Chinese',
        'icon': '🇨🇳',
        'desc': 'Stir-fries, dumplings, and traditional dishes'
      },
      {
        'name': 'Mexican',
        'icon': '🇲🇽',
        'desc': 'Spicy, flavorful dishes with beans and rice'
      },
      {
        'name': 'Indian',
        'icon': '🇮🇳',
        'desc': 'Rich spices, curries, and traditional recipes'
      },
      {
        'name': 'Japanese',
        'icon': '🇯🇵',
        'desc': 'Sushi, ramen, and fresh ingredients'
      },
      {
        'name': 'Thai',
        'icon': '🇹🇭',
        'desc': 'Sweet, sour, and spicy balanced flavors'
      },
      {
        'name': 'French',
        'icon': '🇫🇷',
        'desc': 'Classic techniques and refined dishes'
      },
      {
        'name': 'Mediterranean',
        'icon': '🫒',
        'desc': 'Olive oil, herbs, and fresh vegetables'
      },
      {
        'name': 'American',
        'icon': '🇺🇸',
        'desc': 'Comfort food and classic favorites'
      },
      {
        'name': 'Korean',
        'icon': '🇰🇷',
        'desc': 'Fermented foods and bold flavors'
      },
      {
        'name': 'Vietnamese',
        'icon': '🇻🇳',
        'desc': 'Fresh herbs and light, flavorful broths'
      },
      {
        'name': 'Greek',
        'icon': '🇬🇷',
        'desc': 'Fresh seafood, olives, and feta cheese'
      },
      {
        'name': 'Spanish',
        'icon': '🇪🇸',
        'desc': 'Tapas, paella, and olive oil dishes'
      },
      {
        'name': 'Lebanese',
        'icon': '🇱🇧',
        'desc': 'Middle Eastern spices and fresh ingredients'
      },
      {
        'name': 'Turkish',
        'icon': '🇹🇷',
        'desc': 'Ottoman cuisine with rich flavors'
      },
      {
        'name': 'Moroccan',
        'icon': '🇲🇦',
        'desc': 'Tagines and exotic spice blends'
      },
      {
        'name': 'Brazilian',
        'icon': '🇧🇷',
        'desc': 'Tropical fruits and grilled meats'
      },
      {
        'name': 'German',
        'icon': '🇩🇪',
        'desc': 'Hearty dishes and traditional recipes'
      },
      {
        'name': 'British',
        'icon': '🇬🇧',
        'desc': 'Traditional pub food and comfort meals'
      },
      {
        'name': 'Russian',
        'icon': '🇷🇺',
        'desc': 'Hearty soups and warming dishes'
      },
      {
        'name': 'Ethiopian',
        'icon': '🇪🇹',
        'desc': 'Spicy stews and injera bread'
      },
      {
        'name': 'Peruvian',
        'icon': '🇵🇪',
        'desc': 'Fresh ingredients and fusion flavors'
      },
      {
        'name': 'Other',
        'icon': '🌍',
        'desc': 'International and fusion cuisines'
      },
    ];

    return cuisines.map((cuisine) =>
        DropdownItem(
          value: cuisine['name']!,
          label: cuisine['name']!,
          description: cuisine['desc']!,
          icon: cuisine['icon']!,
        )).toList();
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