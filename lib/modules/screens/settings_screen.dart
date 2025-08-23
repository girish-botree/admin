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
      backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
      appBar: _buildModernAppBar(context),
      body: _buildResponsiveLayout(screenWidth),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Get.back<void>(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: context.theme.colorScheme.onSurface,
          ),
        ),
      ),
      title: Text(
        'settings'.tr,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: context.theme.colorScheme.onSurface,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildResponsiveLayout(double screenWidth) {
    if (screenWidth < 600) {
      return _buildMobileLayout();
    } else if (screenWidth < 900) {
      return _buildTabletLayout();
    } else {
      return _buildWebLayout();
    }
  }

  Widget _buildMobileLayout() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate(_buildSettingsItems()),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(32),
              sliver: SliverList(
                delegate: SliverChildListDelegate(_buildSettingsItems()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildWelcomeHeader(),
                  const SizedBox(height: 40),
                  ..._buildSettingsItems(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Get.theme.colorScheme.primary.withValues(alpha: 0.1),
            Get.theme.colorScheme.secondary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.settings_rounded,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings & Preferences',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Get.theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Customize your experience',
                      style: TextStyle(
                        fontSize: 16,
                        color: Get.theme.colorScheme.onSurface.withValues(
                            alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSettingsItems() {
    return [
      _buildModernSectionHeader('appearance'.tr, Icons.palette_rounded),
      const SizedBox(height: 16),
      Obx(() {
        final themeController = Get.find<ThemeController>();
        String currentTheme;
        IconData themeIcon;
        switch (themeController.themeMode.value) {
          case ThemeMode.light:
            currentTheme = 'light_theme'.tr;
            themeIcon = Icons.light_mode_rounded;
            break;
          case ThemeMode.dark:
            currentTheme = 'dark_theme'.tr;
            themeIcon = Icons.dark_mode_rounded;
            break;
          case ThemeMode.system:
            currentTheme = 'System Theme'.tr;
            themeIcon = Icons.settings_suggest_rounded;
            break;
        }
        return _buildModernSettingsTile(
          icon: themeIcon,
          title: 'theme'.tr,
          subtitle: currentTheme,
          onTap: () => _showModernThemeDialog(Get.context!),
          color: Colors.purple,
        );
      }),

      const SizedBox(height: 32),
      _buildModernSectionHeader('localization'.tr, Icons.language_rounded),
      const SizedBox(height: 16),
      Obx(() {
        final languageController = Get.find<LanguageController>();
        final isEnglish = languageController.locale.value.languageCode == 'en';
        return _buildModernSettingsTile(
          icon: Icons.translate_rounded,
          title: 'language'.tr,
          subtitle: isEnglish ? 'english'.tr : 'tamil'.tr,
          onTap: () => _showModernLanguageDialog(Get.context!),
          color: Colors.blue,
        );
      }),

      const SizedBox(height: 32),
      _buildModernSectionHeader('about'.tr, Icons.info_rounded),
      const SizedBox(height: 16),
      _buildModernSettingsTile(
        icon: Icons.info_outline_rounded,
        title: 'about'.tr,
        subtitle: 'version_info'.tr,
        onTap: () => _showModernAboutDialog(Get.context!),
        color: Colors.green,
      ),

      const SizedBox(height: 40),
      _buildModernLogoutTile(),
      const SizedBox(height: 32),
    ];
  }

  Widget _buildModernSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Get.theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Get.theme.colorScheme.onSurface,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Get.context!.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Get.context!.theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Get.context!.theme.colorScheme.shadow.withValues(
                alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? Colors.red.withValues(alpha: 0.1)
                        : color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: isDestructive ? Colors.red : color,
                  ),
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
                          fontWeight: FontWeight.w600,
                          color: isDestructive
                              ? Colors.red
                              : Get.theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Get.theme.colorScheme.onSurface.withValues(
                              alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: Get.theme.colorScheme.onSurface.withValues(
                        alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernLogoutTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutConfirmation(),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 24,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'logout'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'sign_out'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: Colors.red.withValues(alpha: 0.7),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Get.theme.colorScheme.surface,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 32,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Confirm Logout',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Get.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to sign out of your account?',
                style: TextStyle(
                  fontSize: 16,
                  color: Get.theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back<void>(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(
                          color: Get.theme.colorScheme.outline.withValues(
                              alpha: 0.5),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final controller = Get.find<MainLayoutController>();
                        Get.back<void>();
                        controller.logout();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Logout'),
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

  void _showModernThemeDialog(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Get.theme.colorScheme.surface,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Theme Settings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Get.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Obx(() =>
                  ListTile(
                    title: Text('Light Theme'),
                    leading: const Icon(Icons.light_mode_rounded),
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
                    title: Text('Dark Theme'),
                    leading: const Icon(Icons.dark_mode_rounded),
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
                    title: Text('System Theme'),
                    leading: const Icon(Icons.settings_suggest_rounded),
                    trailing: themeController.themeMode.value ==
                        ThemeMode.system
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
      ),
    );
  }

  void _showModernLanguageDialog(BuildContext context) {
    final languageController = Get.find<LanguageController>();

    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Get.theme.colorScheme.surface,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Language Settings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Get.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Obx(() =>
                  ListTile(
                    title: Text('English'),
                    trailing: languageController.locale.value.languageCode ==
                        'en'
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      languageController.changeLanguage(
                          const Locale('en', 'US'));
                      Get.back<void>();
                    },
                  )),
              Obx(() =>
                  ListTile(
                    title: Text('Tamil'),
                    trailing: languageController.locale.value.languageCode ==
                        'ta'
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      languageController.changeLanguage(
                          const Locale('ta', 'IN'));
                      Get.back<void>();
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _showModernAboutDialog(BuildContext context) {
    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Get.theme.colorScheme.surface,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'About',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Get.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Version',
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
                    'Developer Contact',
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
                    Text('Email'),
                    const SizedBox(height: 4),
                    Text('Website'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}