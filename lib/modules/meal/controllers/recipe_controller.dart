import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/error/error_handler.dart';
import '../models/recipe_model.dart';
import '../repositories/recipe_repository.dart';
import '../../../utils/search_utils.dart';

/// Focused Recipe Controller
/// Handles recipe-specific operations and state management
class RecipeController extends GetxController {
  final RecipeRepository _recipeRepository = RecipeRepository();
  final ErrorHandler _errorHandler = ErrorHandler();

  // Recipe state
  final recipes = <Recipe>[].obs;
  final filteredRecipes = <Recipe>[].obs;
  final selectedRecipe = Rxn<Recipe>();
  
  // Search state
  final recipeSearchController = TextEditingController();
  final recipeSearchQuery = ''.obs;

  // Sort state
  final recipeSortBy = 'name'.obs; // name, servings, calories
  final sortAscending = true.obs;

  // Filter state
  final selectedRecipeCuisine = 'All'.obs;
  final calorieRange = const RangeValues(0, 1000).obs;
  final proteinRange = const RangeValues(0, 100).obs;

  // Filter visibility
  final showFilters = false.obs;

  // Loading state
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
  final vitaminsController = TextEditingController();
  final mineralsController = TextEditingController();
  final saturatedFatController = TextEditingController();
  final monoFatController = TextEditingController();
  final polyFatController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    _setupSearchListener();
    _setupReactiveListeners();
    fetchRecipes();
  }

  @override
  void onClose() {
    recipeSearchController.dispose();
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
    vitaminsController.dispose();
    mineralsController.dispose();
    saturatedFatController.dispose();
    monoFatController.dispose();
    polyFatController.dispose();
    super.onClose();
  }

  void _setupSearchListener() {
    recipeSearchController.addListener(() {
      SearchUtils.debounceSearch(
        recipeSearchController.text,
        (query) {
          recipeSearchQuery.value = query;
          updateFilteredRecipes();
        },
      );
    });

    cuisineController.addListener(() {
      selectedCuisine.value = cuisineController.text;
    });
  }

  void _setupReactiveListeners() {
    ever(recipeSearchQuery, (_) => updateFilteredRecipes());
    ever(recipeSortBy, (_) => updateFilteredRecipes());
    ever(sortAscending, (_) => updateFilteredRecipes());
    ever(selectedRecipeCuisine, (_) => updateFilteredRecipes());
    ever(calorieRange, (_) => updateFilteredRecipes());
    ever(proteinRange, (_) => updateFilteredRecipes());
  }

  // Recipe CRUD operations
  Future<void> fetchRecipes() async {
    isLoading.value = true;
    error.value = '';
    
    try {
      final recipeList = await _recipeRepository.getAll(showLoading: false);
      recipes.value = recipeList;
      updateFilteredRecipes();
    } catch (e) {
      error.value = e.toString();
      _errorHandler.handleApiError(e, customMessage: 'Failed to fetch recipes');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      return await _recipeRepository.getById(recipeId, showLoading: false);
    } catch (e) {
      _errorHandler.handleApiError(e, customMessage: 'Failed to fetch recipe');
      return null;
    }
  }

  Future<bool> createRecipe(Map<String, dynamic> data) async {
    isLoading.value = true;
    error.value = '';
    
    try {
      final success = await _recipeRepository.create(data, showLoading: false);
      if (success) {
        await fetchRecipes();
        _errorHandler.showSuccess('Recipe created successfully');
        clearForm();
      }
      return success;
    } catch (e) {
      error.value = e.toString();
      _errorHandler.handleApiError(e, customMessage: 'Failed to create recipe');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> updateRecipe(String id, Map<String, dynamic> data) async {
    isLoading.value = true;
    error.value = '';
    
    try {
      final success = await _recipeRepository.update(id, data, showLoading: false);
      if (success) {
        await fetchRecipes();
        _errorHandler.showSuccess('Recipe updated successfully');
        clearForm();
      }
      return success;
    } catch (e) {
      error.value = e.toString();
      _errorHandler.handleApiError(e, customMessage: 'Failed to update recipe');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> deleteRecipe(String id) async {
    isLoading.value = true;
    error.value = '';
    
    try {
      final success = await _recipeRepository.delete(id, showLoading: false);
      if (success) {
        await fetchRecipes();
        _errorHandler.showSuccess('Recipe deleted successfully');
      }
      return success;
    } catch (e) {
      error.value = e.toString();
      _errorHandler.handleApiError(e, customMessage: 'Failed to delete recipe');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Advanced recipe operations
  Future<List<Recipe>> getRecipesByCuisine(String cuisine) async {
    try {
      return await _recipeRepository.getRecipesByCuisine(cuisine);
    } catch (e) {
      _errorHandler.handleApiError(e, customMessage: 'Failed to fetch recipes by cuisine');
      return [];
    }
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      return await _recipeRepository.searchRecipes(query);
    } catch (e) {
      _errorHandler.handleApiError(e, customMessage: 'Failed to search recipes');
      return [];
    }
  }

  Future<List<Recipe>> getLowCarbRecipes({double maxCarbs = 30.0}) async {
    try {
      return await _recipeRepository.getLowCarbRecipes(maxCarbs: maxCarbs);
    } catch (e) {
      _errorHandler.handleApiError(e, customMessage: 'Failed to fetch low-carb recipes');
      return [];
    }
  }

  Future<List<Recipe>> getVegetarianRecipes() async {
    try {
      return await _recipeRepository.getVegetarianRecipes();
    } catch (e) {
      _errorHandler.handleApiError(e, customMessage: 'Failed to fetch vegetarian recipes');
      return [];
    }
  }

  // Filtering and sorting
  void updateFilteredRecipes() {
    var filtered = List<Recipe>.from(recipes);

    // Apply search filter
    if (recipeSearchQuery.value.isNotEmpty) {
      filtered = filtered.where((recipe) =>
        recipe.name.toLowerCase().contains(recipeSearchQuery.value.toLowerCase()) ||
        recipe.description.toLowerCase().contains(recipeSearchQuery.value.toLowerCase())
      ).toList();
    }

    // Apply cuisine filter
    if (selectedRecipeCuisine.value != 'All') {
      filtered = filtered.where((recipe) =>
        recipe.cuisine.toLowerCase() == selectedRecipeCuisine.value.toLowerCase()
      ).toList();
    }

    // Apply calorie range filter
    filtered = filtered.where((recipe) =>
      recipe.calories >= calorieRange.value.start &&
      recipe.calories <= calorieRange.value.end
    ).toList();

    // Apply protein range filter
    filtered = filtered.where((recipe) =>
      recipe.protein >= proteinRange.value.start &&
      recipe.protein <= proteinRange.value.end
    ).toList();

    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;
      switch (recipeSortBy.value) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'servings':
          comparison = a.servings.compareTo(b.servings);
          break;
        case 'calories':
          comparison = a.calories.compareTo(b.calories);
          break;
        default:
          comparison = a.name.compareTo(b.name);
      }
      return sortAscending.value ? comparison : -comparison;
    });

    filteredRecipes.value = filtered;
  }

  // Form management
  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    servingsController.clear();
    cuisineController.clear();
    categoryController.clear();
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
    
    // Clear validation errors
    nameError.value = '';
    descriptionError.value = '';
    servingsError.value = '';
    caloriesError.value = '';
    proteinError.value = '';
    carbsError.value = '';
    fatError.value = '';
  }

  void populateForm(Recipe recipe) {
    nameController.text = recipe.name;
    descriptionController.text = recipe.description;
    servingsController.text = recipe.servings.toString();
    cuisineController.text = recipe.cuisine;
    categoryController.text = recipe.category;
    caloriesController.text = recipe.calories.toString();
    proteinController.text = recipe.protein.toString();
    carbsController.text = recipe.carbs.toString();
    fatController.text = recipe.fat.toString();
    
    selectedRecipe.value = recipe;
  }

  // Validation
  bool validateRecipeForm() {
    bool isValid = true;

    // Name validation
    if (nameController.text.trim().isEmpty) {
      nameError.value = 'Recipe name is required';
      isValid = false;
    } else {
      nameError.value = '';
    }

    // Description validation
    if (descriptionController.text.trim().isEmpty) {
      descriptionError.value = 'Description is required';
      isValid = false;
    } else {
      descriptionError.value = '';
    }

    // Servings validation
    final servings = int.tryParse(servingsController.text);
    if (servings == null || servings <= 0) {
      servingsError.value = 'Valid servings count is required';
      isValid = false;
    } else {
      servingsError.value = '';
    }

    // Calories validation
    final calories = int.tryParse(caloriesController.text);
    if (calories == null || calories < 0) {
      caloriesError.value = 'Valid calories count is required';
      isValid = false;
    } else {
      caloriesError.value = '';
    }

    // Protein validation
    final protein = double.tryParse(proteinController.text);
    if (protein == null || protein < 0) {
      proteinError.value = 'Valid protein value is required';
      isValid = false;
    } else {
      proteinError.value = '';
    }

    // Carbs validation
    final carbs = double.tryParse(carbsController.text);
    if (carbs == null || carbs < 0) {
      carbsError.value = 'Valid carbs value is required';
      isValid = false;
    } else {
      carbsError.value = '';
    }

    // Fat validation
    final fat = double.tryParse(fatController.text);
    if (fat == null || fat < 0) {
      fatError.value = 'Valid fat value is required';
      isValid = false;
    } else {
      fatError.value = '';
    }

    return isValid;
  }

  Map<String, dynamic> getRecipeFormData() {
    return {
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'servings': int.tryParse(servingsController.text) ?? 0,
      'cuisine': cuisineController.text.trim(),
      'category': categoryController.text.trim(),
      'calories': int.tryParse(caloriesController.text) ?? 0,
      'protein': double.tryParse(proteinController.text) ?? 0.0,
      'carbs': double.tryParse(carbsController.text) ?? 0.0,
      'fat': double.tryParse(fatController.text) ?? 0.0,
      'fiber': double.tryParse(fiberController.text) ?? 0.0,
      'sugar': double.tryParse(sugarController.text) ?? 0.0,
      'vitamins': vitaminsController.text.trim(),
      'minerals': mineralsController.text.trim(),
      'saturatedFat': double.tryParse(saturatedFatController.text) ?? 0.0,
      'monoFat': double.tryParse(monoFatController.text) ?? 0.0,
      'polyFat': double.tryParse(polyFatController.text) ?? 0.0,
    };
  }

  // UI helpers
  void toggleFilters() {
    showFilters.value = !showFilters.value;
  }

  void resetFilters() {
    selectedRecipeCuisine.value = 'All';
    calorieRange.value = const RangeValues(0, 1000);
    proteinRange.value = const RangeValues(0, 100);
    recipeSortBy.value = 'name';
    sortAscending.value = true;
    updateFilteredRecipes();
  }

  List<String> getCuisineOptions() {
    final cuisines = recipes.map((recipe) => recipe.cuisine).toSet().toList();
    cuisines.sort();
    return ['All', ...cuisines];
  }
}
