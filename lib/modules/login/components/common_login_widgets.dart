

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Color(0xFFF5F5F5)],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: borderRadius * 0.8,
          offset: Offset(0, borderRadius * 0.3),
        ),
      ],
    ),
    child: Icon(
      Icons.admin_panel_settings_rounded,
      size: iconSize,
      color: Colors.red.shade700,
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
      Text(
        'Welcome Back',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2D3748),
        ),
      ),
      SizedBox(height: fontSize * 0.25),
      Text(
        'Sign in to continue to your dashboard',
        style: TextStyle(
          fontSize: subtitleFontSize,
          color: Colors.grey.shade600,
        ),
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
    style: TextStyle(fontSize: fontSize),
    validator: validator,
    onChanged: (_) => onChanged(),
    decoration: InputDecoration(
      labelText: 'Email',
      hintText: 'Enter your email',
      prefixIcon: Icon(
        Icons.email_outlined,
        color: Colors.red.shade400,
        size: iconSize,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
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
    style: TextStyle(fontSize: fontSize),
    validator: validator,
    onChanged: (_) => onChanged(),
    decoration: InputDecoration(
      labelText: 'Password',
      hintText: 'Enter your password',
      prefixIcon: Icon(
        Icons.lock_outline,
        color: Colors.red.shade400,
        size: iconSize,
      ),
      suffixIcon: IconButton(
        icon: Icon(
          isPasswordVisible.value
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: Colors.grey.shade600,
          size: iconSize,
        ),
        onPressed: toggleVisibility,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
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
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 4,
        disabledBackgroundColor: Colors.grey.shade300,
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
          : Text(
              'Login',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
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
  return Obx(() => errorMessage.value.isNotEmpty
      ? Container(
          width: double.infinity,
          padding: EdgeInsets.all(fontSize * 0.8),
          margin: EdgeInsets.only(bottom: fontSize),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade600,
                size: iconSize,
              ),
              SizedBox(width: fontSize * 0.5),
              Expanded(
                child: Text(
                  errorMessage.value,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: fontSize,
                  ),
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
      child: Text(
        'Forgot Password?',
        style: TextStyle(
          color: Colors.red.shade400,
          fontWeight: FontWeight.w500,
          fontSize: fontSize,
        ),
      ),
    ),
  );
}

Widget buildDemoCredentials({
  required double fontSize,
  required double borderRadius,
  required double iconSize,
}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(fontSize * 1.2),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: Colors.red.shade200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.red.shade600,
              size: iconSize,
            ),
            SizedBox(width: fontSize * 0.5),
            Text(
              'Demo Credentials',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade800,
              ),
            ),
          ],
        ),
        SizedBox(height: fontSize * 0.5),
        Text(
          'Email: jagadeeshgiribabu@gmail.com',
          style: TextStyle(
            fontSize: fontSize * 0.9,
            color: Colors.red.shade700,
          ),
        ),
        SizedBox(height: fontSize * 0.3),
        Text(
          'Password: Test@123',
          style: TextStyle(
            fontSize: fontSize * 0.9,
            color: Colors.red.shade700,
          ),
        ),
      ],
    ),
  );
}