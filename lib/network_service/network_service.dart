import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import '../config/app_string_config.dart';
import '../config/appconstants.dart';
import '../config/common_utils.dart';
import '../config/shared_preference.dart';
import '../widgets/custom_displays.dart';
import 'app_url_config.dart';


class NetworkService {
  static final SharedPreference _sharedPreference = SharedPreference();

  static postData(data, apiUrl, {bearerToken = false}) async {
    try {
      String? token = await _sharedPreference.get(AppConstants.bearerToken);
      var fullUrl = Uri.parse(AppUrl.baseUrl + apiUrl);
      final response = await http.post(fullUrl,
          body: data,
          headers: bearerToken
              ? headersWithToken(token)
              : headersWithoutToken(token));
      return _response(response);
    } on SocketException {
      dismissLoader();
      CommonUtils.debugLog("No Internet Connection");
      throw AppStringConfig.noInternetConnection;
    } on HandshakeException {
      dismissLoader();
      CommonUtils.debugLog("Certificate verify failed");
      throw AppStringConfig.certificateVerifyFailed;
    } on TimeoutException {
      dismissLoader();
      CommonUtils.debugLog("Could not reach the server, try again");
      throw AppStringConfig.couldNotReachTheServer;
    } catch (e) {
      dismissLoader();
      CommonUtils.debugLog(e.toString());
      throw e.toString();
    }
  }



  static getData(apiUrl, {bearerToken = false}) async {
    try {
      String? token = await _sharedPreference.get(AppConstants.bearerToken);
      var fullUrl = Uri.parse(AppUrl.baseUrl + apiUrl);
      final response = await http.get(fullUrl,
          headers: bearerToken
              ? headersWithToken(token)
              : headersWithoutToken(token));
      return _responseGetData(response);
    } on SocketException {
      dismissLoader();
      CommonUtils.debugLog("No Internet Connection");
      throw AppStringConfig.noInternetConnection;
    } on HandshakeException {
      dismissLoader();
      CommonUtils.debugLog("Certificate verify failed");
      throw AppStringConfig.certificateVerifyFailed;
    } on TimeoutException {
      dismissLoader();
      CommonUtils.debugLog("Could not reach the server, try again");
      throw AppStringConfig.couldNotReachTheServer;
    } catch (e) {
      dismissLoader();
      CommonUtils.debugLog(e.toString());
      throw e.toString();
    }
  }

  static putDataWithBody(data, apiUrl, {bearerToken = false}) async {
    try {
      String? token = await _sharedPreference.get(AppConstants.bearerToken);
      var fullUrl = Uri.parse(AppUrl.baseUrl + apiUrl);
      final response = await http.put(fullUrl,
          body: data,
          headers: bearerToken
              ? headersWithToken(token)
              : headersWithoutToken(token));
      return _response(response);
    } on SocketException {
      dismissLoader();
      CommonUtils.debugLog("No Internet Connection");
      throw AppStringConfig.noInternetConnection;
    } on HandshakeException {
      dismissLoader();
      CommonUtils.debugLog("Certificate verify failed");
      throw AppStringConfig.certificateVerifyFailed;
    } on TimeoutException {
      dismissLoader();
      CommonUtils.debugLog("Could not reach the server, try again");
      throw AppStringConfig.couldNotReachTheServer;
    } catch (e) {
      dismissLoader();
      CommonUtils.debugLog(e.toString());
      throw e.toString();
    }
  }


  static putDataWithOutBody( apiUrl, {bearerToken = false}) async {
    try {
      String? token = await _sharedPreference.get(AppConstants.bearerToken);
      var fullUrl = Uri.parse(AppUrl.baseUrl + apiUrl);
      final response = await http.post(fullUrl,
          headers: bearerToken
              ? headersWithToken(token)
              : headersWithoutToken(token));
      return _response(response);
    } on SocketException {
      dismissLoader();
      CommonUtils.debugLog("No Internet Connection");
      throw AppStringConfig.noInternetConnection;
    } on HandshakeException {
      dismissLoader();
      CommonUtils.debugLog("Certificate verify failed");
      throw AppStringConfig.certificateVerifyFailed;
    } on TimeoutException {
      dismissLoader();
      CommonUtils.debugLog("Could not reach the server, try again");
      throw AppStringConfig.couldNotReachTheServer;
    } catch (e) {
      dismissLoader();
      CommonUtils.debugLog(e.toString());
      throw e.toString();
    }
  }

  static dynamic _response(http.Response response) {
    return json.decode(response.body.toString());
  }

  static dynamic _responseGetData(http.Response response) {
    dynamic responseJson;
    if (response.statusCode == 200) {
      responseJson = json.decode(response.body.toString());
    } else {
      responseJson = "Unauthorized";
    }
    return responseJson;
  }

  static headersWithToken(token) => {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ' + token
  };

  static _headersPut(token) => {'Authorization': 'Bearer ' + token};

  static Map<String, String> headersCATELOG = {
    "x-api-key": "API-KEY-PROCUREMENT"
  };

  static headersWithoutToken(token) => {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };

  static void showLoader() {
    if (!EasyLoading.isShow) {
      EasyLoading.show();
    }
  }

  static void dismissLoader() {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
  }

  //Example
  // login(username, userPassword) async {
  //   try {
  //     EasyLoading.show();
  //     Map<String, dynamic> data = {
  //       "username": username,
  //       "password": userPassword
  //     };
  //     String val = json.encode(data);
  //
  //     LoginResponse verifyResponse = LoginResponse.fromJson(
  //         await NetworkService.postData(val, AppUrl.authenticate,
  //             bearerToken: false));
  //     if (verifyResponse.success &&
  //         verifyResponse.data.roles[0].role.toString().toLowerCase() ==
  //             "STUDENT".toString().toLowerCase()) {
  //
  //
  //     } else {
  //       CustomDisplays.showSnackBar(message: verifyResponse.message);
  //     }
  //   } catch (e) {
  //     EasyLoading.dismiss();
  //     CommonUtils.debugLog(e.toString());
  //   }
  // }

}
