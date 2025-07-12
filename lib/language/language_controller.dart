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


  void setLanguage(String lang) async {
    try {
      final SharedPreference sharedPreference = SharedPreference();
      var data = await rootBundle.loadString("assets/language/$lang.json");
      dynamic value = json.decode(data);
      sharedPreference.save('lang', lang);
      if (lang == 'tamil') {
        locale.value = const Locale('ta', 'IN');
      } else if (lang == 'english') {
        locale.value = const Locale('en', 'US');
      }
      Get.updateLocale(locale.value);
    } catch (e) {
      return debugPrint(e.toString());
    }
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('lang') ?? 'english';
    setLanguage(lang);
  }
}