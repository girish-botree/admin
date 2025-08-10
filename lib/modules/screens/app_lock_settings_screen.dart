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
          'App Lock Settings',
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
          _buildSectionHeader('Security'),

          // Master app lock toggle
          Obx(() =>
              _buildSettingsTile(
                icon: Icons.security,
                title: 'Enable App Lock',
                subtitle: 'Secure your app with authentication',
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
            title: 'Biometric Authentication',
            subtitle: controller.isBiometricAvailable.value
                ? controller.biometricTypeString
                : 'Not available on this device',
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
            title: 'System Password',
            subtitle: 'Use device PIN, pattern, or password',
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
              _buildSectionHeader('Lock Timing'),

              _buildSettingsTile(
                icon: Icons.timer,
                title: 'Lock App After',
                subtitle: controller.lockTimeDisplayText,
                onTap: () => _showLockTimeDialog(context, controller),
              ),
            ],
          )
              : const SizedBox.shrink()),

          const SizedBox(height: 16),

          // Information section
          _buildSectionHeader('Information'),

          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About App Lock',
            subtitle: 'How app lock works',
            onTap: () => _showInfoDialog(context),
          ),

          // Troubleshooting section
          _buildSettingsTile(
            icon: Icons.build,
            title: 'Troubleshoot Biometrics',
            subtitle: 'Debug and refresh biometric settings',
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
                    'This is a security app. Keep app lock enabled to protect sensitive admin data.',
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
        title: const Text('Lock App After'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() =>
                _buildTimeOption(
                  'Immediately',
                  'Lock as soon as app goes to background',
                  'immediately',
                  controller.lockTimeOption.value,
                  controller,
                )),
            Obx(() =>
                _buildTimeOption(
                  'After 1 minute',
                  'Lock after 1 minute in background',
                  '1min',
                  controller.lockTimeOption.value,
                  controller,
                )),
            Obx(() =>
                _buildTimeOption(
                  'After 5 minutes',
                  'Lock after 5 minutes in background',
                  '5min',
                  controller.lockTimeOption.value,
                  controller,
                )),
            Obx(() =>
                _buildTimeOption(
                  'After 15 minutes',
                  'Lock after 15 minutes in background',
                  '15min',
                  controller.lockTimeOption.value,
                  controller,
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Close'),
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
        title: const Text('About App Lock'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'App Lock Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Biometric authentication (fingerprint, face, iris)'),
              Text('• System password backup (PIN, pattern, password)'),
              Text('• Customizable lock timing'),
              Text('• Background detection'),
              SizedBox(height: 16),
              Text(
                'Security Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• App locks when moved to background'),
              Text('• Settings are encrypted and stored securely'),
              Text('• Multiple authentication methods for redundancy'),
              Text('• Designed for admin app security requirements'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTroubleshootDialog(BuildContext context,
      AppLockController controller) {
    Get.dialog<void>(
      AlertDialog(
        title: const Text('Troubleshoot Biometrics'),
        content: SingleChildScrollView(
          child: Obx(() =>
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Device Supported: ${controller.isBiometricAvailable
                      .value}'),
                  const SizedBox(height: 8),
                  Text('Biometrics Enabled: ${controller.isBiometricEnabled
                      .value}'),
                  const SizedBox(height: 8),
                  Text('Available Types: ${controller.availableBiometrics}'),
                  const SizedBox(height: 8),
                  Text('System Password: ${controller.isSystemPasswordEnabled
                      .value}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final success = await controller.authenticate(
                          reason: 'Testing biometric authentication',
                        );
                        Get.snackbar(
                          success ? 'Success' : 'Failed',
                          success
                              ? 'Authentication successful'
                              : 'Authentication failed',
                          backgroundColor: success ? Colors.green : Colors.red,
                          colorText: Colors.white,
                        );
                      } catch (e) {
                        Get.snackbar('Error', 'Test failed: $e');
                      }
                    },
                    child: const Text('Test Authentication'),
                  ),
                ],
              )),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await controller.refreshBiometricAvailability();
              Get.back<void>();
              Get.snackbar('Success', 'Biometric settings refreshed');
            },
            child: const Text('Refresh'),
          ),
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}