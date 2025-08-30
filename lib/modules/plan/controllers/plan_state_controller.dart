import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../meal_plan_model.dart';
import '../meal_plan_assignment_model.dart';

/// Plan State Controller
/// Handles reactive state management for the plan module
/// Prevents build-time state updates that cause Obx errors
class PlanStateController extends GetxController {
  // Meal plan data
  final RxList<MealPlan> mealPlans = <MealPlan>[].obs;
  final RxList<MealPlanAssignment> mealPlanAssignments = <MealPlanAssignment>[].obs;
  final RxList<dynamic> recipes = <dynamic>[].obs;
  
  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  
  // Calendar state
  final Rx<DateTime> selectedCalendarDate = DateTime.now().obs;
  final Rx<DateTime> focusedDay = DateTime.now().obs;
  
  // Form state
  final RxString selectedRecipeId = ''.obs;
  final Rx<DateTime> selectedMealDate = DateTime.now().obs;
  final Rx<MealPeriod> selectedPeriod = MealPeriod.breakfast.obs;
  final Rx<MealCategory> selectedCategory = MealCategory.vegan.obs;
  final Rx<BmiCategory> selectedBmiCategory = BmiCategory.normal.obs;
  
  // UI state
  final RxBool showFilters = false.obs;
  final RxBool viewByCategory = false.obs;
  final RxBool showMultiSelection = false.obs;
  
