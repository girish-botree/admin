import 'package:admin/config/app_config.dart';
import 'package:admin/network_service/dio_network_service.dart';

class IngredientsController extends GetxController {
  final ingredients = <dynamic>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchIngredients();
  }

  Future<void> fetchIngredients() async {
    isLoading.value = true;
    error.value = '';
    
    try {
      // Extract unique ingredients from recipes
      final recipes = await DioNetworkService.getRecipes();
      final uniqueIngredients = <String, dynamic>{};
      
      for (final recipe in recipes) {
        final recipeIngredients = recipe['ingredients'] ?? [];
        for (final ingredient in recipeIngredients) {
          final id = ingredient['ingredientId'];
          if (id != null && !uniqueIngredients.containsKey(id)) {
            uniqueIngredients[id] = ingredient;
          }
        }
      }
      
      ingredients.value = uniqueIngredients.values.toList();
    } catch (e) {
      error.value = e.toString();
      debugPrint('Error fetching ingredients: $e');
    } finally {
      isLoading.value = false;
    }
  }
}