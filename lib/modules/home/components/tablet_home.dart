import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_config.dart' show AppText;
import '../../../routes/app_routes.dart';
import '../../../widgets/settings_widget.dart';
import '../../admins/create_admins/create_admin_view.dart';
import '../home_controller.dart';

class TabletHome extends GetView<HomeController> {
  const TabletHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.surface,
      appBar: _buildTabletAppBar(context),
      body: _buildTabletBody(context),
    );
  }

  PreferredSizeWidget _buildTabletAppBar(BuildContext context) {
    return AppBar(
      title: AppText.semiBold(
        'Dashboard',
        color: context.theme.colorScheme.onSurface,
        size: 24,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: context.theme.colorScheme.onSurface,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 24.0),
          child: SettingsWidget(),
        ),
      ],
    );
  }

  Widget _buildTabletBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      child: Column(
        children: [
          // Main content in a row layout for better tablet utilization
          Row(
            children: [
              // Left column - Primary cards
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildTabletCard(
                      context: context,
                      onTap: () => Get.toNamed<void>(AppRoutes.dashboard),
                      icon: Icons.analytics_outlined,
                      title: 'Analytics Dashboard',
                      subtitle: 'View comprehensive insights and metrics',
                      isPrimary: true,
                    ),
                    const SizedBox(height: 16),
                    _buildAdminManagementCard(context),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabletCard({
    required BuildContext context,
    required VoidCallback onTap,
    required IconData icon,
    required String title,
    required String subtitle,
    bool isPrimary = false,
  }) {
    return Container(
      width: double.infinity,
      child: Material(
        color: isPrimary 
          ? context.theme.colorScheme.primaryContainer
            : context.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        elevation: isPrimary ? 2 : 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: context.theme.colorScheme.onSurface,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.semiBold(
                        title,
                        color: context.theme.colorScheme.onSurface,
                        size: 18,
                      ),
                      const SizedBox(height: 6),
                      AppText(
                        subtitle,
                        color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        size: 14,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: context.theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminManagementCard(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Material(
        color: context.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        child: InkWell(
          onTap: () =>
              AdminBottomSheets.showRegistrationBottomSheet(context, "admin"),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.admin_panel_settings_outlined,
                    color: context.theme.colorScheme.onSurface,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.semiBold(
                        'Admin Management',
                        color: context.theme.colorScheme.onSurface,
                        size: 18,
                      ),
                      const SizedBox(height: 6),
                      AppText(
                        'Add new admin account',
                        color: context.theme.colorScheme.onSurface.withValues(alpha: 
                            0.7),
                        size: 14,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.onSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add,
                    color: context.theme.colorScheme.surfaceContainerLowest,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
