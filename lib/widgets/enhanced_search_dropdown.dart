import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/search_utils.dart';
import '../design_system/material_design_system.dart';

/// Enhanced Search Dropdown Widget
/// Provides optimized search functionality with better UX
class EnhancedSearchDropdown<T> extends StatefulWidget {
  final String label;
  final String hint;
  final List<T> items;
  final String Function(T item) itemLabel;
  final String? Function(T item)? itemSubtitle;
  final Widget Function(T item)? itemBuilder;
  final T? selectedItem;
  final Function(T? item) onChanged;
  final bool showSearch;
  final bool isRequired;
  final String? errorText;
  final bool isLoading;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enableFiltering;
  final String? noItemsText;
  final double? maxHeight;
  final bool showClearButton;
  final VoidCallback? onClear;
  final bool showSelectedItem;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final InputBorder? border;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;

  const EnhancedSearchDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.itemLabel,
    this.itemSubtitle,
    this.itemBuilder,
    this.selectedItem,
    required this.onChanged,
    this.showSearch = true,
    this.isRequired = false,
    this.errorText,
    this.isLoading = false,
    this.prefixIcon,
    this.suffixIcon,
    this.enableFiltering = true,
    this.noItemsText,
    this.maxHeight,
    this.showClearButton = true,
    this.onClear,
    this.showSelectedItem = true,
    this.labelStyle,
    this.hintStyle,
    this.border,
    this.fillColor,
    this.contentPadding,
  });

  @override
  State<EnhancedSearchDropdown<T>> createState() => _EnhancedSearchDropdownState<T>();
}

class _EnhancedSearchDropdownState<T> extends State<EnhancedSearchDropdown<T>> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  
  OverlayEntry? _overlayEntry;
  List<T> _filteredItems = [];
  bool _isOpen = false;
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(widget.items);
    _searchController.addListener(_onSearchChanged);
    _focusNode.addListener(_onFocusChanged);
    
    // Set initial search text if item is selected
    if (widget.selectedItem != null) {
      _searchController.text = widget.itemLabel(widget.selectedItem!);
    }
  }

  @override
  void didUpdateWidget(EnhancedSearchDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update filtered items when items change
    if (oldWidget.items != widget.items) {
      _filteredItems = List.from(widget.items);
      _filterItems();
    }
    
    // Update search text when selected item changes
    if (oldWidget.selectedItem != widget.selectedItem) {
      if (widget.selectedItem != null) {
        _searchController.text = widget.itemLabel(widget.selectedItem!);
      } else {
        _searchController.clear();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onSearchChanged() {
    if (widget.enableFiltering) {
      _filterItems();
    }
    _showOverlay();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      // Delay hiding overlay to allow for item selection
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!_focusNode.hasFocus) {
          _hideOverlay();
        }
      });
    }
  }

  void _filterItems() {
    if (_searchController.text.isEmpty) {
      _filteredItems = List.from(widget.items);
    } else {
      _filteredItems = widget.items.where((item) {
        final label = widget.itemLabel(item).toLowerCase();
        final searchText = _searchController.text.toLowerCase();
        return SearchUtils.fuzzyMatches(label, searchText);
      }).toList();
    }
    
    // Reset selected index
    _selectedIndex = -1;
    
    // Update overlay if it's open
    if (_isOpen) {
      _updateOverlay();
    }
  }

  void _showOverlay() {
    if (_overlayEntry == null && _focusNode.hasFocus) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
      _isOpen = true;
    }
  }

  void _hideOverlay() {
    _removeOverlay();
    _isOpen = false;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _updateOverlay() {
    _removeOverlay();
    if (_focusNode.hasFocus) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(MaterialDesignSystem.radius12),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: widget.maxHeight ?? 300,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(MaterialDesignSystem.radius12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: _buildDropdownContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownContent() {
    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(MaterialDesignSystem.spacing16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_filteredItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(MaterialDesignSystem.spacing16),
        child: Center(
          child: Text(
            widget.noItemsText ?? 'No items found',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        final isSelected = item == widget.selectedItem;
        final isHighlighted = index == _selectedIndex;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectItem(item),
            onHover: (hovering) {
              if (hovering) {
                setState(() {
                  _selectedIndex = index;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MaterialDesignSystem.spacing16,
                vertical: MaterialDesignSystem.spacing12,
              ),
              decoration: BoxDecoration(
                color: isSelected || isHighlighted
                    ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1)
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                    width: 0.5,
                  ),
                ),
              ),
              child: widget.itemBuilder?.call(item) ?? _buildDefaultItem(item, isSelected),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultItem(T item, bool isSelected) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.itemLabel(item),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (widget.itemSubtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  widget.itemSubtitle!(item) ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (isSelected)
          Icon(
            Icons.check,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
      ],
    );
  }

  void _selectItem(T item) {
    widget.onChanged(item);
    _searchController.text = widget.itemLabel(item);
    _focusNode.unfocus();
    _hideOverlay();
  }

  void _clearSelection() {
    widget.onChanged(null);
    _searchController.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  widget.label,
                  style: widget.labelStyle ?? Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (widget.isRequired) ...[
                  const SizedBox(width: 4),
                  Text(
                    '*',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: MaterialDesignSystem.spacing8),
          ],
          TextFormField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: widget.hintStyle ?? Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              prefixIcon: widget.prefixIcon ?? const Icon(Icons.search),
              suffixIcon: _buildSuffixIcon(),
              border: widget.border ?? OutlineInputBorder(
                borderRadius: BorderRadius.circular(MaterialDesignSystem.radius12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: widget.border ?? OutlineInputBorder(
                borderRadius: BorderRadius.circular(MaterialDesignSystem.radius12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MaterialDesignSystem.radius12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MaterialDesignSystem.radius12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              filled: true,
              fillColor: widget.fillColor ?? Theme.of(context).colorScheme.surfaceContainerLowest,
              contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(
                horizontal: MaterialDesignSystem.spacing16,
                vertical: MaterialDesignSystem.spacing12,
              ),
              errorText: widget.errorText,
            ),
            readOnly: !widget.showSearch,
            onTap: widget.showSearch ? null : () {
              if (!_isOpen) {
                _focusNode.requestFocus();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (widget.selectedItem != null && widget.showClearButton) {
      return IconButton(
        icon: const Icon(Icons.clear, size: 18),
        onPressed: _clearSelection,
        tooltip: 'Clear selection',
      );
    }

    return widget.suffixIcon ?? const Icon(Icons.arrow_drop_down);
  }
}
