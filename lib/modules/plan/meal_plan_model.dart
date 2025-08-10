
class MealPlan {
  final String? id;
  final String name;
  final String description;
  final String? imageUrl;
  final double? price;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MealPlan({
    this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.price,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
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
    };
  }

  MealPlan copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    double? price,
    bool? isActive,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}