import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../network_service/dio_network_service.dart';

class HomeController extends GetxController {
  // Navigation state
  final RxInt _currentIndex = 0.obs;
  
  // Loading and error states
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  
  // Dashboard data
  final RxMap<String, dynamic> _dashboardData = <String, dynamic>{}.obs;
  
  // Services
  // final AuthService _authService = AuthService.to;

  // Getters
  int get currentIndex => _currentIndex.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  Map<String, dynamic> get dashboardData => _dashboardData;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  @override
  void onReady() {
    super.onReady();
    // Additional initialization after controller is ready
  }

  /// Load initial dashboard data
  Future<void> _loadInitialData() async {
    try {
      _isLoading.value = true;
      _error.value = '';
      
      // Load any initial data needed for the home screen
      await _loadDashboardStats();
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load dashboard statistics
  Future<void> _loadDashboardStats() async {
    try {
      // You can add API calls here to fetch dashboard statistics
      // For now, we'll set some default values
      _dashboardData.value = {
        'totalMeals': 0,
        'totalPlans': 0,
        'totalAdmins': 0,
        'lastActivity': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      // Error loading dashboard stats
    }
  }

  /// Refresh dashboard data
  Future<void> refreshDashboard() async {
    await _loadInitialData();
    
    // Show success message
    Get.snackbar(
      'success'.tr,
      'refresh'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primaryContainer,
      colorText: Get.theme.colorScheme.onPrimaryContainer,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
    );
  }

  /// Navigate to specific section
  void navigateToSection(String route) {
    Get.toNamed<void>(route);
  }

  /// Handle bottom navigation tap
  void onItemTapped(int index) {
    _currentIndex.value = index;
    switch(index) {
      case 0:
        // Home tab - stay on current page
        break;
      case 1:
        Get.toNamed<void>(AppRoutes.plan);
        break;
      case 2:
        // Navigate to meal page
        Get.toNamed<void>(AppRoutes.meal);
        break;
      case 3:
        Get.toNamed<void>(AppRoutes.dashboard);
        break;
      default:
        // Handle other tabs if needed
        break;
    }
  }

  /// Quick actions
  Future<void> createNewMealPlan() async {
    try {
      Get.toNamed<void>(AppRoutes.plan);
      // Additional logic for creating meal plan can be added here
    } catch (e) {
      // Error navigating to meal plan
    }
  }

  Future<void> createNewRecipe() async {
    try {
      Get.toNamed<void>(AppRoutes.meal);
      // Additional logic for creating recipe can be added here
    } catch (e) {
      // Error navigating to meals
    }
  }

  Future<void> addNewAdmin() async {
    try {
      Get.toNamed<void>(AppRoutes.createAdmin);
    } catch (e) {
      // Error navigating to create admin
    }
  }

  /// Logout functionality
  Future<void> logout() async {
    try {
      // Show confirmation dialog
      final bool shouldLogout = await Get.dialog<bool>(
        AlertDialog(
              title: Text('logout'.tr),
              content: Text('logout_confirmation'.tr),
              actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
                  child: Text('cancel'.tr),
                ),
            TextButton(
              onPressed: () => Get.back(result: true),
                  child: Text('logout'.tr),
                ),
          ],
        ),
      ) ?? false;

      if (shouldLogout) {
        try {
          // Optional: Call logout API endpoint if available
          // await DioNetworkService.postData({}, 'api/auth/logout');
          
          // Clear both access and refresh tokens
          await DioNetworkService.clearAllTokens();
          
          // Navigate to login screen
          Get.offAllNamed<void>(AppRoutes.login);
          
          // Show success message
          Get.snackbar(
            'success'.tr,
            'sign_out'.tr,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } catch (logoutError) {
          // Even if API logout fails, clear local tokens and proceed
          await DioNetworkService.clearAllTokens();
          Get.offAllNamed<void>(AppRoutes.login);
          
          Get.snackbar(
            'success'.tr,
            'sign_out'.tr,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      // Handle logout error
      Get.snackbar(
        'error'.tr,
        'try_again'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
} 