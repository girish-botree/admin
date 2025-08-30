import 'package:flutter/material.dart';
import '../utils/responsive.dart';


/// Utility class for creating consistent dropdown menu items with checkmarks
class DropdownUtils {
  /// Creates a DropdownMenuItem with a checkmark icon for the selected item
  static DropdownMenuItem<T> buildDropdownMenuItem<T>({
    required BuildContext context,
    required T value,
    required String label,
    required T? selectedValue,
    TextStyle? textStyle,
    double iconSize = 18,
    IconData checkIcon = Icons.check_circle,
  }) {
    final isSelected = value == selectedValue;
    final theme = Theme.of(context);
    
    return DropdownMenuItem<T>(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: textStyle?.copyWith(
                color: isSelected 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ) ?? TextStyle(
                color: isSelected 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          if (isSelected)
            Icon(
              checkIcon,
              color: theme.colorScheme.primary,
              size: iconSize,
            ),
        ],
      ),
    );
  }

  /// Creates a list of DropdownMenuItems with checkmarks from a map of values and labels
  static List<DropdownMenuItem<T>> buildDropdownMenuItems<T>({
    required BuildContext context,
    required Map<T, String> items,
    required T? selectedValue,
    TextStyle? textStyle,
    double iconSize = 18,
    IconData checkIcon = Icons.check_circle,
  }) {
    return items.entries.map((entry) {
      return buildDropdownMenuItem<T>(
        context: context,
        value: entry.key,
        label: entry.value,
        selectedValue: selectedValue,
        textStyle: textStyle,
        iconSize: iconSize,
        checkIcon: checkIcon,
      );
    }).toList();
  }

  /// Creates a list of DropdownMenuItems with checkmarks from a list of strings
  static List<DropdownMenuItem<String>> buildStringDropdownMenuItems({
    required BuildContext context,
    required List<String> items,
    required String? selectedValue,
    TextStyle? textStyle,
    double iconSize = 18,
    IconData checkIcon = Icons.check_circle,
  }) {
    return items.map((item) {
      return buildDropdownMenuItem<String>(
        context: context,
        value: item,
        label: item,
        selectedValue: selectedValue,
        textStyle: textStyle,
        iconSize: iconSize,
        checkIcon: checkIcon,
      );
    }).toList();
  }

  /// Creates a list of DropdownMenuItems with checkmarks from a list of enums
  static List<DropdownMenuItem<T>> buildEnumDropdownMenuItems<T extends Enum>({
    required BuildContext context,
    required List<T> values,
    required T? selectedValue,
    required String Function(T) labelBuilder,
    TextStyle? textStyle,
    double iconSize = 18,
    IconData checkIcon = Icons.check_circle,
  }) {
    return values.map((value) {
      return buildDropdownMenuItem<T>(
        context: context,
        value: value,
        label: labelBuilder(value),
        selectedValue: selectedValue,
        textStyle: textStyle,
        iconSize: iconSize,
        checkIcon: checkIcon,
      );
    }).toList();
  }
}

/// Extension on List<DropdownMenuItem> for easy checkmark addition
extension DropdownMenuItemListExtension<T> on List<DropdownMenuItem<T>> {
  /// Adds checkmarks to existing dropdown menu items
  List<DropdownMenuItem<T>> withCheckmarks({
    required BuildContext context,
    required T? selectedValue,
    double iconSize = 18,
    IconData checkIcon = Icons.check_circle,
  }) {
    final theme = Theme.of(context);
    
    return map((item) {
      final isSelected = item.value == selectedValue;
      
      return DropdownMenuItem<T>(
        value: item.value,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: item.child),
            if (isSelected)
              Icon(
                checkIcon,
                color: theme.colorScheme.primary,
                size: iconSize,
              ),
          ],
        ),
      );
    }).toList();
  }

  /// Creates enhanced dropdown menu items with clear option
  static List<DropdownMenuItem<T?>> withClearOption<T>({
    required BuildContext context,
    required List<DropdownMenuItem<T>> items,
    required T? selectedValue,
    String clearLabel = 'Clear Selection',
    double iconSize = 18,
    IconData checkIcon = Icons.check_circle,
    IconData clearIcon = Icons.clear,
  }) {
    final theme = Theme.of(context);
    
    List<DropdownMenuItem<T?>> enhancedItems = [];
    
    // Add clear option if there's a selection
    if (selectedValue != null) {
      enhancedItems.add(
        DropdownMenuItem<T?>(
          value: null,
          child: Row(
            children: [
              Icon(
                clearIcon,
                color: theme.colorScheme.error,
                size: iconSize,
              ),
              const SizedBox(width: 8),
              Text(
                clearLabel,
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
      
      // Add divider
      enhancedItems.add(
        DropdownMenuItem<T?>(
          enabled: false,
          value: null,
          child: const Divider(height: 1),
        ),
      );
    }
    
    // Add regular items with checkmarks
    enhancedItems.addAll(
      items.map((item) {
        final isSelected = item.value == selectedValue;
        
        return DropdownMenuItem<T?>(
          value: item.value,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: item.child),
              if (isSelected)
                Icon(
                  checkIcon,
                  color: theme.colorScheme.primary,
                  size: iconSize,
                ),
            ],
          ),
        );
      }),
    );
    
    return enhancedItems;
  }

  // Enhanced dropdown performance utilities
  static const Duration debounceDelay = Duration(milliseconds: 150);
  static const int virtualizationThreshold = 100;
  
  /// Performance monitoring for dropdowns
  static void logPerformanceMetrics(String dropdownId, {
    required int itemCount,
    required Duration searchTime,
    required Duration renderTime,
    String? searchQuery,
  }) {
    // Performance logging disabled to reduce console noise
  }
  
  /// Check if virtualization should be enabled for performance
  static bool shouldVirtualize(int itemCount) {
    return itemCount > virtualizationThreshold;
  }
  
  /// Get optimal visible item count based on screen size
  static int getOptimalVisibleItems(BuildContext context) {
    return Responsive.responsiveValue(
      context,
      mobile: 5,
      tablet: 7,
      web: 9,
    );
  }
  
  /// Get optimal item height based on content and screen size
  static double getOptimalItemHeight(BuildContext context, {bool hasDescription = false}) {
    final baseHeight = Responsive.responsiveValue(
      context,
      mobile: 48.0,
      tablet: 56.0,
      web: 64.0,
    );
    
    return hasDescription ? baseHeight * 1.5 : baseHeight;
  }
}
