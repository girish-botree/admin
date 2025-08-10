import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

void configLoading() {
  EasyLoading.instance
    ..indicatorWidget = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.grey.shade50.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue,
                      Colors.blueAccent,
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Please Wait'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    )
    ..maskType = EasyLoadingMaskType.black
    ..boxShadow = List<BoxShadow>.empty(growable: false)
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorColor = Colors.blue
    ..textColor = Colors.black87
    ..radius = 20.0
    ..backgroundColor = Colors.transparent
    ..maskColor = Colors.black.withValues(alpha: 0.6)
    ..userInteractions = false
    ..dismissOnTap = false;
}