import 'package:admin/config/app_text.dart';
import 'package:admin/modules/plan/plan_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../network_service/dio_network_service.dart';
import '../../widgets/custom_displays.dart';
import 'meal_plan_model.dart';
import 'meal_plan_assignment_model.dart';
import 'widgets/meal_plan_form_dialog.dart';

class PlanController extends GetxController {
  final RxList<MealPlan> mealPlans = <MealPlan>[].obs;
  final RxList<MealPlanAssignment> mealPlanAssignments = <MealPlanAssignment>[].obs;
  final RxList<dynamic> recipes = <dynamic>[].obs;
  final RxList<dynamic> _filteredRecipesCache = <dynamic>[].obs; // Cache filtered recipes
  MealCategory? _lastFilteredCategory; // Track last filtered category
  final RxBool isLoading = false.obs;
  
  // Form controllers for meal plans
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final imageUrlController = TextEditingController();
  final RxBool isActive = true.obs;
  
  // Form controllers for meal plan assignments
  final RxString selectedRecipeId = ''.obs;
  final Rx<DateTime> selectedMealDate = DateTime.now().obs;
  final Rx<MealPeriod> selectedPeriod = MealPeriod.breakfast.obs;
  final Rx<MealCategory> selectedCategory = MealCategory.vegan.obs;
  final Rx<BmiCategory> selectedBmiCategory = BmiCategory.normal.obs;
  
  // Multiple meal selection support
  final RxList<String> selectedRecipeIds = <String>[].obs;
  final RxBool showMultiSelection = false.obs;
  final RxInt selectedMealCount = 0.obs;
  
  // Multi-selection per meal period
  final RxMap<MealPeriod, List<String>> selectedMealRecipeIds = <MealPeriod, List<String>>{}.obs;
  
  // Calendar functionality
  final Rx<DateTime> selectedCalendarDate = DateTime.now().obs;
  final Rx<DateTime> focusedDay = DateTime.now().obs;
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  // Current editing items
  MealPlan? currentMealPlan;
  MealPlanAssignment? currentAssignment;

  // Enhanced meal creation flow properties
  final RxBool showDietTypeSelection = true.obs;
  final Rx<MealCategory?> selectedDietType = Rx<MealCategory?>(null);
  final RxMap<MealPeriod, String> selectedMealRecipes = <MealPeriod, String>{}
      .obs;

  // View mode toggle
  final RxBool viewByCategory = false.obs;

  @override
  void onInit() {
    super.onInit();
    _debugEnumValues(); // Debug enum values on init
    getMealPlans();
    getRecipes();
    getMealPlansByDate();
    selectedCalendarDate.listen((_) => getMealPlansByDate());
  }
  
  // Debug method to verify enum values
  void _debugEnumValues() {
    // Debug method removed to reduce console noise
  }

  @override
  void onClose() {
    super.onClose();
  }

  // Get all recipes
  Future<void> getRecipes() async {
    try {
      final response = await DioNetworkService.getData('api/Recipe', showLoader: false);
      
      // Handle the enhanced response structure
      final responseData = response['httpResponse']?['data'] ?? response['data'];
      
      if (responseData is List) {
        _safeStateUpdate(() {
          recipes.value = responseData.cast<dynamic>();
          if (responseData.isNotEmpty && selectedRecipeId.value.isEmpty) {
            final firstRecipe = responseData.first;
            if (firstRecipe is Map<String, dynamic>) {
              selectedRecipeId.value =
                  firstRecipe['recipeId']?.toString() ?? '';
            }
          }
        });
      } else if (responseData is Map && responseData['data'] is List) {
        final recipeList = (responseData['data'] as List).cast<dynamic>();
        _safeStateUpdate(() {
          recipes.value = recipeList;
          if (recipeList.isNotEmpty && selectedRecipeId.value.isEmpty) {
            final firstRecipe = recipeList.first;
            if (firstRecipe is Map<String, dynamic>) {
              selectedRecipeId.value =
                  firstRecipe['recipeId']?.toString() ?? '';
            }
          }
        });
      }
    } catch (e) {
      CustomDisplays.showInfoBar(
        message: 'Failed to load recipes. Please check your connection.',
        type: InfoBarType.networkError,
        actionText: 'Retry',
        onAction: () {
          CustomDisplays.dismissInfoBar();
          getRecipes();
        },
      );
    }
  }

  // Get all meal plans
  Future<void> getMealPlans() async {
    _safeStateUpdate(() {
      isLoading.value = true;
    });
    try {
      final response = await DioNetworkService.getData('api/MealPlan', showLoader: false);
      
      // Handle the enhanced response structure
      final responseData = response['httpResponse']?['data'] ?? response['data'];
      
      if (responseData is List) {
        _safeStateUpdate(() {
          mealPlans.value = responseData.where((json) => json is Map<String, dynamic>)
              .map((json) => MealPlan.fromJson(json as Map<String, dynamic>))
              .toList();
        });
      } else if (responseData is Map && responseData['data'] is List) {
        final dataList = responseData['data'] as List;
        _safeStateUpdate(() {
          mealPlans.value =
              dataList.where((json) => json is Map<String, dynamic>)
                  .map((json) =>
                  MealPlan.fromJson(json as Map<String, dynamic>))
                  .toList();
        });
      }
    } catch (e) {
      CustomDisplays.showInfoBar(
        message: 'Failed to load meal plans. Please check your connection.',
        type: InfoBarType.networkError,
        actionText: 'Retry',
        onAction: () {
          CustomDisplays.dismissInfoBar();
          getMealPlans();
        },
      );
    } finally {
      _safeStateUpdate(() {
        isLoading.value = false;
      });
    }
  }



