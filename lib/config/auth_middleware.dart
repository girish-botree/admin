import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import 'auth_service.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = AuthService.to;

    // If auth service is not initialized yet, wait
    if (!authService.isInitialized) {
      return null;
    }

    // If user is not logged in and trying to access protected routes
    if (!authService.isLoggedIn && route != AppRoutes.login &&
        route != AppRoutes.splash) {
      return const RouteSettings(name: AppRoutes.login);
    }

    // If user is logged in and trying to access login page, redirect to main layout
    if (authService.isLoggedIn && route == AppRoutes.login) {
      return const RouteSettings(name: AppRoutes.mainLayout);
    }

    return null;
  }
}