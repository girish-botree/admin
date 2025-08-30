import 'package:get/get.dart';
import '../../../core/error/error_handler.dart';
import '../models/recipe_model.dart';
import '../repositories/recipe_repository.dart';

/// Recipe Service
/// Handles business logic for recipe operations
class RecipeService extends GetxService {
  final RecipeRepository _recipeRepository = RecipeRepository();
  final ErrorHandler _errorHandler = ErrorHandler();

  /// Get all recipes with optional filtering
  Future<List<Recipe>> getAllRecipes({
    String? searchQuery,
    String? cuisine,
    String? category,
    int? minCalories,
    int? maxCalories,
    double? minProtein,
    double? maxCarbs,
    bool? vegetarian,
    bool? vegan,
    int? limit,
  }) async {
    try {
      List<Recipe> recipes = await _recipeRepository.getAll(showLoading: false);
      
      // Apply filters
      recipes = _applyFilters(
        recipes,
        searchQuery: searchQuery,
        cuisine: cuisine,
        category: category,
        minCalories: minCalories,
        maxCalories: maxCalories,
        minProtein: minProtein,
        maxCarbs: maxCarbs,
        vegetarian: vegetarian,
        vegan: vegan,
      );

      // Apply limit
      if (limit != null && limit > 0) {
        recipes = recipes.take(limit).toList();
      }

      return recipes;
    } catch (e) {
      _errorHandler.handleApiError(e, customMessage: 'Failed to fetch recipes');
      return [];
    }
  }

  /// Get recipe by ID
  Future<Recipe?> getRecipeById(String id) async {
    try {
      return await _recipeRepository.getById(id, showLoading: false);
    } catch (e) {
      _errorHandler.handleApiError(e, customMessage: 'Failed to fetch recipe');
      return null;
    }
  }

  /// Create new recipe
  Future<bool> createRecipe(Map<String, dynamic> recipeData) async {
    try {
      // Validate recipe data
      final validationResult = _validateRecipeData(recipeData);
      if (!validationResult.isValid) {
        _errorHandler.handleValidationError('Recipe', validationResult.errorMessage);
        return false;
      }

      final success = await _recipeRepository.create(recipeData, showLoading: false);
      if (success) {
        _errorHandler.showSuccess('Recipe created successfully');
      }
      return success;
    } catch (e) {
      _errorHandler.handleApiError(e, customMessage: 'Failed to create recipe');
      return false;
    }
  }

  /// Update existing recipe
  Future<bool> updateRecipe(String id, Map<String, dynamic> recipeData) async {
    try {
      // Validate recipe data
      final validationResult = _validateRecipeData(recipeData);
      if (!validationResult.isValid) {
        _errorHandler.handleValidationError('Recipe', validationResult.errorMessage);
        return false;
      }

      final success = await _recipeRepository.update(id, recipeData, showLoading: false);
      if (success) {
        _errorHandler.showSuccess('Recipe updated successfully');
      }
      return success;
    } catch (e) {
      _errorHandler.handleApiError(e, customMessage: 'Failed to update recipe');
      return false;
    }
  }

  /// Delete recipe
  Future<bool> deleteRecipe(String id) async {
    try {
      final success = await _recipeRepository.delete(id, showLoading: false);
      if (success) {
        _errorHandler.showSuccess('Recipe deleted successfully');
      }
      return success;
    } catch (e) {
      _errorHandler.handleApiError(e, customMessage: 'Failed to delete recipe');
      return false;
    }
  }

  /// Get recipes by cuisine
  Future<List<Recipe>> getRecipesByCuisine(String cuisine) async {
    try {
      return await _recipeRepository.getRecipesByCuisine(cuisine);
    } catch (e) {
      _errorHandler.handleApiError(e, customMessage: 'Failed to fetch recipes by cuisine');
      return [];
    }
  }

