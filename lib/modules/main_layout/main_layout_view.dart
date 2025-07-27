import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/home_view.dart';
import '../meal/meal_view.dart';
import 'main_layout_controller.dart';

class MainLayoutView extends GetView<MainLayoutController> {
  const MainLayoutView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex,
        children: [
          HomeView(showBottomNav: false),
          Scaffold(body: Center(child: Text('Plan Screen'))),
          MealView(),
          Scaffold(body: Center(child: Text('Empty Screen'))),
        ],
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        currentIndex: controller.currentIndex,
        onTap: controller.changePage,
        selectedItemColor: context.theme.colorScheme.onSurface,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Meal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.desktop_access_disabled_rounded),
            label: 'Empty',
          ),
        ],
      )),
    );
  }
}