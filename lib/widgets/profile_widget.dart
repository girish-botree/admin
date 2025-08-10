import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/main_layout/main_layout_controller.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainLayoutController>();
    
    return Obx(() => PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'logout') {
          controller.logout();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: context.theme.colorScheme.primary,
              child: Icon(
                Icons.person,
                size: 20,
                color: context.theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 8),
            if (controller.userEmail.isNotEmpty)
              Text(
                controller.userEmail.value,
                style: TextStyle(
                  color: context.theme.colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 16),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
        ),
      ],
    ));
  }
}