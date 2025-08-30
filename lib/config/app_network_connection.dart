import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class AppNetworkConnection {
  static Future<void> checkInternetConnection() async {
    final checker = InternetConnectionChecker.createInstance();
    checker.onStatusChange.listen(
          (InternetConnectionStatus status) {
        switch (status) {
          case InternetConnectionStatus.connected:
            Get.back<void>();
            break;
          case InternetConnectionStatus.disconnected:
            // EasyLoading.dismiss(); // Removed overscreen loading
            break;
          default:
            break;
        }
      },
    );
  }
}