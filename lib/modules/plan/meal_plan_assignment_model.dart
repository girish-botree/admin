
class MealPlanAssignment {
  final String? id;
  final String recipeId;
  final String? recipeName;
  final String? recipeDescription;
  final String? recipeImageUrl;
  final DateTime mealDate;
  final MealPeriod period;
  final MealCategory category;
  final BmiCategory bmiCategory;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MealPlanAssignment({
    this.id,
    required this.recipeId,
    this.recipeName,
    this.recipeDescription,
    this.recipeImageUrl,
    required this.mealDate,
    required this.period,
    required this.category,
    required this.bmiCategory,
    this.createdAt,
    this.updatedAt,
  });

  factory MealPlanAssignment.fromJson(Map<String, dynamic> json) {
    return MealPlanAssignment(
      id: json['id']?.toString(),
      recipeId: (json['recipeId'] as String?) ?? '',
      recipeName: json['recipeName']?.toString(),
      recipeDescription: json['recipeDescription']?.toString(),
      recipeImageUrl: json['recipeImageUrl']?.toString(),
      mealDate: DateTime.parse(
          (json['mealDate'] as String?) ?? DateTime.now().toIso8601String()),
      period: _parseMealPeriod(json['period']),
      category: _parseMealCategory(json['category']),
      bmiCategory: _parseBmiCategory(json['bmiCategory']),
      createdAt: json['createdAt'] != null ? DateTime.parse(
          json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(
          json['updatedAt'].toString()) : null,
    );
  }

  static MealPeriod _parseMealPeriod(dynamic value) {
    if (value is int) {
      switch (value) {
        case 0:
          return MealPeriod.breakfast;
        case 1:
          return MealPeriod.lunch;
        case 2:
          return MealPeriod.dinner;
        case 3:
          return MealPeriod.snack;
        default:
          return MealPeriod.breakfast;
      }
    } else if (value is String) {
      return MealPeriod.values.firstWhere(
            (e) => e.name.toUpperCase() == value.toUpperCase(),
        orElse: () => MealPeriod.breakfast,
      );
    }
    return MealPeriod.breakfast;
  }

  static MealCategory _parseMealCategory(dynamic value) {
    if (value is int) {
      switch (value) {
        case 0:
          return MealCategory.vegan;
        case 1:
          return MealCategory.vegetarian;
        case 2:
          return MealCategory.eggitarian;
        case 3:
          return MealCategory.nonVegetarian;
        case 4:
          return MealCategory.other;
        default:
          return MealCategory.vegetarian;
      }
    } else if (value is String) {
      return MealCategory.values.firstWhere(
            (e) => e.name.toUpperCase() == value.toUpperCase(),
        orElse: () => MealCategory.vegetarian,
      );
    }
    return MealCategory.vegetarian;
  }

  static BmiCategory _parseBmiCategory(dynamic value) {
    if (value is int) {
      switch (value) {
        case 0:
          return BmiCategory.underweight;
        case 1:
          return BmiCategory.normal;
        case 2:
          return BmiCategory.overweight;
        case 3:
          return BmiCategory.obese;
        default:
          return BmiCategory.normal;
      }
    } else if (value is String) {
      return BmiCategory.values.firstWhere(
            (e) => e.name.toUpperCase() == value.toUpperCase(),
        orElse: () => BmiCategory.normal,
      );
    }
    return BmiCategory.normal;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'recipeId': recipeId,
      'mealDate': mealDate.toIso8601String(),
      'period': period.index, // Send as integer
      // category is now optional and used only for local filtering
      'bmiCategory': bmiCategory.index, // Send as integer
    };
  }

  // Method to create API request data without category field
  Map<String, dynamic> toApiJson() {
    return {
      if (id != null) 'id': id,
      'recipeId': recipeId,
      'mealDate': mealDate.toIso8601String(),
      'period': period.index, // Send as integer
      'bmiCategory': bmiCategory.index, // Send as integer
      // category field is intentionally omitted for API requests
    };
  }
}

enum MealPeriod {
  breakfast, // 0
  lunch, // 1
  dinner, // 2
  snack // 3
}

enum MealCategory {
  vegan, // 0
  vegetarian, // 1
  eggitarian, // 2
  nonVegetarian, // 3
  other, // 4
}

enum BmiCategory {
  underweight, // 0
  normal, // 1
  overweight, // 2
  obese // 3
}