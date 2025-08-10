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
            icon: Assets.icons.icHome.svg(
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                controller.currentIndex == 0
                    ? context.theme.colorScheme.onSurface
                    : Colors.grey,
                BlendMode.srcIn,
              ),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Assets.icons.icPlan.svg(
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                controller.currentIndex == 1
                    ? context.theme.colorScheme.onSurface
                    : Colors.grey,
                BlendMode.srcIn,
              ),
            ),
            label: 'Plan',
          ),
          BottomNavigationBarItem(
            icon: Assets.icons.icMeal.svg(
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                controller.currentIndex == 2
                    ? context.theme.colorScheme.onSurface
                    : Colors.grey,
                BlendMode.srcIn,
              ),
            ),
            label: 'Meal',
          ),
          BottomNavigationBarItem(
            icon: Assets.icons.icDashboard.svg(
              width: 26,
              height: 26,
              colorFilter: ColorFilter.mode(
                controller.currentIndex == 3
                    ? context.theme.colorScheme.onSurface
                    : Colors.grey,
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
    return Obx(() =>
        Drawer(
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
              _buildDrawerItem(
                context,
                icon: Assets.icons.icHome.svg(
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    controller.currentIndex == 0
                        ? context.theme.colorScheme.primary
                        : Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
                title: 'Home',
                index: 0,
              ),
              _buildDrawerItem(
                context,
                icon: Assets.icons.icPlan.svg(
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    controller.currentIndex == 1
                        ? context.theme.colorScheme.primary
                        : Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
                title: 'Plan',
                index: 1,
              ),
              _buildDrawerItem(
                context,
                icon: Assets.icons.icMeal.svg(
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    controller.currentIndex == 2
                        ? context.theme.colorScheme.primary
                        : Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
                title: 'Meal',
                index: 2,
              ),
              _buildDrawerItem(
                context,
                icon: Assets.icons.icDashboard.svg(
                  width: 26,
                  height: 26,
                  colorFilter: ColorFilter.mode(
                    controller.currentIndex == 3
                        ? context.theme.colorScheme.primary
                        : Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
                title: 'Analytics',
                index: 3,
              ),
            ],
          ),
        ));
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
        return HomeView(showBottomNav: false);
      case 1:
        return PlanView();
      case 2:
        return MealView();
      case 3:
        return DashboardView();
      default:
        return HomeView(showBottomNav: false);
    }
  }
}