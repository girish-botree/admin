

import 'dart:ui';

import 'package:admin/config/app_config.dart';

Widget buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required double containerWidth,
    required double containerHeight,
    required double borderRadius,
    required double blurRadius,
    required double iconSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: containerWidth,
        height: containerHeight,
        decoration: BoxDecoration(
          color: Get.context!.theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Get.context!.theme.colorScheme.shadow.withValues(
                  alpha: 0.1),
              blurRadius: blurRadius,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: iconSize, color: color),
      ),
    );
  }

Widget buildLogoContainer({
  required double height,
  required double width,
  required double borderRadius,
  required double iconSize,
}) {
  return Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Get.context!.theme.colorScheme.surfaceContainerLowest, Get.context!.theme.colorScheme.surfaceContainerLow],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: (0.1)),
          blurRadius: borderRadius * 0.8,
          offset: Offset(0, borderRadius * 0.3),
        ),
      ],
    ),
    child: Icon(
      Icons.admin_panel_settings_rounded,
      size: iconSize,
      color: Get.context!.theme.colorScheme.onSurface,
    ),
  );
}

Widget buildWelcomeText({
  required double fontSize,
  required double subtitleFontSize,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText.bold(
        'Welcome Back',
        size: fontSize,
        color: Get.context!.theme.colorScheme.onSurface,
      ),
      SizedBox(height: fontSize * 0.25),
      AppText.regular(
        'Sign in to continue to your dashboard',
        size: subtitleFontSize,
        color: Get.context!.theme.colorScheme.outline,
      ),
    ],
  );
}

Widget buildEmailField({
  required TextEditingController controller,
  required String? Function(String?) validator,
  required VoidCallback onChanged,
  required double fontSize,
  required double borderRadius,
  required double iconSize,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: TextInputType.emailAddress,
    style: TextStyle(
      fontSize: fontSize,
      color: Get.context!.theme.colorScheme.onSurface,
    ),
    validator: validator,
    onChanged: (_) => onChanged(),
    decoration: InputDecoration(
      labelText: 'Email',
      hintText: 'Enter your email',
      labelStyle: TextStyle(color: Get.context!.theme.colorScheme.outline),
      hintStyle: TextStyle(color: Get.context!.theme.colorScheme.outline),
      prefixIcon: Icon(
        Icons.email_outlined,
        color: Get.context!.theme.colorScheme.outline,
        size: iconSize,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Get.context!.theme.colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Get.context!.theme.colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
            color: Get.context!.theme.colorScheme.primary, width: 2),
      ),
      filled: true,
      fillColor: Get.context!.theme.colorScheme.surfaceContainerHigh,
      contentPadding: EdgeInsets.symmetric(
        vertical: fontSize * 0.8,
        horizontal: fontSize * 1.2,
      ),
    ),
  );
}

Widget buildPasswordField({
  required TextEditingController controller,
  required RxBool isPasswordVisible,
  required String? Function(String?) validator,
  required VoidCallback onChanged,
  required VoidCallback toggleVisibility,
  required double fontSize,
  required double borderRadius,
  required double iconSize,
}) {
  return Obx(() => TextFormField(
    controller: controller,
    obscureText: !isPasswordVisible.value,
    style: TextStyle(
      fontSize: fontSize,
      color: Get.context!.theme.colorScheme.onSurface,
    ),
    validator: validator,
    onChanged: (_) => onChanged(),
    decoration: InputDecoration(
      labelText: 'Password',
      hintText: 'Enter your password',
      labelStyle: TextStyle(color: Get.context!.theme.colorScheme.outline),
      hintStyle: TextStyle(color: Get.context!.theme.colorScheme.outline),
      prefixIcon: Icon(
        Icons.lock_outline,
        color: Get.context!.theme.colorScheme.outline,
        size: iconSize,
      ),
      suffixIcon: IconButton(
        icon: Icon(
          isPasswordVisible.value
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: Get.context!.theme.colorScheme.outline,
          size: iconSize,
        ),
        onPressed: toggleVisibility,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Get.context!.theme.colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Get.context!.theme.colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
            color: Get.context!.theme.colorScheme.primary, width: 2),
      ),
      filled: true,
      fillColor: Get.context!.theme.colorScheme.surfaceContainerHigh,
      contentPadding: EdgeInsets.symmetric(
        vertical: fontSize * 0.8,
        horizontal: fontSize * 1.2,
      ),
    ),
  ));
}

Widget buildLoginButton({
  required RxBool isLoading,
  required VoidCallback onPressed,
  required double height,
  required double fontSize,
  required double borderRadius,
}) {
  return Obx(() => SizedBox(
    width: double.infinity,
    height: height,
    child: ElevatedButton(
      onPressed: isLoading.value ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Get.context!.theme.colorScheme.onSurface,
        foregroundColor: Get.context!.theme.colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 4,
        disabledBackgroundColor: Get.context!.theme.colorScheme
            .surfaceContainerLow,
      ),
      child: isLoading.value
          ? SizedBox(
              width: height * 0.5,
              height: height * 0.5,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : AppText.semiBold(
              'Login',
              size: fontSize,
              color: AppColor.white,
            ),
    ),
  ));
}

Widget buildErrorMessage({
  required RxString errorMessage,
  required double fontSize,
  required double borderRadius,
  required double iconSize,
}) {
  return Obx(() => errorMessage.value.isNotEmpty
      ? Container(
          width: double.infinity,
          padding: EdgeInsets.all(fontSize * 0.8),
          margin: EdgeInsets.only(bottom: fontSize),
          decoration: BoxDecoration(
            color: Get.context!.theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Get.context!.theme.colorScheme.error),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Get.context!.theme.colorScheme.onError,
                size: iconSize,
              ),
              SizedBox(width: fontSize * 0.5),
              Expanded(
                child: AppText.regular(
                  errorMessage.value,
                  size: fontSize,
                  color: Get.context!.theme.colorScheme.onError,
                ),
              ),
            ],
          ),
        )
      : const SizedBox());
}

Widget buildForgotPasswordButton({
  required VoidCallback onPressed,
  required double fontSize,
}) {
  return Center(
    child: TextButton(
      onPressed: onPressed,
      child: AppText.medium(
        'Forgot Password?',
        size: fontSize,
        color:Get.context!.theme.colorScheme.onSurface,
      ),
    ),
  );
}