  // Create meal plan
  Future<void> createMealPlan() async {
    if (!formKey.currentState!.validate()) return;

    // Validate that a recipe is selected
    if (selectedRecipeId.value.isEmpty) {
      CustomDisplays.showToast(
        message: 'Please select a recipe',
        type: MessageType.warning,
      );
      return;
    }

    final mealPlanData = {
      'recipeId': selectedRecipeId.value,
      'mealDate': selectedMealDate.value.toIso8601String(),
      'period': selectedPeriod.value.index,
      // Send as integer (0, 1, 2, 3)
      'category': selectedCategory.value.index,
      // Send as integer (0, 1, 2)
      'bmiCategory': selectedBmiCategory.value.index,
      // Send as integer (0, 1, 2, 3)
    };
    
    try {
      final response = await DioNetworkService.postData(mealPlanData, 'api/admin/AdminMealPlan', showLoader: false);
      
      // Check if the HTTP response was successful
      final httpStatus = response['httpResponse']?['status'] ?? 0;
      if (httpStatus == 200 || httpStatus == 201) {
        CustomDisplays.showToast(
          message: PlanConstants.mealPlanCreated,
          type: MessageType.success,
        );
        getMealPlansByDate();
        clearForm();
        getMealPlans();
        Get.back<void>();
      }
    } catch (e) {
      CustomDisplays.showToast(
        message: 'Failed to create meal plan',
        type: MessageType.error,
      );
    }
  }

  // Create meal plan assignment
  Future<void> createMealPlanAssignment() async {
    if (selectedRecipeId.value.isEmpty) {
      CustomDisplays.showToast(
        message: 'Please select a recipe',
        type: MessageType.warning,
      );
      return;
    }
    
    final assignment = MealPlanAssignment(
      recipeId: selectedRecipeId.value,
      mealDate: selectedMealDate.value,
      period: selectedPeriod.value,
      category: selectedCategory.value,
      bmiCategory: selectedBmiCategory.value,
    );
    
    try {
      final response = await DioNetworkService.postData(assignment.toJson(), 'api/admin/meal-plan-assignments', showLoader: false);
      
      // Check if the HTTP response was successful
      final httpStatus = response['httpResponse']?['status'] ?? 0;
      if (httpStatus == 200 || httpStatus == 201) {
        CustomDisplays.showToast(
          message: 'Meal plan assignment created successfully',
          type: MessageType.success,
        );
        clearAssignmentForm();
        Get.back<void>();
        getMealPlansByDate();
      }
    } catch (e) {
      CustomDisplays.showToast(
        message: 'Failed to create meal plan assignment',
        type: MessageType.error,
      );
    }
  }

  // Update meal plan assignment
  Future<void> updateMealPlanAssignment() async {
    if (selectedRecipeId.value.isEmpty || currentAssignment?.id == null) {
      CustomDisplays.showToast(
        message: 'Please select a recipe',
        type: MessageType.warning,
      );
      return;
    }
    
    final updatedData = {
      'recipeId': selectedRecipeId.value,
      'mealDate': selectedMealDate.value.toIso8601String(),
      'period': selectedPeriod.value.index,
      'category': selectedCategory.value.index,
      'bmiCategory': selectedBmiCategory.value.index,
    };
    
    try {
      final response = await DioNetworkService.putDataWithBody(updatedData, 'api/admin/AdminMealPlan/${currentAssignment!.id!}', showLoader: false);
      
      // Check if the HTTP response was successful
      final httpStatus = response['httpResponse']?['status'] ?? 0;
      if (httpStatus == 200) {
        CustomDisplays.showToast(
          message: 'Meal plan updated successfully',
          type: MessageType.success,
        );
        clearAssignmentForm();
        Get.back<void>();
        await getMealPlans();
        await getMealPlansByDate();
      }
    } catch (e) {
      CustomDisplays.showToast(
        message: 'Failed to update meal plan',
        type: MessageType.error,
      );
    }
  }


  

  // Update meal plan
  Future<void> updateMealPlan(String id, Map<String, dynamic> data) async {
    try {
      final response = await DioNetworkService.putDataWithBody(data, 'api/admin/AdminMealPlan/$id', showLoader: false);
      
      // Check if the HTTP response was successful
      final httpStatus = response['httpResponse']?['status'] ?? 0;
      if (httpStatus == 200) {
        CustomDisplays.showToast(
          message: PlanConstants.mealPlanUpdated,
          type: MessageType.success,
        );
        await getMealPlans();
        await getMealPlansByDate();
      }
    } catch (e) {
      CustomDisplays.showToast(
        message: 'Failed to update meal plan',
        type: MessageType.error,
      );
    }
  }

