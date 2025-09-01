import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../utils/responsive.dart';
import '../config/app_config.dart';

/// Standardized shimmer-only loading widget for consistent UX
class StandardLoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;
  final bool showMessage;
  final EdgeInsets? padding;
  final bool isFullScreen;
  final Widget? customShimmerChild;

  const StandardLoadingWidget({
    super.key,
    this.message,
    this.size,
    this.color,
    this.showMessage = true,
    this.padding,
    this.isFullScreen = false,
    this.customShimmerChild,
  });

  /// Factory for inline shimmer loading (small, no message)
  factory StandardLoadingWidget.inline({
    Key? key,
    double? size,
    Color? color,
  }) {
    return StandardLoadingWidget(
      key: key,
      size: size ?? 20.0,
      color: color,
      showMessage: false,
      isFullScreen: false,
    );
  }

  /// Factory for card shimmer loading
  factory StandardLoadingWidget.card({
    Key? key,
    String? message,
  }) {
    return StandardLoadingWidget(
      key: key,
      message: message ?? 'Loading...',
      showMessage: false, // Don't show message, use shimmer only
      isFullScreen: false,
      padding: const EdgeInsets.all(32),
    );
  }

  /// Factory for full-screen shimmer loading
  factory StandardLoadingWidget.fullScreen({
    Key? key,
    String? message,
  }) {
    return StandardLoadingWidget(
      key: key,
      message: message ?? 'Please wait...',
      showMessage: true,
      isFullScreen: true,
    );
  }

  /// Factory for circular shimmer (replacing CircularProgressIndicator)
  factory StandardLoadingWidget.circular({
    Key? key,
    double? size,
    Color? color,
  }) {
    final shimmerSize = size ?? 48.0;
    final shimmerColor = color ?? Theme
        .of(Get.context!)
        .colorScheme
        .onSurface; // Changed here
    return StandardLoadingWidget(
      key: key,
      size: shimmerSize,
      showMessage: false,
      isFullScreen: false,
      customShimmerChild: Container(
        width: shimmerSize,
        height: shimmerSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: shimmerColor,
        ),
      ),
    );
  }

  /// Factory for button shimmer loading
  factory StandardLoadingWidget.button({
    Key? key,
    double width = 100,
    double height = 40,
  }) {
    return StandardLoadingWidget(
      key: key,
      showMessage: false,
      isFullScreen: false,
      customShimmerChild: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme
              .of(Get.context!)
              .colorScheme
              .surface, // Changed here
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loadingSize = size ?? Responsive.responsiveValue(
      context,
      mobile: 32.0,
      tablet: 40.0,
      web: 48.0,
    );
    
    Widget shimmerChild;
    
    if (customShimmerChild != null) {
      shimmerChild = customShimmerChild!;
    } else {
      // Default shimmer shape (rounded rectangle)
      shimmerChild = Container(
        width: loadingSize,
        height: loadingSize,
        decoration: BoxDecoration(
          color: Theme
              .of(context)
              .colorScheme
              .surface, // Changed here
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }
    
    final widget = Container(
      padding: padding ?? const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShimmerLoadingWidget(
            child: shimmerChild,
          ),
          if (showMessage && message != null) ...[
            SizedBox(
              height: Responsive.responsiveValue(
                context,
                mobile: 16.0,
                tablet: 20.0,
                web: 24.0,
              ),
            ),
            ShimmerLoadingWidget(
              child: Container(
                width: 120,
                height: 16,
                decoration: BoxDecoration(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .surface, // Changed here
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return isFullScreen ? Center(child: widget) : widget;
  }
}

/// High-performance shimmer loading widget for content placeholders
class ShimmerLoadingWidget extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;

  const ShimmerLoadingWidget({
    super.key,
    required this.child,
    this.enabled = true,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1200), // Slightly faster for better UX
  });

  @override
  State<ShimmerLoadingWidget> createState() => _ShimmerLoadingWidgetState();
}

class _ShimmerLoadingWidgetState extends State<ShimmerLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.period,
      vsync: this,
    );
    
    // Use more efficient curve for better performance
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear, // Linear is more performant than easeInOutSine
    ));
    
    // Start animation only when widget is enabled
    if (widget.enabled) {
      _controller.repeat();
    }
  }
  
  @override
  void didUpdateWidget(ShimmerLoadingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle enabled state changes efficiently
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final theme = context.theme;
    final baseColor = widget.baseColor ?? theme.colorScheme.surfaceContainer;
    final highlightColor = widget.highlightColor ?? theme.colorScheme.surfaceContainerHigh;

    return AnimatedBuilder(
      animation: _animation,
      child: widget.child, // Cache child widget for better performance
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final animationValue = _animation.value;
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                (animationValue - 0.3).clamp(0.0, 1.0),
                animationValue.clamp(0.0, 1.0),
                (animationValue + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

/// High-performance loading list widget with optimized rendering
class LoadingListWidget extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsets padding;
  final double spacing;
  final bool useShimmer;

  const LoadingListWidget({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80.0,
    this.padding = const EdgeInsets.all(16.0),
    this.spacing = 12.0,
    this.useShimmer = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    // Pre-build shared decoration for better performance
    final itemDecoration = BoxDecoration(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
    );
    
    if (!useShimmer) {
      // Simple loading without shimmer for better performance on low-end devices
      return ListView.separated(
        padding: padding,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        separatorBuilder: (context, index) => SizedBox(height: spacing),
        itemBuilder: (context, index) {
          return Container(
            height: itemHeight,
            decoration: itemDecoration,
          );
        },
      );
    }
    
    return ListView.separated(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) {
        return ShimmerLoadingWidget(
          child: Container(
            height: itemHeight,
            decoration: itemDecoration,
          ),
        );
      },
    );
  }
}

/// High-performance loading grid widget with optimized rendering
class LoadingGridWidget extends StatelessWidget {
  final int itemCount;
  final double childAspectRatio;
  final EdgeInsets padding;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final int Function(double) getCrossAxisCount;
  final bool useShimmer;

  const LoadingGridWidget({
    super.key,
    this.itemCount = 6,
    this.childAspectRatio = 1.0,
    this.padding = const EdgeInsets.all(16.0),
    this.crossAxisSpacing = 12.0,
    this.mainAxisSpacing = 12.0,
    required this.getCrossAxisCount,
    this.useShimmer = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    // Pre-build shared decoration for better performance
    final itemDecoration = BoxDecoration(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
    );
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = getCrossAxisCount(constraints.maxWidth);
        
        // Create grid delegate once for better performance
        final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
        );
        
        if (!useShimmer) {
          // Simple loading without shimmer for better performance on low-end devices
          return GridView.builder(
            padding: padding,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: gridDelegate,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return Container(
                decoration: itemDecoration,
              );
            },
          );
        }
        
        return GridView.builder(
          padding: padding,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: gridDelegate,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return ShimmerLoadingWidget(
              child: Container(
                decoration: itemDecoration,
              ),
            );
          },
        );
      },
    );
  }
}

/// Shimmer-only loading configuration for consistent UX
void configLoading() {
  EasyLoading.instance
    ..indicatorWidget = const _ShimmerLoadingIndicator()
    ..maskType = EasyLoadingMaskType.black
    ..boxShadow = const <BoxShadow>[] // Use const for better performance
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorColor = Colors.transparent
    ..textColor = Colors.transparent
    ..radius = 20.0
    ..backgroundColor = Colors.transparent
    ..maskColor = Get.context != null
        ? Theme
        .of(Get.context!)
        .colorScheme
        .scrim
        .withValues(alpha: 0.6)
        : Colors.black.withValues(alpha: 0.6)
    ..userInteractions = false
    ..dismissOnTap = false;
}

/// Shimmer-based loading indicator widget
class _ShimmerLoadingIndicator extends StatelessWidget {
  const _ShimmerLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShimmerLoadingWidget(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme
                    .of(context)
                    .colorScheme
                    .surface, // Changed here
              ),
            ),
          ),
          const SizedBox(height: 16),
          ShimmerLoadingWidget(
            child: Container(
              width: 100,
              height: 16,
              decoration: BoxDecoration(
                color: Theme
                    .of(context)
                    .colorScheme
                    .surface, // Changed here
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}