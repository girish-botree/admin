import 'package:flutter/services.dart';

import '../../../config/app_config.dart';
import '../meal_controller.dart';

class ReceipesView extends GetView<MealController> {
  const ReceipesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MealController());
    
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Recipes', style: TextStyle(color: context.theme.colorScheme.onSurface, fontSize: 20)),
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back_ios, color: context.theme.colorScheme.onSurface),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
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
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
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
          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No recipes found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
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
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
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
    final imageUrl = recipe['imageUrl'];
    
    if (imageUrl != null && imageUrl.toString().isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackImage(context, color),
      );
    } else {
      return _buildFallbackImage(context, color);
    }
  }
  
  Widget _buildFallbackImage(BuildContext context, Color color) {
    return Container(
      color: color.withOpacity(0.7),
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 80,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
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
              recipe['name'] ?? 'Unnamed Recipe',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildChip('${recipe['ingredients']?.length ?? 0} ingredients', Icons.restaurant_menu),
              ],
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
        color: Colors.white.withOpacity(0.2),
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
    if (recipe['dietaryCategory'] == null || recipe['dietaryCategory'] == 0) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getDietaryColor(recipe['dietaryCategory']),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _getDietaryLabel(recipe['dietaryCategory']),
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
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Recipe',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: context.theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildValidatedTextField(
                    controller.nameController,
                    'Recipe Name',
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
                  Row(
                    children: [
                      Expanded(
                        child: _buildValidatedTextField(
                          controller.servingsController,
                          'Servings',
                          context,
                          keyboardType: TextInputType.number,
                          inputFormatters: MealController.getIntegerInputFormatters(),
                          isRequired: true,
                          errorText: controller.servingsError.value,
                          onChanged: controller.validateServings,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(controller.cuisineController, 'Cuisine', context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDietaryDropdown(context, dietaryCategory, (value) => setState(() => dietaryCategory = value ?? 0)),
                  const SizedBox(height: 24),
                  
                  _buildIngredientsSection(context, ingredients, setState),
                  const SizedBox(height: 32),
                  
                  _buildDialogActions(context, () {
                    if (controller.validateRecipeForm()) {
                      final data = controller.createRecipeData(dietaryCategory, ingredients);
                      controller.createRecipe(data).then((success) {
                        if (success) {
                          Get.back();
                          Get.snackbar('Success', 'Recipe created successfully');
                        }
                      });
                    }
                  }),
                ],
              )),
            ),
          ),
        ),
      ),
    );
  }
  
  void _showEditRecipeDialog(BuildContext context, dynamic recipe) {
    controller.setupRecipeForm(recipe);
    int dietaryCategory = recipe['dietaryCategory'] ?? 0;
    final List<dynamic> ingredients = recipe['ingredients'] != null ? List<dynamic>.from(recipe['ingredients']) : [];
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Recipe',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: context.theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildTextField(controller.nameController, 'Recipe Name', context),
                  const SizedBox(height: 16),
                  _buildTextField(controller.descriptionController, 'Description', context, maxLines: 3),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(controller.servingsController, 'Servings', context, keyboardType: TextInputType.number)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(controller.cuisineController, 'Cuisine', context)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDietaryDropdown(context, dietaryCategory, (value) => setState(() => dietaryCategory = value ?? 0)),
                  const SizedBox(height: 24),
                  
                  _buildIngredientsSection(context, ingredients, setState),
                  const SizedBox(height: 32),
                  
                  _buildDialogActions(context, () {
                    if (controller.nameController.text.isEmpty) {
                      Get.snackbar('Error', 'Recipe name is required');
                      return;
                    }
                    
                    final data = controller.createRecipeData(dietaryCategory, ingredients);
                    data['recipeId'] = recipe['recipeId'];
                    data['isActive'] = recipe['isActive'] ?? true;
                    data['createdBy'] = recipe['createdBy'];
                    data['createdOn'] = recipe['createdOn'];
                    
                    controller.updateRecipe(recipe['recipeId'], data).then((success) {
                      if (success) {
                        Get.back();
                        Get.snackbar('Success', 'Recipe updated successfully');
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
    Function(String)? onChanged,
    bool isRequired = false,
  }) {
    return TextField(
      controller: textController,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(color: context.theme.colorScheme.onSurface),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        labelStyle: TextStyle(color: context.theme.colorScheme.onSurface.withOpacity(0.7)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.theme.colorScheme.outline.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.theme.colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
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
    return TextField(
      controller: textController,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: context.theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: context.theme.colorScheme.onSurface.withOpacity(0.7)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.theme.colorScheme.outline.withOpacity(0.5)),
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
  
  Widget _buildDietaryDropdown(BuildContext context, int value, Function(int?) onChanged) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(
        labelText: 'Dietary Category',
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.theme.colorScheme.outline.withOpacity(0.5)),
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
              style: TextStyle(color: context.theme.colorScheme.onSurface.withOpacity(0.7)),
            )
          : Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: context.theme.colorScheme.outline.withOpacity(0.5)),
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
                        child: Text('• ${ingredient['ingredientName'] ?? 'Ingredient'} (${ingredient['quantity']}g)'),
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
          onPressed: () => Get.back(),
          style: TextButton.styleFrom(
            foregroundColor: context.theme.colorScheme.onSurface.withOpacity(0.8),
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
    // Simple ingredient selection dialog
    Get.dialog(
      AlertDialog(
        title: const Text('Add Ingredient'),
        content: const Text('Select ingredients from available list'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Mock ingredient addition
              setState(() {
                ingredients.add({
                  'ingredientId': '1',
                  'ingredientName': 'Sample Ingredient',
                  'quantity': 100,
                });
              });
              Get.back();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, dynamic recipe) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        title: Text('Delete Recipe', style: TextStyle(color: context.theme.colorScheme.onSurface)),
        content: Text(
          'Are you sure you want to delete "${recipe['name']}"?',
          style: TextStyle(color: context.theme.colorScheme.onSurface.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(foregroundColor: context.theme.colorScheme.onSurface.withOpacity(0.8)),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteRecipe(recipe['recipeId']).then((success) {
                if (success) {
                  Get.back();
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
    Get.dialog(
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
                  recipe['name'] ?? 'Unnamed Recipe',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recipe['description'] ?? 'No description',
                  style: TextStyle(
                    fontSize: 16,
                    color: context.theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoChip(context, 'Servings', '${recipe['servings'] ?? 1}', Icons.people),
                    const SizedBox(width: 12),
                    _buildInfoChip(context, 'Cuisine', recipe['cuisine'] ?? 'Unknown', Icons.public),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                ..._buildIngredientsList(recipe),
              ],
            ),
          ),
        ),
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
                  color: context.theme.colorScheme.onSurface.withOpacity(0.7),
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
  
  List<Widget> _buildIngredientsList(dynamic recipe) {
    final ingredients = recipe['ingredients'] as List?;
    if (ingredients == null || ingredients.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text('No ingredients added yet'),
          ),
        )
      ];
    }
    
    return ingredients.map((ingredient) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient['ingredientName'] ?? 'Unknown Ingredient',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${ingredient['quantity'] ?? 0}g',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    )).toList();
  }
}