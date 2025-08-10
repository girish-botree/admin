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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE2E8F0),
              Color(0xFFF1F5F9),
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.transparent,
                Colors.blue.withValues(alpha: 0.02),
              ],
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
          child: SafeArea(
            child: Responsive(
              mobile: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  color: Colors.white.withValues(alpha: 0.95),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: const ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: MobileDashboard(),
                ),
              ),
              tablet: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: Colors.white.withValues(alpha: 0.95),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: const TabletDashboard(),
                ),
              ),
              web: Container(
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: Colors.white.withValues(alpha: 0.98),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: const WebDashboard(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}