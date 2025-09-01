import 'package:admin/config/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum MessageType { success, error, info, warning }
enum InfoBarType { networkError, generalError, warning, info }

class CustomDisplays {
  // Static variables for deduplication
  static String? _lastToastMessage;
  static String? _lastInfoBarMessage;
  static DateTime? _lastToastTime;
  static DateTime? _lastInfoBarTime;
  static const Duration _deduplicationWindow = Duration(seconds: 2);
  static bool _isShowingToast = false;
  static bool _isShowingInfoBar = false;

  // Toast for quick notifications (replaces most Snackbar usage)
  static void showToast({
    required String message,
    MessageType type = MessageType.info,
    Duration duration = const Duration(seconds: 3),
    bool allowDuplicate = false,
  }) {
    // Deduplication logic
    if (!allowDuplicate && _shouldDeduplicateToast(message)) {
      return;
    }

    // Prevent multiple toasts from showing simultaneously
    if (_isShowingToast) {
      return;
    }

    _isShowingToast = true;
    _lastToastMessage = message;
    _lastToastTime = DateTime.now();

    try {
      final context = Get.context;
      if (context == null) {
        // Fallback to GetX snackbar if no context available
        _showFallbackSnackbar(message, type, duration);
        return;
      }

      final overlay = Overlay.maybeOf(context);
      if (overlay == null) {
        // Fallback to GetX snackbar if no overlay available
        _showFallbackSnackbar(message, type, duration);
        return;
      }

      late OverlayEntry overlayEntry;

      overlayEntry = OverlayEntry(
        builder: (context) =>
            _ToastWidget(
              message: message,
              type: type,
              onDismiss: () {
                overlayEntry.remove();
                _isShowingToast = false;
              },
            ),
      );

      overlay.insert(overlayEntry);

      // Auto-dismiss after duration
      Future.delayed(duration, () {
        if (overlayEntry.mounted) {
          overlayEntry.remove();
        }
        _isShowingToast = false;
      });
    } catch (e) {
      // Fallback to GetX snackbar on any error
      _showFallbackSnackbar(message, type, duration);
      _isShowingToast = false;
    }
  }

  // Check if toast should be deduplicated
  static bool _shouldDeduplicateToast(String message) {
    if (_lastToastMessage == message && _lastToastTime != null) {
      final timeSinceLastToast = DateTime.now().difference(_lastToastTime!);
      return timeSinceLastToast < _deduplicationWindow;
    }
    return false;
  }

  // Fallback method using GetX snackbar
  static void _showFallbackSnackbar(String message, MessageType type, Duration duration) {
    // Close any existing snackbars first
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Color backgroundColor;
    Color textColor = Colors.white;
    IconData icon;

    switch (type) {
      case MessageType.success:
        backgroundColor = Colors.green.shade600;
        icon = Icons.check_circle_outline;
        break;
      case MessageType.error:
        backgroundColor = Colors.red.shade600;
        icon = Icons.error_outline;
        break;
      case MessageType.warning:
        backgroundColor = Colors.orange.shade600;
        icon = Icons.warning_outlined;
        break;
      case MessageType.info:
        backgroundColor = Colors.blue.shade600;
        icon = Icons.info_outline;
        break;
    }

    Get.showSnackbar(
      GetSnackBar(
        message: message,
        backgroundColor: backgroundColor,
        messageText: Text(
          message,
          style: TextStyle(color: textColor),
        ),
        icon: Icon(icon, color: textColor),
        duration: duration,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        isDismissible: true,
      ),
    );
  }

  // Show persistent info bar (for network issues, etc.)
  static void showInfoBar({
    required String message,
    InfoBarType type = InfoBarType.info,
    String? actionText,
    VoidCallback? onAction,
    bool persistent = true,
    bool allowDuplicate = false,
  }) {
    // Deduplication logic
    if (!allowDuplicate && _shouldDeduplicateInfoBar(message)) {
      return;
    }

    // Prevent multiple info bars from showing simultaneously
    if (_isShowingInfoBar) {
      return;
    }

    _isShowingInfoBar = true;
    _lastInfoBarMessage = message;
    _lastInfoBarTime = DateTime.now();

    // Close any existing snackbars first
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.showSnackbar(
      GetSnackBar(
        messageText: _InfoBarWidget(
          message: message,
          type: type,
          actionText: actionText,
          onAction: () {
            _isShowingInfoBar = false;
            onAction?.call();
          },
        ),
        backgroundColor: Colors.transparent,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: persistent ? const Duration(days: 1) : const Duration(seconds: 5),
        isDismissible: !persistent,
        showProgressIndicator: false,
      ),
    );
  }

