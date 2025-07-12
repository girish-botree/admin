import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class AppNetworkConnection {
  static Future<void> checkInternetConnection() async {
    final checker = InternetConnectionChecker.createInstance();
    debugPrint('Current status: ${await checker.connectionStatus}');
    checker.onStatusChange.listen(
          (InternetConnectionStatus status) {
        switch (status) {
          case InternetConnectionStatus.connected:
            debugPrint('Online');
            Get.back();
            break;
          case InternetConnectionStatus.disconnected:
            debugPrint('Offline');
            EasyLoading.dismiss();
            break;
          default:
            debugPrint('Unknown status: $status');
            break;
        }
      },
    );
  }
}