import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_config.dart';

Widget buildLogoContainer({
  required double height,
  required double width,
  required double borderRadius,
  required double iconSize,
}) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    height: height,
    width: width,
    decoration: BoxDecoration(
      color: Get.context!.theme.colorScheme.onSurface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Get.context!.theme.colorScheme.onSurface.withAlpha(30),
        width: 1,
      ),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Get.context!.theme.colorScheme.onSurface.withAlpha(30),
          width: 1,
        ),
      ),
      child: Icon(
        Icons.admin_panel_settings_rounded,
        size: iconSize,
        color: Get.context!.theme.colorScheme.surfaceContainerLowest,
      ),
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
      AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 400),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Get.context!.theme.colorScheme.onSurface,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        child: const Text('Welcome Back'),
      ),
      SizedBox(height: fontSize * 0.3),
      AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 600),
        style: TextStyle(
          fontSize: subtitleFontSize,
          fontWeight: FontWeight.w400,
          color: Get.context!.theme.colorScheme.onSurface,
          letterSpacing: 0.2,
          height: 1.4,
        ),
        child: const Text('Sign in to continue to your dashboard'),
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
  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    child: TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: Get.context!.theme.colorScheme.onSurface,
        letterSpacing: 0.1,
      ),
      validator: validator,
      onChanged: (_) => onChanged(),
      decoration: InputDecoration(
        labelText: 'Email Address',
        hintText: 'Enter your email address',
        labelStyle: TextStyle(
          color: Get.context!.theme.colorScheme.onSurface,
          fontSize: fontSize * 0.9,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: Get.context!.theme.colorScheme.onSurface.withAlpha(120),
          fontSize: fontSize * 0.95,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: Get.context!.theme.colorScheme.onSurface,
          size: iconSize,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: Get.context!.theme.colorScheme.onSurface,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: Get.context!.theme.colorScheme.onSurface,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: Get.context!.theme.colorScheme.onSurface,
            width: 2.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: Get.context!.theme.colorScheme.onSurface,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: Get.context!.theme.colorScheme.onSurface,
            width: 2.5,
          ),
        ),
        filled: true,
        fillColor: Get.context!.theme.colorScheme.surfaceContainerLowest,
        contentPadding: EdgeInsets.symmetric(
          vertical: fontSize * 1.0,
          horizontal: fontSize * 1.2,
        ),
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
  return Obx(() =>
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: TextFormField(
          controller: controller,
          obscureText: !isPasswordVisible.value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: Get.context!.theme.colorScheme.onSurface,
            letterSpacing: isPasswordVisible.value ? 0.1 : 1.5,
          ),
          validator: validator,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            labelStyle: TextStyle(
              color: Get.context!.theme.colorScheme.onSurface,
              fontSize: fontSize * 0.9,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: TextStyle(
              color: Get.context!.theme.colorScheme.onSurface.withAlpha(120),
              fontSize: fontSize * 0.95,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              Icons.lock_outline,
              color: Get.context!.theme.colorScheme.onSurface,
              size: iconSize,
            ),
            suffixIcon: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: toggleVisibility,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isPasswordVisible.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    key: ValueKey(isPasswordVisible.value),
                    color: Get.context!.theme.colorScheme.onSurface,
                    size: iconSize,
                  ),
                ),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: Get.context!.theme.colorScheme.onSurface,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: Get.context!.theme.colorScheme.onSurface,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: Get.context!.theme.colorScheme.onSurface,
                width: 2.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: Get.context!.theme.colorScheme.onSurface,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: Get.context!.theme.colorScheme.onSurface,
                width: 2.5,
              ),
            ),
            filled: true,
            fillColor: Get.context!.theme.colorScheme.surfaceContainerLowest,
            contentPadding: EdgeInsets.symmetric(
              vertical: fontSize * 1.0,
              horizontal: fontSize * 1.2,
            ),
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
  return Obx(() =>
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: height,
        child: ElevatedButton(
          onPressed: isLoading.value ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Get.context!.theme.colorScheme.onSurface,
            foregroundColor: Get.context!.theme.colorScheme
                .surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            elevation: isLoading.value ? 2 : 6,
            shadowColor: Get.context!.theme.colorScheme.onSurface.withAlpha(60),
            disabledBackgroundColor: Get.context!.theme.colorScheme.onSurface
                .withAlpha(80),
            disabledForegroundColor: Get.context!.theme.colorScheme
                .surfaceContainerLowest,
          ).copyWith(
            overlayColor: WidgetStateProperty.all(
              Get.context!.theme.colorScheme.surfaceContainerLowest.withAlpha(
                  20),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isLoading.value
                ? SizedBox(
              width: height * 0.45,
              height: height * 0.45,
              child: CircularProgressIndicator(
                color: Get.context!.theme.colorScheme.surfaceContainerLowest,
                strokeWidth: 2.5,
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.login_rounded,
                  size: fontSize * 1.1,
                  color: Get.context!.theme.colorScheme.surfaceContainerLowest,
                ),
                SizedBox(width: fontSize * 0.5),
                Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: Get.context!.theme.colorScheme
                        .surfaceContainerLowest,
                  ),
                ),
              ],
            ),
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
  return Obx(() =>
      AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        height: errorMessage.value.isNotEmpty ? null : 0,
        margin: EdgeInsets.only(
            bottom: errorMessage.value.isNotEmpty ? fontSize * 0.8 : 0),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: errorMessage.value.isNotEmpty ? 1.0 : 0.0,
          child: errorMessage.value.isNotEmpty
              ? Container(
            width: double.infinity,
            padding: EdgeInsets.all(fontSize * 0.9),
            decoration: BoxDecoration(
              color: Get.context!.theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Get.context!.theme.colorScheme.onSurface.withAlpha(100),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Get.context!.theme.colorScheme.onSurface,
                  size: iconSize,
                ),
                SizedBox(width: fontSize * 0.7),
                Expanded(
                  child: Text(
                    errorMessage.value,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      color: Get.context!.theme.colorScheme.onSurface,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ),
          )
              : const SizedBox(),
        ),
      ));
}

Widget buildForgotPasswordButton({
  required VoidCallback onPressed,
  required double fontSize,
}) {
  return Center(
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: fontSize * 1.2,
          vertical: fontSize * 0.6,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(fontSize * 0.8),
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(
          Get.context!.theme.colorScheme.onSurface.withAlpha(20),
        ),
      ),
      child: Text(
        'Forgot Password?',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: Get.context!.theme.colorScheme.onSurface,
          letterSpacing: 0.2,
        ),
      ),
    ),
  );
}