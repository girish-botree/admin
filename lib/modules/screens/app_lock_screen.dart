import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_lock_controller.dart';
import '../../config/app_text.dart';

class AppLockScreen extends StatelessWidget {
  const AppLockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppLockController>();

    return Scaffold(
      backgroundColor: context.theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon/Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.lock,
                  size: 50,
                  color: context.theme.colorScheme.onPrimaryContainer,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              AppText.semiBold(
                'App Locked',
                size: 28,
                color: context.theme.colorScheme.onSurface,
              ),

              const SizedBox(height: 16),

              // Description
              AppText.regular(
                'Please authenticate to access the admin app',
                size: 16,
                color: context.theme.colorScheme.onSurfaceVariant,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Biometric info
              Obx(() =>
              controller.isBiometricEnabled.value &&
                  controller.isBiometricAvailable.value
                  ? Column(
                children: [
                  Icon(
                    _getBiometricIcon(controller.availableBiometrics.first),
                    size: 48,
                    color: context.theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  AppText.medium(
                    controller.biometricTypeString,
                    size: 16,
                    color: context.theme.colorScheme.onSurface,
                  ),
                  const SizedBox(height: 32),
                ],
              )
                  : const SizedBox.shrink()),

              // Unlock button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final success = await controller.authenticate();
                    if (!success) {
                      Get.snackbar(
                        'Authentication Failed',
                        'Please try again',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() =>
                          Icon(
                            controller.isBiometricEnabled.value && controller
                                .isBiometricAvailable.value
                                ? _getBiometricIcon(
                                controller.availableBiometrics.isNotEmpty
                                    ? controller.availableBiometrics.first
                                    : null)
                                : Icons.lock_open,
                          )),
                      const SizedBox(width: 12),
                      AppText.semiBold(
                        'Unlock App',
                        size: 16,
                        color: context.theme.colorScheme.onPrimary,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Alternative unlock methods
              Obx(() =>
              controller.isSystemPasswordEnabled.value
                  ? TextButton(
                onPressed: () async {
                  final success = await controller.authenticate();
                  if (!success) {
                    Get.snackbar(
                      'Authentication Failed',
                      'Please try again',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                child: AppText.medium(
                  'Use System Password',
                  size: 14,
                  color: context.theme.colorScheme.primary,
                ),
              )
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getBiometricIcon(dynamic biometricType) {
    if (biometricType == null) return Icons.lock_open;

    switch (biometricType.toString()) {
      case 'BiometricType.fingerprint':
        return Icons.fingerprint;
      case 'BiometricType.face':
        return Icons.face;
      case 'BiometricType.iris':
        return Icons.visibility;
      default:
        return Icons.security;
    }
  }
}