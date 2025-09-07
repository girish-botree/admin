import 'package:admin/modules/login/components/common_login_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/responsive.dart';
import '../login_controller.dart';

class TabLogin extends GetView<LoginController> {
  const TabLogin({super.key});

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
          child: Responsive.isLandscape(context)
              ? _buildTabletLandscapeLayout(context)
              : _buildTabletPortraitLayout(context),
        ),
      ),
    );
  }

  Widget _buildTabletLandscapeLayout(BuildContext context) {
    return Row(
      children: [
        // Left side - Welcome section
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App title
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 800),
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: context.theme.colorScheme.onSurface,
                    letterSpacing: -1.5,
                    height: 0.9,
                  ),
                  child: const Text('Elith'),
                ),
                const SizedBox(height: 24),

                // Subtitle
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 1000),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: context.theme.colorScheme.onSurface.withOpacity(0.7),
                    letterSpacing: 0.3,
                    height: 1.4,
                  ),
                  child: const Text(
                    'Transform your nutrition journey with our professional dashboard',
                  ),
                ),
                const SizedBox(height: 48),

                // Quote section
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: context.theme.colorScheme.onSurface.withOpacity(
                        0.05),
                    border: Border.all(
                      color: context.theme.colorScheme.onSurface.withOpacity(
                          0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 32,
                        color: context.theme.colorScheme.onSurface,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome to Elith — your comprehensive administrative dashboard designed to streamline operations and enhance productivity.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: context.theme.colorScheme.onSurface,
                          letterSpacing: 0.3,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Efficient. Reliable. Professional.',
                        style: TextStyle(
                          fontSize: 14,
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
              ],
            ),
          ),
        ),

        // Right side - Login form
        Expanded(
          flex: 4,
          child: Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: context.theme.colorScheme.onSurface.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 16),
                  blurRadius: 48,
                  color: context.theme.colorScheme.onSurface.withOpacity(0.1),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: _buildTabletLoginForm(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletPortraitLayout(BuildContext context) {
    return Column(
      children: [
        // Top section with title and quote
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App title
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 800),
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: context.theme.colorScheme.onSurface,
                    letterSpacing: -1.2,
                    height: 0.9,
                  ),
                  child: const Text('Elith'),
                ),
                const SizedBox(height: 24),

                // Subtitle
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 1000),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: context.theme.colorScheme.onSurface.withOpacity(0.7),
                    letterSpacing: 0.3,
                    height: 1.4,
                  ),
                  child: const Text(
                    'Professional Nutrition Dashboard',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                // Quote section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: context.theme.colorScheme.onSurface.withOpacity(
                        0.05),
                    border: Border.all(
                      color: context.theme.colorScheme.onSurface.withOpacity(
                          0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 28,
                        color: context.theme.colorScheme.onSurface,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Welcome to Elith — your comprehensive administrative dashboard designed to streamline operations and enhance productivity.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.theme.colorScheme.onSurface,
                          letterSpacing: 0.3,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Efficient. Reliable. Professional.',
                        style: TextStyle(
                          fontSize: 14,
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
              ],
            ),
          ),
        ),

        // Bottom section with login form
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              border: Border.all(
                color: context.theme.colorScheme.onSurface.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -8),
                  blurRadius: 32,
                  color: context.theme.colorScheme.onSurface.withOpacity(0.1),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                child: _buildTabletLoginForm(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLoginForm(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            buildWelcomeText(fontSize: 34, subtitleFontSize: 17),
            const SizedBox(height: 40),

            buildEmailField(
              controller: controller.emailController,
              validator: controller.validateEmail,
              onChanged: controller.clearError,
              fontSize: 17,
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
              fontSize: 17,
              borderRadius: 16,
              iconSize: 22,
            ),
            const SizedBox(height: 28),

            buildErrorMessage(
              errorMessage: controller.errorMessage,
              fontSize: 15,
              borderRadius: 12,
              iconSize: 22,
            ),

            buildLoginButton(
              isLoading: controller.isLoading,
              onPressed: controller.login,
              height: 54,
              fontSize: 17,
              borderRadius: 16,
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
