import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'language_controller.dart';

class Language extends StatelessWidget {
  Language({super.key});

  final LanguageController controller = Get.put(LanguageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('language'.tr),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('english'.tr),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                controller.setLanguage('english');
              },
              child: Text('english'.tr),
            ),
            Text('tamil'.tr),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                controller.setLanguage('tamil');
              },
              child: Text('tamil'.tr),
            ),
            Text('hindi'.tr),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                controller.setLanguage('hindi');
              },
              child: Text('hindi'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
