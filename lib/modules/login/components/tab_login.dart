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
          color: Theme
              .of(context)
              .colorScheme
              .surfaceContainerLowest,
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
          flex: 5,
          child: Container(
            color: Theme
                .of(context)
                .colorScheme
                .surfaceContainerLowest,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
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
                      64,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutBack,
                      child: _buildTabletCompactLogoSection(context),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .colorScheme
                  .surfaceContainerLowest,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Theme
                    .of(context)
                    .colorScheme
                    .onSurface
                    .withAlpha(30),
                width: 1,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
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

  Widget _buildTabletPortraitLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            color: Theme
                .of(context)
                .colorScheme
                .surfaceContainerLowest,
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutBack,
                  child: _buildTabletLogoSection(context),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .colorScheme
                  .surfaceContainerLowest,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32)),
              border: Border.all(
                color: Theme
                    .of(context)
                    .colorScheme
                    .onSurface
                    .withAlpha(20),
                width: 1,
              ),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              child: _buildTabletLoginForm(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLogoSection(BuildContext context) {
    return Column(
      children: [
        Hero(
          tag: 'app_logo',
          child: buildLogoContainer(
            height: 160,
            width: 160,
            borderRadius: 36,
            iconSize: 80,
          ),
        ),
        const SizedBox(height: 40),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 600),
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w800,
            color: context.theme.colorScheme.onSurface,
            letterSpacing: -0.8,
            height: 1.1,
          ),
          child: const Text('Elith Admin'),
        ),
        const SizedBox(height: 20),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 800),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: context.theme.colorScheme.onSurface,
            letterSpacing: 0.4,
            height: 1.3,
          ),
          child: const Text('Professional Admin Dashboard'),
        ),
      ],
    );
  }

  Widget _buildTabletCompactLogoSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Hero(
          tag: 'app_logo',
          child: buildLogoContainer(
            height: 120,
            width: 120,
            borderRadius: 28,
            iconSize: 60,
          ),
        ),
        const SizedBox(height: 28),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 600),
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: context.theme.colorScheme.onSurface,
            letterSpacing: -0.5,
            height: 1.1,
          ),
          child: const Text('Elith Admin'),
        ),
        const SizedBox(height: 16),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 800),
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
