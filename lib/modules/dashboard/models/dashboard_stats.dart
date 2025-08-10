class DashboardStats {
  final int totalRecipes;
  final int totalIngredients;
  final int totalMealPlans;
  final List<Map<String, dynamic>> recipes;
  final List<Map<String, dynamic>> ingredients;
  final List<Map<String, dynamic>> mealPlans;
  final List<Map<String, dynamic>> userGrowthData;
  final List<Map<String, dynamic>> orderDistributionData;

  const DashboardStats({
    required this.totalRecipes,
    required this.totalIngredients,
    required this.totalMealPlans,
    required this.recipes,
    required this.ingredients,
    required this.mealPlans,
    required this.userGrowthData,
    required this.orderDistributionData,
  });

  bool get hasData =>
      totalRecipes > 0 || totalIngredients > 0 || totalMealPlans > 0;

  factory DashboardStats.empty() {
    return const DashboardStats(
      totalRecipes: 0,
      totalIngredients: 0,
      totalMealPlans: 0,
      recipes: [],
      ingredients: [],
      mealPlans: [],
      userGrowthData: [],
      orderDistributionData: [],
    );
  }

  DashboardStats copyWith({
    int? totalRecipes,
    int? totalIngredients,
    int? totalMealPlans,
    List<Map<String, dynamic>>? recipes,
    List<Map<String, dynamic>>? ingredients,
    List<Map<String, dynamic>>? mealPlans,
    List<Map<String, dynamic>>? userGrowthData,
    List<Map<String, dynamic>>? orderDistributionData,
  }) {
    return DashboardStats(
      totalRecipes: totalRecipes ?? this.totalRecipes,
      totalIngredients: totalIngredients ?? this.totalIngredients,
      totalMealPlans: totalMealPlans ?? this.totalMealPlans,
      recipes: recipes ?? this.recipes,
      ingredients: ingredients ?? this.ingredients,
      mealPlans: mealPlans ?? this.mealPlans,
      userGrowthData: userGrowthData ?? this.userGrowthData,
      orderDistributionData: orderDistributionData ?? this.orderDistributionData,
    );
  }
}