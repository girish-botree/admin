import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../routes/app_routes.dart';
import '../../network_service/dio_network_service.dart';
import '../../config/shared_preference.dart';
import '../../config/auth_service.dart';

class LoginController extends GetxController {
  // Form key and controllers
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Services
  final AuthService _authService = AuthService.to;

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

      // Extract the actual data from the enhanced response structure
      final responseData = response['data'] as Map<String, dynamic>?;
      final httpResponse = response['httpResponse'] as Map<String, dynamic>?;
      
      // Log the detailed response information
      if (httpResponse != null) {
        debugPrint('HTTP Response Status: ${httpResponse['status']}');
        debugPrint('HTTP Response Message: ${httpResponse['statusMessage']}');
        debugPrint('HTTP Response URL: ${httpResponse['url']}');
      }

      // Check if response contains token (successful login)
      // Look for token in both the responseData and direct response for compatibility
      final token = responseData?['data']?['token'] as String? ?? 
                   responseData?['token'] as String? ??
                   response['token'] as String?;
      
      final refreshToken = responseData?['data']?['refreshToken'] as String? ?? 
                          responseData?['refreshToken'] as String? ??
                          response['refreshToken'] as String?;

      if (token != null && token.isNotEmpty) {
        // Store tokens using AuthService
        await _authService.login(
          token,
          refreshToken: refreshToken,
        );

        // Store user email for display in app bar
        final sharedPref = SharedPreference();
        await sharedPref.save('userEmail', emailController.text.trim());

        // Wait a brief moment to ensure state is updated
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Navigate to main layout
        Get.offAllNamed<void>(AppRoutes.mainLayout);
        
        // Show success message with HTTP status info
        final statusCode = httpResponse?['status'] ?? 200;
        Get.snackbar(
          'Success',
          'Login successful! Welcome to Admin Dashboard. (HTTP $statusCode)',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        // Response received but no token - treat as error
        final errorMsg = responseData?['message'] as String? ??
                        response['message'] as String? ??
                        'Login failed. Invalid response from server.';
        errorMessage.value = errorMsg;
      }
    } on DioException catch (dioError) {
      // Handle specific HTTP errors
      String errorMsg = 'Login failed. Please try again.';

      // Enhanced CORS error detection for web
      if (kIsWeb && (
          dioError.message?.contains('XMLHttpRequest') == true ||
              dioError.message?.contains('CORS') == true ||
              dioError.message?.contains('connection error') == true ||
              dioError.type == DioExceptionType.connectionError ||
              (dioError.response == null &&
                  dioError.message?.contains('onError') == true)
      )) {
        errorMsg = '''CORS Error: The server must allow cross-origin requests from your domain.

For development, you can:
• Run Flutter web with --web-browser-flag "--disable-web-security"
• Contact the API server administrator to add CORS headers
• Use a proxy server for development

Current API URL: ${dioError.requestOptions.uri}''';
      } else if (dioError.response != null) {
        final statusCode = dioError.response!.statusCode;
        final responseData = dioError.response!.data as Map<String, dynamic>?;
        
        switch (statusCode) {
          case 400:
            errorMsg = responseData?['message'] as String? ??
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
            errorMsg = responseData?['message'] as String? ??
                'Login failed. Please try again.';
        }
      } else {
        // Network error - provide web-specific guidance
        if (kIsWeb) {
          errorMsg =
          'Network error. Please check:\n• Your internet connection\n• If the server allows web requests (CORS)\n• If the API URL is correct';
        } else {
          errorMsg = 'Network error. Please check your internet connection.';
        }
      }
      
      errorMessage.value = errorMsg;
    } catch (e) {
      // Handle other errors
      debugPrint('${e}');
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
