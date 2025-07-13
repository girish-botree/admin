import 'package:admin/modules/login/components/common_login_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/resposive.dart';
import '../login_controller.dart';

class MobileLogin extends GetView<LoginController> {
  const MobileLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [context.theme.colorScheme.surfaceContainerHighest, context.theme.colorScheme.surfaceContainerHigh, context.theme.colorScheme.surfaceContainer],
          ),
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
                  color: Colors.black.withOpacity(0.1),
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
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF5F5F5)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.admin_panel_settings_rounded,
            size: 50,
            color: Colors.red.shade700,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Elith Admin',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'HEALTH TRACKING MANAGEMENT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
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
        Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF5F5F5)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.admin_panel_settings_rounded,
            size: 35,
            color: Colors.red.shade700,
          ),
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
            color: Colors.white.withOpacity(0.9),
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
          backgroundColor: Colors.white,
          foregroundColor: Colors.red.shade600,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login_rounded, size: 22, color: Colors.red.shade600),
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
            color: Colors.white.withOpacity(0.8),
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
          const Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sign in to continue to your dashboard',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),

          _buildMobileEmailField(),
          const SizedBox(height: 16),

          _buildMobilePasswordField(),
          const SizedBox(height: 18),

          // Error message
          Obx(() => controller.errorMessage.value.isNotEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox()),

          _buildMobileLoginButton(),
          const SizedBox(height: 14),

          _buildMobileForgotPasswordButton(),
          const SizedBox(height: 18),

          _buildMobileDemoCredentials(),
        ],
      ),
    );
  }

  Widget _buildMobileEmailField() {
    return TextFormField(
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(fontSize: 14),
      validator: controller.validateEmail,
      onChanged: (value) => controller.clearError(),
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email',
        prefixIcon: Icon(
          Icons.email_outlined,
          color: Colors.red.shade400,
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
      ),
    );
  }

  Widget _buildMobilePasswordField() {
    return Obx(() => TextFormField(
      controller: controller.passwordController,
      obscureText: !controller.isPasswordVisible.value,
      style: const TextStyle(fontSize: 14),
      validator: controller.validatePassword,
      onChanged: (value) => controller.clearError(),
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Colors.red.shade400,
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            controller.isPasswordVisible.value
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey.shade600,
            size: 20,
          ),
          onPressed: controller.togglePasswordVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
      ),
    ));
  }

  Widget _buildMobileLoginButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: controller.isLoading.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Login',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    ));
  }

  Widget _buildMobileForgotPasswordButton() {
    return Center(
      child: TextButton(
        onPressed: controller.navigateToForgotPassword,
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: Colors.red.shade400,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileDemoCredentials() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.red.shade600, size: 16),
              const SizedBox(width: 6),
              Text(
                'Demo Credentials',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Email: jagadeeshgiribabu@gmail.com',
            style: TextStyle(fontSize: 12, color: Colors.red.shade700),
          ),
          const SizedBox(height: 3),
          Text(
            'Password: Test@123',
            style: TextStyle(fontSize: 12, color: Colors.red.shade700),
          ),
        ],
      ),
    );
  }

  void _showMobileLoginBottomSheet(BuildContext context) {
    showModalBottomSheet(
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
              decoration: const BoxDecoration(
                color: Colors.white,
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
