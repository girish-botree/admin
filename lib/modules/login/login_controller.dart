import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../routes/app_routes.dart';
import '../../network_service/dio_network_service.dart';
import '../../config/shared_preference.dart';
import '../../config/appconstants.dart';

class LoginController extends GetxController {
  final SharedPreference _sharedPreference = SharedPreference();

  // Form key and controllers
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Reactive variables
  final isPasswordVisible = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Pre-fill demo credentials
    emailController.text = 'super@gmail.com';
    passwordController.text = 'Test@123';
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void clearError() {
    errorMessage.value = '';
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    clearError();
    isLoading.value = true;

    try {
      final response = await DioNetworkService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      // Check if response contains token (successful login)
      if (response != null && response['token'] != null) {
        // Store the token
        _sharedPreference.save(AppConstants.bearerToken, response['token']);

        // Navigate to home page
        Get.offAllNamed(AppRoutes.home);
        
        // Show success message
        Get.snackbar(
          'Success',
          'Login successful! Welcome to Admin Dashboard.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        // Response received but no token - treat as error
        errorMessage.value = response?['message'] ?? 'Login failed. Invalid response from server.';
      }
    } on DioException catch (dioError) {
      // Handle specific HTTP errors
      String errorMsg = 'Login failed. Please try again.';
      
      if (dioError.response != null) {
        final statusCode = dioError.response!.statusCode;
        final responseData = dioError.response!.data;
        
        switch (statusCode) {
          case 400:
            errorMsg = responseData?['message'] ?? 'Invalid email or password format.';
            break;
          case 401:
            errorMsg = 'Invalid email or password. Please check your credentials.';
            break;
          case 403:
            errorMsg = 'Access denied. You do not have admin privileges.';
            break;
          case 404:
            errorMsg = 'Login service not found. Please contact support.';
            break;
          case 429:
            errorMsg = 'Too many login attempts. Please try again later.';
            break;
          case 500:
            errorMsg = 'Server error. Please try again later.';
            break;
          default:
            errorMsg = responseData?['message'] ?? 'Login failed. Please try again.';
        }
      } else {
        // Network error
        errorMsg = 'Network error. Please check your internet connection.';
      }
      
      errorMessage.value = errorMsg;
    } catch (e) {
      // Handle other errors
      errorMessage.value = 'An unexpected error occurred. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToForgotPassword() {
    // Navigate to forgot password screen if implemented
    Get.snackbar(
      'Info',
      'Contact administrator to reset password',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
}
