import 'package:admin/config/app_config.dart';
import 'package:admin/network_service/dio_network_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

class MealController extends GetxController {
  // Recipe state
  final recipes = <dynamic>[].obs;
  final filteredRecipes = <dynamic>[].obs;
  final selectedRecipe = Rxn<dynamic>();
  
  // Ingredient state
  final ingredients = <dynamic>[].obs;
  final filteredIngredients = <dynamic>[].obs;
  final selectedIngredient = Rxn<dynamic>();

  // Search state
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  // Sort state
  final recipeSortBy = 'name'.obs; // name, servings, calories
  final ingredientSortBy = 'name'.obs; // name, calories, protein, carbs
  final sortAscending = true.obs;

  // Filter state
  final selectedRecipeCuisine = 'All'.obs;
  final selectedIngredientCategory = 'All'.obs;
  final calorieRange = const RangeValues(0, 1000).obs;
  final proteinRange = const RangeValues(0, 100).obs;

  // Filter visibility
  final showFilters = false.obs;

  // Shared state
  final isLoading = false.obs;
  final error = ''.obs;
  
  // Validation state
  final nameError = RxString('');
  final descriptionError = RxString('');
  final servingsError = RxString('');
  final caloriesError = RxString('');
  final proteinError = RxString('');
  final carbsError = RxString('');
  final fatError = RxString('');
  final quantityError = RxString('');
  
  // Form controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final servingsController = TextEditingController();
  final cuisineController = TextEditingController();
  final categoryController = TextEditingController();
  final caloriesController = TextEditingController();
  final proteinController = TextEditingController();
  final carbsController = TextEditingController();
  final fatController = TextEditingController();
  final fiberController = TextEditingController();
  final sugarController = TextEditingController();
  final quantityController = TextEditingController();
  final vitaminsController = TextEditingController();
  final mineralsController = TextEditingController();
  final saturatedFatController = TextEditingController();
  final monoFatController = TextEditingController();
  final polyFatController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    fetchRecipes();
    fetchIngredients();

    // Listen to search query changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    // Setup reactive listeners
    ever(searchQuery, (_) {
      updateFilteredRecipes();
      updateFilteredIngredients();
    });

    ever(recipeSortBy, (_) => updateFilteredRecipes());
    ever(ingredientSortBy, (_) => updateFilteredIngredients());
    ever(sortAscending, (_) {
      updateFilteredRecipes();
      updateFilteredIngredients();
    });

