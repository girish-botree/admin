import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/shared_preference.dart';



class LanguageController extends GetxController {
  Rx<Locale> locale = const Locale('en', 'US').obs;

  @override
  void onInit() {
    _loadLanguage();
    super.onInit();
  }

  // Helper method to verify all languages are working
  Future<void> verifyLanguages() async {
    try {
      // Verify English
      var enData = await rootBundle.loadString("assets/language/english.json");
      var enJson = json.decode(enData);
      print('English verification: ${enJson['dashboard']}');

      // Verify Tamil
      var taData = await rootBundle.loadString("assets/language/tamil.json");
      var taJson = json.decode(taData);
      print('Tamil verification: ${taJson['dashboard']}');

      // Verify Hindi
      var hiData = await rootBundle.loadString("assets/language/hindi.json");
      var hiJson = json.decode(hiData);
      print('Hindi verification: ${hiJson['dashboard']}');
    } catch (e) {
      print('Error verifying languages: $e');
    }
  }

  void setLanguage(String lang) async {
    try {
      final SharedPreference sharedPreference = SharedPreference();
      print('Setting language to: $lang');
      var data = await rootBundle.loadString("assets/language/$lang.json");
      json.decode(data); // Validate JSON
      sharedPreference.save('lang', lang);

      if (lang == 'tamil') {
        locale.value = const Locale('ta', 'IN');
        print('Set locale to: ta_IN');
      } else if (lang == 'english') {
        locale.value = const Locale('en', 'US');
        print('Set locale to: en_US');
      } else if (lang == 'hindi') {
        locale.value = const Locale('hi', 'IN');
        print('Set locale to: hi_IN');
      } else {
        print('Unknown language: $lang, defaulting to English');
        locale.value = const Locale('en', 'US');
      }

      Get.updateLocale(locale.value);
      print('Updated locale to: ${locale.value.languageCode}_${locale.value
          .countryCode}');
    } catch (e) {
      print('Error in setLanguage: $e');
      return debugPrint(e.toString());
    }
  }

  void changeLanguage(Locale newLocale) async {
    try {
      print('Changing language to locale: ${newLocale.languageCode}_${newLocale
          .countryCode}');
      locale.value = newLocale;
      Get.updateLocale(newLocale);

      final SharedPreference sharedPreference = SharedPreference();
      if (newLocale.languageCode == 'ta') {
        sharedPreference.save('lang', 'tamil');
        print('Saved language preference: tamil');
      } else if (newLocale.languageCode == 'hi') {
        sharedPreference.save('lang', 'hindi');
        print('Saved language preference: hindi');
      } else {
        sharedPreference.save('lang', 'english');
        print('Saved language preference: english');
      }
    } catch (e) {
      print('Error in changeLanguage: $e');
      debugPrint(e.toString());
    }
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString('lang') ?? 'english';
      print('Loading saved language preference: $lang');
      
      // Clear any stored Hindi preference from previous testing
      if (lang == 'hindi') {
        print('Clearing Hindi test language preference. Defaulting to English as primary language.');
        await prefs.remove('lang'); // Clear the stored preference
        setLanguage('english');
      } else {
        setLanguage(lang);
      }
    } catch (e) {
      print('Error in _loadLanguage: $e');
      debugPrint(e.toString());
      // Default to English on error
      setLanguage('english');
    }
  }
}