  /// Search recipes
  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      return await _recipeRepository.searchRecipes(query);
    } catch (e) {
      _errorHandler.handleApiError(e, customMessage: 'Failed to search recipes');
      return [];
    }
  }

  /// Get low-carb recipes
  Future<List<Recipe>> getLowCarbRecipes({double maxCarbs = 30.0}) async {
    try {
      return await _recipeRepository.getLowCarbRecipes(maxCarbs: maxCarbs);
    } catch (e) {
      _errorHandler.handleApiError(e, customMessage: 'Failed to fetch low-carb recipes');
      return [];
    }
  }

  /// Get vegetarian recipes
  Future<List<Recipe>> getVegetarianRecipes() async {
    try {
      return await _recipeRepository.getVegetarianRecipes();
    } catch (e) {
      _errorHandler.handleApiError(e, customMessage: 'Failed to fetch vegetarian recipes');
      return [];
    }
  }

  /// Get vegan recipes
  Future<List<Recipe>> getVeganRecipes() async {
    try {
      final allRecipes = await _recipeRepository.getAll(showLoading: false);
      return allRecipes.where((recipe) => 
        recipe.category.toLowerCase() == 'vegan' ||
        recipe.name.toLowerCase().contains('vegan') ||
        recipe.description.toLowerCase().contains('vegan')
      ).toList();
    } catch (e) {
      _errorHandler.handleApiError(e, customMessage: 'Failed to fetch vegan recipes');
      return [];
    }
  }

  /// Get popular recipes (most viewed/rated)
  Future<List<Recipe>> getPopularRecipes({int limit = 10}) async {
    try {
      return await _recipeRepository.getPopularRecipes(limit: limit);
    } catch (e) {
      _errorHandler.handleApiError(e, customMessage: 'Failed to fetch popular recipes');
      return [];
    }
  }

  /// Get recent recipes
  Future<List<Recipe>> getRecentRecipes({int limit = 10}) async {
    try {
      return await _recipeRepository.getRecentRecipes(limit: limit);
    } catch (e) {
      _errorHandler.handleApiError(e, customMessage: 'Failed to fetch recent recipes');
      return [];
    }
  }

  /// Get meal prep recipes
  Future<List<Recipe>> getMealPrepRecipes() async {
    try {
      return await _recipeRepository.getMealPrepRecipes();
    } catch (e) {
      _errorHandler.handleApiError(e, customMessage: 'Failed to fetch meal prep recipes');
      return [];
    }
  }

  /// Get cuisine options
  Future<List<String>> getCuisineOptions() async {
    try {
      final recipes = await _recipeRepository.getAll(showLoading: false);
      final cuisines = recipes.map((recipe) => recipe.cuisine).toSet().toList();
      cuisines.sort();
      return cuisines;
    } catch (e) {
      _errorHandler.handleApiError(e, customMessage: 'Failed to fetch cuisine options');
      return [];
    }
  }

  /// Get category options
  Future<List<String>> getCategoryOptions() async {
    try {
      final recipes = await _recipeRepository.getAll(showLoading: false);
      final categories = recipes.map((recipe) => recipe.category).toSet().toList();
      categories.sort();
      return categories;
    } catch (e) {
      _errorHandler.handleApiError(e, customMessage: 'Failed to fetch category options');
      return [];
    }
  }

  /// Apply filters to recipes
  List<Recipe> _applyFilters(
    List<Recipe> recipes, {
    String? searchQuery,
    String? cuisine,
    String? category,
    int? minCalories,
    int? maxCalories,
    double? minProtein,
    double? maxCarbs,
    bool? vegetarian,
    bool? vegan,
  }) {
    return recipes.where((recipe) {
      // Search query filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!recipe.name.toLowerCase().contains(query) &&
            !recipe.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Cuisine filter
      if (cuisine != null && cuisine.isNotEmpty && cuisine != 'All') {
        if (recipe.cuisine.toLowerCase() != cuisine.toLowerCase()) {
          return false;
        }
      }

      // Category filter
      if (category != null && category.isNotEmpty && category != 'All') {
        if (recipe.category.toLowerCase() != category.toLowerCase()) {
          return false;
        }
      }

      // Calorie range filter
      if (minCalories != null && recipe.calories < minCalories) {
        return false;
      }
      if (maxCalories != null && recipe.calories > maxCalories) {
        return false;
      }

      // Protein filter
      if (minProtein != null && recipe.protein < minProtein) {
        return false;
      }

      // Carbs filter
      if (maxCarbs != null && recipe.carbs > maxCarbs) {
        return false;
      }

      // Vegetarian filter
      if (vegetarian == true) {
        if (recipe.category.toLowerCase() != 'vegetarian' &&
            recipe.category.toLowerCase() != 'vegan') {
          return false;
        }
      }

      // Vegan filter
      if (vegan == true) {
        if (recipe.category.toLowerCase() != 'vegan') {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Validate recipe data
  ValidationResult _validateRecipeData(Map<String, dynamic> data) {
    // Name validation
    if (data['name'] == null || data['name'].toString().trim().isEmpty) {
      return ValidationResult(false, 'Recipe name is required');
    }

    // Description validation
    if (data['description'] == null || data['description'].toString().trim().isEmpty) {
      return ValidationResult(false, 'Recipe description is required');
    }

    // Servings validation
    final servings = data['servings'];
    if (servings == null || (servings is int && servings <= 0)) {
      return ValidationResult(false, 'Valid servings count is required');
    }

    // Calories validation
    final calories = data['calories'];
    if (calories == null || (calories is int && calories < 0)) {
      return ValidationResult(false, 'Valid calories count is required');
    }

    // Protein validation
    final protein = data['protein'];
    if (protein == null || (protein is num && protein < 0)) {
      return ValidationResult(false, 'Valid protein value is required');
    }

    // Carbs validation
    final carbs = data['carbs'];
    if (carbs == null || (carbs is num && carbs < 0)) {
      return ValidationResult(false, 'Valid carbs value is required');
    }

    // Fat validation
    final fat = data['fat'];
    if (fat == null || (fat is num && fat < 0)) {
      return ValidationResult(false, 'Valid fat value is required');
    }

    return ValidationResult(true, '');
  }
}

/// Validation result class
class ValidationResult {
  final bool isValid;
  final String errorMessage;

  ValidationResult(this.isValid, this.errorMessage);
}
