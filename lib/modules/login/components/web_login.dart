import 'package:admin/modules/login/components/common_login_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../login_controller.dart';

class WebLogin extends GetView<LoginController> {
  const WebLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8B0000), Color(0xFF660000), Color(0xFF330000)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(60),
            child: Card(
              elevation: 20,
              shadowColor: Colors.black.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              child: Container(
                width: 1000,
                height: 650,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF8B0000),
                              Color(0xFF660000),
                              Color(0xFF440000),
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            bottomLeft: Radius.circular(32),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(60),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildWebLogoSection(),
                              const SizedBox(height: 40),
                              _buildWebSocialLoginOptions(),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(60),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: SingleChildScrollView(
                                child: _buildWebLoginForm(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebLogoSection() {
    return Column(
      children: [
        Container(
          height: 160,
          width: 160,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF5F5F5)],
            ),
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Icon(
            Icons.admin_panel_settings_rounded,
            size: 80,
            color: Colors.red.shade700,
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Elith Admin',
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'HEALTH TRACKING MANAGEMENT',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 2.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWebSocialLoginOptions() {
    return Column(
      children: [
        Text(
          'Or continue with',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildSocialButton(
              icon: Icons.facebook,
              color: const Color(0xFF1877F2),
              onTap: () => print('Facebook login tapped'),
              containerWidth: 80,
              containerHeight: 80,
              borderRadius: 28,
              blurRadius: 12,
              iconSize: 38,
            ),
            const SizedBox(width: 28),
            buildSocialButton(
              icon: Icons.g_mobiledata_outlined,
              color: const Color(0xFF4285F4),
              onTap: () => print('Google login tapped'),
              containerWidth: 80,
              containerHeight: 80,
              borderRadius: 28,
              blurRadius: 12,
              iconSize: 38,
            ),
            const SizedBox(width: 28),
            buildSocialButton(
              icon: Icons.apple,
              color: Colors.black,
              onTap: () => print('Apple login tapped'),
              containerWidth: 80,
              containerHeight: 80,
              borderRadius: 28,
              blurRadius: 12,
              iconSize: 38,
            ),
          ],
        ),
      ],
    );
  }

  // Widget _buildWebSocialButton({
  //   required IconData icon,
  //   required Color color,
  //   required VoidCallback onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       width: 80,
  //       height: 80,
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(28),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.1),
  //             blurRadius: 12,
  //             offset: const Offset(0, 6),
  //           ),
  //         ],
  //       ),
  //       child: Icon(icon, size: 38, color: color),
  //     ),
  //   );
  // }

  Widget _buildWebLoginForm() {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sign in to continue to your dashboard',
            style: TextStyle(fontSize: 20, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 40),

          _buildWebEmailField(),
          const SizedBox(height: 24),

          _buildWebPasswordField(),
          const SizedBox(height: 28),

          // Error message
          Obx(() => controller.errorMessage.value.isNotEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox()),

          _buildWebLoginButton(),
          const SizedBox(height: 24),

          _buildWebForgotPasswordButton(),
          const SizedBox(height: 28),

          _buildWebDemoCredentials(),
        ],
      ),
    );
  }

  Widget _buildWebEmailField() {
    return TextFormField(
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(fontSize: 20),
      validator: controller.validateEmail,
      onChanged: (value) => controller.clearError(),
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email',
        prefixIcon: Icon(
          Icons.email_outlined,
          color: Colors.red.shade400,
          size: 24,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 24,
        ),
      ),
    );
  }

  Widget _buildWebPasswordField() {
    return Obx(() => TextFormField(
      controller: controller.passwordController,
      obscureText: !controller.isPasswordVisible.value,
      style: const TextStyle(fontSize: 20),
      validator: controller.validatePassword,
      onChanged: (value) => controller.clearError(),
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Colors.red.shade400,
          size: 24,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            controller.isPasswordVisible.value
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey.shade600,
            size: 24,
          ),
          onPressed: controller.togglePasswordVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 24,
        ),
      ),
    ));
  }

  Widget _buildWebLoginButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 6,
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: controller.isLoading.value
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Login',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
      ),
    ));
  }

  Widget _buildWebForgotPasswordButton() {
    return Center(
      child: TextButton(
        onPressed: controller.navigateToForgotPassword,
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: Colors.red.shade400,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildWebDemoCredentials() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.red.shade600, size: 20),
              const SizedBox(width: 10),
              Text(
                'Demo Credentials',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Email: jagadeeshgiribabu@gmail.com',
            style: TextStyle(fontSize: 16, color: Colors.red.shade700),
          ),
          const SizedBox(height: 6),
          Text(
            'Password: Test@123',
            style: TextStyle(fontSize: 16, color: Colors.red.shade700),
          ),
        ],
      ),
    );
  }
}
