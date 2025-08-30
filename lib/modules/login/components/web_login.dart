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
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(60),
            child: Card(
              elevation: 20,
              shadowColor: Theme
                  .of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              child: Container(
                width: 1000,
                height: 650,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface,
                          borderRadius: const BorderRadius.only(
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
        buildLogoContainer(
          height: 160,
          width: 160,
          borderRadius: 36,
          iconSize: 80,
        ),
        const SizedBox(height: 40),
        Text(
          'Elith Admin',
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.bold,
            color: Get.context!.theme.colorScheme.onSurface,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'HEALTH TRACKING MANAGEMENT',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Get.context!.theme.colorScheme.onSurface,
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
            color: Get.context!.theme.colorScheme.onSurface,
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
  //             color: Colors.black.withValues(alpha: 0.1),
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
          buildWelcomeText(
            fontSize: 36,
            subtitleFontSize: 20,
          ),
          const SizedBox(height: 40),

          buildEmailField(
            controller: controller.emailController,
            validator: controller.validateEmail,
            onChanged: controller.clearError,
            fontSize: 20,
            borderRadius: 18,
            iconSize: 24,
          ),
          const SizedBox(height: 24),

          buildPasswordField(
            controller: controller.passwordController,
            isPasswordVisible: controller.isPasswordVisible,
            validator: controller.validatePassword,
            onChanged: controller.clearError,
            toggleVisibility: controller.togglePasswordVisibility,
            fontSize: 20,
            borderRadius: 18,
            iconSize: 24,
          ),
          const SizedBox(height: 28),

          buildErrorMessage(
            errorMessage: controller.errorMessage,
            fontSize: 18,
            borderRadius: 14,
            iconSize: 28,
          ),

          buildLoginButton(
            isLoading: controller.isLoading,
            onPressed: controller.login,
            height: 60,
            fontSize: 22,
            borderRadius: 18,
          ),
          const SizedBox(height: 24),

          buildForgotPasswordButton(
            onPressed: controller.navigateToForgotPassword,
            fontSize: 20,
          ),
        ],
      ),
    );
  }


}
