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
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  // Removed _rotationAnimation as it's no longer needed with shimmer effects

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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
      body: Container(
        height: Get.height,
        width: Get.width,
        child: Stack(
          children: [
            // Decorative geometric patterns
            Positioned(
              top: -50,
              right: -50,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.theme.colorScheme.onSurface.withValues(alpha: 0.08),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 100,
              right: -80,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.theme.colorScheme.onSurface.withValues(alpha: 0.04),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: context.theme.colorScheme.onSurface.withValues(alpha: 0.06),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 150,
              left: -30,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.theme.colorScheme.onSurface.withValues(alpha: 0.03),
                  ),
                ),
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated icon with beautiful container
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.onSurface.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(35),
                        border: Border.all(
                          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.12),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.dashboard_rounded,
                        size: 80,
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Animated title with enhanced typography
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          Text(
                            'Admin Dashboard',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: context.theme.colorScheme.onSurface,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: 60,
                            height: 3,
                            decoration: BoxDecoration(
                              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppText.bold(
                            'E L I T H',
                            size: 18,
                            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            letterSpacing: 3.0,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),

                  // Loading indicator with theme colors
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            backgroundColor: context.theme.colorScheme.onSurface.withValues(alpha: 0.1),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SlideTransition(
                          position: _slideAnimation,
                          child: Text(
                            'Loading...',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              letterSpacing: 1.2,
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
      ),
    );
  }
}
