import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  static Map<String, Map<String, String>> translations = {
    'en_US': {},
    'ta_IN': {},
    'hi_IN': {},
  };

  static Future<void> load() async {
    try {
      // Load English
      final enData = await rootBundle.loadString(
          'assets/language/english.json');
      final enMap = json.decode(enData) as Map<String, dynamic>;
      translations['en_US'] = Map<String, String>.from(enMap);
      print('Successfully loaded English translations: ${enMap['dashboard']}');

      // Load Tamil
      final taData = await rootBundle.loadString('assets/language/tamil.json');
      final taMap = json.decode(taData) as Map<String, dynamic>;
      translations['ta_IN'] = Map<String, String>.from(taMap);
      print('Successfully loaded Tamil translations: ${taMap['dashboard']}');

      // Load Hindi
      try {
        final hiData = await rootBundle.loadString(
            'assets/language/hindi.json');
        final hiMap = json.decode(hiData) as Map<String, dynamic>;
        translations['hi_IN'] = Map<String, String>.from(hiMap);
        print('Successfully loaded Hindi translations: ${hiMap['dashboard']}');
      } catch (e) {
        print('Error loading Hindi translations: $e');
        // Try again with explicit path
        try {
          final String hiDataAlt = await rootBundle.loadString(
              'assets/language/hindi.json', cache: false);
          final hiMapAlt = json.decode(hiDataAlt) as Map<String, dynamic>;
          translations['hi_IN'] = Map<String, String>.from(hiMapAlt);
          print(
              'Successfully loaded Hindi translations (alternative method): ${hiMapAlt['dashboard']}');
        } catch (e2) {
          print('Second attempt to load Hindi translations failed: $e2');
          // Use English as fallback for Hindi if there's an error
          if (translations['en_US'] != null) {
            translations['hi_IN'] =
            Map<String, String>.from(translations['en_US']!);
          }
        }
      }
    } catch (e) {
      print('Error in AppTranslations.load(): $e');
    }
  }

  @override
  Map<String, Map<String, String>> get keys => translations;
}