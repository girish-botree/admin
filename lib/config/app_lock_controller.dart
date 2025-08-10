import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockController extends GetxController with WidgetsBindingObserver {
  static AppLockController get instance => Get.find<AppLockController>();

  final LocalAuthentication _localAuth = LocalAuthentication();

  // Observable properties
  RxBool isAppLockEnabled = false.obs;
  RxBool isBiometricEnabled = false.obs;
  RxBool isSystemPasswordEnabled = false.obs;
  RxString lockTimeOption = 'immediately'.obs; // immediately, 1min, 5min, 15min
  RxBool isAppLocked = false.obs;
  RxBool isBiometricAvailable = false.obs;
  RxList<BiometricType> availableBiometrics = <BiometricType>[].obs;

  DateTime? _backgroundTime;

  // Lock time options in minutes
  final Map<String, int> lockTimeOptions = {
    'immediately': 0,
    '1min': 1,
    '5min': 5,
    '15min': 15,
  };

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initializeAppLock();
  }

  Future<void> _initializeAppLock() async {
    await _loadSettings();
    await _checkBiometricAvailability();

    // Debug info
    // debugPrintBiometricInfo();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!isAppLockEnabled.value) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _backgroundTime = DateTime.now();
        break;
      case AppLifecycleState.resumed:
        _checkIfShouldLock();
        break;
      default:
        break;
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isAppLockEnabled.value = prefs.getBool('app_lock_enabled') ?? false;
    isBiometricEnabled.value = prefs.getBool('biometric_enabled') ?? false;
    isSystemPasswordEnabled.value =
        prefs.getBool('system_password_enabled') ?? true;
    lockTimeOption.value = prefs.getString('lock_time_option') ?? 'immediately';
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_lock_enabled', isAppLockEnabled.value);
    await prefs.setBool('biometric_enabled', isBiometricEnabled.value);
    await prefs.setBool(
        'system_password_enabled', isSystemPasswordEnabled.value);
    await prefs.setString('lock_time_option', lockTimeOption.value);
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      // Check if device supports biometrics
      final bool deviceSupported = await _localAuth.isDeviceSupported();
      final bool canCheck = await _localAuth.canCheckBiometrics;

      isBiometricAvailable.value = deviceSupported && canCheck;

      if (isBiometricAvailable.value) {
        availableBiometrics.value = await _localAuth.getAvailableBiometrics();
        // If no biometrics are available, mark as unavailable
        if (availableBiometrics.isEmpty) {
          isBiometricAvailable.value = false;
        }
      } else {
        availableBiometrics.clear();
      }
    } catch (e) {
      print('Error checking biometric availability: $e');
      isBiometricAvailable.value = false;
      availableBiometrics.clear();
    }
  }

  void _checkIfShouldLock() {
    if (_backgroundTime == null || !isAppLockEnabled.value) return;

    final timeDifference = DateTime.now().difference(_backgroundTime!);
    final lockTimeMinutes = lockTimeOptions[lockTimeOption.value] ?? 0;

    if (timeDifference.inMinutes >= lockTimeMinutes) {
      isAppLocked.value = true;
    }
  }

  Future<bool> authenticate(
      {String reason = 'Please authenticate to access the app'}) async {
    try {
      if (!isAppLockEnabled.value) return true;

      bool authResult = false;

      // Try biometric authentication first if enabled and available
      if (isBiometricEnabled.value && isBiometricAvailable.value &&
          availableBiometrics.isNotEmpty) {
        try {
          authResult = await _localAuth.authenticate(
            localizedReason: reason,
            options: const AuthenticationOptions(
              biometricOnly: true,
              stickyAuth: true,
            ),
          );

          if (authResult) {
            isAppLocked.value = false;
            return true;
          }
        } catch (e) {
          print('Biometric authentication error: $e');
          // Continue to system password if biometric fails
        }
      }

      // Fall back to system password if biometric failed or not available
      if (isSystemPasswordEnabled.value && !authResult) {
        try {
          authResult = await _localAuth.authenticate(
            localizedReason: reason,
            options: const AuthenticationOptions(
              biometricOnly: false,
              stickyAuth: true,
            ),
          );

          if (authResult) {
            isAppLocked.value = false;
            return true;
          }
        } catch (e) {
          print('System authentication error: $e');
        }
      }

      return authResult;
    } on PlatformException catch (e) {
      print('Authentication platform exception: ${e.code} - ${e.message}');

      // Handle specific error codes
      switch (e.code) {
        case 'BiometricOnlyNotSupported':
        // Fallback to system auth
          if (isSystemPasswordEnabled.value) {
            return authenticate(reason: reason);
          }
          break;
        case 'NotAvailable':
          Get.snackbar('Error', 'Biometric authentication is not available');
          break;
        case 'NotEnrolled':
          Get.snackbar('Error', 'No biometric data enrolled on this device');
          break;
        case 'LockedOut':
          Get.snackbar('Error', 'Too many attempts. Please try again later');
          break;
      }

      return false;
    } catch (e) {
      print('Authentication error: $e');
      return false;
    }
  }

  Future<void> enableAppLock() async {
    final authenticated = await authenticate(
        reason: 'Please authenticate to enable app lock');
    if (authenticated) {
      isAppLockEnabled.value = true;
      await _saveSettings();
    }
  }

  Future<void> disableAppLock() async {
    final authenticated = await authenticate(
        reason: 'Please authenticate to disable app lock');
    if (authenticated) {
      isAppLockEnabled.value = false;
      isBiometricEnabled.value = false;
      isSystemPasswordEnabled.value = false;
      isAppLocked.value = false;
      await _saveSettings();
    }
  }

  Future<void> toggleBiometric() async {
    // Re-check availability before toggling
    await _checkBiometricAvailability();

    if (!isBiometricAvailable.value) {
      Get.snackbar(
          'Error', 'Biometric authentication is not available on this device');
      return;
    }

    if (availableBiometrics.isEmpty) {
      Get.snackbar(
          'Error',
          'No biometric data is enrolled on this device. Please set up biometrics in your device settings first.');
      return;
    }

    if (!isBiometricEnabled.value) {
      try {
        final authenticated = await _localAuth.authenticate(
          localizedReason: 'Please authenticate to enable biometric lock',
          options: const AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
          ),
        );

        if (authenticated) {
          isBiometricEnabled.value = true;
          await _saveSettings();
          Get.snackbar('Success', 'Biometric authentication enabled');
        }
      } catch (e) {
        print('Enable biometric error: $e');
        Get.snackbar('Error', 'Failed to enable biometric authentication');
      }
    } else {
      isBiometricEnabled.value = false;
      await _saveSettings();
      Get.snackbar('Success', 'Biometric authentication disabled');
    }
  }

  Future<void> toggleSystemPassword() async {
    if (!isSystemPasswordEnabled.value) {
      final authenticated = await authenticate(
          reason: 'Please authenticate to enable system password lock');
      if (authenticated) {
        isSystemPasswordEnabled.value = true;
        await _saveSettings();
      }
    } else {
      isSystemPasswordEnabled.value = false;
      await _saveSettings();
    }
  }

  Future<void> setLockTimeOption(String option) async {
    if (lockTimeOptions.containsKey(option)) {
      lockTimeOption.value = option;
      await _saveSettings();
    }
  }

  String get biometricTypeString {
    if (availableBiometrics.isEmpty) return 'None';

    List<String> types = [];
    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      types.add('Fingerprint');
    }
    if (availableBiometrics.contains(BiometricType.face)) {
      types.add('Face ID');
    }
    if (availableBiometrics.contains(BiometricType.iris)) {
      types.add('Iris');
    }
    if (availableBiometrics.contains(BiometricType.strong) ||
        availableBiometrics.contains(BiometricType.weak)) {
      types.add('Biometric');
    }

    return types.isEmpty ? 'System Authentication' : types.join(', ');
  }

  String get lockTimeDisplayText {
    switch (lockTimeOption.value) {
      case 'immediately':
        return 'Immediately';
      case '1min':
        return 'After 1 minute';
      case '5min':
        return 'After 5 minutes';
      case '15min':
        return 'After 15 minutes';
      default:
        return 'Immediately';
    }
  }

  // Debug method to print biometric information
  void debugPrintBiometricInfo() {
    print('=== App Lock Debug Info ===');
    print('Biometric Available: ${isBiometricAvailable.value}');
    print('Biometric Enabled: ${isBiometricEnabled.value}');
    print('Available Biometrics: $availableBiometrics');
    print('System Password Enabled: ${isSystemPasswordEnabled.value}');
    print('App Lock Enabled: ${isAppLockEnabled.value}');
    print('==========================');
  }

  // Method to force refresh biometric availability
  Future<void> refreshBiometricAvailability() async {
    await _checkBiometricAvailability();
    debugPrintBiometricInfo();
  }
}