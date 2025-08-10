import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SharedPreference {
  static final _secureStorage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: const IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Future<void> save(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  Future<void> saveBool(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  Future<String?> get(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<bool?> getBool(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  Future<bool> remove(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  Future<void> saveSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getSecure(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> removeSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> clearAllSecure() async {
    await _secureStorage.deleteAll();
  }
}
