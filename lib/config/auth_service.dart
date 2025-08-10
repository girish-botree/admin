import 'package:get/get.dart';
import 'shared_preference.dart';
import 'appconstants.dart';

class AuthService extends GetxController {
  static AuthService get to => Get.find();

  final _isLoggedIn = false.obs;
  final _isInitialized = false.obs;
  final SharedPreference _sharedPreference = SharedPreference();

  bool get isLoggedIn => _isLoggedIn.value;

  bool get isInitialized => _isInitialized.value;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final token = await _sharedPreference.getSecure(AppConstants.bearerToken);
      _isLoggedIn.value = token != null && token.isNotEmpty;
    } catch (e) {
      _isLoggedIn.value = false;
    } finally {
      _isInitialized.value = true;
    }
  }

  Future<void> login(String token, {String? refreshToken}) async {
    await _sharedPreference.saveSecure(AppConstants.bearerToken, token);
    if (refreshToken != null) {
      await _sharedPreference.saveSecure(
          AppConstants.refreshToken, refreshToken);
    }
    _isLoggedIn.value = true;
  }

  Future<void> logout() async {
    await _sharedPreference.removeSecure(AppConstants.bearerToken);
    await _sharedPreference.removeSecure(AppConstants.refreshToken);
    await _sharedPreference.clearAllSecure();
    _isLoggedIn.value = false;
  }

  Future<String?> getToken() async {
    return await _sharedPreference.getSecure(AppConstants.bearerToken);
  }

  Future<String?> getRefreshToken() async {
    return await _sharedPreference.getSecure(AppConstants.refreshToken);
  }

  // Additional methods for backward compatibility with DioNetworkService
  Future<void> storeToken(String token) async {
    await _sharedPreference.saveSecure(AppConstants.bearerToken, token);
    _isLoggedIn.value = true;
  }

  Future<void> storeRefreshToken(String refreshToken) async {
    await _sharedPreference.saveSecure(AppConstants.refreshToken, refreshToken);
  }

  Future<void> clearToken() async {
    await _sharedPreference.removeSecure(AppConstants.bearerToken);
    await _sharedPreference.removeSecure(AppConstants.refreshToken);
    await _sharedPreference.clearAllSecure();
    _isLoggedIn.value = false;
  }

  Future<void> clearRefreshToken() async {
    await _sharedPreference.removeSecure(AppConstants.refreshToken);
  }
}