  // Check if info bar should be deduplicated
  static bool _shouldDeduplicateInfoBar(String message) {
    if (_lastInfoBarMessage == message && _lastInfoBarTime != null) {
      final timeSinceLastInfoBar = DateTime.now().difference(_lastInfoBarTime!);
      return timeSinceLastInfoBar < _deduplicationWindow;
    }
    return false;
  }

  // Dismiss persistent info bar
  static void dismissInfoBar() {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    _isShowingInfoBar = false;
  }

  // Clear all notifications and reset state
  static void clearAllNotifications() {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    _isShowingToast = false;
    _isShowingInfoBar = false;
    _lastToastMessage = null;
    _lastInfoBarMessage = null;
    _lastToastTime = null;
    _lastInfoBarTime = null;
  }

  // Show session expired message (deduplicated)
  static void showSessionExpiredMessage() {
    showToast(
      message: 'Your session has expired. Please log in again.',
      type: MessageType.error,
      duration: const Duration(seconds: 4),
      allowDuplicate: false,
    );
  }

  // Show network error message (deduplicated)
  static void showNetworkErrorMessage() {
    showToast(
      message: 'Network error. Please try again.',
      type: MessageType.error,
      allowDuplicate: false,
    );
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
        return colorScheme.secondary; // use secondary for success
      case MessageType.error:
        return colorScheme.error;
      case MessageType.warning:
        return colorScheme.tertiary; // use tertiary for warning if present
      case MessageType.info:
        return colorScheme.primary;
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
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  _getIcon(),
                  color: Theme
                      .of(context)
                      .colorScheme
                      .onSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppText(
                    widget.message.tr,
                    color: Theme
                        .of(context)
                        .colorScheme
                        .onSecondary,
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
          color: _getTextColor(context).withValues(alpha: 0.2),
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
        return colorScheme.secondaryContainer;
      case MessageType.error:
        return colorScheme.errorContainer;
      case MessageType.warning:
        return colorScheme.tertiaryContainer;
      case MessageType.info:
        return colorScheme.primaryContainer;
    }
  }

  Color _getTextColor(BuildContext context) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    switch (type) {
      case MessageType.success:
        return colorScheme.onSecondaryContainer;
      case MessageType.error:
        return colorScheme.onErrorContainer;
      case MessageType.warning:
        return colorScheme.onTertiaryContainer;
      case MessageType.info:
        return colorScheme.onPrimaryContainer;
    }
  }

  Color _getBorderColor(BuildContext context) {
    switch (type) {
      case MessageType.success:
        return Theme
            .of(context)
            .colorScheme
            .secondary;
      case MessageType.error:
        return Theme
            .of(context)
            .colorScheme
            .error;
      case MessageType.warning:
        return Theme
            .of(context)
            .colorScheme
            .tertiary;
      case MessageType.info:
        return Theme
            .of(context)
            .colorScheme
            .primary;
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
                  .withValues(alpha: 0.4),
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
                .withValues(alpha: 0.7),
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
                  .withValues(alpha: 0.5),
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

// OrderStatusChip
class OrderStatusChip extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusChip({
    super.key,
    required this.status,
  });

  static Color _getStatusColor(OrderStatus status) {
    final colorScheme = Theme
        .of(Get.context!)
        .colorScheme;
    Color textColor = Colors.white;
    Color backgroundColor;

    switch (status) {
      case OrderStatus.confirmed:
        backgroundColor = colorScheme.secondary; // use secondary for success
        break;
      case OrderStatus.cancelled:
        backgroundColor = colorScheme.error;
        break;
      case OrderStatus.preparing:
        backgroundColor =
            colorScheme.tertiary; // use tertiary for warning if present
        break;
      case OrderStatus.onTheWay:
        backgroundColor = colorScheme.primary;
        break;
      default:
        backgroundColor = colorScheme.surface;
        break;
    }

    return backgroundColor;
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        status
            .toString()
            .split('.')
            .last,
        style: TextStyle(
          color: Theme
              .of(context)
              .colorScheme
              .onSecondary,
        ),
      ),
      backgroundColor: _getStatusColor(status),
    );
  }
}

enum OrderStatus {
  confirmed,
  preparing,
  onTheWay,
  cancelled,
  delivered,
}
