import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import '../home/home_view.dart';
import '../meal/meal_view.dart';
import '../plan/plan_view.dart';
import '../dashboard/dashboard_view.dart';
import 'main_layout_controller.dart';
import '../../gen/assets.gen.dart';

class MainLayoutView extends GetView<MainLayoutController> {
  const MainLayoutView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kIsWeb ? AppBar(
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        elevation: 0,
      ) : null,
      drawer: kIsWeb ? _buildDrawer(context) : null,
      body: Obx(() => _getCurrentPage()),
      bottomNavigationBar: kIsWeb ? null : Obx(() =>
          BottomNavigationBar(
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        currentIndex: controller.currentIndex,
        onTap: controller.changePage,
        selectedItemColor: context.theme.colorScheme.onSurface,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: (controller.currentIndex == 0
                ? Assets.icons.icHomeFill
                : Assets.icons.icHomeStroke).svg(
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                controller.currentIndex == 0
                    ? context.theme.colorScheme.onSurface
                    : context.theme.colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: (controller.currentIndex == 1
                ? Assets.icons.icPlanFill
                : Assets.icons.icPlan).svg(
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                controller.currentIndex == 1
                    ? context.theme.colorScheme.onSurface
                    : context.theme.colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            label: 'Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              controller.currentIndex == 2
                  ? Icons.point_of_sale
                  : Icons.point_of_sale_outlined,
              size: 24,
              color: controller.currentIndex == 2
                  ? context.theme.colorScheme.onSurface
                  : context.theme.colorScheme.onSurfaceVariant,
            ),
            label: 'Sales',
          ),
          BottomNavigationBarItem(
            icon: (controller.currentIndex == 3
                ? Assets.icons.icDashboardFill
                : Assets.icons.icDashbaordStroke).svg(
              width: 26,
              height: 26,
              colorFilter: ColorFilter.mode(
                controller.currentIndex == 3
                    ? context.theme.colorScheme.onSurface
                    : context.theme.colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            label: 'Analytics',
          ),
        ],
      )),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: context.theme.colorScheme.primary,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: context.theme.colorScheme.onPrimary,
                fontSize: 24,
              ),
            ),
          ),
          Obx(() =>
              _buildDrawerItem(
                context,
                icon: (controller.currentIndex == 0
                    ? Assets.icons.icHomeFill
                    : Assets.icons.icHomeStroke).svg(
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    controller.currentIndex == 0
                        ? context.theme.colorScheme.primary
                        : context.theme.colorScheme.onSurfaceVariant,
                    BlendMode.srcIn,
              ),
            ),
            title: 'Home',
            index: 0,
          )),
          Obx(() =>
              _buildDrawerItem(
                context,
                icon: (controller.currentIndex == 1
                    ? Assets.icons.icPlanFill
                    : Assets.icons.icPlan).svg(
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    controller.currentIndex == 1
                        ? context.theme.colorScheme.primary
                        : context.theme.colorScheme.onSurfaceVariant,
                    BlendMode.srcIn,
              ),
            ),
            title: 'Plan',
            index: 1,
          )),
          Obx(() =>
              _buildDrawerItem(
                context,
                icon: Icon(
                  controller.currentIndex == 2
                      ? Icons.point_of_sale
                      : Icons.point_of_sale_outlined,
                  size: 24,
                  color: controller.currentIndex == 2
                      ? context.theme.colorScheme.primary
                      : context.theme.colorScheme.onSurfaceVariant,
                ),
                title: 'Sales',
                index: 2,
              )),
          Obx(() =>
              _buildDrawerItem(
                context,
                icon: (controller.currentIndex == 3
                    ? Assets.icons.icDashboardFill
                    : Assets.icons.icDashbaordStroke).svg(
                  width: 26,
                  height: 26,
                  colorFilter: ColorFilter.mode(
                    controller.currentIndex == 3
                        ? context.theme.colorScheme.primary
                        : context.theme.colorScheme.onSurfaceVariant,
                    BlendMode.srcIn,
              ),
            ),
            title: 'Analytics',
            index: 3,
          )),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {
    required Widget icon,
    required String title,
    required int index,
  }) {
    return ListTile(
      leading: icon,
      title: Text(title),
      selected: controller.currentIndex == index,
      onTap: () {
        controller.changePage(index);
        Navigator.of(context).pop();
      },
    );
  }

  Widget _getCurrentPage() {
    switch (controller.currentIndex) {
      case 0:
        return const HomeView(showBottomNav: false);
      case 1:
        return const PlanView();
      case 2:
        return _buildSalesView();
      case 3:
        return const DashboardView();
      default:
        return const HomeView(showBottomNav: false);
    }
  }

  Widget _buildSalesView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        backgroundColor: Get.theme.colorScheme.surfaceContainerLowest,
        elevation: 0,
        centerTitle: false,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Sales Module',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Coming Soon...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}