import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_config.dart' show AppText;
import '../../../routes/app_routes.dart';
import '../../../widgets/settings_widget.dart';
import '../../admins/create_admins/create_admin_view.dart';
import '../home_controller.dart';

class MobileHome extends GetView<HomeController> {
  const MobileHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.surface,
      appBar: _buildMobileAppBar(context),
      body: _buildMobileBody(context),
    );
  }

  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    return AppBar(
      title: AppText.semiBold(
        'Dashboard',
        color: context.theme.colorScheme.onSurface,
        size: 20,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: context.theme.colorScheme.onSurface,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: SettingsWidget(),
        ),
      ],
    );
  }

  Widget _buildMobileBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // Analytics Dashboard Card
          _buildMobileCard(
            context: context,
            onTap: () => Get.toNamed<void>(AppRoutes.dashboard),
            icon: Icons.analytics_outlined,
            title: 'Analytics',
            subtitle: 'View insights and metrics',
            isPrimary: true,
          ),
          
          const SizedBox(height: 12),

          // Admin Management Card with Add Button
          _buildAdminManagementCard(context),
        ],
      ),
    );
  }

  Widget _buildMobileCard({
    required BuildContext context,
    required VoidCallback onTap,
    required IconData icon,
    required String title,
    required String subtitle,
    bool isPrimary = false,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Material(
        color: isPrimary 
          ? context.theme.colorScheme.onSurface
            : context.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: context.theme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.semiBold(
                        title,
                        color: context.theme.colorScheme.surfaceContainerLowest,
                        size: 16,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        subtitle,
                        color: context.theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.7),
                        size: 14,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: context.theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 16,
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
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Material(
        color: context.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () =>
              AdminBottomSheets.showAdminOptionsBottomSheet(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.admin_panel_settings_outlined,
                    color: context.theme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.semiBold(
                        'Admin Management',
                        color: context.theme.colorScheme.onSurface,
                        size: 16,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        'Add new admin or delivery person',
                        color: context.theme.colorScheme.onSurface.withValues(alpha: 
                            0.7),
                        size: 14,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.onSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add,
                    color: context.theme.colorScheme.surfaceContainerLowest,
                    size: 20,
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
