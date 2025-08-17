import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import '../../../config/app_config.dart';
import '../../../utils/responsive.dart';
import '../meal_controller.dart';

class ReceipesView extends GetView<MealController> {
  const ReceipesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MealController());
    
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: AppText.semiBold(
              'Recipes', color: context.theme.colorScheme.onSurface,
              size: Responsive.getTitleTextSize(context)),
          leading: IconButton(
            onPressed: () => Get.back<void>(),
            icon: Icon(Icons.arrow_back_ios, color: context.theme.colorScheme.onSurface),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return _buildShimmerLoading(context);
          }
          
          if (controller.error.value.isNotEmpty) {
            return _buildErrorState(context, controller);
          }
          
          if (controller.recipes.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return _buildRecipeGrid(context, controller);
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddRecipeDialog(context),
          backgroundColor: context.theme.colorScheme.onSurface,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
  
  Widget _buildErrorState(BuildContext context, MealController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Error: Data not found, try restarting the app',
            style: TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.fetchRecipes(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No recipes found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add recipes to get started',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddRecipeDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Recipe'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecipeGrid(BuildContext context, MealController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1200 ? 5 : 
                            constraints.maxWidth > 900 ? 4 : 
                            constraints.maxWidth > 600 ? 3 : 2;
        
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.0,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: controller.recipes.length,
          itemBuilder: (context, index) {
            final recipe = controller.recipes[index];
            return _buildRecipeCard(context, recipe);
          },
        );
      },
    );
  }
  
  Widget _buildRecipeCard(BuildContext context, dynamic recipe) {
    return GestureDetector(
      onTap: () => _showRecipeDetails(context, recipe),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: _buildPlaceholderImage(context, recipe)),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            _buildRecipeInfo(context, recipe),
            _buildPopupMenu(context, recipe),
            _buildDietaryBadge(context, recipe),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlaceholderImage(BuildContext context, dynamic recipe) {
    final color = Colors.primaries[recipe['name'].toString().length % Colors.primaries.length];
    final imageUrl = recipe['imageUrl']?.toString();

    if (imageUrl != null && imageUrl.isNotEmpty) {
      // Check if it's base64 data
      if (imageUrl.startsWith('data:image/') || _isBase64String(imageUrl)) {
        try {
          // Handle data URL format (data:image/jpeg;base64,...)
          String base64String = imageUrl;
          if (imageUrl.startsWith('data:image/')) {
            base64String = imageUrl.split(',')[1];
          }

          final bytes = base64Decode(base64String);
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading base64 image: $error');
              return _buildFallbackImage(context, color);
            },
          );
        } catch (e) {
          debugPrint('Error decoding base64 image: $e');
          return _buildFallbackImage(context, color);
        }
      } else {
        // Handle regular network URL
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading network image: $error');
            return _buildFallbackImage(context, color);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: color.withValues(alpha: 0.7),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                ),
              ),
            );
          },
        );
      }
    } else {
      return _buildFallbackImage(context, color);
    }
  }
  
  Widget _buildFallbackImage(BuildContext context, Color color) {
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

  // Helper method to check if a string is base64
  bool _isBase64String(String str) {
    try {
      // Remove any whitespace and check if it's valid base64
      final cleanStr = str.replaceAll(RegExp(r'\s+'), '');
      // Base64 strings should be divisible by 4 in length (with padding)
      if (cleanStr.length % 4 != 0) return false;

      // Try to decode - if it fails, it's not valid base64
      base64Decode(cleanStr);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Widget _buildRecipeInfo(BuildContext context, dynamic recipe) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipe['name']?.toString() ?? 'Unnamed Recipe',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPopupMenu(BuildContext context, dynamic recipe) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditRecipeDialog(context, recipe);
                break;
              case 'delete':
                _showDeleteConfirmation(context, recipe);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDietaryBadge(BuildContext context, dynamic recipe) {
    final dietaryCategory = recipe['dietaryCategory'] as int?;
    if (dietaryCategory == null || dietaryCategory == 0) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getDietaryColor(dietaryCategory),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _getDietaryLabel(dietaryCategory),
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ),
    );
  }
  
  Color _getDietaryColor(int category) {
    switch (category) {
      case 1: return Colors.green;
      case 2: return Colors.lightGreen;
      case 3: return Colors.orange;
      case 4: return Colors.blue;
      case 5: return Colors.purple;
      case 6: return Colors.brown;
      default: return Colors.grey;
    }
  }
  
  String _getDietaryLabel(int category) {
    switch (category) {
      case 1: return 'Vegetarian';
      case 2: return 'Vegan';
      case 3: return 'Gluten-Free';
      case 4: return 'Dairy-Free';
      case 5: return 'Keto';
      case 6: return 'Paleo';
      default: return 'Regular';
    }
  }
  
  void _showAddRecipeDialog(BuildContext context) {
    controller.clearRecipeForm();
    int dietaryCategory = 0;
    final List<dynamic> ingredients = [];
    File? image;
    bool isDialogActive = true;
    
    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (dialogContext, setState) {
              if (!isDialogActive) return Container(); // Safety check

              return SingleChildScrollView(
                child: Obx(() =>
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Recipe',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: dialogContext.theme.colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 24),

                    _buildValidatedTextField(
                      controller.nameController,
                      'Recipe Name',
                      dialogContext,
                      isRequired: true,
                      errorText: controller.nameError.value,
                      onChanged: controller.validateName,
                    ),
                    const SizedBox(height: 16),
                    _buildValidatedTextField(
                      controller.descriptionController,
                      'Description',
                      dialogContext,
                      maxLines: 3,
                      errorText: controller.descriptionError.value,
                      onChanged: controller.validateDescription,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildValidatedTextField(
                            controller.servingsController,
                            'Servings',
                            dialogContext,
                            keyboardType: TextInputType.number,
                            inputFormatters: MealController
                                .getIntegerInputFormatters(),
                            isRequired: true,
                            errorText: controller.servingsError.value,
                            onChanged: controller.validateServings,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                              controller.cuisineController, 'Cuisine',
                              dialogContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildDietaryDropdown(
                        dialogContext, dietaryCategory, (value) =>
                        setState(() => dietaryCategory = value ?? 0)),
                    const SizedBox(height: 24),

                    _buildIngredientsSection(
                        dialogContext, ingredients, setState),
                    const SizedBox(height: 24),

                        Text(
                          'Recipe Image (Optional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: dialogContext.theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select an image from your gallery or take a photo',
                          style: TextStyle(
                            fontSize: 12,
                            color: dialogContext.theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final XFile? photo = await picker.pickImage(
                                      source: ImageSource.gallery);
                                  if (photo != null) {
                                    setState(() => image = File(photo.path));
                                  }
                                },
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Gallery'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: dialogContext.theme
                                      .colorScheme
                                      .primaryContainer,
                                  foregroundColor: dialogContext.theme
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final XFile? photo = await picker.pickImage(
                                      source: ImageSource.camera);
                                  if (photo != null) {
                                    setState(() => image = File(photo.path));
                                  }
                                },
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Camera'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: dialogContext.theme
                                      .colorScheme
                                      .secondaryContainer,
                                  foregroundColor: dialogContext.theme
                                      .colorScheme
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
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Text(
                                    'Image Preview:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: dialogContext.theme.colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () =>
                                        setState(() => image = null),
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
                                    color: dialogContext.theme.colorScheme
                                        .primary.withOpacity(0.15),
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
                                      color: dialogContext.theme.colorScheme
                                          .onSurface.withOpacity(0.2),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 32),

                    _buildDialogActions(dialogContext, () async {
                      if (controller.validateRecipeForm()) {
                        final data = controller.createRecipeData(
                            dietaryCategory, ingredients);
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
                        controller.createRecipe(data).then((success) {
                          if (success) {
                            isDialogActive = false;
                            Get.back<void>();
                            Get.snackbar(
                                'Success', 'Recipe created successfully');
                          }
                        });
                      }
                    }),
                  ],
                )),
              );
            },
          ),
        ),
      ),
    ).whenComplete(() {
      isDialogActive = false;
    });
  }
  
  void _showEditRecipeDialog(BuildContext context, dynamic recipe) {
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

                    _buildTextField(controller.nameController, 'Recipe Name',
                        dialogContext),
                    const SizedBox(height: 16),
                    _buildTextField(
                        controller.descriptionController, 'Description',
                        dialogContext, maxLines: 3),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(
                            controller.servingsController, 'Servings',
                            dialogContext, keyboardType: TextInputType.number)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField(
                            controller.cuisineController, 'Cuisine',
                            dialogContext)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildDietaryDropdown(
                        dialogContext, dietaryCategory, (value) =>
                        setState(() => dietaryCategory = value ?? 0)),
                    const SizedBox(height: 24),

                    _buildIngredientsSection(
                        dialogContext, ingredients, setState),
                    const SizedBox(height: 24),

                    Text(
                      'Recipe Image (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: dialogContext.theme.colorScheme.onSurface,
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
                              color: dialogContext.theme.colorScheme.onSurface,
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
                                color: dialogContext.theme.colorScheme.primary
                                    .withOpacity(0.15),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildPlaceholderImage(
                                  dialogContext, recipe),
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
                        color: dialogContext.theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final XFile? photo = await picker.pickImage(
                                  source: ImageSource.gallery);
                              if (photo != null) {
                                setState(() => image = File(photo.path));
                              }
                            },
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Gallery'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.theme.colorScheme
                                  .primaryContainer,
                              foregroundColor: context.theme.colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final XFile? photo = await picker.pickImage(
                                  source: ImageSource.camera);
                              if (photo != null) {
                                setState(() => image = File(photo.path));
                              }
                            },
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Camera'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.theme.colorScheme
                                  .secondaryContainer,
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
                                onPressed: () => setState(() => image = null),
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
                                color: context.theme.colorScheme.primary
                                    .withOpacity(0.15),
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
                                  color: context.theme.colorScheme.onSurface
                                      .withOpacity(0.2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 32),

                    _buildDialogActions(dialogContext, () async {
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
    // Check if controller is disposed to prevent errors
    try {
      // Try to access the text property - this will throw if disposed
      textController.text;
    } catch (e) {
      // Controller is disposed, return empty container
      return Container();
    }

    return TextField(
      controller: textController,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(color: context.theme.colorScheme.onSurface),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        labelStyle: TextStyle(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.theme.colorScheme.outline.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.theme.colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        errorText: errorText != null && errorText.isNotEmpty ? errorText : null,
        filled: true,
        fillColor: context.theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    // Check if controller is disposed to prevent errors
    try {
      // Try to access the text property - this will throw if disposed
      textController.text;
    } catch (e) {
      // Controller is disposed, return empty container
      return Container();
    }

    return TextField(
      controller: textController,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: context.theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.theme.colorScheme.outline.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.theme.colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: context.theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
  
  Widget _buildDietaryDropdown(BuildContext context, int value, void Function(int?) onChanged) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(
        labelText: 'Dietary Category',
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.theme.colorScheme.outline.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.theme.colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: context.theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: TextStyle(color: context.theme.colorScheme.onSurface),
      dropdownColor: context.theme.colorScheme.surface,
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
  
  Widget _buildIngredientsSection(BuildContext context, List<dynamic> ingredients, StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredients (${ingredients.length})',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        ingredients.isEmpty
          ? Text(
              'No ingredients added yet',
              style: TextStyle(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            )
          : Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: context.theme.colorScheme.outline.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ingredients.map<Widget>((ingredient) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('• ${ingredient['ingredientName'] ??
                            ingredient['name'] ??
                            'Ingredient'} (${ingredient['quantity']}g)'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                        onPressed: () => setState(() => ingredients.remove(ingredient)),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => _showAddIngredientDialog(context, ingredients, setState),
          icon: const Icon(Icons.add),
          label: const Text('Add Ingredient'),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.theme.colorScheme.primaryContainer,
            foregroundColor: context.theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDialogActions(BuildContext context, VoidCallback onSave) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Get.back<void>(),
          style: TextButton.styleFrom(
            foregroundColor: context.theme.colorScheme.onSurface.withValues(alpha: 0.8),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
  
  void _showAddIngredientDialog(BuildContext context, List<dynamic> ingredients, StateSetter setState) {
    dynamic selectedIngredient;
    bool isDialogActive = true;

    // Ensure ingredients are loaded before showing dialog
    if (controller.ingredients.isEmpty) {
      controller.fetchIngredients();
    }

    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        child: Container(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.6,
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              if (!isDialogActive) return Container();

              // Create controller inside StatefulBuilder to avoid disposal issues
              final quantityController = TextEditingController();

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Ingredient',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: dialogContext.theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Ingredient Selection
                    Text(
                      'Select Ingredient',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: dialogContext.theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: dialogContext.theme
                            .colorScheme
                            .outline.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Obx(() {
                        // Debug print to see what's in ingredients
                        debugPrint(
                            'Ingredients in dialog: ${controller.ingredients
                                .length}');
                        for (var ingredient in controller.ingredients) {
                          debugPrint('Ingredient: ${ingredient}');
                        }


                        if (controller.ingredients.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined,
                                    size: 48,
                                    color: dialogContext.theme.colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5)
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No ingredients available',
                                  style: TextStyle(
                                    color: dialogContext.theme.colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    debugPrint('Refreshing ingredients...');
                                    controller.fetchIngredients();
                                  },
                                  child: const Text('Refresh'),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: controller.ingredients.length,
                          itemBuilder: (context, index) {
                            final ingredient = controller.ingredients[index];
                            final isSelected = selectedIngredient ==
                                ingredient;

                            return ListTile(
                              title: Text(
                                ingredient['name']?.toString() ??
                                    ingredient['ingredientName']
                                        ?.toString() ?? 'Unknown',
                                style: TextStyle(
                                  color: dialogContext.theme.colorScheme
                                      .onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                ingredient['description']?.toString() ??
                                    'No description',
                                style: TextStyle(
                                  color: dialogContext.theme.colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? dialogContext.theme.colorScheme.primary
                                      : dialogContext.theme.colorScheme
                                      .primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.eco,
                                  size: 16,
                                  color: isSelected
                                      ? Colors.white
                                      : dialogContext.theme.colorScheme
                                      .onPrimaryContainer,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(Icons.check_circle,
                                  color: dialogContext.theme.colorScheme
                                      .primary)
                                  : null,
                              selected: isSelected,
                              selectedTileColor: dialogContext.theme.colorScheme
                                  .primaryContainer.withValues(alpha: 0.2),
                              onTap: () {
                                if (isDialogActive) {
                                  setDialogState(() {
                                    selectedIngredient = ingredient;
                                  });
                                }
                              },
                            );
                          },
                        );
                      }),
                    ),

                    const SizedBox(height: 16),

                    // Quantity Input
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: MealController
                          .getIntegerInputFormatters(),
                      style: TextStyle(
                          color: dialogContext.theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Quantity (grams) *',
                        labelStyle: TextStyle(
                            color: dialogContext.theme.colorScheme.onSurface
                                .withValues(alpha: 0.7)
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: dialogContext.theme.colorScheme.outline
                                  .withValues(alpha: 0.5)
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: dialogContext.theme.colorScheme.primary,
                              width: 2
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: dialogContext.theme.colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Dialog Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            isDialogActive = false;
                            Get.back<void>();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: dialogContext.theme.colorScheme
                                .onSurface.withValues(alpha: 0.8),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (!isDialogActive) return;

                            if (selectedIngredient == null) {
                              Get.snackbar(
                                  'Error', 'Please select an ingredient');
                              return;
                            }

                            final quantityText = quantityController.text;
                            if (quantityText.isEmpty) {
                              Get.snackbar('Error', 'Please enter quantity');
                              return;
                            }

                            final quantity = int.tryParse(quantityText);
                            if (quantity == null || quantity <= 0) {
                              Get.snackbar(
                                  'Error', 'Please enter a valid quantity');
                              return;
                            }

                            // Check if ingredient already exists
                            final exists = ingredients.any((ing) =>
                            ing['ingredientId'] ==
                                selectedIngredient['ingredientId']);

                            if (exists) {
                              Get.snackbar('Error',
                                  'This ingredient is already added');
                              return;
                            }

                            setState(() {
                              ingredients.add({
                                'ingredientId': selectedIngredient['ingredientId'],
                                'ingredientName': selectedIngredient['name']
                                    ?.toString() ?? 'Unknown Ingredient',
                                'quantity': quantity,
                              });
                            });

                            isDialogActive = false;
                            Get.back<void>();
                            Get.snackbar('Success',
                                'Ingredient added successfully');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: dialogContext.theme.colorScheme
                                .onSurface,
                            foregroundColor: dialogContext.theme.colorScheme
                                .surfaceContainerLowest,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Add Ingredient'),
                        ),
                      ],
                    ),
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
  
  void _showDeleteConfirmation(BuildContext context, dynamic recipe) {
    Get.dialog<void>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        title: Text('Delete Recipe', style: TextStyle(color: context.theme.colorScheme.onSurface)),
        content: Text(
          'Are you sure you want to delete "${recipe['name']?.toString() ??
              'this recipe'}"?',
          style: TextStyle(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            style: TextButton.styleFrom(foregroundColor: context.theme.colorScheme.onSurface.withValues(alpha: 0.8)),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller
                  .deleteRecipe(recipe['recipeId']?.toString() ?? '')
                  .then((success) {
                if (success) {
                  Get.back<void>();
                  Get.snackbar('Success', 'Recipe deleted successfully');
                }
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  void _showRecipeDetails(BuildContext context, dynamic recipe) {
    // Observables
    final RxList<dynamic> recipeIngredients = <dynamic>[].obs;
    final RxString ingredientsError = ''.obs;
    final RxBool isLoadingIngredients = true.obs;
    final Rx<Map<String, dynamic>?> nutritionData = Rx<Map<String, dynamic>?>(
        null);
    final RxBool isIngredientsExpanded = false.obs;
    final RxBool isNutritionExpanded = false.obs;

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
                Container(
                  height: 250,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildPlaceholderImage(context, recipe),
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
                                        _getDietaryLabel(
                                            recipe['dietaryCategory'] as int),
                                        color: _getDietaryColor(
                                            recipe['dietaryCategory'] as int),
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
                        child: _buildFloatingActionButton(
                          context,
                          icon: Icons.close,
                          onPressed: () => Get.back<void>(),
                        ),
                      ),
                    ],
                  ),
                ),

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
                          _buildSectionHeader(context, 'Description', Icons
                              .description),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.theme.colorScheme
                                  .surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: context.theme.colorScheme.outline
                                    .withValues(alpha: 0.2),
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
                          const SizedBox(height: 24),
                        ],

                        _buildSectionHeader(
                          context,
                          'Ingredients${recipeIngredients.isNotEmpty
                              ? ' (${recipeIngredients.length})'
                              : ''}',
                          Icons.restaurant_menu,
                          trailing: Obx(() =>
                              IconButton(
                                onPressed: () => isIngredientsExpanded.toggle(),
                                icon: AnimatedRotation(
                                  turns: isIngredientsExpanded.value
                                      ? 0.5
                                      : 0.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: context.theme.colorScheme.primary,
                                  ),
                                ),
                              )),
                        ),
                        const SizedBox(height: 12),
                        Obx(() =>
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                              child: isIngredientsExpanded.value
                                  ? _buildIngredientsContent(
                                  context, recipeIngredients, ingredientsError,
                                  isLoadingIngredients, fetchRecipeIngredients)
                                  : _buildIngredientsPreview(
                                  context, recipeIngredients, ingredientsError,
                                  isLoadingIngredients),
                            )),
                        const SizedBox(height: 24),

                        Obx(() {
                          final nutrition = nutritionData.value;
                          if (nutrition == null) return const SizedBox.shrink();

                          final hasNutritionData = (nutrition['calories'] as num? ??
                              0) > 0 ||
                              (nutrition['protein'] as num? ?? 0) > 0 ||
                              (nutrition['carbohydrates'] as num? ?? 0) > 0 ||
                              (nutrition['fat'] as num? ?? 0) > 0;

                          if (!hasNutritionData) {
                            return _buildNutritionPlaceholder(context);
                          }

                          return Column(
                            children: [
                              _buildSectionHeader(
                                context,
                                'Nutrition (Per Serving)',
                                Icons.analytics,
                                trailing: IconButton(
                                  onPressed: () => isNutritionExpanded.toggle(),
                                  icon: Obx(() =>
                                      AnimatedRotation(
                                        turns: isNutritionExpanded.value
                                            ? 0.5
                                            : 0.0,
                                        duration: const Duration(
                                            milliseconds: 300),
                                        child: Icon(
                                          Icons.keyboard_arrow_down,
                                          color: context.theme.colorScheme
                                              .primary,
                                        ),
                                      )),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Obx(() =>
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                    child: isNutritionExpanded.value
                                        ? _buildExpandedNutritionContent(
                                        context, nutrition)
                                        : _buildNutritionPreview(
                                        context, nutrition),
                                  )),
                            ],
                          );
                        }),
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

  Widget _buildFloatingActionButton(BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: color ?? Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon,
      {Widget? trailing}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildIngredientsPreview(BuildContext context,
      RxList<dynamic> ingredients, RxString error, RxBool isLoading) {
    return Obx(() {
      if (isLoading.value) {
        return _buildLoadingCard(context, 'Loading ingredients...');
      }

      if (error.value.isNotEmpty) {
        return _buildErrorCard(context, error.value, () {});
      }

      if (ingredients.isEmpty) {
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
              ingredients.take(3).map((ing) =>
              ing['name']?.toString() ?? 'Unknown').join(', ') +
                  (ingredients.length > 3 ? ', and ${ingredients.length -
                      3} more...' : ''),
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

  Widget _buildIngredientsContent(BuildContext context,
      RxList<dynamic> ingredients, RxString error, RxBool isLoading,
      VoidCallback retry) {
    return Obx(() {
      if (isLoading.value) {
        return _buildLoadingCard(context, 'Loading detailed ingredients...');
      }

      if (error.value.isNotEmpty) {
        return _buildErrorCard(context, error.value, retry);
      }

      if (ingredients.isEmpty) {
        return _buildEmptyCard(
            context, 'No ingredients added to this recipe yet',
            Icons.restaurant_menu_outlined);
      }

      return Column(
        children: ingredients.map((ingredient) =>
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
                        '${ingredient['quantity'] ?? 0}g',
                        style: TextStyle(
                          color: context.theme.colorScheme.onSecondaryContainer,
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
    return Column(
      children: [
        // Macronutrients with progress bars
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.5),
                context.theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Macronutrients',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _buildNutritionBar(
                  context,
                  'Calories',
                  nutrition['calories'] != null
                      ? (nutrition['calories'] is num
                      ? (nutrition['calories'] as num).toDouble()
                      : double.tryParse(nutrition['calories'].toString()) ?? 0)
                      : 0,
                  2000,
                  'kcal',
                  Colors.orange),
              _buildNutritionBar(
                  context,
                  'Protein',
                  nutrition['protein'] != null
                      ? (nutrition['protein'] is num
                      ? (nutrition['protein'] as num).toDouble()
                      : double.tryParse(nutrition['protein'].toString()) ?? 0)
                      : 0,
                  50,
                  'g',
                  Colors.red),
              _buildNutritionBar(
                  context,
                  'Carbohydrates',
                  nutrition['carbohydrates'] != null
                      ? (nutrition['carbohydrates'] is num
                      ? (nutrition['carbohydrates'] as num).toDouble()
                      : double.tryParse(
                      nutrition['carbohydrates'].toString()) ?? 0)
                      : 0,
                  300,
                  'g',
                  Colors.blue),
              _buildNutritionBar(
                  context,
                  'Fat',
                  nutrition['fat'] != null
                      ? (nutrition['fat'] is num ? (nutrition['fat'] as num)
                      .toDouble() : double.tryParse(
                      nutrition['fat'].toString()) ?? 0)
                      : 0,
                  65,
                  'g',
                  Colors.green),
              _buildNutritionBar(
                  context,
                  'Fiber',
                  nutrition['fiber'] != null
                      ? (nutrition['fiber'] is num ? (nutrition['fiber'] as num)
                      .toDouble() : double.tryParse(
                      nutrition['fiber'].toString()) ?? 0)
                      : 0,
                  25,
                  'g',
                  Colors.brown),
              _buildNutritionBar(
                  context,
                  'Sugar',
                  nutrition['sugar'] != null
                      ? (nutrition['sugar'] is num ? (nutrition['sugar'] as num)
                      .toDouble() : double.tryParse(
                      nutrition['sugar'].toString()) ?? 0)
                      : 0,
                  50,
                  'g',
                  Colors.pink),
            ],
          ),
        ),

        if (nutrition['vitamins'] != null) ...[
          const SizedBox(height: 16),
          _buildVitaminsSection(
              context, nutrition['vitamins'] as Map<String, dynamic>),
        ],

        if (nutrition['minerals'] != null) ...[
          const SizedBox(height: 16),
          _buildMineralsSection(
              context, nutrition['minerals'] as Map<String, dynamic>),
        ],
      ],
    );
  }

  Widget _buildNutritionBar(BuildContext context, String label, double value,
      double maxValue, String unit, Color color) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}$unit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitaminsSection(BuildContext context,
      Map<String, dynamic> vitamins) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
            context.theme.colorScheme.secondaryContainer.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💊 Essential Vitamins',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: vitamins.entries
                .where((entry) =>
            entry.value != null && (entry.value as num) > 0)
                .take(8)
                .map((entry) =>
                _buildVitaminChip(
                  context,
                  'Vitamin ${entry.key}',
                  '${entry.value.toStringAsFixed(1)}${_getVitaminUnit(
                      entry.key)}',
                ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMineralsSection(BuildContext context,
      Map<String, dynamic> minerals) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
            context.theme.colorScheme.tertiaryContainer.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚡ Key Minerals',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: (minerals.entries)
                .where((entry) =>
            entry.value != null && (entry.value is num) &&
                (entry.value as num) > 0)
                .take(8)
                .map((entry) =>
                _buildMineralChip(
                  context,
                  entry.key,
                  '${(entry.value as num).toStringAsFixed(1)}mg',
                ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVitaminChip(BuildContext context, String name, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMineralChip(BuildContext context, String name, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
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
          Text(
            'Add ingredients to this recipe to unlock detailed nutrition analysis',
            style: TextStyle(
              fontSize: 14,
              color: Colors.amber[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  
  Widget _buildInfoChip(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: context.theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
        ],
      ),
    );
  }

  Widget _buildNutritionItem(BuildContext context, String label, String value,
      String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: context.theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
                TextSpan(
                  text: unit,
                  style: TextStyle(
                    fontSize: 10,
                    color: context.theme.colorScheme.onSurface.withValues(
                        alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getVitaminUnit(String vitamin) {
    switch (vitamin.toUpperCase()) {
      case 'A':
        return 'μg';
      case 'C':
        return 'mg';
      case 'E':
        return 'mg';
      case 'K':
        return 'μg';
      case 'B1':
      case 'B3':
      case 'B6':
        return 'mg';
      case 'B12':
        return 'μg';
      case 'FOLATE':
        return 'μg';
      default:
        return 'mg';
    }
  }


  Widget _buildShimmerLoading(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1200 ? 5 :
        constraints.maxWidth > 900 ? 4 :
        constraints.maxWidth > 600 ? 3 : 2;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.0,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            return _buildShimmerRecipeCard(context);
          },
        );
      },
    );
  }

  Widget _buildShimmerRecipeCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: _buildShimmerContainer(
                double.infinity, double.infinity, borderRadius: 16),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerContainer(120, 16, borderRadius: 8),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildShimmerContainer(80, 12, borderRadius: 6),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: _buildShimmerContainer(24, 24, borderRadius: 12),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: _buildShimmerContainer(60, 20, borderRadius: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerContainer(double width, double height,
      {double borderRadius = 4}) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 1200),
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: const LinearGradient(
              begin: Alignment(-1.0, -0.3),
              end: Alignment(1.0, 0.3),
              colors: [
                Color(0xFFF0F0F0),
                Color(0xFFE0E0E0),
                Color(0xFFF0F0F0),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

}