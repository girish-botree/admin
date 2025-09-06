import 'package:admin/config/app_config.dart';
import 'package:admin/network_service/dio_network_service.dart';
import 'package:admin/utils/search_utils.dart';
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
  final recipeSearchController = TextEditingController();
  final ingredientSearchController = TextEditingController();
  final recipeSearchQuery = ''.obs;
  final ingredientSearchQuery = ''.obs;

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
  final isRefreshing = false.obs;
  final isRecipesLoading = false.obs;
  final isIngredientsLoading = false.obs;
  final error = ''.obs;

  // Carousel state
  final currentCarouselIndex = 0.obs;

  // Validation state
  final nameError = RxString('');
  final descriptionError = RxString('');
  final servingsError = RxString('');
  final caloriesError = RxString('');
  final proteinError = RxString('');
  final carbsError = RxString('');
  final fatError = RxString('');
  final fiberError = RxString('');
  final sugarError = RxString('');
  final quantityError = RxString('');
  
  // Form controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final servingsController = TextEditingController();
  final cuisineController = TextEditingController();
  final selectedCuisine = RxString('');
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
  final instructionsController = TextEditingController();

  // Observable nutrition values for real-time composition tracking
  final caloriesValue = RxDouble(0.0);
  final proteinValue = RxDouble(0.0);
  final carbsValue = RxDouble(0.0);
  final fatValue = RxDouble(0.0);
  final fiberValue = RxDouble(0.0);
  final sugarValue = RxDouble(0.0);

  // Computed property for total nutrition composition (reactive)
  double get totalComposition =>
      proteinValue.value + carbsValue.value + fatValue.value +
          fiberValue.value + sugarValue.value;

  @override
  void onInit() {
    super.onInit();
    fetchRecipes();
    fetchIngredients();

    // Listen to search query changes with debouncing
    recipeSearchController.addListener(() {
      SearchUtils.debounceSearch(
        recipeSearchController.text,
        (query) {
          recipeSearchQuery.value = query;
          updateFilteredRecipes();
        },
      );
    });

    ingredientSearchController.addListener(() {
      SearchUtils.debounceSearch(
        ingredientSearchController.text,
        (query) {
          ingredientSearchQuery.value = query;
          updateFilteredIngredients();
        },
      );
    });

    // Listen to cuisine controller changes
    cuisineController.addListener(() {
      selectedCuisine.value = cuisineController.text;
    });

    // Listen to nutrition controllers for real-time composition tracking
    caloriesController.addListener(() {
      caloriesValue.value = double.tryParse(caloriesController.text) ?? 0.0;
    });
    proteinController.addListener(() {
      proteinValue.value = double.tryParse(proteinController.text) ?? 0.0;
    });
    carbsController.addListener(() {
      carbsValue.value = double.tryParse(carbsController.text) ?? 0.0;
    });
    fatController.addListener(() {
      fatValue.value = double.tryParse(fatController.text) ?? 0.0;
    });
    fiberController.addListener(() {
      fiberValue.value = double.tryParse(fiberController.text) ?? 0.0;
    });
    sugarController.addListener(() {
      sugarValue.value = double.tryParse(sugarController.text) ?? 0.0;
    });

    // Setup reactive listeners
    ever(recipeSearchQuery, (_) => updateFilteredRecipes());
    ever(ingredientSearchQuery, (_) => updateFilteredIngredients());
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

    // Update main loading state based on individual loading states
    ever(isRecipesLoading, (_) => _updateMainLoadingState());
    ever(isIngredientsLoading, (_) => _updateMainLoadingState());
  }

  // Helper method to update main loading state
  void _updateMainLoadingState() {
    isLoading.value = isRecipesLoading.value || isIngredientsLoading.value ||
        isRefreshing.value;
  }

  // Recipe methods
  Future<void> fetchRecipes() async {
    isRecipesLoading.value = true;
    error.value = '';
    
    try {
      final response = await DioNetworkService.getRecipes(showLoader: false);
      if (response is Map<String, dynamic> && response['data'] != null) {
        recipes.value = (response['data'] as List<dynamic>? ?? []).cast<dynamic>();
        updateFilteredRecipes();
      } else {
        recipes.value = [];
        filteredRecipes.value = [];
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isRecipesLoading.value = false;
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
      throw Exception('Failed to fetch recipe ingredients: $e');
    }
  }

  Future<dynamic> getRecipeById(String recipeId) async {
    try {
      final response = await DioNetworkService.getRecipeById(recipeId);
      return response;
    } catch (e) {
      throw Exception('Failed to fetch recipe: $e');
    }
  }

  Future<dynamic> getRecipeDetails(String recipeId) async {
    try {
      final response = await DioNetworkService.getRecipeDetails(recipeId);
      return response;
    } catch (e) {
      throw Exception('Failed to fetch recipe details: $e');
    }
  }

  Future<bool> createRecipe(Map<String, dynamic> data) async {
    isRecipesLoading.value = true;
    _updateMainLoadingState();
    error.value = '';
    
    try {
      await DioNetworkService.createRecipe(data, showLoader: false);
      await fetchRecipes();
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isRecipesLoading.value = false;
      _updateMainLoadingState();
    }
  }
  
  Future<bool> updateRecipe(String id, Map<String, dynamic> data) async {
    isRecipesLoading.value = true;
    _updateMainLoadingState();
    error.value = '';
    
    try {
      await DioNetworkService.updateRecipe(id, data, showLoader: false);
      await fetchRecipes();
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isRecipesLoading.value = false;
      _updateMainLoadingState();
    }
  }
  
  Future<bool> deleteRecipe(String id) async {
    isRecipesLoading.value = true;
    _updateMainLoadingState();
    error.value = '';
    
    try {
      await DioNetworkService.deleteRecipe(id, showLoader: false);
      await fetchRecipes();
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isRecipesLoading.value = false;
      _updateMainLoadingState();
    }
  }
  
  // Ingredient methods
  Future<void> fetchIngredients() async {
    isIngredientsLoading.value = true;
    error.value = '';
    
    try {
      final response = await DioNetworkService.getIngredients(showLoader: false);
      if (response is Map<String, dynamic> && response['data'] != null) {
        ingredients.value = (response['data'] as List<dynamic>? ?? []).cast<dynamic>();
        updateFilteredIngredients();
      } else {
        ingredients.value = [];
        filteredIngredients.value = [];
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isIngredientsLoading.value = false;
    }
  }
  
  Future<bool> createIngredient(Map<String, dynamic> data) async {
    isIngredientsLoading.value = true;
    _updateMainLoadingState();
    error.value = '';
    
    try {
      await DioNetworkService.createIngredient(data, showLoader: false);
      await fetchIngredients();
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isIngredientsLoading.value = false;
      _updateMainLoadingState();
    }
  }
  
  Future<bool> updateIngredient(String id, Map<String, dynamic> data) async {
    isIngredientsLoading.value = true;
    _updateMainLoadingState();
    error.value = '';
    
    try {
      await DioNetworkService.updateIngredient(id, data, showLoader: false);
      await fetchIngredients();
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isIngredientsLoading.value = false;
      _updateMainLoadingState();
    }
  }
  
  Future<bool> deleteIngredient(String id) async {
    isIngredientsLoading.value = true;
    _updateMainLoadingState();
    error.value = '';
    
    try {
      await DioNetworkService.deleteIngredient(id, showLoader: false);
      await fetchIngredients();
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isIngredientsLoading.value = false;
      _updateMainLoadingState();
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
      caloriesError.value = 'Calories is required for recipes';
      return false;
    }
    try {
      final calories = int.parse(value);
      if (calories < 0) {
        caloriesError.value = 'Calories cannot be negative';
        return false;
      } else if (calories > 9000) {
        caloriesError.value = 'Calories cannot exceed 9,000 per serving';
        return false;
      } else if (calories == 0) {
        caloriesError.value = 'Calories must be greater than 0';
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
      return true; // Optional field for macronutrients
    }
    try {
      final nutrient = double.parse(value);
      if (nutrient < 0) {
        errorState.value = '$fieldName cannot be negative';
        return false;
      }

      // Specific validation for each nutrient type
      switch (fieldName.toLowerCase()) {
        case 'protein':
          if (nutrient > 100.0) {
            errorState.value = 'Protein cannot exceed 100g per 100g';
            return false;
          }
          break;
        case 'carbs':
        case 'carbohydrates':
          if (nutrient > 100.0) {
            errorState.value = 'Carbohydrates cannot exceed 100g per 100g';
            return false;
          }
          break;
        case 'fat':
          if (nutrient > 100.0) {
            errorState.value = 'Fat cannot exceed 100g per 100g';
            return false;
          }
          break;
        case 'fiber':
          if (nutrient > 50.0) {
            errorState.value = 'Fiber cannot exceed 50g per 100g';
            return false;
          }
          break;
        case 'sugar':
          if (nutrient > 100.0) {
            errorState.value = 'Sugar cannot exceed 100g per 100g';
            return false;
          }
          break;
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

  // New comprehensive composition validation method
  bool validateNutritionComposition() {
    double protein = double.tryParse(proteinController.text) ?? 0.0;
    double carbs = double.tryParse(carbsController.text) ?? 0.0;
    double fat = double.tryParse(fatController.text) ?? 0.0;
    double fiber = double.tryParse(fiberController.text) ?? 0.0;
    double sugar = double.tryParse(sugarController.text) ?? 0.0;

    // Check total composition
    double totalComposition = protein + carbs + fat + fiber + sugar;

    if (totalComposition > 100.0) {
      // Set specific errors for each field if composition exceeds 100g
      if (protein > 0) proteinError.value = 'Total composition exceeds 100g';
      if (carbs > 0) carbsError.value = 'Total composition exceeds 100g';
      if (fat > 0) fatError.value = 'Total composition exceeds 100g';
      return false;
    }

    // Additional logical validations
    if (sugar > carbs && carbs > 0) {
      carbsError.value = 'Sugar cannot exceed total carbohydrates';
      return false;
    }

    if (fiber > carbs && carbs > 0) {
      carbsError.value = 'Fiber cannot exceed total carbohydrates';
      return false;
    }

    // Clear any composition-related errors if validation passes
    if (proteinError.value.contains('Total composition exceeds')) {
      proteinError.value = '';
    }
    if (carbsError.value.contains('Total composition exceeds')) {
      carbsError.value = '';
    }
    if (fatError.value.contains('Total composition exceeds')) {
      fatError.value = '';
    }

    return true;
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
    fiberError.value = '';
    sugarError.value = '';
    quantityError.value = '';
  }
  
  void clearRecipeForm() {
    nameController.clear();
    descriptionController.clear();
    servingsController.text = '1';
    cuisineController.clear();
    selectedCuisine.value = '';
    instructionsController.clear();
    // Clear nutrition controllers
    caloriesController.clear();
    proteinController.clear();
    carbsController.clear();
    fatController.clear();
    fiberController.clear();
    sugarController.clear();
    vitaminsController.clear();
    mineralsController.clear();
    saturatedFatController.clear();
    monoFatController.clear();
    polyFatController.clear();
    // Reset observable nutrition values
    caloriesValue.value = 0.0;
    proteinValue.value = 0.0;
    carbsValue.value = 0.0;
    fatValue.value = 0.0;
    fiberValue.value = 0.0;
    sugarValue.value = 0.0;
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
    instructionsController.clear();
    // Reset observable nutrition values
    caloriesValue.value = 0.0;
    proteinValue.value = 0.0;
    carbsValue.value = 0.0;
    fatValue.value = 0.0;
    fiberValue.value = 0.0;
    sugarValue.value = 0.0;
    resetFormErrors();
  }
  
  void setupRecipeForm(dynamic recipe) {
    if (recipe == null) {
      clearRecipeForm();
      return;
    }

    nameController.text = (recipe['name'] as String?) ?? '';

    // Parse description and instructions
    String fullDescription = (recipe['description'] as String?) ?? '';
    String description = '';
    String instructions = '';

    // Check if description contains preparation steps
    if (fullDescription.contains('--- Preparation Steps ---')) {
      final parts = fullDescription.split('--- Preparation Steps ---');
      description = parts[0].trim();
      instructions = parts.length > 1 ? parts[1].trim() : '';
    } else {
      description = fullDescription;
    }

    descriptionController.text = description;
    instructionsController.text = instructions;

    servingsController.text = (recipe['servings']?.toString()) ?? '1';
    cuisineController.text = (recipe['cuisine'] as String?) ?? '';
    selectedCuisine.value = cuisineController.text;

    // Set nutrition values and observable values
    final calories = double.tryParse('${recipe['calories'] ?? 0}') ?? 0.0;
    final protein = double.tryParse('${recipe['protein'] ?? 0}') ?? 0.0;
    final carbs = double.tryParse('${recipe['carbohydrates'] ?? 0}') ?? 0.0;
    final fat = double.tryParse('${recipe['fat'] ?? 0}') ?? 0.0;
    final fiber = double.tryParse('${recipe['fiber'] ?? 0}') ?? 0.0;
    final sugar = double.tryParse('${recipe['sugar'] ?? 0}') ?? 0.0;

    caloriesController.text = calories.toInt().toString();
    proteinController.text = protein.toInt().toString();
    carbsController.text = carbs.toInt().toString();
    fatController.text = fat.toInt().toString();
    fiberController.text = fiber.toInt().toString();
    sugarController.text = sugar.toInt().toString();

    // Update observable values
    caloriesValue.value = calories;
    proteinValue.value = protein;
    carbsValue.value = carbs;
    fatValue.value = fat;
    fiberValue.value = fiber;
    sugarValue.value = sugar;
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
      // Error parsing JSON
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

    // Strict nutrition validation for recipes
    if (!validateCalories(caloriesController.text)) isValid = false;
    if (!validateNutrient(proteinController.text, proteinError, 'Protein'))
      isValid = false;
    if (!validateNutrient(carbsController.text, carbsError, 'Carbohydrates'))
      isValid = false;
    if (!validateNutrient(fatController.text, fatError, 'Fat')) isValid = false;
    if (!validateNutrient(fiberController.text, fiberError, 'Fiber'))
      isValid = false;
    if (!validateNutrient(sugarController.text, sugarError, 'Sugar'))
      isValid = false;

    // Validate overall composition
    if (!validateNutritionComposition()) isValid = false;

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
    String formatJsonField(String controllerText) {
      if (controllerText.isEmpty) return '{}';
      try {
        // Validate JSON format
        final decoded = jsonDecode(controllerText);
        // Ensure it's a valid object or array
        if (decoded is Map || decoded is List) {
          return controllerText;
        }
        return '{}';
      } catch (e) {
        // Invalid JSON format
        return '{}';
      }
    }

    return {
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'category': categoryController.text.trim(),
      'dietaryCategory': dietaryCategory,
      'calories': double.tryParse(caloriesController.text) ?? 0.0,
      'protein': double.tryParse(proteinController.text) ?? 0.0,
      'carbohydrates': double.tryParse(carbsController.text) ?? 0.0,
      'fat': double.tryParse(fatController.text) ?? 0.0,
      'fiber': double.tryParse(fiberController.text) ?? 0.0,
      'sugar': double.tryParse(sugarController.text) ?? 0.0,
      'vitamins': formatJsonField(vitaminsController.text),
      'minerals': formatJsonField(mineralsController.text),
      'fatBreakdown': jsonEncode(fatBreakdownData),
    };
  }
  
  // Create recipe data from form
  Map<String, dynamic> createRecipeData(int dietaryCategory, List<dynamic> ingredients) {
    // Combine description and instructions for the preparation steps
    String fullDescription = descriptionController.text.trim();
    if (instructionsController.text
        .trim()
        .isNotEmpty) {
      if (fullDescription.isNotEmpty) {
        fullDescription += '\n\n--- Preparation Steps ---\n';
      }
      fullDescription += instructionsController.text.trim();
    }

    return {
      'name': nameController.text,
      'description': fullDescription,
      'servings': int.tryParse(servingsController.text) ?? 1,
      'imageUrl': '',
      'dietaryCategory': dietaryCategory,
      'cuisine': cuisineController.text,
      'calories': int.tryParse(caloriesController.text) ?? 0,
      'protein': int.tryParse(proteinController.text) ?? 0,
      'carbohydrates': int.tryParse(carbsController.text) ?? 0,
      'fat': int.tryParse(fatController.text) ?? 0,
      'fiber': int.tryParse(fiberController.text) ?? 0,
      'sugar': int.tryParse(sugarController.text) ?? 0,
      'vitamins': vitaminsController.text,
      'minerals': mineralsController.text,
      'fatBreakdown': '', // Can be filled from a separate field if needed
      'ingredients': ingredients.map((ingredient) => {
        'ingredientId': ingredient['ingredientId'],
        'quantity': ingredient['quantity']
      }).toList(),
      'isActive': true, // Add isActive field
    };
  }

  void updateFilteredRecipes() {
    List<dynamic> filtered = recipes.toList();

    // Apply search filter with optimized prefix search
    if (recipeSearchQuery.value.isNotEmpty) {
      filtered = SearchUtils.filterAndSort(
        filtered,
        recipeSearchQuery.value,
        (recipe) => [
          recipe['name'] as String? ?? '',
          recipe['description'] as String? ?? '',
          recipe['cuisine'] as String? ?? '',
        ],
        fallbackToContains: true,
      );
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
    List<dynamic> filtered = ingredients.toList();

    // Apply search filter with optimized prefix search
    if (ingredientSearchQuery.value.isNotEmpty) {
      filtered = SearchUtils.filterAndSort(
        filtered,
        ingredientSearchQuery.value,
        (ingredient) => [
          ingredient['name'] as String? ??
            ingredient['ingredientName'] as String? ?? '',
          ingredient['description'] as String? ?? '',
          ingredient['category'] as String? ?? '',
        ],
        fallbackToContains: true,
      );
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
        case 'carbohydrates':
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
    recipeSearchController.clear();
    ingredientSearchController.clear();
    recipeSearchQuery.value = '';
    ingredientSearchQuery.value = '';
    updateFilteredRecipes();
    updateFilteredIngredients();
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

  void updateCarouselIndex(int index) {
    currentCarouselIndex.value = index;
  }

  // Add refresh method with proper loading state management
  Future<void> refreshData() async {
    if (isRefreshing.value) return; // Prevent multiple refresh operations

    isRefreshing.value = true;
    _updateMainLoadingState();
    error.value = '';

    try {
      await Future.wait([
        fetchRecipes(),
        fetchIngredients(),
      ]);
    } catch (e) {
      error.value = e.toString();
      rethrow; // Re-throw so UI can handle the error
    } finally {
      isRefreshing.value = false;
      _updateMainLoadingState();
    }
  }

  @override
  void onClose() {
    // Cancel any pending debounced searches
    SearchUtils.cancelDebouncedSearch();
    
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
    instructionsController.dispose(); // Dispose instructions controller
    recipeSearchController.dispose();
    ingredientSearchController.dispose();
    super.onClose();
  }
}