import 'package:flutter/foundation.dart';

class CommonUtils {
  static void debugLog(String log) {
    if (kDebugMode) {
      debugPrint(log);
    }
  }

}