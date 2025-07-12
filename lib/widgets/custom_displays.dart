import 'package:flutter/material.dart';
import 'package:get/get.dart';


class CustomDisplays {
  static showSnackBar(
      {required String message, double fontSize = 16.0, int duration = 3000}) {
    return Get.showSnackbar(
      GetSnackBar(
        borderRadius: 6,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor:  Get.context!.theme.colorScheme.onSurface,
        messageText: SizedBox(
          width: 150,
          child: Wrap(
            children: [
              Center(
                child: Text(
                  message.tr,
                  style: Get.context!.theme.textTheme.titleSmall,
                ),
              ),
            ],
          ),
        ),
        margin: const EdgeInsets.all(15),
        duration: const Duration(seconds: 2),
        isDismissible: true,
        //  forwardAnimationCurve: Curves.bounceIn,
      ),
    );
  }

}
