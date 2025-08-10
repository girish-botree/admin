import 'package:get/get.dart';
import '../../network_service/api_client.dart';
import 'models/dashboard_stats.dart';

class DashboardController extends GetxController
    with StateMixin<DashboardStats> {
  @override
  void onInit() {
    super.onInit();
    change(DashboardStats.empty(), status: RxStatus.empty());
  }

  @override
  void onReady() {
    super.onReady();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    change(null, status: RxStatus.loading());

    try {
      final results = await Future.wait([
        _fetchRecipes(),
        _fetchIngredients(),
        _fetchMealPlans(),
      ]);

      final recipes = results[0];
      final ingredients = results[1];
      final mealPlans = results[2];

      final stats = DashboardStats(
        totalRecipes: recipes.length,
        totalIngredients: ingredients.length,
        totalMealPlans: mealPlans.length,
        recipes: recipes,
        ingredients: ingredients,
        mealPlans: mealPlans,
        userGrowthData: [],
        orderDistributionData: [],
      );

      change(stats, status: RxStatus.success());
    } catch (error) {
      change(null, status: RxStatus.error(error.toString()));
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRecipes() async {
    try {
      final response = await ApiHelper.callApi(
        () => ApiHelper.getApiClient().getRecipes(),
        showLoadingIndicator: false,
      );

      if (response?.response.statusCode == 200) {
        final responseData = response?.data;
        if (responseData is Map<String, dynamic> &&
            responseData['data'] is List) {
          final dataList = responseData['data'] as List;
          return List<Map<String, dynamic>>.from(dataList);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchIngredients() async {
    try {
      final response = await ApiHelper.callApi(
        () => ApiHelper.getApiClient().getIngredients(),
        showLoadingIndicator: false,
      );

      if (response?.response.statusCode == 200) {
        final responseData = response?.data;
        if (responseData is Map<String, dynamic> &&
            responseData['data'] is List) {
          final dataList = responseData['data'] as List;
          return List<Map<String, dynamic>>.from(dataList);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchMealPlans() async {
    try {
      final response = await ApiHelper.callApi(
        () => ApiHelper.getApiClient().getMealPlan(),
        showLoadingIndicator: false,
      );

      if (response?.response.statusCode == 200) {
        final responseData = response?.data;
        if (responseData is Map<String, dynamic> &&
            responseData['data'] is List) {
          final dataList = responseData['data'] as List;
          return List<Map<String, dynamic>>.from(dataList);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> refreshData() async {
    await fetchDashboardData();
  }

  // Getters for backward compatibility
  bool get isLoading => status.isLoading;

  int get totalRecipes => state?.totalRecipes ?? 0;

  int get totalIngredients => state?.totalIngredients ?? 0;

  int get totalMealPlans => state?.totalMealPlans ?? 0;
}