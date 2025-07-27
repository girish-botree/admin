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
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface,
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
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    48,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTabletCompactLogoSection(context),
                  const SizedBox(height: 24),
                  _buildTabletSocialLoginOptions(context),
                ],
              ),
            ),
          ),
        ),

        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: _buildTabletLoginForm(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletPortraitLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTabletLogoSection(context),
                const SizedBox(height: 32),
                _buildTabletSocialLoginOptions(context),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 24,
                  offset: Offset(0, -12),
                ),
              ],
            ),
            child: _buildTabletLoginForm(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLogoSection(BuildContext context) {
    return Column(
      children: [
        buildLogoContainer(
          height: 140,
          width: 140,
          borderRadius: 32,
          iconSize: 70,
        ),
        const SizedBox(height: 32),
        Text(
          'Elith Admin',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: context.theme.colorScheme.surfaceContainerLowest,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'HEALTH TRACKING MANAGEMENT',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            letterSpacing: 2.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTabletCompactLogoSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildLogoContainer(
          height: 100,
          width: 100,
          borderRadius: 24,
          iconSize: 50,
        ),
        const SizedBox(height: 20),
        Text(
          'Elith Admin',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: context.theme.colorScheme.surfaceContainerLowest,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'HEALTH TRACKING',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            letterSpacing: 2.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTabletSocialLoginOptions(BuildContext context) {
    return Column(
      children: [
        Text(
          'Or continue with',
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildSocialButton(
              icon: Icons.facebook,
              color: const Color(0xFF1877F2),
              onTap: () => print('Facebook login tapped'),
              containerWidth: 72,
              containerHeight: 72,
              borderRadius: 24,
              blurRadius: 10,
              iconSize: 34,
            ),
            const SizedBox(width: 24),
            buildSocialButton(
              icon: Icons.g_mobiledata_outlined,
              color: const Color(0xFF4285F4),
              onTap: () => print('Google login tapped'),
              containerWidth: 72,
              containerHeight: 72,
              borderRadius: 24,
              blurRadius: 10,
              iconSize: 34,
            ),
            const SizedBox(width: 24),
            buildSocialButton(
              icon: Icons.apple,
              color: Colors.black,
              onTap: () => print('Apple login tapped'),
              containerWidth: 72,
              containerHeight: 72,
              borderRadius: 24,
              blurRadius: 10,
              iconSize: 34,
            ),
          ],
        ),
      ],
    );
  }

  // Widget _buildTabletSocialButton({
  //   required IconData icon,
  //   required Color color,
  //   required VoidCallback onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       width: 72,
  //       height: 72,
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(24),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.1),
  //             blurRadius: 10,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: Icon(icon, size: 34, color: color),
  //     ),
  //   );
  // }

  Widget _buildTabletLoginForm(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildWelcomeText(
            fontSize: 32,
            subtitleFontSize: 18,
          ),
          const SizedBox(height: 32),

          buildEmailField(
            controller: controller.emailController,
            validator: controller.validateEmail,
            onChanged: controller.clearError,
            fontSize: 18,
            borderRadius: 16,
            iconSize: 24,
          ),
          const SizedBox(height: 20),

          buildPasswordField(
            controller: controller.passwordController,
            isPasswordVisible: controller.isPasswordVisible,
            validator: controller.validatePassword,
            onChanged: controller.clearError,
            toggleVisibility: controller.togglePasswordVisibility,
            fontSize: 18,
            borderRadius: 16,
            iconSize: 24,
          ),
          const SizedBox(height: 24),

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
            fontSize: 20,
            borderRadius: 16,
          ),
          const SizedBox(height: 20),

          buildForgotPasswordButton(
            onPressed: controller.navigateToForgotPassword,
            fontSize: 18,
          ),
          const SizedBox(height: 24),

          buildDemoCredentials(
            fontSize: 16,
            borderRadius: 12,
            iconSize: 18,
          ),
        ],
      ),
    );
  }


}
