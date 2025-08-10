import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_lock_controller.dart';
import '../modules/screens/app_lock_screen.dart';

class AppLockWrapper extends StatelessWidget {
  final Widget child;

  const AppLockWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppLockController>(
      builder: (controller) {
        return Obx(() {
          if (controller.isAppLocked.value &&
              controller.isAppLockEnabled.value) {
            return const AppLockScreen();
          }
          return child;
        });
      },
    );
  }
}