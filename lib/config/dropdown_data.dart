class DropdownDataManager {
  // Dietary Categories
  static const List<DropdownItem> dietaryCategories = [
    DropdownItem(
      value: 0,
      label: 'Regular',
      description: 'Standard dietary preference',
      icon: '🍽️',
    ),
    DropdownItem(
      value: 1,
      label: 'Vegetarian',
      description: 'Plant-based with dairy',
      icon: '🥗',
    ),
    DropdownItem(
      value: 2,
      label: 'Eggitarian',
      description: 'Plant-based with dairy and eggs',
      icon: '🥚',
    ),
    DropdownItem(
      value: 3,
      label: 'Non-Vegetarian',
      description: 'Includes meat, poultry, and seafood',
      icon: '🍖',
    ),
    DropdownItem(
      value: 4,
      label: 'Other',
      description: 'Other dietary preferences',
      icon: '🍽️',
    ),
  ];

  // BMI Categories
  static const List<DropdownItem> bmiCategories = [
    DropdownItem(
      value: 'underweight',
      label: 'Underweight',
      description: 'BMI < 18.5',
      icon: '📉',
    ),
    DropdownItem(
      value: 'normal',
      label: 'Normal',
      description: 'BMI 18.5 - 24.9',
      icon: '📊',
    ),
    DropdownItem(
      value: 'overweight',
      label: 'Overweight',
      description: 'BMI 25 - 29.9',
      icon: '📈',
    ),
    DropdownItem(
      value: 'obese',
      label: 'Obese',
      description: 'BMI ≥ 30',
      icon: '🔴',
    ),
  ];

  // Meal Categories
  static const List<DropdownItem> mealCategories = [
    DropdownItem(
      value: 'vegan',
      label: 'Vegan',
      description: 'Completely plant-based meals',
      icon: '🌱',
    ),
    DropdownItem(
      value: 'vegetarian',
      label: 'Vegetarian',
      description: 'Plant-based with dairy and eggs',
      icon: '🥗',
    ),
    DropdownItem(
      value: 'eggitarian',
      label: 'Eggitarian',
      description: 'Plant-based with dairy and eggs meals',
      icon: '🥚',
    ),
    DropdownItem(
      value: 'nonVegetarian',
      label: 'Non-Vegetarian',
      description: 'Includes meat, poultry, and seafood meals',
      icon: '🍖',
    ),
    DropdownItem(
      value: 'other',
      label: 'Other',
      description: 'Other meal preferences',
      icon: '🍽️',
    ),
  ];

  // Admin Roles
  static const List<DropdownItem> adminRoles = [
    DropdownItem(
      value: 'super_admin',
      label: 'Super Admin',
      description: 'Full system access and control',
      icon: '👑',
    ),
    DropdownItem(
      value: 'admin',
      label: 'Admin',
      description: 'General administrative access',
      icon: '👨‍💼',
    ),
    DropdownItem(
      value: 'moderator',
      label: 'Moderator',
      description: 'Content moderation privileges',
      icon: '🛡️',
    ),
    DropdownItem(
      value: 'viewer',
      label: 'Viewer',
      description: 'Read-only access',
      icon: '👀',
    ),
  ];

  // Delivery Person Status
  static const List<DropdownItem> deliveryPersonStatus = [
    DropdownItem(
      value: 'active',
      label: 'Active',
      description: 'Currently available for delivery',
      icon: '✅',
    ),
    DropdownItem(
      value: 'inactive',
      label: 'Inactive',
      description: 'Not available for delivery',
      icon: '❌',
    ),
    DropdownItem(
      value: 'on_break',
      label: 'On Break',
      description: 'Temporarily unavailable',
      icon: '⏸️',
    ),
    DropdownItem(
      value: 'offline',
      label: 'Offline',
      description: 'Not currently working',
      icon: '🔴',
    ),
  ];

  // Recipe Categories
  static const List<DropdownItem> recipeCategories = [
    DropdownItem(
      value: 'appetizer',
      label: 'Appetizer',
      description: 'Starters and small plates',
      icon: '🥟',
    ),
    DropdownItem(
      value: 'main_course',
      label: 'Main Course',
      description: 'Primary dishes',
      icon: '🍽️',
    ),
    DropdownItem(
      value: 'dessert',
      label: 'Dessert',
      description: 'Sweet treats',
      icon: '🍰',
    ),
    DropdownItem(
      value: 'beverage',
      label: 'Beverage',
      description: 'Drinks and smoothies',
      icon: '🥤',
    ),
    DropdownItem(
      value: 'salad',
      label: 'Salad',
      description: 'Fresh and healthy greens',
      icon: '🥗',
    ),
    DropdownItem(
      value: 'soup',
      label: 'Soup',
      description: 'Warm and comforting broths',
      icon: '🍲',
    ),
  ];

  // Vitamins
  static const List<DropdownItem> vitamins = [
    DropdownItem(value: 'vitamin_a',
        label: 'Vitamin A',
        description: 'Retinol and carotenoids',
        icon: '🥕'),
    DropdownItem(value: 'vitamin_b1',
        label: 'Vitamin B1 (Thiamine)',
        description: 'Energy metabolism',
        icon: '⚡'),
    DropdownItem(value: 'vitamin_b2',
        label: 'Vitamin B2 (Riboflavin)',
        description: 'Energy production',
        icon: '💪'),
    DropdownItem(value: 'vitamin_b3',
        label: 'Vitamin B3 (Niacin)',
        description: 'Cellular function',
        icon: '🔋'),
    DropdownItem(value: 'vitamin_b5',
        label: 'Vitamin B5 (Pantothenic Acid)',
        description: 'Hormone synthesis',
        icon: '🧬'),
    DropdownItem(value: 'vitamin_b6',
        label: 'Vitamin B6',
        description: 'Protein metabolism',
        icon: '🏗️'),
    DropdownItem(value: 'vitamin_b7',
        label: 'Vitamin B7 (Biotin)',
        description: 'Hair and nail health',
        icon: '💅'),
    DropdownItem(value: 'vitamin_b9',
        label: 'Vitamin B9 (Folate)',
        description: 'DNA synthesis',
        icon: '🧠'),
    DropdownItem(value: 'vitamin_b12',
        label: 'Vitamin B12',
        description: 'Nerve function',
        icon: '🧭'),
    DropdownItem(value: 'vitamin_c',
        label: 'Vitamin C',
        description: 'Immune support',
        icon: '🍊'),
    DropdownItem(value: 'vitamin_d',
        label: 'Vitamin D',
        description: 'Bone health',
        icon: '☀️'),
    DropdownItem(value: 'vitamin_e',
        label: 'Vitamin E',
        description: 'Antioxidant protection',
        icon: '🛡️'),
    DropdownItem(value: 'vitamin_k',
        label: 'Vitamin K',
        description: 'Blood clotting',
        icon: '🩸'),
  ];

  // Minerals
  static const List<DropdownItem> minerals = [
    DropdownItem(value: 'calcium',
        label: 'Calcium',
        description: 'Bone and teeth health',
        icon: '🦴'),
    DropdownItem(value: 'iron',
        label: 'Iron',
        description: 'Oxygen transport',
        icon: '🔴'),
    DropdownItem(value: 'magnesium',
        label: 'Magnesium',
        description: 'Muscle function',
        icon: '💪'),
    DropdownItem(value: 'phosphorus',
        label: 'Phosphorus',
        description: 'Energy storage',
        icon: '⚡'),
    DropdownItem(value: 'potassium',
        label: 'Potassium',
        description: 'Heart health',
        icon: '❤️'),
    DropdownItem(value: 'sodium',
        label: 'Sodium',
        description: 'Fluid balance',
        icon: '💧'),
    DropdownItem(value: 'zinc',
        label: 'Zinc',
        description: 'Immune function',
        icon: '🛡️'),
    DropdownItem(value: 'copper',
        label: 'Copper',
        description: 'Connective tissue',
        icon: '🔗'),
    DropdownItem(value: 'manganese',
        label: 'Manganese',
        description: 'Bone development',
        icon: '🦴'),
    DropdownItem(value: 'selenium',
        label: 'Selenium',
        description: 'Antioxidant enzyme',
        icon: '🛡️'),
    DropdownItem(value: 'chromium',
        label: 'Chromium',
        description: 'Glucose metabolism',
        icon: '🍯'),
    DropdownItem(value: 'molybdenum',
        label: 'Molybdenum',
        description: 'Enzyme function',
        icon: '⚗️'),
    DropdownItem(value: 'fluoride',
        label: 'Fluoride',
        description: 'Dental health',
        icon: '🦷'),
    DropdownItem(value: 'iodine',
        label: 'Iodine',
        description: 'Thyroid function',
        icon: '🔘'),
  ];

  // Meal Periods
  static const List<DropdownItem> mealPeriods = [
    DropdownItem(value: 'breakfast',
        label: 'Breakfast',
        description: 'Morning meal',
        icon: '🌅'),
    DropdownItem(
        value: 'lunch', label: 'Lunch', description: 'Midday meal', icon: '☀️'),
    DropdownItem(value: 'dinner',
        label: 'Dinner',
        description: 'Evening meal',
        icon: '🌙'),
    DropdownItem(value: 'snack',
        label: 'Snack',
        description: 'Light meal between meals',
        icon: '🍪'),
  ];

  // Priority Levels
  static const List<DropdownItem> priorityLevels = [
    DropdownItem(value: 'low',
        label: 'Low',
        description: 'Non-urgent priority',
        icon: '🟢'),
    DropdownItem(value: 'medium',
        label: 'Medium',
        description: 'Standard priority',
        icon: '🟡'),
    DropdownItem(value: 'high',
        label: 'High',
        description: 'Important priority',
        icon: '🟠'),
    DropdownItem(value: 'urgent',
        label: 'Urgent',
        description: 'Critical priority',
        icon: '🔴'),
  ];

  // Status Options
  static const List<DropdownItem> statusOptions = [
    DropdownItem(value: 'pending',
        label: 'Pending',
        description: 'Awaiting action',
        icon: '⏳'),
    DropdownItem(value: 'in_progress',
        label: 'In Progress',
        description: 'Currently being processed',
        icon: '🔄'),
    DropdownItem(value: 'completed',
        label: 'Completed',
        description: 'Successfully finished',
        icon: '✅'),
    DropdownItem(value: 'cancelled',
        label: 'Cancelled',
        description: 'Operation cancelled',
        icon: '❌'),
  ];

  // Helper methods to get dropdown data by type
  static List<DropdownItem> getDropdownItems(DropdownType type) {
    switch (type) {
      case DropdownType.dietaryCategories:
        return dietaryCategories;
      case DropdownType.bmiCategories:
        return bmiCategories;
      case DropdownType.mealCategories:
        return mealCategories;
      case DropdownType.adminRoles:
        return adminRoles;
      case DropdownType.deliveryPersonStatus:
        return deliveryPersonStatus;
      case DropdownType.recipeCategories:
        return recipeCategories;
      case DropdownType.vitamins:
        return vitamins;
      case DropdownType.minerals:
        return minerals;
      case DropdownType.mealPeriods:
        return mealPeriods;
      case DropdownType.priorityLevels:
        return priorityLevels;
      case DropdownType.statusOptions:
        return statusOptions;
    }
  }

  // Search function for filtering items
  static List<DropdownItem> searchItems(List<DropdownItem> items,
      String query) {
    if (query.isEmpty) return items;

    final lowercaseQuery = query.toLowerCase();
    return items.where((item) {
      return item.label.toLowerCase().contains(lowercaseQuery) ||
          item.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Get item by value
  static DropdownItem? findItemByValue(List<DropdownItem> items,
      dynamic value) {
    try {
      return items.firstWhere((item) => item.value == value);
    } catch (e) {
      return null;
    }
  }
}

// Data model for dropdown items
class DropdownItem {
  final dynamic value;
  final String label;
  final String description;
  final String icon;

  const DropdownItem({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DropdownItem && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => label;
}

// Enum for dropdown types
enum DropdownType {
  dietaryCategories,
  bmiCategories,
  mealCategories,
  adminRoles,
  deliveryPersonStatus,
  recipeCategories,
  vitamins,
  minerals,
  mealPeriods,
  priorityLevels,
  statusOptions,
}