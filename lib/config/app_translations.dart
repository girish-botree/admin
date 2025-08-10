import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  static Map<String, Map<String, String>> translations = {};

  static Future<void> load() async {
    // Load English
    final enData = await rootBundle.loadString('assets/language/english.json');
    translations['en_US'] =
    Map<String, String>.from(json.decode(enData) as Map<String, dynamic>);
    // Load Tamil
    final taData = await rootBundle.loadString('assets/language/tamil.json');
    translations['ta_IN'] =
    Map<String, String>.from(json.decode(taData) as Map<String, dynamic>);
  }

  @override
  Map<String, Map<String, String>> get keys => translations;
}