    ever(selectedRecipeCuisine, (_) => updateFilteredRecipes());
    ever(selectedIngredientCategory, (_) => updateFilteredIngredients());
    ever(calorieRange, (_) {
      updateFilteredRecipes();
      updateFilteredIngredients();
    });
    ever(proteinRange, (_) => updateFilteredIngredients());
  }

  // Recipe methods
  Future<void> fetchRecipes() async {
    isLoading.value = true;
    error.value = '';
    
    try {
      final response = await DioNetworkService.getRecipes();
      if (response is Map<String, dynamic> && response['data'] != null) {
        recipes.value = (response['data'] as List<dynamic>? ?? []).cast<dynamic>();
        updateFilteredRecipes();
      } else {
        recipes.value = [];
        filteredRecipes.value = [];
      }
    } catch (e) {
      error.value = e.toString();
      debugPrint('Error fetching recipes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<dynamic>> fetchRecipeIngredients(String recipeId) async {
    try {
      // Find the recipe by ID
      final recipe = recipes.firstWhere(
            (recipe) => recipe['recipeId']?.toString() == recipeId,
        orElse: () => null,
      );

      if (recipe != null && recipe['ingredients'] != null) {
        return List<dynamic>.from(recipe['ingredients'] as List);
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching recipe ingredients: $e');
      throw Exception('Failed to fetch recipe ingredients: $e');
    }
  }

  Future<dynamic> getRecipeById(String recipeId) async {
    try {
      final response = await DioNetworkService.getRecipeById(recipeId);
      return response;
    } catch (e) {
      debugPrint('Error fetching recipe by ID: $e');
      throw Exception('Failed to fetch recipe: $e');
    }
  }

  Future<bool> createRecipe(Map<String, dynamic> data) async {
    isLoading.value = true;
    error.value = '';
    
    try {
      await DioNetworkService.createRecipe(data);
      await fetchRecipes();
      return true;
    } catch (e) {
      error.value = e.toString();
      debugPrint('Error creating recipe: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> updateRecipe(String id, Map<String, dynamic> data) async {
    isLoading.value = true;
    error.value = '';
    
    try {
      await DioNetworkService.updateRecipe(id, data);
      await fetchRecipes();
      return true;
    } catch (e) {
      error.value = e.toString();
      debugPrint('Error updating recipe: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> deleteRecipe(String id) async {
    isLoading.value = true;
    error.value = '';
    
    try {
      await DioNetworkService.deleteRecipe(id);
      await fetchRecipes();
      return true;
    } catch (e) {
      error.value = e.toString();
      debugPrint('Error deleting recipe: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Ingredient methods
  Future<void> fetchIngredients() async {
    isLoading.value = true;
    error.value = '';
    
    try {
      final response = await DioNetworkService.getIngredients();
      if (response is Map<String, dynamic> && response['data'] != null) {
        ingredients.value = (response['data'] as List<dynamic>? ?? []).cast<dynamic>();
        updateFilteredIngredients();
      } else {
        ingredients.value = [];
        filteredIngredients.value = [];
      }
    } catch (e) {
      error.value = e.toString();
      debugPrint('Error fetching ingredients: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> createIngredient(Map<String, dynamic> data) async {
    isLoading.value = true;
    error.value = '';
    
    try {
      await DioNetworkService.createIngredient(data);
      await fetchIngredients();
      return true;
    } catch (e) {
      error.value = e.toString();
      debugPrint('Error creating ingredient: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> updateIngredient(String id, Map<String, dynamic> data) async {
    isLoading.value = true;
    error.value = '';
    
    try {
      await DioNetworkService.updateIngredient(id, data);
      await fetchIngredients();
      return true;
    } catch (e) {
      error.value = e.toString();
      debugPrint('Error updating ingredient: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> deleteIngredient(String id) async {
    isLoading.value = true;
    error.value = '';
    
    try {
      await DioNetworkService.deleteIngredient(id);
      await fetchIngredients();
      return true;
    } catch (e) {
      error.value = e.toString();
      debugPrint('Error deleting ingredient: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Validation methods
  bool validateName(String value) {
    if (value.isEmpty) {
      nameError.value = 'Name is required';
      return false;
    } else if (value.length < 2) {
      nameError.value = 'Name must be at least 2 characters';
      return false;
    }
    nameError.value = '';
    return true;
  }
  
  bool validateDescription(String value) {
    if (value.isEmpty) {
      descriptionError.value = 'Description is required';
      return false;
    }
    descriptionError.value = '';
    return true;
  }
  
  bool validateServings(String value) {
    if (value.isEmpty) {
      servingsError.value = 'Servings is required';
      return false;
    }
    try {
      final servings = int.parse(value);
      if (servings <= 0) {
        servingsError.value = 'Servings must be greater than 0';
        return false;
      }
    } catch (e) {
      servingsError.value = 'Please enter a valid number';
      return false;
    }
    servingsError.value = '';
    return true;
  }
  
  bool validateCalories(String value) {
    if (value.isEmpty) {
      caloriesError.value = '';
      return true; // Optional field
    }
    try {
      final calories = int.parse(value);
      if (calories < 0) {
        caloriesError.value = 'Calories cannot be negative';
        return false;
      }
    } catch (e) {
      caloriesError.value = 'Please enter a valid number';
      return false;
    }
    caloriesError.value = '';
    return true;
  }
  
  bool validateNutrient(String value, RxString errorState, String fieldName) {
    if (value.isEmpty) {
      errorState.value = '';
      return true; // Optional field
    }
    try {
      final nutrient = double.parse(value);
      if (nutrient < 0) {
        errorState.value = '$fieldName cannot be negative';
        return false;
      }
    } catch (e) {
      errorState.value = 'Please enter a valid number';
      return false;
    }
    errorState.value = '';
    return true;
  }
  
  bool validateQuantity(String value) {
    if (value.isEmpty) {
      quantityError.value = '';
      return true; // Optional field
    }
    try {
      final quantity = int.parse(value);
      if (quantity <= 0) {
        quantityError.value = 'Quantity must be greater than 0';
        return false;
      }
    } catch (e) {
      quantityError.value = 'Please enter a valid number';
      return false;
    }
    quantityError.value = '';
    return true;
  }
  
  bool validateJsonFormat(String value) {
    if (value.isEmpty) {
      return true; // Optional field
    }
    try {
      jsonDecode(value);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Form handling methods
  void resetFormErrors() {
    nameError.value = '';
    descriptionError.value = '';
    servingsError.value = '';
    caloriesError.value = '';
    proteinError.value = '';
    carbsError.value = '';
    fatError.value = '';
    quantityError.value = '';
  }
  
  void clearRecipeForm() {
    nameController.clear();
    descriptionController.clear();
    servingsController.text = '1';
    cuisineController.clear();
    resetFormErrors();
  }
  
  void clearIngredientForm() {
    nameController.clear();
    descriptionController.clear();
    categoryController.clear();
    caloriesController.clear();
    proteinController.clear();
    carbsController.clear();
    fatController.clear();
    fiberController.clear();
    sugarController.clear();
    quantityController.clear();
    vitaminsController.clear();
    mineralsController.clear();
    saturatedFatController.clear();
    monoFatController.clear();
    polyFatController.clear();
    resetFormErrors();
  }
  
  void setupRecipeForm(dynamic recipe) {
    if (recipe == null) {
      clearRecipeForm();
      return;
    }

    nameController.text = (recipe['name'] as String?) ?? '';
    descriptionController.text = (recipe['description'] as String?) ?? '';
    servingsController.text = (recipe['servings']?.toString()) ?? '1';
    cuisineController.text = (recipe['cuisine'] as String?) ?? '';
  }
  
  void setupIngredientForm(dynamic ingredient) {
    if (ingredient == null) {
      clearIngredientForm();
      return;
    }

    nameController.text = (ingredient['name'] as String?) ??
        (ingredient['ingredientName'] as String?) ?? '';
    descriptionController.text = (ingredient['description'] as String?) ?? '';
    categoryController.text = (ingredient['category'] as String?) ?? '';
    caloriesController.text = '${ingredient['calories'] ?? 0}';
    proteinController.text = '${ingredient['protein'] ?? 0}';
    carbsController.text = '${ingredient['carbohydrates'] ?? 0}';
    fatController.text = '${ingredient['fat'] ?? 0}';
    fiberController.text = '${ingredient['fiber'] ?? 0}';
    sugarController.text = '${ingredient['sugar'] ?? 0}';
    quantityController.text = '${ingredient['quantity'] ?? 0}';
    vitaminsController.text = (ingredient['vitamins'] as String?) ?? '';
    mineralsController.text = (ingredient['minerals'] as String?) ?? '';
    
    // Parse JSON fields if they exist
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
      debugPrint('Error parsing JSON: $e');
    }
    
    saturatedFatController.text = '${fatBreakdown['Saturated'] ?? 0}';
    monoFatController.text = '${fatBreakdown['Monounsaturated'] ?? 0}';
    polyFatController.text = '${fatBreakdown['Polyunsaturated'] ?? 0}';
  }
  
  // Input formatters
  static List<TextInputFormatter> getNumberInputFormatters() {
    return [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      TextInputFormatter.withFunction((oldValue, newValue) {
        // Allow only one decimal point
        if (newValue.text.isEmpty) return newValue;
        if (newValue.text == '.') return const TextEditingValue(text: '0.');
        
        // Count decimal points
        final decimalPoints = newValue.text.split('.').length - 1;
        if (decimalPoints > 1) return oldValue;
        
        return newValue;
      }),
    ];
  }
  
  static List<TextInputFormatter> getIntegerInputFormatters() {
    return [
      FilteringTextInputFormatter.digitsOnly,
    ];
  }
  
  // Recipe form validation
  bool validateRecipeForm() {
    bool isValid = true;
    
    if (!validateName(nameController.text)) isValid = false;
    if (!validateDescription(descriptionController.text)) isValid = false;
    if (!validateServings(servingsController.text)) isValid = false;
    
    return isValid;
  }
  
  // Ingredient form validation
  bool validateIngredientForm() {
    bool isValid = true;
    
    if (!validateName(nameController.text)) isValid = false;
    if (!validateDescription(descriptionController.text)) isValid = false;
    if (!validateCalories(caloriesController.text)) isValid = false;
    if (!validateNutrient(proteinController.text, proteinError, 'Protein')) isValid = false;
    if (!validateNutrient(carbsController.text, carbsError, 'Carbs')) isValid = false;
    if (!validateNutrient(fatController.text, fatError, 'Fat')) isValid = false;
    if (!validateQuantity(quantityController.text)) isValid = false;
    
    return isValid;
  }
  
  // Create ingredient data from form
  Map<String, dynamic> createIngredientData(int dietaryCategory) {
    final fatBreakdownData = {
      'Saturated': double.tryParse(saturatedFatController.text) ?? 0.0,
      'Monounsaturated': double.tryParse(monoFatController.text) ?? 0.0,
      'Polyunsaturated': double.tryParse(polyFatController.text) ?? 0.0,
    };

    // Helper function to validate and format JSON fields
    String? formatJsonField(String controllerText) {
      if (controllerText.isEmpty) return null;
      try {
        // Validate JSON format
        final decoded = jsonDecode(controllerText);
        // Ensure it's a valid object or array
        if (decoded is Map || decoded is List) {
          return controllerText;
        }
        return null;
      } catch (e) {
        debugPrint('Invalid JSON format: $controllerText');
        return null;
      }
    }

    final data = {
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'category': categoryController.text.trim(),
      'dietaryCategory': dietaryCategory,
      'calories': int.tryParse(caloriesController.text) ?? 0,
      'protein': double.tryParse(proteinController.text) ?? 0.0,
      'carbohydrates': double.tryParse(carbsController.text) ?? 0.0,
      'fat': double.tryParse(fatController.text) ?? 0.0,
      'fiber': double.tryParse(fiberController.text) ?? 0.0,
      'sugar': double.tryParse(sugarController.text) ?? 0.0,
      'fatBreakdown': jsonEncode(fatBreakdownData)
    };

    // Only add vitamins and minerals if they have valid values
    final vitaminsJson = formatJsonField(vitaminsController.text);
    if (vitaminsJson != null) {
      data['vitamins'] = vitaminsJson;
    }

    final mineralsJson = formatJsonField(mineralsController.text);
    if (mineralsJson != null) {
      data['minerals'] = mineralsJson;
    }

    return data;
  }
  
  // Create recipe data from form
  Map<String, dynamic> createRecipeData(int dietaryCategory, List<dynamic> ingredients) {
    return {
      'name': nameController.text,
      'description': descriptionController.text,
      'servings': int.tryParse(servingsController.text) ?? 1,
      'imageUrl': '',
      'dietaryCategory': dietaryCategory,
      'cuisine': cuisineController.text,
      'ingredients': ingredients.map((ingredient) => {
        'ingredientId': ingredient['ingredientId'],
        'quantity': ingredient['quantity']
      }).toList(),
    };
  }

  void updateFilteredRecipes() {
    List<dynamic> filtered = recipes.value;

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((recipe) {
        final name = (recipe['name'] as String? ?? '').toLowerCase();
        final description = (recipe['description'] as String? ?? '')
            .toLowerCase();
        final cuisine = (recipe['cuisine'] as String? ?? '').toLowerCase();
        final query = searchQuery.value.toLowerCase();

        return name.contains(query) ||
            description.contains(query) ||
            cuisine.contains(query);
      }).toList();
    }

    // Apply cuisine filter
    if (selectedRecipeCuisine.value != 'All') {
      filtered = filtered.where((recipe) {
        final cuisine = recipe['cuisine'] as String? ?? '';
        return cuisine.toLowerCase() ==
            selectedRecipeCuisine.value.toLowerCase();
      }).toList();
    }

    // Apply calorie range filter
    filtered = filtered.where((recipe) {
      final calories = (recipe['calories'] as num?)?.toDouble() ?? 0.0;
      return calories >= calorieRange.value.start &&
          calories <= calorieRange.value.end;
    }).toList();

    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;

      switch (recipeSortBy.value) {
        case 'name':
          comparison = (a['name'] as String? ?? '').compareTo(
              b['name'] as String? ?? '');
          break;
        case 'servings':
          comparison = ((a['servings'] as num?) ?? 0).compareTo(
              (b['servings'] as num?) ?? 0);
          break;
        case 'calories':
          comparison = ((a['calories'] as num?) ?? 0).compareTo(
              (b['calories'] as num?) ?? 0);
          break;
      }

      return sortAscending.value ? comparison : -comparison;
    });

    filteredRecipes.value = filtered;
  }

  void updateFilteredIngredients() {
    List<dynamic> filtered = ingredients.value;

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((ingredient) {
        final name = (ingredient['name'] as String? ??
            ingredient['ingredientName'] as String? ?? '').toLowerCase();
        final description = (ingredient['description'] as String? ?? '')
            .toLowerCase();
        final category = (ingredient['category'] as String? ?? '')
            .toLowerCase();
        final query = searchQuery.value.toLowerCase();

        return name.contains(query) ||
            description.contains(query) ||
            category.contains(query);
      }).toList();
    }

    // Apply category filter
    if (selectedIngredientCategory.value != 'All') {
      filtered = filtered.where((ingredient) {
        final category = ingredient['category'] as String? ?? '';
        return category.toLowerCase() ==
            selectedIngredientCategory.value.toLowerCase();
      }).toList();
    }

    // Apply calorie range filter
    filtered = filtered.where((ingredient) {
      final calories = (ingredient['calories'] as num?)?.toDouble() ?? 0.0;
      return calories >= calorieRange.value.start &&
          calories <= calorieRange.value.end;
    }).toList();

    // Apply protein range filter
    filtered = filtered.where((ingredient) {
      final protein = (ingredient['protein'] as num?)?.toDouble() ?? 0.0;
      return protein >= proteinRange.value.start &&
          protein <= proteinRange.value.end;
    }).toList();

    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;

      switch (ingredientSortBy.value) {
        case 'name':
          final nameA = a['name'] as String? ??
              a['ingredientName'] as String? ?? '';
          final nameB = b['name'] as String? ??
              b['ingredientName'] as String? ?? '';
          comparison = nameA.compareTo(nameB);
          break;
        case 'calories':
          comparison = ((a['calories'] as num?) ?? 0).compareTo(
              (b['calories'] as num?) ?? 0);
          break;
        case 'protein':
          comparison = ((a['protein'] as num?) ?? 0).compareTo(
              (b['protein'] as num?) ?? 0);
          break;
        case 'carbs':
          comparison = ((a['carbohydrates'] as num?) ?? 0).compareTo(
              (b['carbohydrates'] as num?) ?? 0);
          break;
      }

      return sortAscending.value ? comparison : -comparison;
    });

    filteredIngredients.value = filtered;
  }

  // Helper methods for getting filter options
  List<String> get availableRecipeCuisines {
    final cuisines = recipes
        .map((recipe) => recipe['cuisine'] as String? ?? '')
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    cuisines.sort();
    return ['All', ...cuisines];
  }

  List<String> get availableIngredientCategories {
    final categories = ingredients.map((
        ingredient) => ingredient['category'] as String? ?? '').where((c) =>
    c.isNotEmpty).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  // Search and filter control methods
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void resetFilters() {
    selectedRecipeCuisine.value = 'All';
    selectedIngredientCategory.value = 'All';
    calorieRange.value = const RangeValues(0, 1000);
    proteinRange.value = const RangeValues(0, 100);
  }

  void toggleFilterVisibility() {
    showFilters.value = !showFilters.value;
  }

  @override
  void onClose() {
    // Dispose controllers
    nameController.dispose();
    descriptionController.dispose();
    servingsController.dispose();
    cuisineController.dispose();
    categoryController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
    fiberController.dispose();
    sugarController.dispose();
    quantityController.dispose();
    vitaminsController.dispose();
    mineralsController.dispose();
    saturatedFatController.dispose();
    monoFatController.dispose();
    polyFatController.dispose();
    searchController.dispose();
    super.onClose();
  }
}