import 'package:admin/config/app_config.dart';
import 'package:admin/modules/admins/create_admins/create_admin_controller.dart';
import 'package:get/get.dart';

class CreateAdminBinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.put(CreateAdminController());
  }
}