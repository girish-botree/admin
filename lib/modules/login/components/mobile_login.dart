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
        height: MediaQuery
            .of(context)
            .size
            .height,
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surfaceContainerHighest,
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
    return Column(
      children: [
        // Top section with Elith title
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: _buildTopSection(context),
        ),

        // Middle section with background and quote
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: context.theme.colorScheme.onSurface.withOpacity(0.05),
              border: Border.all(
                color: context.theme.colorScheme.onSurface.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: _buildMiddleSection(context),
          ),
        ),

        // Bottom section with Get Started button
        Container(
          padding: const EdgeInsets.all(24),
          child: _buildBottomSection(context),
        ),
      ],
    );
  }

  Widget _buildMobileLandscapeLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainerHighest,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery
                      .of(context)
                      .size
                      .height -
                      MediaQuery
                          .of(context)
                          .padding
                          .top -
                      MediaQuery
                          .of(context)
                          .padding
                          .bottom -
                      40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMobileCompactLogoSection(context),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 7,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: context.theme.colorScheme.onSurface.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 8),
                  blurRadius: 32,
                  color: context.theme.colorScheme.onSurface.withOpacity(0.1),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildMobileLoginForm(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileCompactLogoSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.theme.colorScheme.onSurface.withOpacity(0.1),
            border: Border.all(
              color: context.theme.colorScheme.onSurface.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.admin_panel_settings_rounded,
            size: 40,
            color: context.theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 20),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 500),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: context.theme.colorScheme.onSurface,
            letterSpacing: -0.5,
            height: 1.1,
          ),
          child: const Text('Elith'),
        ),
        const SizedBox(height: 8),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 700),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.theme.colorScheme.onSurface.withOpacity(0.7),
            letterSpacing: 0.2,
            height: 1.3,
          ),
          child: const Text('Professional Dashboard'),
        ),
      ],
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return Column(
      children: [
        // App title "Elith"
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 800),
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: context.theme.colorScheme.onSurface,
            letterSpacing: -1.0,
            height: 1.0,
          ),
          child: const Text('Elith'),
        ),
      ],
    );
  }

  Widget _buildMiddleSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Decorative icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.theme.colorScheme.onSurface.withOpacity(0.1),
              border: Border.all(
                color: context.theme.colorScheme.onSurface.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.restaurant_rounded,
              size: 40,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 32),

          // Inspiring quote
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 1000),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: context.theme.colorScheme.onSurface,
              letterSpacing: 0.3,
              height: 1.4,
            ),
            child: const Text(
              '"Let food be thy medicine and medicine be thy food. A healthy outside starts from the inside."',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

          // Quote attribution
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 1200),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.theme.colorScheme.onSurface.withOpacity(0.7),
              letterSpacing: 0.5,
              fontStyle: FontStyle.italic,
            ),
            child: const Text(
              '— Hippocrates',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Column(
      children: [
        // Get Started Button
        Container(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => _showMobileLoginBottomSheet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.theme.colorScheme.onSurface,
              foregroundColor: context.theme.colorScheme
                  .surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 2,
              shadowColor: context.theme.colorScheme.onSurface.withOpacity(
                0.3,
              ),
            ).copyWith(
              overlayColor: WidgetStateProperty.all(
                    context.theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.1),
                  ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.rocket_launch_rounded,
                  size: 24,
                  color: context.theme.colorScheme.surfaceContainerHighest,
                ),
                const SizedBox(width: 12),
                Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: context.theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Subtitle
        Text(
          'Transform your nutrition journey',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.theme.colorScheme.onSurface.withOpacity(0.7),
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
              decoration: BoxDecoration(
                color: Get.context!.theme.colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28)),
                border: Border.all(
                  color: Get.context!.theme.colorScheme.onSurface.withAlpha(30),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.onSurface
                          .withAlpha(60),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(28),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMobileLoginForm(context),
                          SizedBox(
                            height: MediaQuery
                                .of(context)
                                .viewInsets
                                .bottom > 0 ? 100 : 20,
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

  Widget _buildMobileLoginForm(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            buildWelcomeText(
              fontSize: 26,
              subtitleFontSize: 16,
            ),
            const SizedBox(height: 32),

            buildEmailField(
              controller: controller.emailController,
              validator: controller.validateEmail,
              onChanged: controller.clearError,
              fontSize: 16,
              borderRadius: 14,
              iconSize: 20,
            ),
            const SizedBox(height: 20),

            buildPasswordField(
              controller: controller.passwordController,
              isPasswordVisible: controller.isPasswordVisible,
              validator: controller.validatePassword,
              onChanged: controller.clearError,
              toggleVisibility: controller.togglePasswordVisibility,
              fontSize: 16,
              borderRadius: 14,
              iconSize: 20,
            ),
            const SizedBox(height: 24),

            buildErrorMessage(
              errorMessage: controller.errorMessage,
              fontSize: 14,
              borderRadius: 10,
              iconSize: 18,
            ),

            buildLoginButton(
              isLoading: controller.isLoading,
              onPressed: controller.login,
              height: 50,
              fontSize: 16,
              borderRadius: 14,
            ),
            const SizedBox(height: 20),

            buildForgotPasswordButton(
              onPressed: controller.navigateToForgotPassword,
              fontSize: 14,
            ),
          ],
        ),
      ),
    );
  }
}
