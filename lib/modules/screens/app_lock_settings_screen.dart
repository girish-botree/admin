import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_lock_controller.dart';
import '../../config/app_text.dart';

class AppLockSettingsScreen extends StatelessWidget {
  const AppLockSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppLockController>();

    return Scaffold(
      appBar: AppBar(
        title: AppText.semiBold(
          'app_lock'.tr,
          size: 20,
          color: context.theme.colorScheme.onSurface,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: context.theme.colorScheme.onSurface,
          ),
          onPressed: () => Get.back<void>(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('security'.tr),

          // Master app lock toggle
          Obx(() =>
              _buildSettingsTile(
                icon: Icons.security,
                title: 'app_lock'.tr,
                subtitle: 'biometric_security'.tr,
                trailing: Switch(
                  value: controller.isAppLockEnabled.value,
                  onChanged: (value) async {
                    if (value) {
                      await controller.enableAppLock();
                    } else {
                      await controller.disableAppLock();
                    }
                  },
                ),
              )),

          // Biometric authentication
          Obx(() =>
          controller.isAppLockEnabled.value
              ? _buildSettingsTile(
            icon: Icons.fingerprint,
            title: 'biometric_authentication'.tr,
            subtitle: controller.isBiometricAvailable.value
                ? controller.biometricTypeString
                : 'device_supported'.tr,
            trailing: Switch(
              value: controller.isBiometricEnabled.value &&
                  controller.isBiometricAvailable.value,
              onChanged: controller.isBiometricAvailable.value
                  ? (value) async {
                await controller.toggleBiometric();
              }
                  : null,
            ),
            isEnabled: controller.isBiometricAvailable.value,
          )
              : const SizedBox.shrink()),

          // System password
          Obx(() =>
          controller.isAppLockEnabled.value
              ? _buildSettingsTile(
            icon: Icons.password,
            title: 'system_password'.tr,
            subtitle: 'system_password_backup'.tr,
            trailing: Switch(
              value: controller.isSystemPasswordEnabled.value,
              onChanged: (value) async {
                await controller.toggleSystemPassword();
              },
            ),
          )
              : const SizedBox.shrink()),

          const SizedBox(height: 16),

          // Lock timing section
          Obx(() =>
          controller.isAppLockEnabled.value
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('customizable_lock_timing'.tr),

              _buildSettingsTile(
                icon: Icons.timer,
                title: 'lock_app_after'.tr,
                subtitle: controller.lockTimeDisplayText,
                onTap: () => _showLockTimeDialog(context, controller),
              ),
            ],
          )
              : const SizedBox.shrink()),

          const SizedBox(height: 16),

          // Information section
          _buildSectionHeader('information'.tr),

          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'about_app_lock'.tr,
            subtitle: 'security_features'.tr,
            onTap: () => _showInfoDialog(context),
          ),

          // Troubleshooting section
          _buildSettingsTile(
            icon: Icons.build,
            title: 'troubleshoot_biometrics'.tr,
            subtitle: 'biometrics_enabled'.tr,
            onTap: () => _showTroubleshootDialog(context, controller),
          ),

          const SizedBox(height: 32),

          // Security warning
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.theme.colorScheme.error.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning,
                  color: context.theme.colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppText.regular(
                    'security_warning'.tr,
                    size: 12,
                    color: context.theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Get.theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isEnabled = true,
  }) {
    return Card(
      elevation: 2,
      color: Get.context!.theme.colorScheme.surfaceContainerLowest,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isEnabled
              ? Get.theme.colorScheme.onSurface
              : Get.theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isEnabled
                ? null
                : Get.theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isEnabled
                ? null
                : Get.theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        trailing: trailing ??
            (onTap != null ? const Icon(Icons.chevron_right) : null),
        onTap: isEnabled ? onTap : null,
      ),
    );
  }

  void _showLockTimeDialog(BuildContext context, AppLockController controller) {
    Get.dialog<void>(
      AlertDialog(
        title: Text('lock_app_after'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() =>
                _buildTimeOption(
                  'immediately'.tr,
                  'app_locks_background'.tr,
                  'immediately',
                  controller.lockTimeOption.value,
                  controller,
                )),
            Obx(() =>
                _buildTimeOption(
                  'after_1_minute'.tr,
                  'lock_after_1_minute'.tr,
                  '1min',
                  controller.lockTimeOption.value,
                  controller,
                )),
            Obx(() =>
                _buildTimeOption(
                  'after_5_minutes'.tr,
                  'lock_after_5_minutes'.tr,
                  '5min',
                  controller.lockTimeOption.value,
                  controller,
                )),
            Obx(() =>
                _buildTimeOption(
                  'after_15_minutes'.tr,
                  'lock_after_15_minutes'.tr,
                  '15min',
                  controller.lockTimeOption.value,
                  controller,
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text('close'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeOption(String title,
      String subtitle,
      String value,
      String selectedValue,
      AppLockController controller,) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: selectedValue == value
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () async {
        await controller.setLockTimeOption(value);
        Get.back<void>();
      },
    );
  }

  void _showInfoDialog(BuildContext context) {
    Get.dialog<void>(
      AlertDialog(
        title: Text('about_app_lock'.tr),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'security_features'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('biometric_authentication'.tr),
              Text('system_password_backup'.tr),
              Text('customizable_lock_timing'.tr),
              Text('background_detection'.tr),
              const SizedBox(height: 16),
              Text(
                'security_notes'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('app_locks_background'.tr),
              Text('settings_encrypted'.tr),
              Text('multiple_auth_methods'.tr),
              Text('admin_security'.tr),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text('close'.tr),
          ),
        ],
      ),
    );
  }

  void _showTroubleshootDialog(BuildContext context,
      AppLockController controller) {
    Get.dialog<void>(
      AlertDialog(
        title: Text('troubleshoot_biometrics'.tr),
        content: SingleChildScrollView(
          child: Obx(() =>
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('device_supported'.tr +
                      ': ${controller.isBiometricAvailable
                      .value}'),
                  const SizedBox(height: 8),
                  Text('biometrics_enabled'.tr +
                      ': ${controller.isBiometricEnabled
                      .value}'),
                  const SizedBox(height: 8),
                  Text('available_types'.tr +
                      ': ${controller.availableBiometrics}'),
                  const SizedBox(height: 8),
                  Text('system_password'.tr +
                      ': ${controller.isSystemPasswordEnabled
                      .value}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final success = await controller.authenticate(
                          reason: 'test_authentication'.tr,
                        );
                        Get.snackbar(
                          success ? 'success'.tr : 'error'.tr,
                          success
                              ? 'success'.tr
                              : 'error'.tr,
                          backgroundColor: success ? Colors.green : Colors.red,
                          colorText: Colors.white,
                        );
                      } catch (e) {
                        Get.snackbar('error'.tr, 'error'.tr + ': $e');
                      }
                    },
                    child: Text('test_authentication'.tr),
                  ),
                ],
              )),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await controller.refreshBiometricAvailability();
              Get.back<void>();
              Get.snackbar('success'.tr, 'refresh'.tr);
            },
            child: Text('refresh'.tr),
          ),
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text('close'.tr),
          ),
        ],
      ),
    );
  }
}