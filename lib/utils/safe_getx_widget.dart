import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SafeObx extends StatefulWidget {
  final Widget Function() builder;

  const SafeObx({super.key, required this.builder});

  @override
  State<SafeObx> createState() => _SafeObxState();
}

class _SafeObxState extends State<SafeObx> {
  @override
  Widget build(BuildContext context) {
    try {
      return Obx(() {
        try {
          return widget.builder();
        } catch (e) {
          // Return empty widget if builder fails
          return const SizedBox.shrink();
        }
      });
    } catch (e) {
      // Return empty widget if Obx fails
      return const SizedBox.shrink();
    }
  }
}

class SafeGetView<T extends GetxController> extends StatelessWidget {
  final Widget Function(T controller) builder;
  final Widget? fallback;

  const SafeGetView({
    super.key,
    required this.builder,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    try {
      if (!Get.isRegistered<T>()) {
        return fallback ?? const Center(child: CircularProgressIndicator());
      }

      final controller = Get.find<T>();
      return builder(controller);
    } catch (e) {
      return fallback ?? const Center(
        child: Text('Error loading controller'),
      );
    }
  }
}

mixin SafeGetxMixin on GetxController {
  bool _disposed = false;

  bool get isDisposed => _disposed;

  @override
  void onClose() {
    _disposed = true;
    super.onClose();
  }

  void safeUpdate(VoidCallback callback) {
    if (!_disposed) {
      try {
        callback();
      } catch (e) {
        // Silently handle update errors during disposal
      }
    }
  }
}