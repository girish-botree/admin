import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../config/shared_preference.dart';
import '../../config/appconstants.dart';
import 'package:flutter/material.dart';

class MainLayoutController extends GetxController {
  final SharedPreference _sharedPreference = SharedPreference();
  final RxInt _currentIndex = 0.obs;

  int get currentIndex => _currentIndex.value;

  void changePage(int index) {
    _currentIndex.value = index;
  }
  
  /// Logout functionality
  Future<void> logout() async {
    try {
      // Show confirmation dialog
      final bool shouldLogout = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Logout'),
            ),
          ],
        ),
      ) ?? false;

      if (shouldLogout) {
        // Clear user session data
        await _sharedPreference.remove(AppConstants.bearerToken);
        
        // Navigate to login screen
        Get.offAllNamed(AppRoutes.login);
        
        // Show success message
        Get.snackbar(
          'Success',
          'Logged out successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
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