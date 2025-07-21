import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../network_service/dio_network_service.dart';

class HomeController extends GetxController {
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
        // Clear both access and refresh tokens
        await DioNetworkService.clearToken();
        
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