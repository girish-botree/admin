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

      // Verify Tamil
      var taData = await rootBundle.loadString("assets/language/tamil.json");
      var taJson = json.decode(taData);

      // Verify Hindi
      var hiData = await rootBundle.loadString("assets/language/hindi.json");
      var hiJson = json.decode(hiData);
    } catch (e) {
      // Error verifying languages
    }
  }

  void setLanguage(String lang) async {
    try {
      final SharedPreference sharedPreference = SharedPreference();
      var data = await rootBundle.loadString("assets/language/$lang.json");
      json.decode(data); // Validate JSON
      sharedPreference.save('lang', lang);

      if (lang == 'tamil') {
        locale.value = const Locale('ta', 'IN');
      } else if (lang == 'english') {
        locale.value = const Locale('en', 'US');
      } else if (lang == 'hindi') {
        locale.value = const Locale('hi', 'IN');
      } else {
        locale.value = const Locale('en', 'US');
      }

      Get.updateLocale(locale.value);
    } catch (e) {
      return;
    }
  }

  void changeLanguage(Locale newLocale) async {
    try {
      locale.value = newLocale;
      Get.updateLocale(newLocale);

      final SharedPreference sharedPreference = SharedPreference();
      if (newLocale.languageCode == 'ta') {
        sharedPreference.save('lang', 'tamil');
      } else if (newLocale.languageCode == 'hi') {
        sharedPreference.save('lang', 'hindi');
      } else {
        sharedPreference.save('lang', 'english');
      }
    } catch (e) {
      // Error changing language
    }
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString('lang') ?? 'english';
      
      // Clear any stored Hindi preference from previous testing
      if (lang == 'hindi') {
        await prefs.remove('lang'); // Clear the stored preference
        setLanguage('english');
      } else {
        setLanguage(lang);
      }
    } catch (e) {
      // Default to English on error
      setLanguage('english');
    }
  }
}