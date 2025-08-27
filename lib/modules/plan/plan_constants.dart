class PlanConstants {
  // Screen titles
  static const String mealPlans = 'Meal Plans';
  static const String createMealPlan = 'Create Meal Plan';
  static const String editMealPlan = 'Edit Meal Plan';
  static const String deleteMealPlan = 'Delete Meal Plan';
  
  // Form labels
  static const String name = 'Name';
  static const String description = 'Description';
  static const String price = 'Price';
  static const String imageUrl = 'Image URL';
  static const String isActive = 'Active';
  
  // Placeholders
  static const String enterName = 'Enter meal plan name';
  static const String enterDescription = 'Enter description';
  static const String enterPrice = 'Enter price';
  static const String enterImageUrl = 'Enter image URL (optional)';
  
  // Buttons
  static const String create = 'Create';
  static const String update = 'Update';
  static const String delete = 'Delete';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String edit = 'Edit';
  
  // Messages
  static const String noMealPlans = 'No meal plans found';
  static const String confirmDelete = 'Are you sure you want to delete this meal plan?';
  static const String deleteWarning = 'This action cannot be undone.';
  static const String mealPlanCreated = 'Meal plan created successfully';
  static const String mealPlanUpdated = 'Meal plan updated successfully';
  static const String mealPlanDeleted = 'Meal plan deleted successfully';
  static const String fillRequiredFields = 'Please fill all required fields';
  static const String invalidPrice = 'Please enter a valid price';
  
  // Status
  static const String active = 'Active';
  static const String inactive = 'Inactive';

  // Dietary Preferences Constants
  static const int vegan = 0;
  static const int vegetarian = 1;
  static const int eggitarian = 2;
  static const int nonVegetarian = 3;
  static const int other = 4;

  // Dietary Preference Labels
  static const String veganLabel = 'Vegan';
  static const String vegetarianLabel = 'Vegetarian';
  static const String eggitarianLabel = 'Eggitarian';
  static const String nonVegetarianLabel = 'Non-Vegetarian';
  static const String otherLabel = 'Other';
}