import 'package:admin/modules/login/components/common_login_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/responsive.dart';
import '../login_controller.dart';

class MobileLogin extends GetView<LoginController> {
  const MobileLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surfaceContainerLowest
        ),
        child: SafeArea(
          child: Responsive.isLandscape(context)
              ? _buildMobileLandscapeLayout(context)
              : _buildMobilePortraitLayout(context),
        ),
      ),
    );
  }

  Widget _buildMobilePortraitLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        constraints: BoxConstraints(
          minHeight:
              MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),

            _buildMobileLogoSection(context),
            const SizedBox(height: 30),

            _buildMobileGetStartedButton(context),
            const SizedBox(height: 20),

            _buildMobileSocialLoginOptions(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLandscapeLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    32,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMobileCompactLogoSection(context),
                  const SizedBox(height: 16),
                  _buildMobileSocialLoginOptions(context),
                ],
              ),
            ),
          ),
        ),

        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(child: _buildMobileLoginForm(context)),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLogoSection(BuildContext context) {
    return Column(
      children: [
        buildLogoContainer(
          height: 100,
          width: 100,
          borderRadius: 24,
          iconSize: 50,
        ),
        const SizedBox(height: 24),
        Text(
          'Elith Admin',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: context.theme.colorScheme.onSurface,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'HEALTH TRACKING MANAGEMENT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.9),
            letterSpacing: 2.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMobileCompactLogoSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildLogoContainer(
          height: 70,
          width: 70,
          borderRadius: 18,
          iconSize: 35,
        ),
        const SizedBox(height: 12),
        const Text(
          'Elith Admin',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'HEALTH TRACKING',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.9),
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMobileGetStartedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showMobileLoginBottomSheet(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
          foregroundColor: context.theme.colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login_rounded, size: 22, color: context.theme.colorScheme.onSurface),
            const SizedBox(width: 10),
            const Text(
              'Get Started',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileSocialLoginOptions(BuildContext context) {
    return Column(
      children: [
        Text(
          'Or continue with',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildSocialButton(
              icon: Icons.facebook,
              color: const Color(0xFF1877F2),
              onTap: () => print('Facebook login tapped'),
              containerWidth: 56,
              containerHeight: 56,
              borderRadius: 16,
              blurRadius: 8,
              iconSize: 26,
            ),
            const SizedBox(width: 16),
            buildSocialButton(
              icon: Icons.g_mobiledata_outlined,
              color: const Color(0xFF4285F4),
              onTap: () => print('Google login tapped'),
              containerWidth: 56,
              containerHeight: 56,
              borderRadius: 16,
              blurRadius: 8,
              iconSize: 26,
            ),
            const SizedBox(width: 16),
            buildSocialButton(
              icon: Icons.apple,
              color: Colors.black,
              onTap: () => print('Apple login tapped'),
              containerWidth: 56,
              containerHeight: 56,
              borderRadius: 16,
              blurRadius: 8,
              iconSize: 26,
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildMobileLoginForm(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildWelcomeText(
            fontSize: 22,
            subtitleFontSize: 14,
          ),
          const SizedBox(height: 20),

          buildEmailField(
            controller: controller.emailController,
            validator: controller.validateEmail,
            onChanged: controller.clearError,
            fontSize: 14,
            borderRadius: 14,
            iconSize: 20,
          ),
          const SizedBox(height: 16),

          buildPasswordField(
            controller: controller.passwordController,
            isPasswordVisible: controller.isPasswordVisible,
            validator: controller.validatePassword,
            onChanged: controller.clearError,
            toggleVisibility: controller.togglePasswordVisibility,
            fontSize: 14,
            borderRadius: 14,
            iconSize: 20,
          ),
          const SizedBox(height: 18),

          buildErrorMessage(
            errorMessage: controller.errorMessage,
            fontSize: 14,
            borderRadius: 8,
            iconSize: 20,
          ),

          buildLoginButton(
            isLoading: controller.isLoading,
            onPressed: controller.login,
            height: 46,
            fontSize: 16,
            borderRadius: 14,
          ),
          const SizedBox(height: 14),

          buildForgotPasswordButton(
            onPressed: controller.navigateToForgotPassword,
            fontSize: 14,
          ),
        ],
      ),
    );
  }



  void _showMobileLoginBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration:  BoxDecoration(
                color: Get.context!.theme.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMobileLoginForm(context),

                          SizedBox(
                            height: MediaQuery.of(context).viewInsets.bottom > 0
                                ? 100
                                : 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
