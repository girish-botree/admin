import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/theme_controller.dart';
import '../../language/language_controller.dart';
import '../main_layout/main_layout_controller.dart';
import '../../widgets/circular_back_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildSettingsSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      elevation: 0,
      backgroundColor: context.theme.colorScheme.background,
      surfaceTintColor: Colors.transparent,
      pinned: true,
      leading: const CircularBackButton(backgroundColor: null),
      title: Text(
        'settings'.tr,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: context.theme.colorScheme.onBackground,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      children: [
        _buildSettingsGroup([
          Obx(() {
            final themeController = Get.find<ThemeController>();
            String currentTheme;
            IconData themeIcon;
            switch (themeController.themeMode.value) {
              case ThemeMode.light:
                currentTheme = 'light'.tr;
                themeIcon = Icons.light_mode_outlined;
                break;
              case ThemeMode.dark:
                currentTheme = 'dark'.tr;
                themeIcon = Icons.dark_mode_outlined;
                break;
              case ThemeMode.system:
                currentTheme = 'system'.tr;
                themeIcon = Icons.phone_android_outlined;
                break;
            }
            return _buildSettingsTile(
              icon: themeIcon,
              title: 'theme'.tr,
              subtitle: currentTheme,
              onTap: () => _showThemeDialog(),
              isFirst: true,
            );
          }),
          Obx(() {
            final languageController = Get.find<LanguageController>();
            final locale = languageController.locale.value.languageCode;
            String currentLanguage;
            if (locale == 'en') {
              currentLanguage = 'english'.tr;
            } else if (locale == 'ta') {
              currentLanguage = 'tamil'.tr;
            } else if (locale == 'hi') {
              currentLanguage = 'hindi'.tr;
            } else {
              currentLanguage = 'english'.tr;
            }
            return _buildSettingsTile(
              icon: Icons.language_outlined,
              title: 'language'.tr,
              subtitle: currentLanguage,
              onTap: () => _showLanguageDialog(),
              isLast: true,
            );
          }),
        ]),

        _buildSettingsGroup([
          _buildSettingsTile(
            icon: Icons.info_outlined,
            title: 'about'.tr,
            subtitle: 'version'.tr,
            onTap: () => _showAboutDialog(),
            isFirst: true,
            isLast: true,
          ),
        ]),


        _buildLogoutButton(),
      ],
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Get.context!.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: !isLast ? Border(
              bottom: BorderSide(
                color: Get.context!.theme.colorScheme.outline.withValues(
                    alpha: 0.1),
                width: 0.5,
              ),
            ) : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: Get.context!.theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Get.context!.theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Get.context!.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Get.context!.theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Get.context!.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutConfirmation(),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(
                  Icons.logout,
                  size: 24,
                  color: Colors.red,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'logout'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Get.theme.colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'logout'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Get.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'logout_confirmation'.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: Get.theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back<void>(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'cancel'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Get.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final controller = Get.find<MainLayoutController>();
                        Get.back<void>();
                        controller.logout();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'logout'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeDialog() {
    final themeController = Get.find<ThemeController>();

    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Get.theme.colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'theme'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Get.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              _buildThemeOption(
                  'light'.tr, Icons.light_mode_outlined, ThemeMode.light,
                  themeController),
              _buildThemeOption(
                  'dark'.tr, Icons.dark_mode_outlined, ThemeMode.dark,
                  themeController),
              _buildThemeOption(
                  'system'.tr, Icons.phone_android_outlined, ThemeMode.system,
                  themeController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(String title, IconData icon, ThemeMode mode,
      ThemeController controller) {
    return Obx(() =>
        InkWell(
          onTap: () {
            controller.changeThemeMode(mode);
            Get.back<void>();
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: Get.theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Get.theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (controller.themeMode.value == mode)
                  Icon(
                    Icons.check,
                    size: 20,
                    color: Get.theme.colorScheme.primary,
                  ),
              ],
            ),
          ),
        ));
  }

  void _showLanguageDialog() {
    final languageController = Get.find<LanguageController>();

    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Get.theme.colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'language'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Get.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              _buildLanguageOption('english'.tr, 'en', languageController),
              _buildLanguageOption('tamil'.tr, 'ta', languageController),
              _buildLanguageOption('hindi'.tr, 'hi', languageController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String title, String langCode,
      LanguageController controller) {
    return Obx(() =>
        InkWell(
          onTap: () {
            // Map language codes to file names
            String langFile;
            if (langCode == 'en') {
              langFile = 'english';
            } else if (langCode == 'ta') {
              langFile = 'tamil';
            } else if (langCode == 'hi') {
              langFile = 'hindi';
            } else {
              langFile = 'english';
            }
            // Set the language using the file name
            controller.setLanguage(langFile);
            Get.back<void>();
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Get.theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (controller.locale.value.languageCode == langCode)
                  Icon(
                    Icons.check,
                    size: 20,
                    color: Get.theme.colorScheme.primary,
                  ),
              ],
            ),
          ),
        ));
  }

  void _showAboutDialog() {
    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Get.theme.colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'about'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Get.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.info_outlined,
                    size: 20,
                    color: Get.theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'version'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      color: Get.theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.person_outlined,
                    size: 20,
                    color: Get.theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'developer_contact'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      color: Get.theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}