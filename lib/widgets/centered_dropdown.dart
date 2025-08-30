import 'package:flutter/material.dart';

/// A centered dropdown that displays options in the middle of the screen
class CenteredDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final bool enabled;
  final bool required;
  final Widget? prefixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final InputDecoration? decoration;

  const CenteredDropdown({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.labelText,
    this.hintText,
    this.errorText,
    this.enabled = true,
    this.required = false,
    this.prefixIcon,
    this.contentPadding,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: enabled ? () => _showCenteredDropdown(context) : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          enabled: false,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: enabled
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withOpacity(0.38),
          ),
          decoration: decoration ?? InputDecoration(
            labelText: required ? '$labelText *' : labelText,
            hintText: hintText,
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: Icon(
              Icons.arrow_drop_down,
              color: enabled
                  ? theme.colorScheme.onSurface.withOpacity(0.7)
                  : theme.colorScheme.onSurface.withOpacity(0.38),
            ),
            filled: true,
            fillColor: enabled
                ? theme.colorScheme.surfaceContainerLowest
                : theme.colorScheme.surfaceContainerLowest.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.12),
                width: 1,
              ),
            ),
            contentPadding: contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          controller: TextEditingController(
            text: _getDisplayText(),
          ),
        ),
      ),
    );
  }

  String _getDisplayText() {
    if (value == null) return '';
    
    final selectedItem = items.firstWhere(
      (item) => item.value == value,
      orElse: () => DropdownMenuItem(value: value, child: Text('Unknown')),
    );
    
    // Extract text from the child widget
    if (selectedItem.child is Text) {
      return (selectedItem.child as Text).data ?? '';
    }
    
    return value.toString();
  }

  void _showCenteredDropdown(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext dialogContext) {
        return _CenteredDropdownDialog<T>(
          items: items,
          selectedValue: value,
          onChanged: (T? newValue) {
            Navigator.of(dialogContext).pop();
            onChanged?.call(newValue);
          },
          title: labelText ?? 'Select Option',
        );
      },
    );
  }
}

class _CenteredDropdownDialog<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T?>? onChanged;
  final String title;

  const _CenteredDropdownDialog({
    required this.items,
    this.selectedValue,
    this.onChanged,
    required this.title,
  });

  @override
  State<_CenteredDropdownDialog<T>> createState() => _CenteredDropdownDialogState<T>();
}

class _CenteredDropdownDialogState<T> extends State<_CenteredDropdownDialog<T>> {
  late List<DropdownMenuItem<T>> _filteredItems;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          final itemText = _getItemText(item).toLowerCase();
          return itemText.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  String _getItemText(DropdownMenuItem<T> item) {
    if (item.child is Text) {
      return (item.child as Text).data ?? '';
    } else if (item.child is Row) {
      // Handle items with icons and text
      final row = item.child as Row;
      for (final child in row.children) {
        if (child is Expanded) {
          final expandedChild = child.child;
          if (expandedChild is Text) {
            return expandedChild.data ?? '';
          }
        } else if (child is Text) {
          return child.data ?? '';
        }
      }
    }
    return item.value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    final dialogWidth = screenSize.width * 0.85;
    final dialogHeight = (screenSize.height - keyboardHeight) * 0.7;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Center(
        child: Container(
          width: dialogWidth.clamp(300.0, 600.0),
          height: dialogHeight.clamp(400.0, 700.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(theme),
              _buildSearchField(theme),
              Expanded(
                child: _buildItemsList(theme),
              ),
              _buildFooter(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Search options...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            onPressed: () {
              _searchController.clear();
              _filterItems('');
            },
            icon: Icon(
              Icons.clear,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              size: 18,
            ),
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          isDense: true,
        ),
        onChanged: _filterItems,
      ),
    );
  }

  Widget _buildItemsList(ThemeData theme) {
    if (_filteredItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No options found',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        final isSelected = item.value == widget.selectedValue;
        
        return InkWell(
          onTap: () => widget.onChanged?.call(item.value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              children: [
                Expanded(child: item.child),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${_filteredItems.length} options available',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
