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
          color: context.theme.colorScheme.surfaceContainerLowest,
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery
              .of(context)
              .size
              .height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 40),
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              child: _buildMobileLogoSection(context),
            ),
            const SizedBox(height: 60),
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              child: _buildMobileGetStartedButton(context),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLandscapeLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            color: context.theme.colorScheme.surfaceContainerLowest,
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
              color: context.theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: context.theme.colorScheme.onSurface.withAlpha(40),
                width: 1,
              ),
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

  Widget _buildMobileLogoSection(BuildContext context) {
    return Column(
      children: [
        Hero(
          tag: 'app_logo',
          child: buildLogoContainer(
            height: 120,
            width: 120,
            borderRadius: 30,
            iconSize: 60,
          ),
        ),
        const SizedBox(height: 32),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 500),
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: context.theme.colorScheme.onSurface,
            letterSpacing: -0.5,
            height: 1.1,
          ),
          child: const Text('Elith Admin'),
        ),
        const SizedBox(height: 12),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 700),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: context.theme.colorScheme.onSurface,
            letterSpacing: 0.3,
            height: 1.3,
          ),
          child: const Text('Professional Dashboard'),
        ),
      ],
    );
  }

  Widget _buildMobileCompactLogoSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Hero(
          tag: 'app_logo',
          child: buildLogoContainer(
            height: 80,
            width: 80,
            borderRadius: 20,
            iconSize: 40,
          ),
        ),
        const SizedBox(height: 20),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 500),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: context.theme.colorScheme.onSurface,
            letterSpacing: -0.3,
            height: 1.1,
          ),
          child: const Text('Elith Admin'),
        ),
        const SizedBox(height: 8),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 700),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.theme.colorScheme.onSurface,
            letterSpacing: 0.2,
            height: 1.3,
          ),
          child: const Text('Professional Dashboard'),
        ),
      ],
    );
  }

  Widget _buildMobileGetStartedButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _showMobileLoginBottomSheet(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.theme.colorScheme.onSurface,
          foregroundColor: context.theme.colorScheme.surfaceContainerLowest,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ).copyWith(
          overlayColor: WidgetStateProperty.all(
            context.theme.colorScheme.surfaceContainerLowest.withAlpha(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.login_rounded,
              size: 20,
              color: context.theme.colorScheme.surfaceContainerLowest,
            ),
            const SizedBox(width: 12),
            Text(
              'Get Started',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: context.theme.colorScheme.surfaceContainerLowest,
              ),
            ),
          ],
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
                color: Get.context!.theme.colorScheme.surfaceContainerLowest,
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
}
