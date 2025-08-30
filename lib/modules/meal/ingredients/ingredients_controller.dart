import 'package:admin/config/app_config.dart';
import 'package:admin/network_service/dio_network_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

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

      if (recipes is List) {
        for (final recipe in recipes) {
          if (recipe is Map<String, dynamic>) {
            final recipeIngredients = recipe['ingredients'];
            if (recipeIngredients is List) {
              for (final ingredient in recipeIngredients) {
                if (ingredient is Map<String, dynamic>) {
                  final id = ingredient['ingredientId'] as String?;
                  if (id != null && !uniqueIngredients.containsKey(id)) {
                    uniqueIngredients[id] = ingredient;
                  }
                }
              }
            }
          }
        }
      }
      
      ingredients.value = uniqueIngredients.values.toList();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}