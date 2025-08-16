import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_text.dart';
import '../../config/theme_controller.dart';
import '../../language/language_controller.dart';
import '../main_layout/main_layout_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      appBar: AppBar(
        title: AppText.semiBold('settings'.tr, size: 20,
            color: context.theme.colorScheme.onSurface),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Get.context!.theme.colorScheme.onSurface,),
          onPressed: () => Get.back<void>(),
        ),
      ),
      body: _buildResponsiveLayout(screenWidth),
    );
  }

  Widget _buildResponsiveLayout(double screenWidth) {
    if (screenWidth < 600) {
      // Mobile Layout
      return _buildMobileLayout();
    } else if (screenWidth < 900) {
      // Tablet Layout
      return _buildTabletLayout();
    } else {
      // Web Layout
      return _buildWebLayout();
    }
  }

  Widget _buildMobileLayout() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _buildSettingsItems(),
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: _buildSettingsItems(),
        ),
      ),
    );
  }

  Widget _buildWebLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('about'.tr),
            _buildSettingsTile(
              icon: Icons.info,
              title: 'about'.tr,
              subtitle: 'version_info'.tr,
              onTap: () => _showAboutDialog(Get.context!),
            ),

            const SizedBox(height: 32),
            _buildSettingsTile(
              icon: Icons.logout,
              title: 'logout'.tr,
              subtitle: 'sign_out'.tr,
              onTap: () {
                final controller = Get.find<MainLayoutController>();
                controller.logout();
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSettingsItems() {
    return [
      _buildSectionHeader('appearance'.tr),
      Obx(() {
        final themeController = Get.find<ThemeController>();
        String currentTheme;
        switch (themeController.themeMode.value) {
          case ThemeMode.light:
            currentTheme = 'light_theme'.tr;
            break;
          case ThemeMode.dark:
            currentTheme = 'dark_theme'.tr;
            break;
          case ThemeMode.system:
            currentTheme = 'System Theme'.tr;
            break;
        }
        return _buildSettingsTile(
          icon: Icons.palette,
          title: 'theme'.tr,
          subtitle: currentTheme,
          onTap: () => _showThemeDialog(Get.context!),
        );
      }),

      const SizedBox(height: 16),
      _buildSectionHeader('localization'.tr),
      _buildSettingsTile(
        icon: Icons.language,
        title: 'language'.tr,
        subtitle: '${'english'.tr}, ${'tamil'.tr}',
        onTap: () => _showLanguageDialog(Get.context!),
      ),

      const SizedBox(height: 16),
      _buildSectionHeader('about'.tr),
      _buildSettingsTile(
        icon: Icons.info,
        title: 'about'.tr,
        subtitle: 'version_info'.tr,
        onTap: () => _showAboutDialog(Get.context!),
      ),

      const SizedBox(height: 32),
      _buildSettingsTile(
        icon: Icons.logout,
        title: 'logout'.tr,
        subtitle: 'sign_out'.tr,
        onTap: () {
          final controller = Get.find<MainLayoutController>();
          controller.logout();
        },
        isDestructive: true,
      ),
    ];
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
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      elevation: 2,
      color: Get.context!.theme.colorScheme.surfaceContainerLowest,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Get.theme.colorScheme.onSurface,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    Get.dialog<void>(
      AlertDialog(
        title: Text('theme_settings'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() =>
                ListTile(
                  title: Text('light_theme'.tr),
              leading: const Icon(Icons.light_mode),
              trailing: themeController.themeMode.value == ThemeMode.light
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                themeController.changeThemeMode(ThemeMode.light);
                Get.back<void>();
              },
            )),
            Obx(() =>
                ListTile(
                  title: Text('dark_theme'.tr),
                  leading: const Icon(Icons.dark_mode),
                  trailing: themeController.themeMode.value == ThemeMode.dark
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    themeController.changeThemeMode(ThemeMode.dark);
                    Get.back<void>();
                  },
                )),
            Obx(() =>
                ListTile(
                  title: Text('System Theme'.tr),
                  leading: const Icon(Icons.settings_suggest),
                  trailing: themeController.themeMode.value == ThemeMode.system
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    themeController.changeThemeMode(ThemeMode.system);
                    Get.back<void>();
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final languageController = Get.find<LanguageController>();

    Get.dialog<void>(
      AlertDialog(
        title: Text('language_settings'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() =>
                ListTile(
                  title: Text('english'.tr),
              trailing: languageController.locale.value.languageCode == 'en'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                languageController.changeLanguage(const Locale('en', 'US'));
                Get.back<void>();
              },
            )),
            Obx(() =>
                ListTile(
                  title: Text('tamil'.tr),
              trailing: languageController.locale.value.languageCode == 'ta'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                languageController.changeLanguage(const Locale('ta', 'IN'));
                Get.back<void>();
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    Get.dialog<void>(
      AlertDialog(
        title: Text('about'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, size: 20),
                const SizedBox(width: 8),
                Text(
                  'version'.tr,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 8),
                Text(
                  'developer_contact'.tr,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('email'.tr),
                  const SizedBox(height: 4),
                  Text('website'.tr),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back<void>(),
              child: Text('close'.tr)),
        ],
      ),
    );
  }
}