  // Update meal plan (original method for form-based updates)
  Future<void> updateMealPlanFromForm() async {
    if (!formKey.currentState!.validate() || currentMealPlan?.id == null) return;
    
    final mealPlan = MealPlan(
      id: currentMealPlan!.id,
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      price: double.tryParse(priceController.text.trim()),
      imageUrl: imageUrlController.text.trim().isEmpty ? null : imageUrlController.text.trim(),
      isActive: isActive.value,
    );
    
    try {
      final response = await DioNetworkService.putDataWithBody(mealPlan.toJson(), 'api/admin/AdminMealPlan/${currentMealPlan!.id!}', showLoader: false);
      
      // Check if the HTTP response was successful
      final httpStatus = response['httpResponse']?['status'] ?? 0;
      if (httpStatus == 200) {
        CustomDisplays.showToast(
          message: PlanConstants.mealPlanUpdated,
          type: MessageType.success,
        );
        clearForm();
        Get.back<void>();
        getMealPlans();
      }
    } catch (e) {
      CustomDisplays.showToast(
        message: 'Failed to update meal plan',
        type: MessageType.error,
      );
    }
  }

  // Delete meal plan
  Future<void> deleteMealPlan(String id) async {
    print('DELETE MEAL PLAN CALLED with ID: $id');
    try {
      print('Sending DELETE request to: api/admin/AdminMealPlan/$id');
      final response = await DioNetworkService.deleteData('api/admin/AdminMealPlan/$id', showLoader: false);

      print('Delete response: $response');

      // Check if the HTTP response was successful
      final httpStatus = response['httpResponse']?['status'] ?? 0;
      print('HTTP Status: $httpStatus');

      if (httpStatus == 200 || httpStatus == 204) {
        print('Delete successful, refreshing data...');
        CustomDisplays.showToast(
          message: PlanConstants.mealPlanDeleted,
          type: MessageType.success,
        );
        await getMealPlans();
        await getMealPlansByDate();
        print('Data refresh completed');
      } else {
        print('Delete failed - unexpected status code: $httpStatus');
        CustomDisplays.showToast(
          message: 'Delete failed: HTTP $httpStatus',
          type: MessageType.error,
        );
      }
    } catch (e) {
      print('Delete error: $e');
      CustomDisplays.showToast(
        message: 'Failed to delete meal plan: $e',
        type: MessageType.error,
      );
    }
  }

  // Prepare form for editing
  void prepareEditForm(MealPlan mealPlan) {
    currentMealPlan = mealPlan;
    nameController.text = mealPlan.name;
    descriptionController.text = mealPlan.description;
    priceController.text = mealPlan.price?.toString() ?? '';
    imageUrlController.text = mealPlan.imageUrl ?? '';
    _safeStateUpdate(() {
      isActive.value = mealPlan.isActive;
    });
  }

  // Prepare assignment form for editing
  void prepareEditAssignmentForm(MealPlan mealPlan) {
    // Find the assignment for this meal plan
    final assignment = mealPlanAssignments.firstWhere(
      (a) => a.id == mealPlan.id,
      orElse: () => MealPlanAssignment(
        recipeId: mealPlan.id ?? '',
        mealDate: selectedCalendarDate.value,
        period: MealPeriod.breakfast,
        category: MealCategory.vegetarian,
        bmiCategory: BmiCategory.normal,
      ),
    );
    
    currentAssignment = assignment;
    _safeStateUpdate(() {
      selectedRecipeId.value = assignment.recipeId;
      selectedMealDate.value = assignment.mealDate;
      selectedPeriod.value = assignment.period;
      selectedCategory.value = assignment.category;
      selectedBmiCategory.value = assignment.bmiCategory;
    });
  }

  void clearForm() {
    currentMealPlan = null;
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    imageUrlController.clear();
    _safeStateUpdate(() {
      isActive.value = true;
    });
    _resetEnhancedForm();
  }

  // Clear assignment form
  void clearAssignmentForm() {
    currentAssignment = null;
    _safeStateUpdate(() {
      selectedRecipeId.value = '';
      selectedMealDate.value = DateTime.now();
      selectedPeriod.value = MealPeriod.breakfast;
      selectedCategory.value = MealCategory.vegan;
      selectedBmiCategory.value = BmiCategory.normal;
    });
  }

  // Validation for assignment form
  String? validateRecipeSelection() {
    if (selectedRecipeId.value.isEmpty) {
      return 'Please select a recipe';
    }
    return null;
  }

