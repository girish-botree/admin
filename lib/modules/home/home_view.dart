import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import '../../utils/responsive.dart';

import 'components/mobile_home.dart';
import 'components/tablet_home.dart';
import 'components/web_home.dart';

class HomeView extends GetView<HomeController> {

  const HomeView({super.key, this.showBottomNav = true});
  final bool showBottomNav;

  @override
  Widget build(BuildContext context) {
    return const Responsive(
      mobile: MobileHome(),
      tablet: TabletHome(),
      web: WebHome(),
    );
  }
}