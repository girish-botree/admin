import 'package:get/get.dart';
import '../../config/app_network_connection.dart';
import '../../routes/app_routes.dart';
import '../../config/auth_service.dart';

class SplashController extends GetxController {
  final AuthService _authService = AuthService.to;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Check internet connection
    AppNetworkConnection.checkInternetConnection();

    // Wait for minimum splash duration for better UX
    await Future<void>.delayed(const Duration(seconds: 2));

    // Wait for auth service to initialize
    while (!_authService.isInitialized) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    // Navigate based on authentication status
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    if (_authService.isLoggedIn) {
      Get.offAllNamed<void>(AppRoutes.mainLayout);
    } else {
      Get.offAllNamed<void>(AppRoutes.login);
    }
  }
}