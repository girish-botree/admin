import 'package:get/get.dart';
import '../../config/app_lock_controller.dart';

class AppLockBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure AppLockController is available
    if (!Get.isRegistered<AppLockController>()) {
      Get.put(AppLockController());
    }
  }
}

class AppLockSettingsBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure AppLockController is available
    if (!Get.isRegistered<AppLockController>()) {
      Get.put(AppLockController());
    }
  }
}