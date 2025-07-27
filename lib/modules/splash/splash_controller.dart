import 'package:get/get.dart';
import 'package:http/http.dart' as _sharedPreference;
import '../../config/app_network_connection.dart';
import '../../routes/app_routes.dart';
import '../../config/shared_preference.dart';
import '../../config/appconstants.dart';


class SplashController extends GetxController {
  @override
  void onInit() {
    Future.delayed(const Duration(seconds: 2), () {
      AppNetworkConnection.checkInternetConnection();
    });
    super.onInit();

  }

  @override
  void onReady() async {
  super.onReady();
  await Future.delayed(const Duration(milliseconds: 3000));
  SharedPreference _sharedPreference = SharedPreference();
  final String? token = await _sharedPreference.get(AppConstants.bearerToken);
  if (token != null && token.isNotEmpty) {
    // User is logged in, navigate to main layout
    Get.offAllNamed(AppRoutes.mainLayout);
  } else {
    // User is not logged in, navigate to login
    Get.offAllNamed(AppRoutes.login);
  }
}

}