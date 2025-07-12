import 'package:get/get.dart';

import '../../config/app_network_connection.dart';


class SplashController extends GetxController {
  @override
  void onInit() {
    Future.delayed(const Duration(seconds: 2), () {
      AppNetworkConnection.checkInternetConnection();
    });
    super.onInit();

  }

  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(milliseconds: 3000), () {
      print("sddd");
    });


  }

}