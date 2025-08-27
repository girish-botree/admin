import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../config/shared_preference.dart';
import '../../config/auth_service.dart';
import 'package:flutter/material.dart';

class MainLayoutController extends GetxController {
  final SharedPreference _sharedPreference = SharedPreference();
  final AuthService _authService = AuthService.to;
  final RxInt _currentIndex = 0.obs;
  final RxString userEmail = ''.obs;

  int get currentIndex => _currentIndex.value;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void changePage(int index) {
    _currentIndex.value = index;
  }

  Future<void> _loadUserData() async {
    final email = await _sharedPreference.get('userEmail');
    if (email != null) {
      userEmail.value = email;
    }
  }
  
  /// Logout functionality
  Future<void> logout() async {
    try {
      // Clear user session data using AuthService
      await _authService.logout();
      await _sharedPreference.remove('userEmail');

      // Navigate to login screen
      Get.offAllNamed<void>(AppRoutes.login);

      // Show success message
      Get.snackbar(
        'Success',
        'Logged out successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      // Handle logout error
      Get.snackbar(
        'Error',
        'Failed to logout. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}