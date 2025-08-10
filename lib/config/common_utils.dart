import 'package:flutter/foundation.dart';

class CommonUtils {
  // Private constructor to prevent instantiation
  CommonUtils._();

  static void debugLog(String log) {
    if (kDebugMode) {
      debugPrint(log);
    }
  }
}