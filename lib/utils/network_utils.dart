import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkUtils {
  static Future<bool> hasNetwork() async {
    try {
      if (kIsWeb) {
        // For web, we assume network is available
        return true;
      }

      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> canReachHost(String host) async {
    try {
      if (kIsWeb) {
        return true;
      }

      final result = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
}