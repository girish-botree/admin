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

    // State variables for section expansion
    bool isBasicExpanded = false;
    bool isDetailsExpanded = false;
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
                    backgroundColor: dialogContext.theme.colorScheme
                        .surfaceContainer,
                    elevation: 0,
                    leading: IconButton(
                      onPressed: () {
                        isDialogActive = false;
                        Get.back<void>();
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: dialogContext.theme.colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: dialogContext.theme.colorScheme.outline
                                .withValues(
                                alpha: 0.2),
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 22,
                          color: dialogContext.theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: dialogContext.theme.colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.restaurant_menu_rounded,
                            size: 24,
                            color: dialogContext.theme.colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Create New Recipe',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: dialogContext.theme.colorScheme
                                      .onSurface,
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
                                  color: dialogContext.theme.colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.7),
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
                          dialogContext.theme.colorScheme.surfaceContainer,
                          dialogContext.theme.colorScheme.surface,
                        ],
                        stops: const [0.0, 0.3],
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Basic Information Section
                          _buildCollapsibleRecipeSection(
                            context: dialogContext,
                            title: 'Basic Information',
                            subtitle: 'Recipe name and description',
                            icon: Icons.info_outline_rounded,
                            iconColor: dialogContext.theme.colorScheme.primary,
                            isExpanded: isBasicExpanded,
                            isRequired: true,
                            onToggle: () =>
                                setDialogState(() =>
                                isBasicExpanded = !isBasicExpanded),
                            children: [
                              _buildRequiredFieldIndicator(dialogContext),
                              const SizedBox(height: 20),
                              Obx(() =>
                                  RecipeValidatedTextField(
                                    controller.nameController,
                                    'Recipe Name',
                                    dialogContext,
                                    isRequired: true,
                                    errorText: controller.nameError.value,
                                    onChanged: controller.validateName,
                                    prefixIcon: Icons.restaurant_menu,
                                  )),
                              const SizedBox(height: 20),
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
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Recipe Details Section
                          _buildCollapsibleRecipeSection(
                            context: dialogContext,
                            title: 'Recipe Details',
                            subtitle: 'Servings, cuisine, and dietary information',
                            icon: Icons.tune_rounded,
                            iconColor: Colors.green,
                            isExpanded: isDetailsExpanded,
                            onToggle: () =>
                                setDialogState(() =>
                                isDetailsExpanded = !isDetailsExpanded),
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Obx(() =>
                                        RecipeValidatedTextField(
                                          controller.servingsController,
                                          'Servings',
                                          dialogContext,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: MealController
                                              .getIntegerInputFormatters(),
                                          isRequired: true,
                                          errorText: controller.servingsError
                                              .value,
                                          onChanged: controller
                                              .validateServings,
                                          prefixIcon: Icons.people_outline,
                                        )),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Obx(() =>
                                        RecipeCuisineDropdown(
                                          dialogContext,
                                          controller.selectedCuisine.value,
                                              (String? value) {
                                            controller.cuisineController.text =
                                                value ?? '';
                                          },
                                        )),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              RecipeDietaryDropdown(
                                  dialogContext,
                                  dietaryCategory,
                                      (value) =>
                                      setDialogState(() =>
                                      dietaryCategory = value ?? 0)
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Ingredients Section
                          _buildCollapsibleRecipeSection(
                            context: dialogContext,
                            title: 'Ingredients',
                            subtitle: 'Add ingredients to your recipe',
                            icon: Icons.inventory_2_outlined,
                            iconColor: Colors.orange,
                            isExpanded: isIngredientsExpanded,
                            onToggle: () =>
                                setDialogState(() =>
                                isIngredientsExpanded = !isIngredientsExpanded),
                            children: [
                              RecipeIngredientsSection(
                                ingredients: ingredients,
                                controller: controller,
                                onIngredientsChanged: () =>
                                    setDialogState(() {}),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Image Section
                          _buildCollapsibleRecipeSection(
                            context: dialogContext,
                            title: 'Recipe Image',
                            subtitle: 'Add an appealing photo (optional)',
                            icon: Icons.image_outlined,
                            iconColor: Colors.purple,
                            isExpanded: isImageExpanded,
                            onToggle: () =>
                                setDialogState(() =>
                                isImageExpanded = !isImageExpanded),
                            children: [
                              RecipeImageSection(
                                image: image,
                                onImageChanged: (File? newImage) =>
                                    setDialogState(() => image = newImage),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  floatingActionButton: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: FloatingActionButton.extended(
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
                      backgroundColor: dialogContext.theme.colorScheme.primary,
                      foregroundColor: dialogContext.theme.colorScheme
                          .onPrimary,
                      elevation: 6,
                      icon: const Icon(Icons.check_rounded, size: 22),
                      label: const Text(
                        'Save Recipe',
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
        boxShadow: [
          BoxShadow(
            color: isExpanded
                ? iconColor.withValues(alpha: 0.1)
                : context.theme.colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: isExpanded ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
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
                      duration: const Duration(milliseconds: 300),
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
                AnimatedSize(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
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
                      : const SizedBox.shrink(),
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
                        Expanded(child: Obx(() =>
                            RecipeCuisineDropdown(
                          dialogContext,
                          controller.selectedCuisine.value,
                              (String? value) {
                            controller.cuisineController.text = value ?? '';
                          },
                        ))),
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
  final void Function(File?) onImageChanged;

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

  Future<void> _pickImage(ImageSource source, void Function(File?) callback) async {
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
              child: Obx(() =>
                  RecipeCuisineDropdown(
                context,
                controller.selectedCuisine.value,
                    (String? value) {
                  controller.cuisineController.text = value ?? '';
                },
              )),
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
                        '${ingredient['quantity'] ?? 0}${ingredient['unit'] ?? 'g'}',
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
    // Selected ingredients with their quantities and units
    final Map<dynamic, Map<String, dynamic>> selectedIngredients = {};

    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: context.theme.colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: context.theme.colorScheme.shadow.withValues(alpha: 0.12),
                blurRadius: 48,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: StatefulBuilder(
            builder: (dialogContext, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Material 3 Header with Icon and Title
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    decoration: BoxDecoration(
                      color: dialogContext.theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
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
                                color: dialogContext.theme.colorScheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.add_shopping_cart_rounded,
                                color: dialogContext.theme.colorScheme.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Add Ingredients',
                                    style: dialogContext.theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: dialogContext.theme.colorScheme.onSurface,
                                      letterSpacing: 0.25,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Select ingredients and set quantities for your recipe',
                                    style: dialogContext.theme.textTheme.bodyMedium?.copyWith(
                                      color: dialogContext.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                      letterSpacing: 0.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Get.back<void>(),
                              icon: Icon(
                                Icons.close_rounded,
                                color: dialogContext.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: dialogContext.theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                padding: const EdgeInsets.all(8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Content Body
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Header
                          Row(
                            children: [
                              Icon(
                                Icons.inventory_2_rounded,
                                color: dialogContext.theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Available Ingredients',
                                style: dialogContext.theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: dialogContext.theme.colorScheme.onSurface,
                                  letterSpacing: 0.15,
                                ),
                              ),
                              const Spacer(),
                              if (selectedIngredients.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: dialogContext.theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${selectedIngredients.length} selected',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: dialogContext.theme.colorScheme.onPrimaryContainer,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Ingredients List
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: dialogContext.theme.colorScheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: dialogContext.theme.colorScheme.outline.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Obx(() {
                                if (controller.isLoading.value) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          color: dialogContext.theme.colorScheme.primary,
                                          strokeWidth: 3,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Loading ingredients...',
                                          style: TextStyle(
                                            color: dialogContext.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                if (controller.ingredients.isEmpty) {
                                  return Container(
                                    padding: const EdgeInsets.all(40),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: dialogContext.theme.colorScheme.surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Icon(
                                            Icons.inventory_2_outlined,
                                            size: 56,
                                            color: dialogContext.theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          'No ingredients available',
                                          style: dialogContext.theme.textTheme.titleMedium?.copyWith(
                                            color: dialogContext.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Please add ingredients to the system first',
                                          style: dialogContext.theme.textTheme.bodySmall?.copyWith(
                                            color: dialogContext.theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: controller.ingredients.length,
                                  itemBuilder: (context, index) {
                                    final ingredient = controller.ingredients[index];
                                    final isSelected = selectedIngredients.containsKey(ingredient);

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? dialogContext.theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                                            : dialogContext.theme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSelected
                                              ? dialogContext.theme.colorScheme.primary.withValues(alpha: 0.5)
                                              : dialogContext.theme.colorScheme.outline.withValues(alpha: 0.2),
                                          width: isSelected ? 2 : 1,
                                        ),
                                        boxShadow: isSelected ? [
                                          BoxShadow(
                                            color: dialogContext.theme.colorScheme.primary.withValues(alpha: 0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ] : [],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(16),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(16),
                                          onTap: () {
                                            setState(() {
                                              if (isSelected) {
                                                selectedIngredients.remove(ingredient);
                                              } else {
                                                selectedIngredients[ingredient] = {
                                                  'quantity': 100,
                                                  'unit': 'g'
                                                };
                                              }
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Main ingredient info row
                                                Row(
                                                  children: [
                                                    // Custom checkbox with animation
                                                    AnimatedContainer(
                                                      duration: const Duration(milliseconds: 200),
                                                      width: 24,
                                                      height: 24,
                                                      decoration: BoxDecoration(
                                                        color: isSelected 
                                                            ? dialogContext.theme.colorScheme.primary
                                                            : Colors.transparent,
                                                        borderRadius: BorderRadius.circular(6),
                                                        border: Border.all(
                                                          color: isSelected
                                                              ? dialogContext.theme.colorScheme.primary
                                                              : dialogContext.theme.colorScheme.outline,
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: isSelected
                                                          ? Icon(
                                                              Icons.check_rounded,
                                                              size: 16,
                                                              color: dialogContext.theme.colorScheme.onPrimary,
                                                            )
                                                          : null,
                                                    ),
                                                    const SizedBox(width: 16),
                                                    // Ingredient icon
                                                    Container(
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: dialogContext.theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Icon(
                                                        Icons.eco_rounded,
                                                        color: dialogContext.theme.colorScheme.primary,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    // Ingredient details
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            ingredient['name']?.toString() ??
                                                                ingredient['ingredientName']?.toString() ??
                                                                'Unknown Ingredient',
                                                            style: dialogContext.theme.textTheme.titleSmall?.copyWith(
                                                              fontWeight: FontWeight.w600,
                                                              color: dialogContext.theme.colorScheme.onSurface,
                                                              letterSpacing: 0.1,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                Icons.local_fire_department_rounded,
                                                                size: 14,
                                                                color: dialogContext.theme.colorScheme.tertiary,
                                                              ),
                                                              const SizedBox(width: 4),
                                                              Text(
                                                                '${ingredient['calories'] ?? 0} cal/100g',
                                                                style: dialogContext.theme.textTheme.bodySmall?.copyWith(
                                                                  color: dialogContext.theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                
                                                // Quantity controls (expandable when selected)
                                                AnimatedContainer(
                                                  duration: const Duration(milliseconds: 300),
                                                  height: isSelected ? null : 0,
                                                  curve: Curves.easeInOut,
                                                  child: isSelected ? Column(
                                                    children: [
                                                      const SizedBox(height: 20),
                                                      Container(
                                                        padding: const EdgeInsets.all(20),
                                                        decoration: BoxDecoration(
                                                          color: dialogContext.theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                                                          borderRadius: BorderRadius.circular(16),
                                                          border: Border.all(
                                                            color: dialogContext.theme.colorScheme.outline.withValues(alpha: 0.1),
                                                          ),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.tune_rounded,
                                                                  size: 16,
                                                                  color: dialogContext.theme.colorScheme.primary,
                                                                ),
                                                                const SizedBox(width: 8),
                                                                Text(
                                                                  'Set Quantity',
                                                                  style: dialogContext.theme.textTheme.labelLarge?.copyWith(
                                                                    fontWeight: FontWeight.w600,
                                                                    color: dialogContext.theme.colorScheme.onSurface,
                                                                    letterSpacing: 0.1,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(height: 16),
                                                            Row(
                                                              children: [
                                                                // Quantity input field
                                                                Expanded(
                                                                  flex: 2,
                                                                  child: Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 0),
                                                                    decoration: BoxDecoration(
                                                                      color: dialogContext.theme.colorScheme.surface,
                                                                      borderRadius: BorderRadius.circular(25),
                                                                      border: Border.all(
                                                                        color: dialogContext.theme.colorScheme.outline.withValues(alpha: 0.3),
                                                                      ),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: dialogContext.theme.colorScheme.shadow.withValues(alpha: 0.05),
                                                                          blurRadius: 6,
                                                                          offset: const Offset(0, 2),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child: TextFormField(
                                                                      keyboardType: TextInputType.number,
                                                                      textAlign: TextAlign.center,
                                                                      initialValue: selectedIngredients[ingredient]!['quantity'].toString(),
                                                                      style: dialogContext.theme.textTheme.titleMedium?.copyWith(
                                                                        fontWeight: FontWeight.w700,
                                                                        color: dialogContext.theme.colorScheme.onSurface,
                                                                        letterSpacing: 0.5,
                                                                      ),
                                                                      decoration: InputDecoration(
                                                                        border: InputBorder.none,
                                                                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                                                        hintText: '100',
                                                                        hintStyle: dialogContext.theme.textTheme.titleMedium?.copyWith(
                                                                          color: dialogContext.theme.colorScheme.onSurface.withValues(alpha: 0.3),
                                                                          fontWeight: FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                      onChanged: (value) {
                                                                        final quantity = int.tryParse(value) ?? 100;
                                                                        selectedIngredients[ingredient]!['quantity'] = quantity;
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 16),
                                                                // Unit dropdown
                                                                Expanded(
                                                                  flex: 3,
                                                                  child: Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                                                    decoration: BoxDecoration(
                                                                      color: dialogContext.theme.colorScheme.surface,
                                                                      borderRadius: BorderRadius.circular(16),
                                                                      border: Border.all(
                                                                        color: dialogContext.theme.colorScheme.outline.withValues(alpha: 0.3),
                                                                      ),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: dialogContext.theme.colorScheme.shadow.withValues(alpha: 0.05),
                                                                          blurRadius: 6,
                                                                          offset: const Offset(0, 2),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child: DropdownButtonHideUnderline(
                                                                      child: DropdownButton<String>(
                                                                        value: selectedIngredients[ingredient]!['unit'] as String,
                                                                        isExpanded: true,
                                                                        style: dialogContext.theme.textTheme.titleSmall?.copyWith(
                                                                          fontWeight: FontWeight.w600,
                                                                          color: dialogContext.theme.colorScheme.onSurface,
                                                                          letterSpacing: 0.1,
                                                                        ),
                                                                        icon: Container(
                                                                          padding: const EdgeInsets.all(6),
                                                                          decoration: BoxDecoration(
                                                                            color: dialogContext.theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                                                                            borderRadius: BorderRadius.circular(8),
                                                                          ),
                                                                          child: Icon(
                                                                            Icons.expand_more_rounded,
                                                                            color: dialogContext.theme.colorScheme.primary,
                                                                            size: 20,
                                                                          ),
                                                                        ),
                                                                        items: const [
                                                                          DropdownMenuItem(value: 'g', child: Text('g')),
                                                                          DropdownMenuItem(value: 'ml', child: Text('ml')),
                                                                          DropdownMenuItem(value: 'kg', child: Text('kg')),
                                                                          DropdownMenuItem(value: 'l', child: Text('l')),
                                                                          DropdownMenuItem(value: 'cup', child: Text('cup')),
                                                                          DropdownMenuItem(value: 'tbsp', child: Text('tbsp')),
                                                                          DropdownMenuItem(value: 'tsp', child: Text('tsp')),
                                                                          DropdownMenuItem(value: 'oz', child: Text('oz')),
                                                                          DropdownMenuItem(value: 'lb', child: Text('lb')),
                                                                        ],
                                                                        onChanged: (String? newUnit) {
                                                                          if (newUnit != null) {
                                                                            setState(() {
                                                                              selectedIngredients[ingredient]!['unit'] = newUnit;
                                                                            });
                                                                          }
                                                                        },
                                                                        dropdownColor: dialogContext.theme.colorScheme.surface,
                                                                        borderRadius: BorderRadius.circular(16),
                                                                        elevation: 12,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ) : null,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Selected ingredients summary section removed

                  // Bottom action bar
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: dialogContext.theme.colorScheme.surfaceContainerLowest,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Cancel button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back<void>(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: dialogContext.theme.colorScheme.onSurface,
                              side: BorderSide(
                                color: dialogContext.theme.colorScheme.outline.withValues(alpha: 0.5),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: dialogContext.theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Add ingredients button (Material 3 Filled Button)
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed: selectedIngredients.isEmpty ? null : () {
                              // Add selected ingredients to the recipe
                              for (final entry in selectedIngredients.entries) {
                                final ingredient = entry.key;
                                final quantityData = entry.value;

                                // Check if ingredient is already added to avoid duplicates
                                final existingIndex = ingredients.indexWhere((existing) =>
                                (existing['ingredientId']?.toString() ?? '') ==
                                    (ingredient['ingredientId']?.toString() ?? '') ||
                                (existing['name']?.toString() ?? '') ==
                                    (ingredient['name']?.toString() ?? ''));

                                if (existingIndex >= 0) {
                                  // Update existing ingredient quantity and unit
                                  ingredients[existingIndex]['quantity'] = quantityData['quantity'];
                                  ingredients[existingIndex]['unit'] = quantityData['unit'];
                                } else {
                                  // Add new ingredient
                                  ingredients.add({
                                    'ingredientId': ingredient['ingredientId'] ?? ingredient['id'],
                                    'ingredientName': ingredient['name'] ?? ingredient['ingredientName'] ?? 'Unknown Ingredient',
                                    'name': ingredient['name'] ?? ingredient['ingredientName'] ?? 'Unknown Ingredient',
                                    'quantity': quantityData['quantity'],
                                    'unit': quantityData['unit'],
                                  });
                                }
                              }

                              // Force UI update
                              onIngredientsChanged();

                              Get.back<void>();

                              // Show success message
                              Get.snackbar(
                                'Success',
                                'Added ${selectedIngredients.length} ingredient${selectedIngredients.length == 1 ? '' : 's'}',
                                duration: const Duration(seconds: 2),
                                backgroundColor: dialogContext.theme.colorScheme.primaryContainer,
                                colorText: dialogContext.theme.colorScheme.onPrimaryContainer,
                                borderRadius: 12,
                                margin: const EdgeInsets.all(16),
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: selectedIngredients.isEmpty
                                  ? dialogContext.theme.colorScheme.onSurface.withValues(alpha: 0.12)
                                  : dialogContext.theme.colorScheme.primary,
                              foregroundColor: selectedIngredients.isEmpty
                                  ? dialogContext.theme.colorScheme.onSurface.withValues(alpha: 0.38)
                                  : dialogContext.theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: selectedIngredients.isEmpty ? 0 : 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_shopping_cart_rounded,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  selectedIngredients.isEmpty
                                      ? 'Select Ingredients'
                                      : 'Add ${selectedIngredients.length} Ingredient${selectedIngredients.length == 1 ? '' : 's'}',
                                  style: dialogContext.theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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

  Future<void> _pickImage(ImageSource source, void Function(File?) callback) async {
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
      prefixIcon: const Icon(Icons.public_outlined),
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