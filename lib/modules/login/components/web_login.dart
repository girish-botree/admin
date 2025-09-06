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
          color: Theme
              .of(context)
              .colorScheme
              .surfaceContainerLowest,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              child: Card(
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Container(
                  width: 1100,
                  height: 700,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(20),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 11,
                          child: Container(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .onSurface,
                            child: Stack(
                              children: [
                                // Decorative background pattern
                                Positioned(
                                  top: -100,
                                  right: -100,
                                  child: Container(
                                    width: 300,
                                    height: 300,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme
                                          .of(context)
                                          .colorScheme
                                          .surfaceContainerLowest
                                          .withAlpha(10),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -150,
                                  left: -150,
                                  child: Container(
                                    width: 400,
                                    height: 400,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme
                                          .of(context)
                                          .colorScheme
                                          .surfaceContainerLowest
                                          .withAlpha(8),
                                    ),
                                  ),
                                ),
                                // Content
                                Padding(
                                  padding: const EdgeInsets.all(60),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildWebLogoSection(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 12,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .surfaceContainerLowest,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 60, vertical: 40),
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
                        ),
                      ],
                    ),
                  ),
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
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          child: buildLogoContainer(
            height: 180,
            width: 180,
            borderRadius: 42,
            iconSize: 90,
          ),
        ),
        const SizedBox(height: 48),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 600),
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w800,
            color: Get.context!.theme.colorScheme.surfaceContainerLowest,
            letterSpacing: -1.0,
            height: 1.1,
          ),
          child: const Text('Elith Admin'),
        ),
        const SizedBox(height: 16),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 800),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Get.context!.theme.colorScheme.surfaceContainerLowest
                .withAlpha(180),
            letterSpacing: 0.5,
            height: 1.3,
          ),
          child: const Text('Professional Admin Dashboard'),
        ),
      ],
    );
  }

  Widget _buildWebLoginForm() {
    return Form(
      key: controller.formKey,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            buildWelcomeText(
              fontSize: 38,
              subtitleFontSize: 18,
            ),
            const SizedBox(height: 48),

            buildEmailField(
              controller: controller.emailController,
              validator: controller.validateEmail,
              onChanged: controller.clearError,
              fontSize: 18,
              borderRadius: 16,
              iconSize: 22,
            ),
            const SizedBox(height: 24),

            buildPasswordField(
              controller: controller.passwordController,
              isPasswordVisible: controller.isPasswordVisible,
              validator: controller.validatePassword,
              onChanged: controller.clearError,
              toggleVisibility: controller.togglePasswordVisibility,
              fontSize: 18,
              borderRadius: 16,
              iconSize: 22,
            ),
            const SizedBox(height: 32),

            buildErrorMessage(
              errorMessage: controller.errorMessage,
              fontSize: 16,
              borderRadius: 12,
              iconSize: 24,
            ),

            buildLoginButton(
              isLoading: controller.isLoading,
              onPressed: controller.login,
              height: 56,
              fontSize: 18,
              borderRadius: 16,
            ),
            const SizedBox(height: 28),

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
