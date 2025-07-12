import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';
import '../../utils/resposive.dart';
import 'components/mobile_login.dart';
import 'components/tab_login.dart';
import 'components/web_login.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: const MobileLogin(),
      tablet: const TabLogin(),
      web: const WebLogin(),
    );
  }
}
