import '../../../core/repository/base_repository.dart';
import '../../../network_service/api_helper.dart';
import '../models/recipe_model.dart';

/// Recipe Repository Implementation
/// Handles all recipe-related data operations
class RecipeRepository extends BaseRepository<Recipe> {
  RecipeRepository() : super('recipes');

  @override
  Future<dynamic> _makeGetRequest(Map<String, dynamic>? queryParameters) async {
    return await ApiHelper.getApiClient().getRecipes();
  }

  @override
  Future<dynamic> _makeGetByIdRequest(String id) async {
    return await ApiHelper.getApiClient().getRecipeById(id);
  }

  @override
  Future<dynamic> _makeCreateRequest(Map<String, dynamic> data) async {
    return await ApiHelper.getApiClient().createRecipe(data);
  }

  @override
  Future<dynamic> _makeUpdateRequest(String id, Map<String, dynamic> data) async {
    return await ApiHelper.getApiClient().updateRecipe(id, data);
  }

  @override
  Future<dynamic> _makeDeleteRequest(String id) async {
    return await ApiHelper.getApiClient().deleteRecipe(id);
  }

  @override
  Recipe fromJson(Map<String, dynamic> json) {
    return Recipe.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(Recipe model) {
    return model.toJson();
  }

  /// Get recipes by cuisine
  Future<List<Recipe>> getRecipesByCuisine(String cuisine) async {
    final allRecipes = await getAll();
    return allRecipes.where((recipe) => recipe.cuisine.toLowerCase() == cuisine.toLowerCase()).toList();
  }

  /// Get recipes by category
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    final allRecipes = await getAll();
    return allRecipes.where((recipe) => recipe.category.toLowerCase() == category.toLowerCase()).toList();
  }

  /// Search recipes by name
  Future<List<Recipe>> searchRecipes(String query) async {
    final allRecipes = await getAll();
    return allRecipes.where((recipe) => 
      recipe.name.toLowerCase().contains(query.toLowerCase()) ||
      recipe.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Get recipes with calorie range
  Future<List<Recipe>> getRecipesByCalorieRange(int minCalories, int maxCalories) async {
    final allRecipes = await getAll();
    return allRecipes.where((recipe) => 
      recipe.calories >= minCalories && recipe.calories <= maxCalories
    ).toList();
  }

  /// Get recipes by protein content
  Future<List<Recipe>> getRecipesByProteinContent(double minProtein) async {
    final allRecipes = await getAll();
    return allRecipes.where((recipe) => recipe.protein >= minProtein).toList();
  }

  /// Get low-carb recipes
  Future<List<Recipe>> getLowCarbRecipes({double maxCarbs = 30.0}) async {
    final allRecipes = await getAll();
    return allRecipes.where((recipe) => recipe.carbs <= maxCarbs).toList();
  }

  /// Get vegetarian recipes
  Future<List<Recipe>> getVegetarianRecipes() async {
    final allRecipes = await getAll();
    // This is a simplified check - in a real app, you'd have a proper vegetarian flag
    return allRecipes.where((recipe) => 
      !recipe.ingredients.any((ingredient) => 
        ingredient.toLowerCase().contains('meat') ||
        ingredient.toLowerCase().contains('chicken') ||
        ingredient.toLowerCase().contains('beef') ||
        ingredient.toLowerCase().contains('pork') ||
        ingredient.toLowerCase().contains('fish')
      )
    ).toList();
  }

  /// Get quick recipes (less than 30 minutes)
  Future<List<Recipe>> getQuickRecipes() async {
    final allRecipes = await getAll();
    // This would need a cooking time field in the model
    // For now, returning all recipes
    return allRecipes;
  }

  /// Get popular recipes (most viewed/rated)
  Future<List<Recipe>> getPopularRecipes({int limit = 10}) async {
    final allRecipes = await getAll();
    // This would need popularity metrics in the model
    // For now, returning first N recipes
    return allRecipes.take(limit).toList();
  }

  /// Get recent recipes
  Future<List<Recipe>> getRecentRecipes({int limit = 10}) async {
    final allRecipes = await getAll();
    allRecipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allRecipes.take(limit).toList();
  }

  /// Get recipes by serving size
  Future<List<Recipe>> getRecipesByServings(int servings) async {
    final allRecipes = await getAll();
    return allRecipes.where((recipe) => recipe.servings == servings).toList();
  }

  /// Get recipes suitable for meal prep
  Future<List<Recipe>> getMealPrepRecipes() async {
    final allRecipes = await getAll();
    // This would need meal prep suitability flag
    // For now, returning recipes with more than 4 servings
    return allRecipes.where((recipe) => recipe.servings >= 4).toList();
  }
}
