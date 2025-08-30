import 'dart:async';
import 'package:flutter/material.dart';

/// Mixin to provide common performance optimizations for dropdown widgets
mixin OptimizedDropdownMixin<T extends StatefulWidget> on State<T> {
  Timer? _debounceTimer;
  String _lastSearchQuery = '';
  
  /// Debounced search function to improve performance
  void debouncedSearch(String query, void Function(String) onSearch, {Duration delay = const Duration(milliseconds: 150)}) {
    if (query == _lastSearchQuery) return;
    
    _lastSearchQuery = query;
    _debounceTimer?.cancel();
    
    _debounceTimer = Timer(delay, () {
      if (mounted) {
        onSearch(query);
      }
    });
  }
  
  /// Cancel any pending debounced operations
  void cancelDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }
  
  @override
  void dispose() {
    cancelDebounce();
    super.dispose();
  }
}

/// Performance optimizations for ListView builders in dropdowns
class OptimizedListViewBuilder extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final ScrollPhysics? physics;
  final double? cacheExtent;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  
  const OptimizedListViewBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.physics = const BouncingScrollPhysics(),
    this.cacheExtent = 600,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.shrinkWrap = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: shrinkWrap,
      padding: padding,
      physics: physics,
      cacheExtent: cacheExtent,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Safety check to prevent index out of bounds
        if (index >= itemCount) return const SizedBox.shrink();
        return itemBuilder(context, index);
      },
    );
  }
}

/// Optimized chip widget for selected items
class OptimizedChip extends StatelessWidget {
  final String label;
  final String? icon;
  final VoidCallback? onDeleted;
  final bool enabled;
  final ThemeData theme;
  
  const OptimizedChip({
    super.key,
    required this.label,
    this.icon,
    this.onDeleted,
    this.enabled = true,
    required this.theme,
  });
  
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      avatar: icon != null ? Text(
        icon!,
        style: const TextStyle(fontSize: 14),
      ) : null,
      onDeleted: enabled ? onDeleted : null,
      deleteIcon: Icon(
        Icons.close,
        size: 16,
        color: theme.colorScheme.onPrimaryContainer,
      ),
      backgroundColor: theme.colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

/// Memory-efficient overlay management
class OverlayManager {
  static OverlayEntry? _currentOverlay;
  
  static void showOverlay(BuildContext context, OverlayEntry overlay) {
    // Close any existing overlay first
    closeOverlay();
    
    _currentOverlay = overlay;
    Overlay.of(context).insert(overlay);
  }
  
  static void closeOverlay() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
  
  static bool get hasOverlay => _currentOverlay != null;
}
