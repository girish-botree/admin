import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:admin/widgets/custom_displays.dart';
import '../../routes/app_routes.dart';
import '../../network_service/dio_network_service.dart';

class LoginController extends GetxController {
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

    final hasConnection =
        await InternetConnectionChecker.createInstance().hasConnection;
    if (!hasConnection) {
      CustomDisplays.showInfoBar(
        message: 'No internet connection. Please check your network.',
        type: InfoBarType.networkError,
        actionText: 'Retry',
        onAction: () {
          CustomDisplays.dismissInfoBar();
          login();
        },
      );
      return;
    }

    try {
      final response = await DioNetworkService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      // Check if response contains token (successful login)
      if (response['data'] != null && response['data']['token'] != null) {
        // Store both access and refresh tokens
        final tokenData = response['data'] as Map<String, dynamic>;
        await DioNetworkService.storeAuthTokens(tokenData);

        // Navigate to main layout
        Get.offAllNamed(AppRoutes.mainLayout);

        // Show success message
        CustomDisplays.showToast(
          message: 'Login successful! Welcome to Admin Dashboard.',
          type: MessageType.success,
        );
      } else {
        // Response received but no token - treat as error
        String errorMsg = (response?['message']?.toString()) ??
            'Login failed. Invalid response from server.';
        CustomDisplays.showToast(
          message: errorMsg,
          type: MessageType.error,
        );
      }
    } on DioException catch (dioError) {
      // Handle specific HTTP errors
      String errorMsg = 'Login failed. Please try again.';

      if (dioError.response != null) {
        final statusCode = dioError.response!.statusCode;
        final responseData = dioError.response!.data;

        switch (statusCode) {
          case 400:
            errorMsg =
                (responseData?['message'] as String?) ??
                'Invalid email or password format.';
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
            errorMsg =
                (responseData?['message'] as String?) ??
                'Login failed. Please try again.';
        }
      } else {
        // Network error
        errorMsg = 'Network error. Please check your internet connection.';
      }

      if (errorMsg.toLowerCase().contains('network') ||
          errorMsg.toLowerCase().contains('internet') ||
          errorMsg.toLowerCase().contains('connection')) {
        CustomDisplays.showInfoBar(
          message: errorMsg,
          type: InfoBarType.networkError,
          actionText: 'Retry',
          onAction: () {
            CustomDisplays.dismissInfoBar();
            login();
          },
        );
      } else {
        CustomDisplays.showToast(
          message: errorMsg,
          type: MessageType.error,
        );
      }
    } catch (e) {
      // Handle other errors
      CustomDisplays.showToast(
        message: 'An unexpected error occurred. Please try again.',
        type: MessageType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToForgotPassword() {
    // Navigate to forgot password screen if implemented
    CustomDisplays.showToast(
      message: 'Contact administrator to reset password',
      type: MessageType.info,
    );
  }
}
