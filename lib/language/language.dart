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
        title: const Text('Language'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('english'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                controller.setLanguage('english');
              },
              child: const Text('english'),
            ),
            const Text('Tamil'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                controller.setLanguage('tamil');

              },
              child: const Text('Tamil'),
            ),
          ],
        ),
      ),
    );
  }
}
