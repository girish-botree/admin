class Recipe {
  final String id;
  final String name;
  final String description;
  final int servings;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String cuisine;
  final String category;
  final List<String> ingredients;
  final List<String> instructions;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.servings,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.cuisine,
    required this.category,
    required this.ingredients,
    required this.instructions,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      servings: json['servings'] as int? ?? 0,
      calories: json['calories'] as int? ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      cuisine: json['cuisine']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      ingredients: (json['ingredients'] as List<dynamic>?)?.cast<String>() ?? [],
      instructions: (json['instructions'] as List<dynamic>?)?.cast<String>() ?? [],
      imageUrl: json['imageUrl']?.toString(),
      createdAt: DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'servings': servings,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'cuisine': cuisine,
      'category': category,
      'ingredients': ingredients,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    int? servings,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    String? cuisine,
    String? category,
    List<String>? ingredients,
    List<String>? instructions,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      servings: servings ?? this.servings,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      cuisine: cuisine ?? this.cuisine,
      category: category ?? this.category,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Recipe(id: $id, name: $name, cuisine: $cuisine, category: $category)';
  }
}
