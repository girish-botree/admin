import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/app_text.dart' show AppText;
import 'splash_controller.dart';

class Splash extends GetView<SplashController> {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSplashBody(),
    );
  }
}

class AnimatedSplashBody extends StatefulWidget {
  @override
  _AnimatedSplashBodyState createState() => _AnimatedSplashBodyState();
}

class _AnimatedSplashBodyState extends State<AnimatedSplashBody>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _rotationController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Start animations with delays
    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _fadeController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      _slideController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      _rotationController.repeat();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height,
      width: Get.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.theme.colorScheme.surfaceContainerLowest,
            context.theme.colorScheme.surfaceContainerLowest,
            context.theme.colorScheme.surfaceContainerLowest,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated background circles
          Positioned(
            top: -100,
            right: -100,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.theme.colorScheme.onSurface.withValues(
                      alpha: 0.05),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.theme.colorScheme.onSurface.withValues(
                      alpha: 0.03),
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.onSurface.withValues(
                          alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: context.theme.colorScheme.onSurface.withValues(
                              alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.dashboard_rounded,
                      size: 100,
                      color: context.theme.colorScheme.onSurface,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Animated title
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        Text(
                          'Admin Dashboard',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: context.theme.colorScheme.onSurface,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: context.theme.colorScheme.onSurface
                                    .withValues(alpha: 0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppText.bold(
                          'E L I T H',
                            size: 20,
                          color: context.theme.colorScheme.onSurface.withValues(
                              alpha: 0.8),
                            letterSpacing: 0.8,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 80),

                // Animated loading indicator
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      RotationTransition(
                        turns: _rotationAnimation,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.theme.colorScheme.onSurface
                                .withValues(alpha: 0.2),
                          ),
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                context.theme.colorScheme.onSurface),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SlideTransition(
                        position: _slideAnimation,
                        child: Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 16,
                            color: context.theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
