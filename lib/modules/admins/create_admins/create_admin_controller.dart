import 'package:admin/config/app_config.dart';
import 'package:admin/network_service/dio_network_service.dart';
import 'package:admin/routes/app_routes.dart';
import 'package:dio/dio.dart';

class CreateAdminController extends GetxController {
  
  // Error messages
  final otpErrorMessage = ''.obs;
  // Form controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  
  // Form keys
  final formKey = GlobalKey<FormState>();
  
  // Loading states
  final isLoading = false.obs;
  final isOtpSent = false.obs;
  final isOtpLoading = false.obs;

  
  // Send OTP to the provided email
  Future<void> sendOtp(String email, String userType) async {
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      CustomDisplays.showSnackBar(message: 'Please enter a valid email address');
      return;
    }
    
    isLoading.value = true;
    try {
      final response = await DioNetworkService.sendOtp(email, showLoader: false);
      
      if (response != null && response['message'] == 'OTP sent successfully') {
        isOtpSent.value = true;
        CustomDisplays.showSnackBar(message: 'OTP sent successfully to your email');
      }
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      CustomDisplays.showSnackBar(message: 'Failed to send OTP: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Clear form fields
  void clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    otpController.clear();
    passwordController.clear();
    isOtpSent.value = false;
  }
  
  // Clear OTP error message
  void clearOtpError() {
    otpErrorMessage.value = '';
  }
  
  // Verify OTP and complete registration
  Future<void> verifyOtp({String userType = "admin"}) async {
    if (otpController.text.isEmpty) {
      otpErrorMessage.value = 'Please enter OTP';
      return;
    }
    
    if (otpController.text.length != 6) {
      otpErrorMessage.value = 'OTP must be 6 digits';
      return;
    }

    clearOtpError();
    isOtpLoading.value = true;

    try {
      // Call appropriate register API based on user type
      final response = userType == "delivery persons" 
        ? await DioNetworkService.registerDeliveryPerson(
            firstNameController.text.trim(),
            lastNameController.text.trim(),
            emailController.text.trim(),
            otpController.text.trim(),
            passwordController.text,
          )
        : await DioNetworkService.registerAdmin(
            firstNameController.text.trim(),
            lastNameController.text.trim(),
            emailController.text.trim(),
            otpController.text.trim(),
            passwordController.text,
          );

      // Check if registration was successful
      if (response != null && response['token'] != null) {
        // Store the token

        // Navigate to home page
        Get.offAllNamed(AppRoutes.home);
        
        // Show success message
        Get.snackbar(
          'Success',
          'Registration completed successfully! Welcome to the dashboard.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Response received but no token - treat as error
        otpErrorMessage.value = response?['message'] ?? 'Registration failed. Invalid response from server.';
      }
    } on DioException catch (dioError) {
      // Handle specific HTTP errors
      String errorMsg = 'Registration failed. Please try again.';
      
      if (dioError.response != null) {
        final statusCode = dioError.response!.statusCode;
        final responseData = dioError.response!.data;
        
        switch (statusCode) {
          case 400:
            errorMsg = responseData?['message'] ?? 'Invalid OTP or registration data.';
            break;
          case 401:
            errorMsg = 'Invalid or expired OTP. Please request a new one.';
            break;
          case 409:
            errorMsg = 'Email already registered. Please use a different email.';
            break;
          case 429:
            errorMsg = 'Too many attempts. Please try again later.';
            break;
          case 500:
            errorMsg = 'Server error. Please try again later.';
            break;
          default:
            errorMsg = responseData?['message'] ?? 'Registration failed. Please try again.';
        }
      } else {
        // Network error
        errorMsg = 'Network error. Please check your internet connection.';
      }
      
      otpErrorMessage.value = errorMsg;
    } catch (error) {
      otpErrorMessage.value = 'An unexpected error occurred. Please try again.';
    } finally {
      isOtpLoading.value = false;
    }
  }
  
  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    otpController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}