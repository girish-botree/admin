import 'package:admin/config/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum MessageType { success, error, info, warning }
enum InfoBarType { networkError, generalError, warning, info }

class CustomDisplays {
  // Toast for quick notifications (replaces most Snackbar usage)
  static void showToast({
    required String message,
    MessageType type = MessageType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final context = Get.context;
    if (context == null) return;

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) =>
          _ToastWidget(
            message: message,
            type: type,
            onDismiss: () => overlayEntry.remove(),
          ),
    );

    overlay.insert(overlayEntry);

    // Auto-dismiss after duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  // Show persistent info bar (for network issues, etc.)
  static void showInfoBar({
    required String message,
    InfoBarType type = InfoBarType.info,
    String? actionText,
    VoidCallback? onAction,
    bool persistent = true,
  }) {
    Get.showSnackbar(
      GetSnackBar(
        messageText: _InfoBarWidget(
          message: message,
          type: type,
          actionText: actionText,
          onAction: onAction,
        ),
        backgroundColor: Colors.transparent,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: persistent ? const Duration(days: 1) : const Duration(
            seconds: 5),
        isDismissible: !persistent,
        showProgressIndicator: false,
      ),
    );
  }

  // Dismiss persistent info bar
  static void dismissInfoBar() {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
  }

  // Legacy method for backward compatibility - now uses toast
  @Deprecated('Use showToast instead')
  static void showSnackBar({
    required String message,
    double fontSize = 16.0,
    int duration = 3000,
  }) {
    showToast(
      message: message,
      duration: Duration(milliseconds: duration),
    );
  }
}

// Toast Widget
class _ToastWidget extends StatefulWidget {
  final String message;
  final MessageType type;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor(BuildContext context) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    switch (widget.type) {
      case MessageType.success:
        return Colors.green.shade600;
      case MessageType.error:
        return colorScheme.error;
      case MessageType.warning:
        return Colors.orange.shade600;
      case MessageType.info:
        return colorScheme.onSurface;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case MessageType.success:
        return Icons.check_circle_outline;
      case MessageType.error:
        return Icons.error_outline;
      case MessageType.warning:
        return Icons.warning_outlined;
      case MessageType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - _animation.value)),
            child: Opacity(
              opacity: _animation.value,
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onTap: () {
            _controller.reverse().then((_) => widget.onDismiss());
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getBackgroundColor(context),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  _getIcon(),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppText(
                    widget.message.tr,
                    color: Colors.white,
                    size: 14,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Info Bar Widget
class _InfoBarWidget extends StatelessWidget {
  final String message;
  final InfoBarType type;
  final String? actionText;
  final VoidCallback? onAction;

  const _InfoBarWidget({
    required this.message,
    required this.type,
    this.actionText,
    this.onAction,
  });

  Color _getBackgroundColor(BuildContext context) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    switch (type) {
      case InfoBarType.networkError:
        return colorScheme.errorContainer;
      case InfoBarType.generalError:
        return colorScheme.errorContainer;
      case InfoBarType.warning:
        return Colors.orange.shade100;
      case InfoBarType.info:
        return colorScheme.primaryContainer;
    }
  }

  Color _getTextColor(BuildContext context) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    switch (type) {
      case InfoBarType.networkError:
        return colorScheme.onErrorContainer;
      case InfoBarType.generalError:
        return colorScheme.onErrorContainer;
      case InfoBarType.warning:
        return Colors.orange.shade800;
      case InfoBarType.info:
        return colorScheme.onPrimaryContainer;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case InfoBarType.networkError:
        return Icons.wifi_off_outlined;
      case InfoBarType.generalError:
        return Icons.error_outline;
      case InfoBarType.warning:
        return Icons.warning_outlined;
      case InfoBarType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getTextColor(context).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            color: _getTextColor(context),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppText(
              message.tr,
              color: _getTextColor(context),
              size: 14,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actionText != null && onAction != null) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: _getTextColor(context),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                minimumSize: const Size(0, 0),
                textStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500),
              ),
              child: Text(actionText!.tr),
            ),
          ],
        ],
      ),
    );
  }
}

// Inline Message Widget for forms and contextual feedback
class InlineMessage extends StatelessWidget {
  final String message;
  final MessageType type;
  final EdgeInsets? margin;
  final bool showIcon;

  const InlineMessage({
    super.key,
    required this.message,
    required this.type,
    this.margin,
    this.showIcon = true,
  });

  Color _getBackgroundColor(BuildContext context) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    switch (type) {
      case MessageType.success:
        return Colors.green.shade50;
      case MessageType.error:
        return colorScheme.errorContainer.withOpacity(0.1);
      case MessageType.warning:
        return Colors.orange.shade50;
      case MessageType.info:
        return colorScheme.primaryContainer.withOpacity(0.1);
    }
  }

  Color _getTextColor(BuildContext context) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    switch (type) {
      case MessageType.success:
        return Colors.green.shade700;
      case MessageType.error:
        return colorScheme.error;
      case MessageType.warning:
        return Colors.orange.shade700;
      case MessageType.info:
        return colorScheme.onPrimaryContainer;
    }
  }

  Color _getBorderColor(BuildContext context) {
    switch (type) {
      case MessageType.success:
        return Colors.green.shade200;
      case MessageType.error:
        return Theme
            .of(context)
            .colorScheme
            .error
            .withOpacity(0.3);
      case MessageType.warning:
        return Colors.orange.shade200;
      case MessageType.info:
        return Theme
            .of(context)
            .colorScheme
            .primary
            .withOpacity(0.3);
    }
  }

  IconData _getIcon() {
    switch (type) {
      case MessageType.success:
        return Icons.check_circle_outline;
      case MessageType.error:
        return Icons.error_outline;
      case MessageType.warning:
        return Icons.warning_outlined;
      case MessageType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getBorderColor(context),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon) ...[
            Icon(
              _getIcon(),
              color: _getTextColor(context),
              size: 16,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: AppText(
              message.tr,
              color: _getTextColor(context),
              size: 12,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Empty State Widget
class EmptyStateWidget extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final double? iconSize;
  final EdgeInsets? padding;

  const EmptyStateWidget({
    super.key,
    this.icon,
    this.title = 'No results found',
    this.subtitle,
    this.action,
    this.iconSize = 48.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: iconSize,
              color: Theme
                  .of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.4),
            ),
            const SizedBox(height: 16),
          ],
          AppText.h6(
            title.tr,
            textAlign: TextAlign.center,
            color: Theme
                .of(context)
                .colorScheme
                .onSurface
                .withOpacity(0.7),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            AppText.body2(
              subtitle!.tr,
              textAlign: TextAlign.center,
              color: Theme
                  .of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.5),
              maxLines: 3,
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: 24),
            action!,
          ],
        ],
      ),
    );
  }
}
