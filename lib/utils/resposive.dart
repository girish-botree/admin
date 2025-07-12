import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  const Responsive({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.web,
  });
  
  final Widget mobile;
  final Widget tablet;
  final Widget web;

  // Breakpoints based on Material Design guidelines
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double webBreakpoint = 1440;

  // Screen type checks
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= mobileBreakpoint &&
      MediaQuery.sizeOf(context).width < tabletBreakpoint;

  static bool isWeb(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  // Additional utility methods
  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  // Get responsive value based on screen size
  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    required T tablet,
    required T web,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return web;
    }
  }

  // Get padding based on screen size
  // static EdgeInsets responsivePadding(BuildContext context) {
  //   if (isMobile(context)) {
  //     return const EdgeInsets.symmetric(horizontal: 16, vertical: 20);
  //   } else if (isTablet(context)) {
  //     return const EdgeInsets.symmetric(horizontal: 32, vertical: 40);
  //   } else {
  //     return const EdgeInsets.symmetric(horizontal: 60, vertical: 60);
  //   }
  // }

  // Get form width based on screen size
  // static double getFormWidth(BuildContext context) {
  //   final screenWidth = MediaQuery.sizeOf(context).width;
  //   if (isMobile(context)) {
  //     return screenWidth * 0.9;
  //   } else if (isTablet(context)) {
  //     return screenWidth * 0.7;
  //   } else {
  //     return 500; // Fixed width for web
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    
    if (screenWidth < mobileBreakpoint) {
      return mobile;
    } else if (screenWidth < tabletBreakpoint) {
      return tablet;
    } else {
      return web;
    }
  }
}