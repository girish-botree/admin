import 'dart:convert';

import 'package:admin/config/app_config.dart';
import '../meal_controller.dart';
import 'package:flutter/services.dart';

class IngredientsView extends GetView<MealController> {
  const IngredientsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MealController());
    
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: AppText.bold('Ingredients', color: context.theme.colorScheme.onSurface, size: 20),
          leading: IconButton(
            onPressed: () => Get.back(), 
            icon: Icon(Icons.arrow_back_ios, color: context.theme.colorScheme.onSurface)
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (controller.error.value.isNotEmpty) {
            return _buildErrorState(context, controller);
          }
          
          if (controller.ingredients.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return _buildIngredientGrid(context, controller);
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddIngredientDialog(context),
          backgroundColor: context.theme.colorScheme.onSurface,
          foregroundColor: context.theme.colorScheme.surfaceContainerLowest,
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
            onPressed: () => controller.fetchIngredients(),
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
          Icon(Icons.no_food, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No ingredients found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add ingredients to get started',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddIngredientDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Ingredient'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildIngredientGrid(BuildContext context, MealController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth > 1200 ? 5 : 
                              constraints.maxWidth > 900 ? 4 : 
                              constraints.maxWidth > 600 ? 3 : 2;
          
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: controller.ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = controller.ingredients[index];
              return _buildIngredientCard(context, ingredient);
            },
          );
        },
      ),
    );
  }
  
  Widget _buildIngredientCard(BuildContext context, dynamic ingredient) {
    return GestureDetector(
      onTap: () => _showIngredientDetails(context, ingredient),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    child: Text(
                      ingredient['name'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildPopupMenu(context, ingredient),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ingredient['description'] ?? 'No description',
                style: TextStyle(
                  fontSize: 14,
                  color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Divider(height: 10, color: context.theme.colorScheme.outline),
              _buildNutrientChips(context, ingredient),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPopupMenu(BuildContext context, dynamic ingredient) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: context.theme.colorScheme.onSurface),
      padding: EdgeInsets.zero,
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
    );
  }
  
  Widget _buildNutrientChips(BuildContext context, dynamic ingredient) {
    return Column(
      children: [
        Row(
          children: [
            _buildNutrientChip(context, 'Cal', '${ingredient['calories'] ?? 0}', Icons.local_fire_department),
            _buildNutrientChip(context, 'Prot', '${ingredient['protein'] ?? 0}g', Icons.fitness_center),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            _buildNutrientChip(context, 'Carbs', '${ingredient['carbohydrates'] ?? 0}g', Icons.grain),
            _buildNutrientChip(context, 'Fat', '${ingredient['fat'] ?? 0}g', Icons.opacity),
          ],
        ),
      ],
    );
  }
  
  Widget _buildNutrientChip(BuildContext context, String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.primaryContainer.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10, color: context.theme.colorScheme.onPrimaryContainer),
            const SizedBox(width: 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 8,
                      color: context.theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: context.theme.colorScheme.onPrimaryContainer,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Ingredient',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                
                _buildSectionTitle(context, 'Basic Information'),
                const SizedBox(height: 12),
                _buildValidatedTextField(
                  controller.nameController,
                  'Ingredient Name',
                  context,
                  isRequired: true,
                  errorText: controller.nameError.value,
                  onChanged: controller.validateName,
                ),
                const SizedBox(height: 12),
                _buildValidatedTextField(
                  controller.descriptionController,
                  'Description',
                  context,
                  maxLines: 3,
                  errorText: controller.descriptionError.value,
                  onChanged: controller.validateDescription,
                ),
                const SizedBox(height: 12),
                _buildValidatedTextField(
                  controller.categoryController,
                  'Category',
                  context,
                ),
                const SizedBox(height: 24),
                
                _buildSectionTitle(context, 'Nutritional Information'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildValidatedTextField(
                        controller.caloriesController,
                        'Calories',
                        context,
                        keyboardType: TextInputType.number,
                        inputFormatters: MealController.getIntegerInputFormatters(),
                        errorText: controller.caloriesError.value,
                        onChanged: controller.validateCalories,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildValidatedTextField(
                        controller.proteinController,
                        'Protein (g)',
                        context,
                        keyboardType: TextInputType.number,
                        inputFormatters: MealController.getNumberInputFormatters(),
                        errorText: controller.proteinError.value,
                        onChanged: (value) => controller.validateNutrient(value, controller.proteinError, 'Protein'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildValidatedTextField(
                        controller.carbsController,
                        'Carbs (g)',
                        context,
                        keyboardType: TextInputType.number,
                        inputFormatters: MealController.getNumberInputFormatters(),
                        errorText: controller.carbsError.value,
                        onChanged: (value) => controller.validateNutrient(value, controller.carbsError, 'Carbs'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildValidatedTextField(
                        controller.fatController,
                        'Fat (g)',
                        context,
                        keyboardType: TextInputType.number,
                        inputFormatters: MealController.getNumberInputFormatters(),
                        errorText: controller.fatError.value,
                        onChanged: (value) => controller.validateNutrient(value, controller.fatError, 'Fat'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildValidatedTextField(
                        controller.fiberController,
                        'Fiber (g)',
                        context,
                        keyboardType: TextInputType.number,
                        inputFormatters: MealController.getNumberInputFormatters(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildValidatedTextField(
                        controller.sugarController,
                        'Sugar (g)',
                        context,
                        keyboardType: TextInputType.number,
                        inputFormatters: MealController.getNumberInputFormatters(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                _buildSectionTitle(context, 'Fat Breakdown'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildValidatedTextField(
                        controller.saturatedFatController,
                        'Saturated (g)',
                        context,
                        keyboardType: TextInputType.number,
                        inputFormatters: MealController.getNumberInputFormatters(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildValidatedTextField(
                        controller.monoFatController,
                        'Monounsaturated (g)',
                        context,
                        keyboardType: TextInputType.number,
                        inputFormatters: MealController.getNumberInputFormatters(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildValidatedTextField(
                  controller.polyFatController,
                  'Polyunsaturated (g)',
                  context,
                  keyboardType: TextInputType.number,
                  inputFormatters: MealController.getNumberInputFormatters(),
                ),
                const SizedBox(height: 24),
                
                _buildSectionTitle(context, 'Additional Information'),
                const SizedBox(height: 12),
                _buildValidatedTextField(
                  controller.vitaminsController,
                  'Vitamins (JSON format)',
                  context,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                _buildValidatedTextField(
                  controller.mineralsController,
                  'Minerals (JSON format)',
                  context,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                _buildDietaryDropdown(context, dietaryCategory, (value) => dietaryCategory = value ?? 0),
                const SizedBox(height: 32),
                
                _buildDialogActions(context, () {
                  if (controller.validateIngredientForm()) {
                    final data = controller.createIngredientData(dietaryCategory);
                    controller.createIngredient(data).then((success) {
                      if (success) {
                        Get.back();
                        Get.snackbar('Success', 'Ingredient created successfully');
                      }
                    });
                  }
                }),
              ],
            )),
          ),
        ),
      ),
    );
  }
  
  void _showEditIngredientDialog(BuildContext context, dynamic ingredient) {
    controller.setupIngredientForm(ingredient);
    int dietaryCategory = ingredient['dietaryCategory'] ?? 0;
    bool isActive = ingredient['isActive'] ?? true;
    
    Get.dialog(
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
                    
                    controller.updateIngredient(ingredient['ingredientId'], data).then((success) {
                      if (success) {
                        Get.back();
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
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: context.theme.colorScheme.onSurface,
      ),
    );
  }
  
  Widget _buildDietaryDropdown(BuildContext context, int value, Function(int?) onChanged) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(
        labelText: 'Dietary Category',
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
  
  void _showDeleteConfirmation(BuildContext context, dynamic ingredient) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        title: Text('Delete Ingredient', style: TextStyle(color: context.theme.colorScheme.onSurface)),
        content: Text(
          'Are you sure you want to delete "${ingredient['name'] ?? ingredient['ingredientName']}"?',
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
              controller.deleteIngredient(ingredient['ingredientId']).then((success) {
                if (success) {
                  Get.back();
                  Get.snackbar('Success', 'Ingredient deleted successfully');
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
  
  void _showIngredientDetails(BuildContext context, dynamic ingredient) {
    // Implementation for ingredient details dialog
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
                  ingredient['name'] ?? 'Unknown Ingredient',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ingredient['description'] ?? 'No description available',
                  style: TextStyle(
                    fontSize: 16,
                    color: context.theme.colorScheme.onSurface.withOpacity(0.8),
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
                _buildNutrientInfo(context, 'Calories', '${ingredient['calories'] ?? 0}'),
                _buildNutrientInfo(context, 'Protein', '${ingredient['protein'] ?? 0}g'),
                _buildNutrientInfo(context, 'Carbohydrates', '${ingredient['carbohydrates'] ?? 0}g'),
                _buildNutrientInfo(context, 'Fat', '${ingredient['fat'] ?? 0}g'),
                _buildNutrientInfo(context, 'Fiber', '${ingredient['fiber'] ?? 0}g'),
                _buildNutrientInfo(context, 'Sugar', '${ingredient['sugar'] ?? 0}g'),
                const SizedBox(height: 24),
                ...(() {
                  final fatBreakdown = ingredient['fatBreakdown'] != null 
                    ? jsonDecode(ingredient['fatBreakdown']) as Map<String, dynamic>
                    : <String, dynamic>{};
                  return [
                    _buildNutrientInfo(context, 'Saturated Fat', '${fatBreakdown['Saturated'] ?? 0}g'),
                    _buildNutrientInfo(context, 'Monounsaturated Fat', '${fatBreakdown['Monounsaturated'] ?? 0}g'),
                    _buildNutrientInfo(context, 'Polyunsaturated Fat', '${fatBreakdown['Polyunsaturated'] ?? 0}g'),
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
}