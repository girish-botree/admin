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

  static bool isDesktop(BuildContext context) =>
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

  // Get responsive text size based on screen size
  static double responsiveTextSize(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double web,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return web;
    }
  }

  // Pre-defined responsive text sizes for common use cases
  static double getBodyTextSize(BuildContext context) {
    return responsiveTextSize(context, mobile: 14, tablet: 16, web: 18);
  }

  static double getSubtitleTextSize(BuildContext context) {
    return responsiveTextSize(context, mobile: 16, tablet: 18, web: 20);
  }

  static double getTitleTextSize(BuildContext context) {
    return responsiveTextSize(context, mobile: 18, tablet: 20, web: 24);
  }

  static double getHeadingTextSize(BuildContext context) {
    return responsiveTextSize(context, mobile: 20, tablet: 24, web: 28);
  }

  static double getLargeHeadingTextSize(BuildContext context) {
    return responsiveTextSize(context, mobile: 24, tablet: 28, web: 36);
  }

  static double getCaptionTextSize(BuildContext context) {
    return responsiveTextSize(context, mobile: 12, tablet: 13, web: 14);
  }

  static double getButtonTextSize(BuildContext context) {
    return responsiveTextSize(context, mobile: 14, tablet: 15, web: 16);
  }

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