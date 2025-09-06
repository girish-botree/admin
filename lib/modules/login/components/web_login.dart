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
        height: MediaQuery
            .of(context)
            .size
            .height,
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surfaceContainerHighest,
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Left side - Welcome section
              Expanded(
                flex: 6,
                child: Container(
                  padding: const EdgeInsets.all(64),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App title
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 800),
                        style: TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.w900,
                          color: context.theme.colorScheme.onSurface,
                          letterSpacing: -2.0,
                          height: 0.9,
                        ),
                        child: const Text('Elith'),
                      ),
                      const SizedBox(height: 32),

                      // Subtitle
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 1000),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: context.theme.colorScheme.onSurface
                              .withOpacity(0.7),
                          letterSpacing: 0.5,
                          height: 1.4,
                        ),
                        child: const Text(
                          'Transform your nutrition journey with our professional admin dashboard',
                        ),
                      ),
                      const SizedBox(height: 64),

                      // Quote section
                      Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          color: context.theme.colorScheme.onSurface
                              .withOpacity(0.05),
                          border: Border.all(
                            color: context.theme.colorScheme.onSurface
                                .withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.restaurant_rounded,
                              size: 40,
                              color: context.theme.colorScheme.onSurface,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '"Let food be thy medicine and medicine be thy food. A healthy outside starts from the inside."',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: context.theme.colorScheme.onSurface,
                                letterSpacing: 0.3,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '— Hippocrates',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: context.theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                                letterSpacing: 0.5,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Feature highlights
                      Wrap(
                        spacing: 32,
                        runSpacing: 16,
                        children: [
                          _buildFeatureItem(
                              Icons.dashboard_rounded, 'Nutrition Dashboard'),
                          _buildFeatureItem(Icons.health_and_safety_rounded,
                              'Health Tracking'),
                          _buildFeatureItem(
                              Icons.analytics_rounded, 'Analytics'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Right side - Login form
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.all(32),
                  constraints: const BoxConstraints(maxWidth: 480),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: context.theme.colorScheme.onSurface.withOpacity(
                          0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 20),
                        blurRadius: 60,
                        color: context.theme.colorScheme.onSurface.withOpacity(
                            0.1),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(48),
                    child: _buildWebLoginForm(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Get.context!.theme.colorScheme.onSurface.withOpacity(0.1),
            border: Border.all(
              color: Get.context!.theme.colorScheme.onSurface.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: Get.context!.theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Get.context!.theme.colorScheme.onSurface.withOpacity(0.7),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildWebLoginForm(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            buildWelcomeText(fontSize: 32, subtitleFontSize: 18),
            const SizedBox(height: 32),
            buildEmailField(
              controller: controller.emailController,
              validator: controller.validateEmail,
              onChanged: controller.clearError,
              fontSize: 18,
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
              fontSize: 18,
              borderRadius: 18,
              iconSize: 24,
            ),
            const SizedBox(height: 28),

            buildErrorMessage(
              errorMessage: controller.errorMessage,
              fontSize: 16,
              borderRadius: 14,
              iconSize: 24,
            ),

            buildLoginButton(
              isLoading: controller.isLoading,
              onPressed: controller.login,
              height: 56,
              fontSize: 18,
              borderRadius: 18,
            ),
            const SizedBox(height: 24),

            buildForgotPasswordButton(
              onPressed: controller.navigateToForgotPassword,
              fontSize: 16,
            ),
          ],
        ),
      ),
    );
  }
}