  // Error state
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Set up reactive listeners with proper scheduling
    _setupReactiveListeners();
  }

  void _setupReactiveListeners() {
    // Use ever with proper scheduling to prevent build-time updates
    ever(selectedCalendarDate, (date) {
      // Schedule the update for the next frame to avoid build-time updates
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // This will be called after the current build is complete
        _onDateChanged(date);
      });
    });
  }

  void _onDateChanged(DateTime date) {
    // This method will be called after the build is complete
    // You can trigger data loading here if needed
  }

  // Safe state update methods
  void updateMealPlans(List<MealPlan> plans) {
    // Use addPostFrameCallback to ensure we're not in a build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mealPlans.value = plans;
    });
  }

  void updateMealPlanAssignments(List<MealPlanAssignment> assignments) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mealPlanAssignments.value = assignments;
    });
  }

  void updateRecipes(List<dynamic> recipeList) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      recipes.value = recipeList;
    });
  }

  void setLoading(bool loading) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isLoading.value = loading;
    });
  }

  void setRefreshing(bool refreshing) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isRefreshing.value = refreshing;
    });
  }

  void setError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      errorMessage.value = message;
      hasError.value = true;
    });
  }

  void clearError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      errorMessage.value = '';
      hasError.value = false;
    });
  }

  void updateSelectedDate(DateTime date) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedCalendarDate.value = date;
      focusedDay.value = date;
    });
  }

  void updateFocusedDay(DateTime date) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusedDay.value = date;
    });
  }

  // Form state management
  void setSelectedRecipeId(String id) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedRecipeId.value = id;
    });
  }

  void setSelectedMealDate(DateTime date) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedMealDate.value = date;
    });
  }

  void setSelectedPeriod(MealPeriod period) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedPeriod.value = period;
    });
  }

  void setSelectedCategory(MealCategory category) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedCategory.value = category;
    });
  }

  void setSelectedBmiCategory(BmiCategory bmiCategory) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedBmiCategory.value = bmiCategory;
    });
  }

  // UI state management
  void toggleFilters() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showFilters.value = !showFilters.value;
    });
  }

  void toggleViewByCategory() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewByCategory.value = !viewByCategory.value;
    });
  }

  void toggleMultiSelection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showMultiSelection.value = !showMultiSelection.value;
    });
  }

  // Clear form state
  void clearFormState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedRecipeId.value = '';
      selectedMealDate.value = DateTime.now();
      selectedPeriod.value = MealPeriod.breakfast;
      selectedCategory.value = MealCategory.vegan;
      selectedBmiCategory.value = BmiCategory.normal;
    });
  }

  // Reset all state
  void resetState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mealPlans.clear();
      mealPlanAssignments.clear();
      recipes.clear();
      isLoading.value = false;
      isRefreshing.value = false;
      errorMessage.value = '';
      hasError.value = false;
      showFilters.value = false;
      viewByCategory.value = false;
      showMultiSelection.value = false;
      clearFormState();
    });
  }

  // Helper methods for data access
  List<MealPlan> getMealPlansForPeriod(MealPeriod period) {
    final assignments = mealPlanAssignments.where((assignment) {
      return assignment.period == period;
    }).toList();

    List<MealPlan> result = [];
    final addedIds = <String>{};

    for (var assignment in assignments) {
      if (assignment.id != null && addedIds.contains(assignment.id!)) {
        continue;
      }

      String recipeName = assignment.recipeName ?? '';
      String recipeDescription = assignment.recipeDescription ?? '';
      String? recipeImageUrl = assignment.recipeImageUrl;

      if (recipeName.isEmpty) {
        try {
          final recipe = recipes.firstWhere(
            (r) => r is Map<String, dynamic> && r['recipeId'] == assignment.recipeId,
            orElse: () => null,
          );
          if (recipe != null && recipe is Map<String, dynamic>) {
            recipeName = recipe['name']?.toString() ?? 'Unknown Recipe';
            recipeDescription = recipe['description']?.toString() ?? 'No description available';
            recipeImageUrl = recipe['imageUrl']?.toString();
          }
        } catch (e) {
          debugPrint('Error finding recipe details: $e');
        }
      }

      if (recipeName.isEmpty) {
        recipeName = 'Unknown Recipe';
      }
      if (recipeDescription.isEmpty) {
        recipeDescription = 'No description available';
      }

      final mealPlan = MealPlan(
        id: assignment.id,
        name: recipeName,
        description: recipeDescription,
        imageUrl: recipeImageUrl,
        isActive: true,
      );

      result.add(mealPlan);
      if (assignment.id != null) {
        addedIds.add(assignment.id!);
      }
    }

    return result;
  }

  Map<MealCategory, List<MealPlan>> getMealPlansByCategory() {
    final categorizedMeals = <MealCategory, List<MealPlan>>{};
    final addedIds = <MealCategory, Set<String>>{};

    for (final category in MealCategory.values) {
      categorizedMeals[category] = [];
      addedIds[category] = <String>{};
    }

    for (final assignment in mealPlanAssignments) {
      if (assignment.id != null && addedIds[assignment.category]!.contains(assignment.id!)) {
        continue;
      }

      String recipeName = assignment.recipeName ?? '';
      String recipeDescription = assignment.recipeDescription ?? '';
      String? recipeImageUrl = assignment.recipeImageUrl;

      if (recipeName.isEmpty) {
        try {
          final recipe = recipes.firstWhere(
            (r) => r is Map<String, dynamic> && r['recipeId'] == assignment.recipeId,
            orElse: () => null,
          );
          if (recipe != null && recipe is Map<String, dynamic>) {
            recipeName = recipe['name']?.toString() ?? 'Unknown Recipe';
            recipeDescription = recipe['description']?.toString() ?? 'No description available';
            recipeImageUrl = recipe['imageUrl']?.toString();
          }
        } catch (e) {
          // Error finding recipe details
        }
      }

      if (recipeName.isEmpty) {
        recipeName = 'Unknown Recipe';
      }
      if (recipeDescription.isEmpty) {
        recipeDescription = 'No description available';
      }

      final mealPlan = MealPlan(
        id: assignment.id,
        name: recipeName,
        description: recipeDescription,
        imageUrl: recipeImageUrl,
        isActive: true,
        foodType: _mapCategoryToFoodType(assignment.category),
      );

      categorizedMeals[assignment.category]?.add(mealPlan);
      if (assignment.id != null) {
        addedIds[assignment.category]!.add(assignment.id!);
      }
    }

    return categorizedMeals;
  }

  FoodType _mapCategoryToFoodType(MealCategory category) {
    switch (category) {
      case MealCategory.vegan:
        return FoodType.vegan;
      case MealCategory.vegetarian:
        return FoodType.vegetarian;
      case MealCategory.eggitarian:
        return FoodType.eggitarian;
      case MealCategory.nonVegetarian:
        return FoodType.nonVegetarian;
      case MealCategory.other:
        return FoodType.other;
    }
  }
}
