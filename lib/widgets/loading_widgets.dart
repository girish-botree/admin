import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

void configLoading() {
  EasyLoading.instance
    ..indicatorWidget = SizedBox(
      width: 180,
      child: Row(
        children: [
          const SizedBox(
            width: 10,
          ),
          SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              color: Get.context?.theme.colorScheme.primary,
            ),
          ),
          const SizedBox(
            width: 25,
          ),
          Text(
            'Please Wait'.tr,
          )
        ],
      ),
    )
    ..maskType = EasyLoadingMaskType.black
    ..boxShadow = List<BoxShadow>.empty(growable: false)
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.white
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}