  // Form validation
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    return null;
  }

  String? validatePrice(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final price = double.tryParse(value.trim());
      if (price == null || price < 0) {
        return PlanConstants.invalidPrice;
      }
    }
    return null;
  }

  // Get meal plans for selected date
  Future<void> getMealPlansByDate() async {
    final dateStr = '${selectedCalendarDate.value.year.toString().padLeft(4, '0')}-${selectedCalendarDate.value.month.toString().padLeft(2, '0')}-${selectedCalendarDate.value.day.toString().padLeft(2, '0')}';

    try {
      final response = await DioNetworkService.getData('api/MealPlan/date/$dateStr', showLoader: false);
      
      // Handle the enhanced response structure
      final responseData = response['httpResponse']?['data'] ?? response['data'];
      
      if (responseData is List) {
        // Debug logging for retrieved data
        debugPrint('📅 Retrieved meal plans for date $dateStr:');
        for (var json in responseData.take(3)) { // Show first 3 items
          if (json is Map<String, dynamic>) {
            debugPrint('  Raw data: $json');
            debugPrint('  Category value: ${json['category']} (type: ${json['category'].runtimeType})');
          }
        }
        
        _safeStateUpdate(() {
          mealPlanAssignments.value =
              responseData.where((json) => json is Map<String, dynamic>)
                  .map((json) =>
                  MealPlanAssignment.fromJson(json as Map<String, dynamic>))
                  .toList();
        });
                
        // Debug logging for parsed assignments
        debugPrint('📋 Parsed meal plan assignments:');
        for (var assignment in mealPlanAssignments.take(3)) { // Show first 3 items
          debugPrint('  Assignment category: ${assignment.category} (index: ${assignment.category.index})');
        }
      } else if (responseData is Map && responseData['data'] is List) {
        final dataList = responseData['data'] as List;
        _safeStateUpdate(() {
          mealPlanAssignments.value =
              dataList.where((json) => json is Map<String, dynamic>)
                  .map((json) =>
                  MealPlanAssignment.fromJson(json as Map<String, dynamic>))
                  .toList();
        });
      }

    } catch (e) {
      CustomDisplays.showInfoBar(
        message: 'Failed to load meal plans for selected date. Please check your connection.',
        type: InfoBarType.networkError,
        actionText: 'Retry',
        onAction: () {
          CustomDisplays.dismissInfoBar();
          getMealPlansByDate();
        },
      );
      debugPrint('Error fetching meal plans by date: $e');
    }
  }

  // Get meal plans organized by category for the selected date
  Map<MealCategory, List<MealPlan>> getMealPlansByCategory() {
    final categorizedMeals = <MealCategory, List<MealPlan>>{};
    final addedIds = <MealCategory, Set<String>>{};  // Track added assignment IDs per category
    
    // Initialize all categories with empty lists
    for (final category in MealCategory.values) {
      categorizedMeals[category] = [];
      addedIds[category] = <String>{};
    }
    
    // Group meal plan assignments by category
    for (final assignment in mealPlanAssignments) {
      // Skip if this assignment ID is already added to prevent duplicates
      if (assignment.id != null && addedIds[assignment.category]!.contains(assignment.id!)) {
        debugPrint('Skipping duplicate assignment ID: ${assignment.id} in category: ${assignment.category}');
        continue;
      }
      
      String recipeName = assignment.recipeName ?? '';
      String recipeDescription = assignment.recipeDescription ?? '';
      String? recipeImageUrl = assignment.recipeImageUrl;

      if (recipeName.isEmpty) {
        // Try to find recipe details from the recipes list
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

      // Create MealPlan from assignment data with food type mapping
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

  // Helper method to map MealCategory to FoodType
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

  // Get meal plans for specific period and selected date
  List<MealPlan> getMealPlansForPeriod(MealPeriod period) {

    for (var assignment in mealPlanAssignments) {
      debugPrint('Assignment - ID: ${assignment.id}, RecipeID: ${assignment
          .recipeId}, Period: ${assignment.period}, Date: ${assignment
          .mealDate}');
    }

    final assignments = mealPlanAssignments.where((assignment) {
      return assignment.period == period;
    }).toList();

    debugPrint('Filtered assignments for $period: ${assignments.length}');

    // Create MealPlan objects directly from assignments since the new API response includes recipe details
    List<MealPlan> result = [];
    final addedIds = <String>{};  // Track added assignment IDs to prevent duplicates
    
    for (var assignment in assignments) {
      print('Processing assignment with recipe: ${assignment.recipeName}');
      
      // Skip if this assignment ID is already added to prevent duplicates
      if (assignment.id != null && addedIds.contains(assignment.id!)) {
        print('Skipping duplicate assignment ID: ${assignment.id}');
        continue;
      }

      // If recipeName is null/empty, try to find it in the recipes list
      String recipeName = assignment.recipeName ?? '';
      String recipeDescription = assignment.recipeDescription ?? '';
      String? recipeImageUrl = assignment.recipeImageUrl;

      if (recipeName.isEmpty) {
        // Try to find recipe details from the recipes list
        try {
          final recipe = recipes.firstWhere(
                (r) =>
            r is Map<String, dynamic> && r['recipeId'] == assignment.recipeId,
            orElse: () => null,
          );
          if (recipe != null && recipe is Map<String, dynamic>) {
            recipeName = recipe['name']?.toString() ?? 'Unknown Recipe';
            recipeDescription =
                recipe['description']?.toString() ?? 'No description available';
            recipeImageUrl = recipe['imageUrl']?.toString();
          }
        } catch (e) {
          print('Error finding recipe details: $e');
        }
      }

      if (recipeName.isEmpty) {
        recipeName = 'Unknown Recipe';
      }
      if (recipeDescription.isEmpty) {
        recipeDescription = 'No description available';
      }

      // Create MealPlan from assignment data
      final mealPlan = MealPlan(
        id: assignment.id,
        name: recipeName,
        description: recipeDescription,
        imageUrl: recipeImageUrl,
        isActive: true, // Default to active
      );

      result.add(mealPlan);
      if (assignment.id != null) {
        addedIds.add(assignment.id!);
      }
      print('Added meal plan: ${mealPlan.name}');
    }

    print('Final result count: ${result.length}');
    print('=== END DEBUG ===');
    return result;
  }

  // Get meal plan details by ID
  Future<void> getMealPlanDetails(String recipeId) async {
    if (recipeId.isEmpty) {
      CustomDisplays.showToast(
        message: 'No meal plan ID provided',
        type: MessageType.warning,
      );
      return;
    }

    try {
      print('Fetching meal plan details for ID: $recipeId');
      final response = await DioNetworkService.getData(
          'api/MealPlan/$recipeId', showLoader: false);

      // Handle the enhanced response structure - the API response has success/data structure
      final responseData = response['data'] ?? response;
      print('Response data: $responseData');

      // Extract the actual meal plan data from the nested structure
      dynamic mealPlanData;
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          mealPlanData = responseData['data'];
        } else {
          mealPlanData = responseData;
        }
      } else {
        mealPlanData = responseData;
      }

      if (mealPlanData != null) {
        _showMealPlanDetails(mealPlanData);
      } else {
        // Instead of showing snackbar for "no meal plan details found", let the UI handle empty state
        // CustomDisplays.showSnackBar(message: 'No meal plan details found');
      }
    } catch (e) {
      print('Error fetching meal plan details: $e');
      CustomDisplays.showToast(
        message: 'Failed to load meal plan details: ${e.toString()}',
        type: MessageType.error,
      );
    }
  }

  // Show meal plan details dialog
  void _showMealPlanDetails(dynamic data) {
    final mealPlan = data is Map<String, dynamic> ? data : <String, dynamic>{};

    // Helper function to format period
    String formatPeriod(dynamic period) {
      if (period is int) {
        switch (period) {
          case 0:
            return 'Breakfast';
          case 1:
            return 'Lunch';
          case 2:
            return 'Dinner';
          case 3:
            return 'Snack';
          default:
            return 'Unknown';
        }
      }
      return period?.toString() ?? 'Unknown';
    }

    // Helper function to format category
    String formatCategory(dynamic category) {
      if (category is int) {
        switch (category) {
          case 0:
            return 'Vegan';
          case 1:
            return 'Vegetarian';
          case 2:
            return 'Eggitarian';
          case 3:
            return 'Non-Vegetarian';
          case 4:
            return 'Other';
          default:
            return 'Unknown';
        }
      }
      return category?.toString() ?? 'Unknown';
    }

    // Helper function to format BMI category
    String formatBmiCategory(dynamic bmiCategory) {
      if (bmiCategory is int) {
        switch (bmiCategory) {
          case 0:
            return 'Underweight';
          case 1:
            return 'Normal';
          case 2:
            return 'Overweight';
          case 3:
            return 'Obese';
          default:
            return 'Unknown';
        }
      }
      return bmiCategory?.toString() ?? 'Unknown';
    }

    // Format date
    String formatDate(dynamic dateString) {
      if (dateString == null) return 'N/A';
      try {
        final date = DateTime.parse(dateString.toString());
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return '${months[date.month - 1]} ${date.day}, ${date.year}';
      } catch (e) {
        return dateString
            .toString()
            .split('T')
            .first;
      }
    }

    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          width: 500,
          constraints: const BoxConstraints(maxHeight: 600),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      color: Get.theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppText.h4(
                        'Meal Plan Details',
                        color: Get.theme.colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back<void>(),
                      icon: Icon(
                        Icons.close,
                        color: Get.theme.colorScheme.onSurface.withValues(
                            alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Recipe Image
                if (mealPlan['recipeImageUrl'] != null &&
                    mealPlan['recipeImageUrl']
                        .toString()
                        .isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(
                            mealPlan['recipeImageUrl'].toString()),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                // Recipe Name
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.restaurant,
                        color: Get.theme.colorScheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppText.h6(
                          mealPlan['recipeName']?.toString() ??
                              'Unknown Recipe',
                          color: Get.theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                if (mealPlan['recipeDescription'] != null &&
                    mealPlan['recipeDescription']
                        .toString()
                        .isNotEmpty) ...[
                  AppText.medium('Description',
                      color: Get.theme.colorScheme.onSurface.withValues(
                          alpha: 0.8)),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppText.body1(
                      mealPlan['recipeDescription']?.toString() ?? '',
                      color: Get.theme.colorScheme.onSurface.withValues(
                          alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Meal Details Grid
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Get.theme.colorScheme.onSurface.withValues(
                          alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(Icons.calendar_today, 'Meal Date',
                          formatDate(mealPlan['mealDate'])),
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.access_time, 'Period',
                          formatPeriod(mealPlan['period'])),
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.category, 'Category',
                          formatCategory(mealPlan['category'])),
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.fitness_center, 'BMI Category',
                          formatBmiCategory(mealPlan['bmiCategory'])),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back<void>(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: Get.theme.colorScheme.onSurface.withValues(
                              alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build detail rows
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Get.theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        AppText.medium(
          '$label: ',
          color: Get.theme.colorScheme.onSurface.withValues(alpha: 0.8),
        ),
        Expanded(
          child: AppText.medium(
            value,
            color: Get.theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // Helper method for safe state updates to prevent build-time errors
  void _safeStateUpdate(VoidCallback updateCallback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateCallback();
    });
  }

  // Update selected date with safe state updates
  void updateSelectedDate(DateTime date) {
    _safeStateUpdate(() {
      selectedCalendarDate.value = date;
      focusedDay.value = date;
    });
  }

  // Enhanced meal creation flow methods
  void proceedToMealSelection() {
    showDietTypeSelection.value = false;
    selectedCategory.value = selectedDietType.value ?? MealCategory.vegan;
    // Set selected date for meals to the calendar selected date
    selectedMealDate.value = selectedCalendarDate.value;
    
    // Debug logging
    debugPrint('📍 proceedToMealSelection:');
    debugPrint('  selectedDietType.value: ${selectedDietType.value}');
    debugPrint('  selectedDietType.value?.index: ${selectedDietType.value?.index}');
    debugPrint('  selectedCategory.value: ${selectedCategory.value}');
    debugPrint('  selectedCategory.value.index: ${selectedCategory.value.index}');
  }

  List<dynamic> getFilteredRecipes() {
    // Performance optimization: Return cached results if category hasn't changed
    if (selectedDietType.value == _lastFilteredCategory && _filteredRecipesCache.isNotEmpty) {
      return _filteredRecipesCache;
    }
    
    if (selectedDietType.value == null) {
      // Use safe state update to prevent build-time errors
      _safeStateUpdate(() {
        _filteredRecipesCache.value = recipes;
        _lastFilteredCategory = null;
      });
      return recipes;
    }

    // Filter recipes based on selected diet type
    final filtered = recipes.where((recipe) {
      if (recipe is Map<String, dynamic>) {
        final recipeCategory = recipe['category'];
        if (recipeCategory is int) {
          return MealCategory.values[recipeCategory] == selectedDietType.value;
        }
      }
      return true; // Show all if filtering fails
    }).toList();
    
    // Cache the filtered results using safe state update
    _safeStateUpdate(() {
      _filteredRecipesCache.value = filtered;
      _lastFilteredCategory = selectedDietType.value;
    });
    
    return filtered;
  }

  String getSelectedRecipeForPeriod(MealPeriod period) {
    return selectedMealRecipes[period] ?? '';
  }

  void setSelectedRecipeForPeriod(MealPeriod period, String recipeId) {
    if (recipeId.isEmpty) {
      selectedMealRecipes.remove(period);
    } else {
      selectedMealRecipes[period] = recipeId;
    }
  }

  // Multi-selection methods for meal periods
  List<String> getSelectedRecipeIdsForPeriod(MealPeriod period) {
    return selectedMealRecipeIds[period] ?? [];
  }

  void setSelectedRecipeIdsForPeriod(MealPeriod period, List<String> recipeIds) {
    if (recipeIds.isEmpty) {
      selectedMealRecipeIds.remove(period);
    } else {
      // Remove duplicates by converting to Set and back to List
      final uniqueRecipeIds = recipeIds.toSet().toList();
      selectedMealRecipeIds[period] = uniqueRecipeIds;
    }
  }

  void addRecipeToMealPeriod(MealPeriod period, String recipeId) {
    if (recipeId.isEmpty) return;
    
    if (!selectedMealRecipeIds.containsKey(period)) {
      selectedMealRecipeIds[period] = [];
    }
    
    if (!selectedMealRecipeIds[period]!.contains(recipeId)) {
      selectedMealRecipeIds[period]!.add(recipeId);
      selectedMealRecipeIds.refresh(); // Trigger reactivity
    }
  }

  void removeRecipeFromMealPeriod(MealPeriod period, String recipeId) {
    if (selectedMealRecipeIds.containsKey(period)) {
      selectedMealRecipeIds[period]!.remove(recipeId);
      if (selectedMealRecipeIds[period]!.isEmpty) {
        selectedMealRecipeIds.remove(period);
      }
      selectedMealRecipeIds.refresh(); // Trigger reactivity
    }
  }

  bool hasSelectedMultipleMeals() {
    return selectedMealRecipeIds.values.any((recipes) => recipes.isNotEmpty);
  }

  bool hasSelectedMeals() {
    return selectedMealRecipes.isNotEmpty;
  }

  // Multiple meal selection methods
  void toggleMultiSelection() {
    _safeStateUpdate(() {
      showMultiSelection.value = !showMultiSelection.value;
      if (!showMultiSelection.value) {
        clearMultiSelection();
      }
    });
  }

  void toggleRecipeSelection(String recipeId) {
    if (selectedRecipeIds.contains(recipeId)) {
      selectedRecipeIds.remove(recipeId);
    } else {
      selectedRecipeIds.add(recipeId);
    }
    _safeStateUpdate(() {
      selectedMealCount.value = selectedRecipeIds.length;
    });
  }

  bool isRecipeSelected(String recipeId) {
    return selectedRecipeIds.contains(recipeId);
  }

  void clearMultiSelection() {
    selectedRecipeIds.clear();
    _safeStateUpdate(() {
      selectedMealCount.value = 0;
    });
  }

  // Create multiple meal plans at once
  Future<void> createMultipleMealPlans() async {
    if (selectedRecipeIds.isEmpty) {
      CustomDisplays.showToast(
        message: 'Please select at least one recipe',
        type: MessageType.warning,
      );
      return;
    }

    _safeStateUpdate(() {
      isLoading.value = true;
    });
    int successCount = 0;
    int failureCount = 0;

    try {
      for (final recipeId in selectedRecipeIds) {
        final mealPlanData = {
          'recipeId': recipeId,
          'mealDate': selectedMealDate.value.toIso8601String(),
          'period': selectedPeriod.value.index,
          'category': selectedCategory.value.index,
          'bmiCategory': selectedBmiCategory.value.index,
        };

        try {
          final response = await DioNetworkService.postData(
            mealPlanData, 
            'api/admin/AdminMealPlan', 
            showLoader: false
          );
          
          final httpStatus = response['httpResponse']?['status'] ?? 0;
          if (httpStatus == 200 || httpStatus == 201) {
            successCount++;
          } else {
            failureCount++;
          }
        } catch (e) {
          failureCount++;
          debugPrint('Error creating meal plan for recipe $recipeId: $e');
        }
      }

      // Show results
      if (successCount > 0) {
        CustomDisplays.showToast(
          message: successCount == selectedRecipeIds.length 
            ? 'All $successCount meal plans created successfully!'
            : '$successCount of ${selectedRecipeIds.length} meal plans created successfully',
          type: MessageType.success,
        );
        
        getMealPlansByDate();
        getMealPlans();
        clearMultiSelection();
        _safeStateUpdate(() {
          showMultiSelection.value = false;
        });
        Get.back<void>();
      }

      if (failureCount > 0) {
        CustomDisplays.showToast(
          message: 'Failed to create $failureCount meal plan(s)',
          type: MessageType.error,
        );
      }
    } catch (e) {
      CustomDisplays.showToast(
        message: 'Failed to create meal plans: ${e.toString()}',
        type: MessageType.error,
      );
      debugPrint('Error creating multiple meal plans: $e');
    } finally {
      // Always hide loading state
      _safeStateUpdate(() {
        isLoading.value = false;
      });
    }
  }

  // Get selected recipe details for confirmation
  List<Map<String, dynamic>> getSelectedRecipeDetails() {
    return selectedRecipeIds.map((recipeId) {
      final recipe = recipes.firstWhere(
        (r) => r['recipeId']?.toString() == recipeId,
        orElse: () => null,
      );
      return recipe as Map<String, dynamic>? ?? {};
    }).where((recipe) => recipe.isNotEmpty).toList();
  }
  
  // Debug method to check current category selection state
  void debugCurrentState() {
    debugPrint('🔍 Current Category Selection State:');
    debugPrint('  selectedDietType.value: ${selectedDietType.value}');
    debugPrint('  selectedDietType.value?.index: ${selectedDietType.value?.index}');
    debugPrint('  selectedCategory.value: ${selectedCategory.value}');
    debugPrint('  selectedCategory.value.index: ${selectedCategory.value.index}');
    debugPrint('  showDietTypeSelection.value: ${showDietTypeSelection.value}');
  }
  
  // Clear all caches to ensure fresh data
  void clearCaches() {
    _filteredRecipesCache.clear();
    _lastFilteredCategory = null;
    debugPrint('🧹 Caches cleared for fresh data refresh');
  }

  Future<void> createEnhancedMealPlans() async {
    // Check if we have multi-selections or single selections
    bool hasMultiSelections = hasSelectedMultipleMeals();
    bool hasSingleSelections = selectedMealRecipes.isNotEmpty;
    
    if (selectedDietType.value == null || (!hasMultiSelections && !hasSingleSelections)) {
      CustomDisplays.showToast(
        message: 'Please select at least one meal',
        type: MessageType.warning,
      );
      return;
    }

    // Show loading state
    isLoading.value = true;

    try {
      List<Future<dynamic>> createRequests = [];
      int totalMealCount = 0;

      // Handle multi-selections (preferred method)
      if (hasMultiSelections) {
        for (var entry in selectedMealRecipeIds.entries) {
          final period = entry.key;
          final recipeIds = entry.value;
          
          for (final recipeId in recipeIds) {
            final mealPlanData = {
              'recipeId': recipeId,
              'mealDate': selectedMealDate.value.toIso8601String(),
              'period': period.index,
              'category': selectedDietType.value!.index,
              'bmiCategory': selectedBmiCategory.value.index,
            };

            createRequests.add(
                DioNetworkService.postData(mealPlanData, 'api/admin/AdminMealPlan', showLoader: false)
            );
            totalMealCount++;
          }
        }
      } 
      // Handle single selections (fallback for existing functionality)
      else if (hasSingleSelections) {
        for (var entry in selectedMealRecipes.entries) {
          final mealPlanData = {
            'recipeId': entry.value,
            'mealDate': selectedMealDate.value.toIso8601String(),
            'period': entry.key.index,
            'category': selectedDietType.value!.index,
            'bmiCategory': selectedBmiCategory.value.index,
          };

          createRequests.add(
              DioNetworkService.postData(mealPlanData, 'api/admin/AdminMealPlan', showLoader: false)
          );
          totalMealCount++;
        }
      }

      // Debug logging
      debugPrint('🍽️ Creating $totalMealCount meal plans');
      debugPrint('Selected diet type: ${selectedDietType.value} (index: ${selectedDietType.value!.index})');

      // Execute all requests
      final responses = await Future.wait(createRequests);

      // Check if all were successful
      bool allSuccessful = responses.every((response) {
        final httpStatus = response['httpResponse']?['status'] ?? 0;
        return httpStatus == 200 || httpStatus == 201;
      });

      if (allSuccessful) {
        // Clear any cached data first to ensure fresh data
        _filteredRecipesCache.clear();
        _lastFilteredCategory = null;
        
        // Refresh data in the correct order
        await getMealPlans();
        await getMealPlansByDate();

        // Reset form and close current dialog
        _resetEnhancedForm();
        if (Get.isDialogOpen ?? false) {
          Get.back<void>();
        }

        // Show success confirmation dialog with Continue/Exit options
        final mealText = totalMealCount == 1 ? 'meal' : 'meals';
        _showMealCreationSuccessDialog(totalMealCount, mealText);
      } else {
        // Handle partial failures
        final successCount = responses.where((response) {
          final httpStatus = response['httpResponse']?['status'] ?? 0;
          return httpStatus == 200 || httpStatus == 201;
        }).length;

        final totalCount = responses.length;

        if (successCount > 0) {
          CustomDisplays.showToast(
            message: '$successCount of $totalCount meal plans created successfully',
            type: MessageType.success,
          );
          // Refresh data even with partial success
          await getMealPlansByDate();
          await getMealPlans();
        } else {
          CustomDisplays.showToast(
            message: 'Failed to create any meal plans. Please try again.',
            type: MessageType.error,
          );
        }
      }
    } catch (e) {
      CustomDisplays.showToast(
        message: 'Failed to create meal plans: ${e.toString()}',
        type: MessageType.error,
      );
      debugPrint('Error creating multiple meal plans: $e');
    } finally {
      // Always hide loading state
      isLoading.value = false;
    }
  }

  void _resetEnhancedForm() {
    _safeStateUpdate(() {
      showDietTypeSelection.value = true;
      selectedDietType.value = null;
      selectedMealRecipes.clear();
      selectedMealRecipeIds.clear();
      selectedBmiCategory.value = BmiCategory.normal;
      // Clear cache when resetting form
      _filteredRecipesCache.clear();
      _lastFilteredCategory = null;
    });
  }

  // Delete all meal plans for a specific date
  Future<void> deleteAllMealPlansForDate(DateTime date) async {
    // Get all meal plan assignments for the date
    final assignments = mealPlanAssignments.where((assignment) =>
    assignment.mealDate.year == date.year &&
        assignment.mealDate.month == date.month &&
        assignment.mealDate.day == date.day
    ).toList();

    if (assignments.isEmpty) {
      // Replace "No meals found for this date" with proper empty state handling in UI
      // Don't show snackbar for empty data - let the UI handle this with EmptyStateWidget
      return;
    }

    try {
      // Create list of delete requests
      List<Future<dynamic>> deleteRequests = [];

      for (var assignment in assignments) {
        if (assignment.id != null) {
          deleteRequests.add(DioNetworkService.deleteData(
              'api/admin/AdminMealPlan/${assignment.id}'));
        }
      }

      // Execute all delete requests
      final responses = await Future.wait(deleteRequests);

      // Check if all were successful
      bool allSuccessful = responses.every((response) {
        final httpStatus = response['httpResponse']?['status'] ?? 0;
        return httpStatus == 200 || httpStatus == 204;
      });

      if (allSuccessful) {
        CustomDisplays.showToast(
          message: 'All meals deleted for ${_formatDate(date)}',
          type: MessageType.success,
        );
        await getMealPlans();
        await getMealPlansByDate();
      } else {
        final successCount = responses.where((response) {
          final httpStatus = response['httpResponse']?['status'] ?? 0;
          return httpStatus == 200 || httpStatus == 204;
        }).length;

        CustomDisplays.showToast(
          message: '$successCount of ${assignments.length} meals deleted',
          type: MessageType.warning,
        );
        await getMealPlans();
        await getMealPlansByDate();
      }
    } catch (e) {
      CustomDisplays.showToast(
        message: 'Failed to delete meals: $e',
        type: MessageType.error,
      );
      debugPrint('Error deleting all meal plans for date: $e');
    }
  }

  // Helper method to format date - moved from view to controller
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Show success confirmation dialog with Continue/Exit options
  void _showMealCreationSuccessDialog(int mealCount, String mealText) {
    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Get.theme.colorScheme.surface,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(
                opacity: value,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Success Icon with animation
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 600),
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        builder: (context, iconValue, child) {
                          return Transform.scale(
                            scale: iconValue,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_circle_outline,
                                size: 48 * iconValue,
                                color: Colors.green,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Success Title
                      AppText.h4(
                        'Meal Successfully Added!',
                        color: Get.theme.colorScheme.onSurface,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      
                      // Success Message
                      AppText.body1(
                        '$mealCount $mealText successfully added to your meal plan for ${_formatDate(selectedCalendarDate.value)}.',
                        color: Get.theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      
                      // Encouraging subtitle
                      AppText.caption(
                        'Your healthy eating journey continues! 🌟',
                        color: Get.theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Get.back<void>(); // Close confirmation dialog
                                // Auto-switch to category view to show the newly added meals
                                viewByCategory.value = true;
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: Get.theme.colorScheme.outline.withValues(alpha: 0.5),
                                ),
                              ),
                              icon: const Icon(Icons.close, size: 20),
                              label: AppText.medium(
                                'Close',
                                color: Get.theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                Get.back<void>(); // Close confirmation dialog
                                clearForm(); // Clear the form
                                Get.dialog<void>(const MealPlanFormDialog()); // Open new meal plan dialog
                              },
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.add, size: 20),
                              label: AppText.medium(
                                'Add More',
                                color: Get.theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      barrierDismissible: true,
    );
  }
}