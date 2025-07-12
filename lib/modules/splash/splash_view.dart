import 'package:admin/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'splash_controller.dart';

class Splash extends GetView<SplashController> {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: Get.height,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dashboard),
            Text('dashboard'.tr),
            const SizedBox(
              height: 100,
            ),
            InkWell(
                onTap: () {
                  Get.toNamed(AppRoutes.login);
                },
                child: Text('Change language'.tr)),
          ],
        )),
      ),
    );
  }
}
