import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_controller.dart';
import '../../utils/responsive.dart';
import 'components/mobile_dashboard.dart';
import 'components/tablet_dashboard.dart';
import 'components/web_dashboard.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DashboardController(), permanent: false);
    return Scaffold(
      body: const Responsive(
        mobile: MobileDashboard(),
        tablet: TabletDashboard(),
        web: WebDashboard(),
      ),
    );
  }
}