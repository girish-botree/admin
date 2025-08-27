enum FoodType {
  vegan, // 0
  vegetarian, // 1
  eggitarian, // 2
  nonVegetarian, // 3
  other, // 4
}

extension FoodTypeExtension on FoodType {
  String get displayName {
    switch (this) {
      case FoodType.vegan:
        return 'Vegan';
      case FoodType.vegetarian:
        return 'Vegetarian';
      case FoodType.eggitarian:
        return 'Eggitarian';
      case FoodType.nonVegetarian:
        return 'Non-Vegetarian';
      case FoodType.other:
        return 'Other';
    }
  }
}

class MealPlan {
  final String? id;
  final String name;
  final String description;
  final String? imageUrl;
  final double? price;
  final bool isActive;
  final FoodType? foodType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MealPlan({
    this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.price,
    this.isActive = true,
    this.foodType,
    this.createdAt,
    this.updatedAt,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    FoodType? foodType;

    // First check for 'foodType' field directly
    if (json['foodType'] != null) {
      switch (json['foodType'].toString().toLowerCase()) {
        case 'vegan':
          foodType = FoodType.vegan;
          break;
        case 'vegetarian':
          foodType = FoodType.vegetarian;
          break;
        case 'eggitarian':
          foodType = FoodType.eggitarian;
          break;
        case 'nonvegetarian':
        case 'non_vegetarian':
        case 'non-vegetarian':
          foodType = FoodType.nonVegetarian;
          break;
        case 'other':
          foodType = FoodType.other;
          break;
      }
    }

    // If foodType is not set, check for 'category' field (for meal plan assignments)
    if (foodType == null && json['category'] != null) {
      final category = json['category'] as int?;
      switch (category) {
        case 0:
          foodType = FoodType.vegan;
          break;
        case 1:
          foodType = FoodType.vegetarian;
          break;
        case 2:
          foodType = FoodType.eggitarian;
          break;
        case 3:
          foodType = FoodType.nonVegetarian;
          break;
        case 4:
          foodType = FoodType.other;
          break;
        default:
        // Any other value defaults to vegetarian
          foodType = FoodType.vegetarian;
          break;
      }
    }

    return MealPlan(
      id: json['recipeId']?.toString() ?? json['id']?.toString(),
      name: (json['recipeName'] as String?) ?? (json['name'] as String?) ?? '',
      description:
          (json['recipeDescription'] as String?) ??
          (json['description'] as String?) ??
          '',
      imageUrl:
          json['recipeImageUrl']?.toString() ?? json['imageUrl']?.toString(),
      price: (json['price'] as num?)?.toDouble(),
      isActive: (json['isActive'] as bool?) ?? true,
      foodType: foodType,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (price != null) 'price': price,
      'isActive': isActive,
      if (foodType != null) 'foodType': foodType!.name,
    };
  }

  MealPlan copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    double? price,
    bool? isActive,
    FoodType? foodType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      foodType: foodType ?? this.foodType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}