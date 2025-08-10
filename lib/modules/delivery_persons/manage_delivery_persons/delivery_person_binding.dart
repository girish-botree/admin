import 'package:get/get.dart';
import 'delivery_person_controller.dart';

class DeliveryPersonBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryPersonController>(() => DeliveryPersonController());
  }
}