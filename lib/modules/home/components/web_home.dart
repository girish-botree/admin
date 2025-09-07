import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../../config/app_config.dart' show AppText;
import '../../../routes/app_routes.dart';
import '../../../widgets/settings_widget.dart';
import '../../admins/create_admins/create_admin_view.dart';
import '../home_controller.dart';

class WebHome extends GetView<HomeController> {
  const WebHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.theme.colorScheme.surfaceContainerLowest.withOpacity(0.3),
            context.theme.colorScheme.surfaceContainerLowest.withOpacity(0.2),
            context.theme.colorScheme.surfaceContainerLowest.withOpacity(0.1),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildWebAppBar(context),
        body: _buildWebBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildWebAppBar(BuildContext context) {
    return AppBar(
      title: AppText.bold(
        'Dashboard',
        color: context.theme.colorScheme.onSurface,
        size: 20,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: context.theme.colorScheme.onSurface,
      centerTitle: false,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: SettingsWidget(),
        ),
      ],
    );
  }

  Widget _buildWebBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // Analytics Dashboard Card
          _buildWebCard(
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

  Widget _buildWebCard({
    required BuildContext context,
    required VoidCallback onTap,
    required IconData icon,
    required String title,
    required String subtitle,
    bool isPrimary = false,
  }) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      blur: 10,
      borderRadius: 12,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
        stops: const [0.1, 1],
      ),
      border: 2,
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          context.theme.colorScheme.onSurface.withOpacity(0.5),
          context.theme.colorScheme.onSurface.withOpacity(0.5),
        ],
      ),
      child: Material(
        color: Colors.transparent,
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
                        color: context.theme.colorScheme.surfaceContainerLowest
                            .withValues(alpha: 0.7),
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
    return GlassmorphicContainer(
      width: double.infinity,
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      blur: 10,
      borderRadius: 12,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
        stops: const [0.1, 1],
      ),
      border: 2,
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          context.theme.colorScheme.onSurface.withOpacity(0.5),
          context.theme.colorScheme.onSurface.withOpacity(0.5),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => Get.toNamed<void>(AppRoutes.deliveryPersons),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(
                            Icons.admin_panel_settings_outlined,
                            color: context.theme.colorScheme.onSurface,
                            size: 24,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.semiBold(
                        'Delivery Management',
                        color: context.theme.colorScheme.onSurface,
                        size: 16,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        'Handle delivery person',
                        color: context.theme.colorScheme.onSurface.withValues(
                            alpha: 0.7),
                        size: 14,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      AdminBottomSheets.showAdminOptionsBottomSheet(context),
                  child: Container(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
