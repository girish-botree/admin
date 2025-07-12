import 'package:get/get.dart';

class LoginController extends GetxController {
  // final AuthService authService = Get.find<AuthService>();

  // // Form key and controllers
  // final formKey = GlobalKey<FormState>();
  // final emailController = TextEditingController();
  // final passwordController = TextEditingController();

  // // Reactive variables
  // final isPasswordVisible = false.obs;
  // final isLoading = false.obs;
  // final errorMessage = ''.obs;
  // final isButtonPressed = false.obs;

  // @override
  // void onInit() {
  //   super.onInit();
  //   // Pre-fill super admin credentials for demo
  //   emailController.text = 'superadmin@elith.com';
  //   passwordController.text = 'Elith_1@7';
  // }

  // @override
  // void onClose() {
  //   emailController.dispose();
  //   passwordController.dispose();
  //   super.onClose();
  // }

  // void togglePasswordVisibility() {
  //   isPasswordVisible.value = !isPasswordVisible.value;
  // }

  // void clearError() {
  //   errorMessage.value = '';
  // }

  // String? validateEmail(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return 'Email is required';
  //   }
  //   if (!GetUtils.isEmail(value)) {
  //     return 'Please enter a valid email';
  //   }
  //   return null;
  // }

  // String? validatePassword(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return 'Password is required';
  //   }
  //   if (value.length < 6) {
  //     return 'Password must be at least 6 characters';
  //   }
  //   return null;
  // }

  // Future<void> login() async {
  //   if (!formKey.currentState!.validate()) {
  //     return;
  //   }

  //   clearError();
  //   isLoading.value = true;

  //   try {
  //     final result = await authService.login(
  //       emailController.text.trim(),
  //       passwordController.text,
  //     );

  //     if (result['success']) {
  //       final user = result['user'];

  //       // Check if user is admin
  //       if (user['role'] == 'super_admin' || user['role'] == 'sub_admin') {
  //         Get.offAllNamed(AppRoutes.dashboard);
  //         Get.snackbar(
  //           'Success',
  //           'Welcome back, ${user['first_name']}!',
  //           backgroundColor: Colors.green,
  //           colorText: Colors.white,
  //           duration: const Duration(seconds: 2),
  //         );
  //       } else {
  //         errorMessage.value = 'Access denied. Admin privileges required.';
  //         await authService.logout();
  //       }
  //     } else {
  //       errorMessage.value = result['message'];
  //     }
  //   } catch (e) {
  //     errorMessage.value = 'An unexpected error occurred';
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // void navigateToForgotPassword() {
  //   // Navigate to forgot password screen if implemented
  //   Get.snackbar(
  //     'Info',
  //     'Contact super admin to reset password',
  //     backgroundColor: Colors.blue,
  //     colorText: Colors.white,
  //   );
  // }
}
