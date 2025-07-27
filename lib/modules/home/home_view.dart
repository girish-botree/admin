import 'package:admin/config/app_config.dart' show AppText;
import 'package:admin/modules/admins/create_admins/create_admin_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';

class HomeView extends StatelessWidget{
  final bool showBottomNav;
  HomeView({super.key, this.showBottomNav = true});
  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.semiBold('Dashboard',color: context.theme.colorScheme.onSurface,size:20),
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        foregroundColor: context.theme.colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => controller.logout(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: GestureDetector(
                    onTap: () => Get.toNamed('/admins'),
                    child: Card(
                      elevation: 2,
                      color: context.theme.colorScheme.onSurface,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manage administrators',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: context.theme.colorScheme.surfaceContainerLowest,
                              ),
                            ),
                            SizedBox(height: 8),
                            AppText(
                              'Here you can view existing ones, or update their details.',
                              size: 14,
                              color: context.theme.colorScheme.surfaceContainerLowest,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () => AdminBottomSheets.showAdminOptionsBottomSheet(context),
                    child: Card(
                      elevation: 2,
                      color: context.theme.colorScheme.surfaceContainerLow,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(
                          Icons.add,
                          size: 50,
                        ),
                      )),
                  ),
                )
              ])
          ],
        ),
      ),
    );
  }
}