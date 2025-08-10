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
  final Rx<MealCategory> selectedCategory = MealCategory.vegetarian.obs;
  final Rx<BmiCategory> selectedBmiCategory = BmiCategory.normal.obs;
  
  // Calendar functionality
  final Rx<DateTime> selectedCalendarDate = DateTime.now().obs;
  final Rx<DateTime> focusedDay = DateTime.now().obs;
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  // Current editing items
  MealPlan? currentMealPlan;
  MealPlanAssignment? currentAssignment;

  @override
  void onInit() {
    super.onInit();
    getMealPlans();
    getRecipes();
    getMealPlansByDate();
    selectedCalendarDate.listen((_) => getMealPlansByDate());
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
        recipes.value = responseData.cast<dynamic>();
        if (responseData.isNotEmpty && selectedRecipeId.value.isEmpty) {
          final firstRecipe = responseData.first;
          if (firstRecipe is Map<String, dynamic>) {
            selectedRecipeId.value =
                firstRecipe['recipeId']?.toString() ?? '';
          }
        }
      } else if (responseData is Map && responseData['data'] is List) {
        final recipeList = (responseData['data'] as List).cast<dynamic>();
        recipes.value = recipeList;
        if (recipeList.isNotEmpty && selectedRecipeId.value.isEmpty) {
          final firstRecipe = recipeList.first;
          if (firstRecipe is Map<String, dynamic>) {
            selectedRecipeId.value =
                firstRecipe['recipeId']?.toString() ?? '';
          }
        }
      }
    } catch (e) {
      CustomDisplays.showSnackBar(message: 'Failed to load recipes');
      debugPrint('Error fetching recipes: $e');
    }
  }

  // Get all meal plans
  Future<void> getMealPlans() async {
    isLoading.value = true;
    try {
      final response = await DioNetworkService.getData('api/MealPlan', showLoader: false);
      
      // Handle the enhanced response structure
      final responseData = response['httpResponse']?['data'] ?? response['data'];
      
      if (responseData is List) {
        mealPlans.value = responseData.where((json) => json is Map<String, dynamic>)
            .map((json) => MealPlan.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (responseData is Map && responseData['data'] is List) {
        final dataList = responseData['data'] as List;
        mealPlans.value =
            dataList.where((json) => json is Map<String, dynamic>)
                .map((json) =>
                MealPlan.fromJson(json as Map<String, dynamic>))
                .toList();
      }
    } catch (e) {
      CustomDisplays.showSnackBar(message: 'Failed to load meal plans');
      debugPrint('Error fetching meal plans: $e');
    } finally {
      isLoading.value = false;
    }
  }



  // Create meal plan
  Future<void> createMealPlan() async {
    if (!formKey.currentState!.validate()) return;

    // Validate that a recipe is selected
    if (selectedRecipeId.value.isEmpty) {
      CustomDisplays.showSnackBar(message: 'Please select a recipe');
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
      final response = await DioNetworkService.postData(mealPlanData, 'api/admin/AdminMealPlan');
      
      // Check if the HTTP response was successful
      final httpStatus = response['httpResponse']?['status'] ?? 0;
      if (httpStatus == 200 || httpStatus == 201) {
        CustomDisplays.showSnackBar(message: PlanConstants.mealPlanCreated);
        getMealPlansByDate();
        clearForm();
        getMealPlans();
        Get.back<void>();
      }
    } catch (e) {
      CustomDisplays.showSnackBar(message: 'Failed to create meal plan');
      debugPrint('Error creating meal plan: $e');
    }
  }

  // Create meal plan assignment
  Future<void> createMealPlanAssignment() async {
    if (selectedRecipeId.value.isEmpty) {
      CustomDisplays.showSnackBar(message: 'Please select a recipe');
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
      final response = await DioNetworkService.postData(assignment.toJson(), 'api/admin/meal-plan-assignments');
      
      // Check if the HTTP response was successful
      final httpStatus = response['httpResponse']?['status'] ?? 0;
      if (httpStatus == 200 || httpStatus == 201) {
        CustomDisplays.showSnackBar(message: 'Meal plan assignment created successfully');
        clearAssignmentForm();
        Get.back<void>();
        getMealPlansByDate();
      }
    } catch (e) {
      CustomDisplays.showSnackBar(message: 'Failed to create meal plan assignment');
      debugPrint('Error creating meal plan assignment: $e');
    }
  }

  // Update meal plan assignment
  Future<void> updateMealPlanAssignment() async {
    if (selectedRecipeId.value.isEmpty || currentAssignment?.id == null) {
      CustomDisplays.showSnackBar(message: 'Please select a recipe');
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
      final response = await DioNetworkService.putDataWithBody(updatedData, 'api/admin/AdminMealPlan/${currentAssignment!.id!}');
      
      // Check if the HTTP response was successful
      final httpStatus = response['httpResponse']?['status'] ?? 0;
      if (httpStatus == 200) {
        CustomDisplays.showSnackBar(message: 'Meal plan updated successfully');
        clearAssignmentForm();
        Get.back<void>();
        await getMealPlans();
        await getMealPlansByDate();
      }
    } catch (e) {
      CustomDisplays.showSnackBar(message: 'Failed to update meal plan');
      debugPrint('Error updating meal plan assignment: $e');
    }
  }


  

  // Update meal plan
  Future<void> updateMealPlan(String id, Map<String, dynamic> data) async {
    try {
      final response = await DioNetworkService.putDataWithBody(data, 'api/admin/AdminMealPlan/$id');
      
      // Check if the HTTP response was successful
      final httpStatus = response['httpResponse']?['status'] ?? 0;
      if (httpStatus == 200) {
        CustomDisplays.showSnackBar(message: PlanConstants.mealPlanUpdated);
        await getMealPlans();
        await getMealPlansByDate();
      }
    } catch (e) {
      CustomDisplays.showSnackBar(message: 'Failed to update meal plan');
      debugPrint('Error updating meal plan: $e');
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
      final response = await DioNetworkService.putDataWithBody(mealPlan.toJson(), 'api/admin/AdminMealPlan/${currentMealPlan!.id!}');
      
      // Check if the HTTP response was successful
      final httpStatus = response['httpResponse']?['status'] ?? 0;
      if (httpStatus == 200) {
        CustomDisplays.showSnackBar(message: PlanConstants.mealPlanUpdated);
        clearForm();
        Get.back<void>();
        getMealPlans();
      }
    } catch (e) {
      CustomDisplays.showSnackBar(message: 'Failed to update meal plan');
      debugPrint('Error updating meal plan from form: $e');
    }
  }

  // Delete meal plan
  Future<void> deleteMealPlan(String id) async {
    try {
      final response = await DioNetworkService.deleteData('api/admin/AdminMealPlan/$id');
      
      // Check if the HTTP response was successful
      final httpStatus = response['httpResponse']?['status'] ?? 0;
      if (httpStatus == 200 || httpStatus == 204) {
        CustomDisplays.showSnackBar(message: PlanConstants.mealPlanDeleted);
        await getMealPlans();
        await getMealPlansByDate();
      }
    } catch (e) {
      CustomDisplays.showSnackBar(message: 'Failed to delete meal plan');
      debugPrint('Error deleting meal plan: $e');
    }
  }

  // Prepare form for editing
  void prepareEditForm(MealPlan mealPlan) {
    currentMealPlan = mealPlan;
    nameController.text = mealPlan.name;
    descriptionController.text = mealPlan.description;
    priceController.text = mealPlan.price?.toString() ?? '';
    imageUrlController.text = mealPlan.imageUrl ?? '';
    isActive.value = mealPlan.isActive;
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
    selectedRecipeId.value = assignment.recipeId;
    selectedMealDate.value = assignment.mealDate;
    selectedPeriod.value = assignment.period;
    selectedCategory.value = assignment.category;
    selectedBmiCategory.value = assignment.bmiCategory;
  }

  // Clear form
  void clearForm() {
    currentMealPlan = null;
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    imageUrlController.clear();
    isActive.value = true;
  }



  // Clear assignment form
  void clearAssignmentForm() {
    currentAssignment = null;
    selectedRecipeId.value = '';
    selectedMealDate.value = DateTime.now();
    selectedPeriod.value = MealPeriod.breakfast;
    selectedCategory.value = MealCategory.vegetarian;
    selectedBmiCategory.value = BmiCategory.normal;
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
        mealPlanAssignments.value =
            responseData.where((json) => json is Map<String, dynamic>)
                .map((json) =>
                MealPlanAssignment.fromJson(json as Map<String, dynamic>))
                .toList();
      } else if (responseData is Map && responseData['data'] is List) {
        final dataList = responseData['data'] as List;
        mealPlanAssignments.value =
            dataList.where((json) => json is Map<String, dynamic>)
                .map((json) =>
                MealPlanAssignment.fromJson(json as Map<String, dynamic>))
                .toList();
      }

    } catch (e) {
      CustomDisplays.showSnackBar(message: 'Failed to load meal plans for selected date');
      debugPrint('Error fetching meal plans by date: $e');
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
    for (var assignment in assignments) {
      print('Processing assignment with recipe: ${assignment.recipeName}');

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
      print('Added meal plan: ${mealPlan.name}');
    }

    print('Final result count: ${result.length}');
    print('=== END DEBUG ===');
    return result;
  }

  // Get meal plan details by ID
  Future<void> getMealPlanDetails(String recipeId) async {
    if (recipeId.isEmpty) {
      CustomDisplays.showSnackBar(message: 'No meal plan ID provided');
      return;
    }

    try {
      print('Fetching meal plan details for ID: $recipeId');
      final response = await DioNetworkService.getData('api/MealPlan/$recipeId', showLoader: true);

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
        CustomDisplays.showSnackBar(message: 'No meal plan details found');
      }
    } catch (e) {
      print('Error fetching meal plan details: $e');
      CustomDisplays.showSnackBar(
          message: 'Failed to load meal plan details: ${e.toString()}');
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
            return 'Non-Vegetarian';
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

  // Update selected calendar date
  void updateSelectedDate(DateTime date) {
    selectedCalendarDate.value = date;
    focusedDay.value = date;
  }
}