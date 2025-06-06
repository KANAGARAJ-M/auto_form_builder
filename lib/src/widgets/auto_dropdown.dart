import 'package:flutter/material.dart';
import '../models/form_field_config.dart';
import '../auto_form_controller.dart';
import '../themes/form_theme.dart';

/// Automatically generated dropdown field based on configuration.
class AutoDropdown extends StatefulWidget {
  /// The field configuration.
  final FormFieldConfig config;
  
  /// The form controller.
  final AutoFormController controller;
  
  /// Whether the field is read-only.
  final bool readOnly;
  
  /// Theme for the dropdown.
  final FormTheme? theme;
  
  /// Custom icon for the dropdown button.
  final Widget? dropdownIcon;
  
  /// Whether to enable searching in the dropdown.
  final bool enableSearch;
  
  /// Placeholder text for the search field.
  final String searchHint;
  
  /// Custom builder for dropdown items.
  final Widget Function(BuildContext, FieldOption)? itemBuilder;
  
  /// Custom builder for the selected item display.
  final Widget Function(BuildContext, dynamic)? selectedItemBuilder;
  
  /// Whether to show a divider between items.
  final bool showDivider;
  
  /// Maximum height of the dropdown menu.
  final double? menuMaxHeight;
  
  /// Whether to show icons for dropdown items.
  final bool showIcons;
  
  /// Default icon to show when item doesn't have one.
  final IconData defaultIcon;
  
  /// Animation duration for dropdown opening/closing.
  final Duration animationDuration;
  
  /// Background color for the dropdown items.
  final Color? itemBackgroundColor;
  
  /// Whether to enable item hover effect.
  final bool enableHover;
  
  /// Whether to show the dropdown button when the field is empty.
  final bool showButtonWhenEmpty;
  
  /// Custom placeholder widget when no item is selected.
  final Widget? placeholder;
  
  /// Whether to show a clear button to remove selection.
  final bool showClearButton;

  const AutoDropdown({
    super.key,
    required this.config,
    required this.controller,
    this.readOnly = false,
    this.theme,
    this.dropdownIcon,
    this.enableSearch = false,
    this.searchHint = 'Search...',
    this.itemBuilder,
    this.selectedItemBuilder,
    this.showDivider = false,
    this.menuMaxHeight,
    this.showIcons = false,
    this.defaultIcon = Icons.circle,
    this.animationDuration = const Duration(milliseconds: 200),
    this.itemBackgroundColor,
    this.enableHover = true,
    this.showButtonWhenEmpty = true,
    this.placeholder,
    this.showClearButton = false,
  });

  @override
  State<AutoDropdown> createState() => _AutoDropdownState();
}

class _AutoDropdownState extends State<AutoDropdown> with SingleTickerProviderStateMixin {
  dynamic _value;
  late FormTheme _theme;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  final TextEditingController _searchController = TextEditingController();
  List<FieldOption> _filteredOptions = [];
  bool _isMenuOpen = false;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  
  @override
  void initState() {
    super.initState();
    _value = widget.controller.getFieldValue(widget.config.name);
    _theme = widget.theme ?? FormTheme();
    _initializeAnimations();
    _filteredOptions = widget.config.options ?? [];
    
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && widget.enableSearch && widget.config.options != null && widget.config.options!.isNotEmpty) {
        _showSearchableDropdown();
      } else if (!_focusNode.hasFocus) {
        _hideOverlay();
      }
    });
  }
  
  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _focusNode.dispose();
    _hideOverlay();
    super.dispose();
  }
  
  void _showSearchableDropdown() {
    _isMenuOpen = true;
    _animationController.forward();
    
    _overlayEntry = OverlayEntry(
      builder: (context) {
        // Get render information at the time overlay is showing
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final size = renderBox.size;
        
        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            offset: const Offset(0, 8),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: widget.menuMaxHeight ?? 300,
                ),
                decoration: BoxDecoration(
                  color: widget.itemBackgroundColor ?? Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _theme.primaryColor.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.enableSearch)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: widget.searchHint,
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onChanged: _onSearchChanged,
                          autofocus: true,
                        ),
                      ),
                    Flexible(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shrinkWrap: true,
                        itemCount: _filteredOptions.length,
                        separatorBuilder: (context, index) => widget.showDivider 
                          ? const Divider(height: 1) 
                          : const SizedBox.shrink(),
                        itemBuilder: (context, index) {
                          final option = _filteredOptions[index];
                          
                          return _buildDropdownItem(option);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }
  
  void _hideOverlay() {
    _isMenuOpen = false;
    _animationController.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
  
  void _onSearchChanged(String query) {
    if (widget.config.options == null) return;
    
    setState(() {
      if (query.isEmpty) {
        _filteredOptions = widget.config.options!;
      } else {
        _filteredOptions = widget.config.options!.where((option) {
          return option.label.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
      
      // Rebuild the overlay with filtered options
      _hideOverlay();
      _showSearchableDropdown();
    });
  }
  
  Widget _buildDropdownItem(FieldOption option) {
    if (widget.itemBuilder != null) {
      return InkWell(
        onTap: () => _selectOption(option.value),
        child: widget.itemBuilder!(context, option),
      );
    }
    
    return InkWell(
      onTap: () => _selectOption(option.value),
      hoverColor: widget.enableHover ? _theme.primaryColor.withOpacity(0.1) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: _value == option.value 
          ? _theme.primaryColor.withOpacity(0.1) 
          : null,
        child: Row(
          children: [
            if (widget.showIcons) ...[
              Icon(
                widget.defaultIcon,
                color: _value == option.value ? _theme.primaryColor : null,
                size: 18,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                option.label,
                style: _theme.inputStyle.copyWith(
                  fontWeight: _value == option.value ? FontWeight.bold : null,
                  color: _value == option.value ? _theme.primaryColor : null,
                ),
              ),
            ),
            if (_value == option.value)
              Icon(
                Icons.check,
                color: _theme.primaryColor,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
  
  void _selectOption(dynamic value) {
    setState(() {
      _value = value;
      widget.controller.updateField(widget.config.name, value);
      _hideOverlay();
      _focusNode.unfocus();
    });
  }
  
  void _clearSelection() {
    setState(() {
      _value = null;
      widget.controller.updateField(widget.config.name, null);
    });
  }
  
  Widget _buildSelectedItem() {
    if (_value == null) {
      return widget.placeholder ?? Text(
        widget.config.hint ?? 'Select an option',
        style: _theme.inputStyle.copyWith(
          color: Colors.black54,
        ),
      );
    }
    
    if (widget.selectedItemBuilder != null) {
      return widget.selectedItemBuilder!(context, _value);
    }
    
    final selectedOption = widget.config.options?.firstWhere(
      (option) => option.value == _value,
      orElse: () => FieldOption(label: _value.toString(), value: _value),
    );
    
    return Row(
      children: [
        if (widget.showIcons) ...[
          Icon(
            widget.defaultIcon,
            color: _theme.primaryColor,
            size: 18,
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            selectedOption?.label ?? _value.toString(),
            style: _theme.inputStyle,
          ),
        ),
        if (widget.showClearButton && !widget.readOnly)
          IconButton(
            icon: const Icon(Icons.clear, size: 18),
            onPressed: _clearSelection,
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.config.options == null || widget.config.options!.isEmpty) {
      return const Text('No options available');
    }
    
    // Use theme-specific decoration for dropdowns or fall back to the default
    final decoration = (_theme.dropdownDecoration ?? _theme.inputDecoration).copyWith(
      labelText: widget.config.label,
      labelStyle: _theme.labelStyle,
      errorStyle: _theme.errorStyle,
    );
    
    if (widget.enableSearch) {
      return FormField<dynamic>(
        initialValue: _value,
        validator: (value) {
          for (var validator in widget.config.validators) {
            final error = validator.validate(value);
            if (error != null) return error;
          }
          return null;
        },
        builder: (FormFieldState<dynamic> field) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CompositedTransformTarget(
                link: _layerLink,
                child: InkWell(
                    onTap: widget.readOnly ? null : () {
                      if (_isMenuOpen) {
                        _hideOverlay();
                      } else {
                        _focusNode.requestFocus();
                      }
                    },
                  borderRadius: BorderRadius.circular(8),
                  child: InputDecorator(
                    decoration: decoration.copyWith(
                      errorText: field.errorText,
                      suffixIcon: RotationTransition(
                        turns: _rotationAnimation,
                        child: widget.dropdownIcon ?? const Icon(Icons.arrow_drop_down),
                      ),
                    ),
                    isEmpty: _value == null,
                    isFocused: _focusNode.hasFocus,
                    child: _buildSelectedItem(),
                  ),
                ),
              ),
              // Hidden focus node for keyboard control
              SizedBox(
                height: 0,
                width: 0,
                child: Focus(
                  focusNode: _focusNode,
                  child: Container(),
                ),
              ),
            ],
              
          );
            
        },
      );
    }
    
    // Use standard DropdownButtonFormField for non-searchable dropdowns
    return FormField<dynamic>(
      initialValue: _value,
      validator: (value) {
        for (var validator in widget.config.validators) {
          final error = validator.validate(value);
          if (error != null) return error;
        }
        return null;
      },
      builder: (FormFieldState<dynamic> field) {
        return DropdownButtonFormField<dynamic>(
          decoration: decoration,
          value: _value,
          style: _theme.inputStyle,
          dropdownColor: widget.itemBackgroundColor ?? _theme.secondaryColor.withOpacity(0.1),
          menuMaxHeight: widget.menuMaxHeight,
          icon: widget.dropdownIcon ?? const Icon(Icons.arrow_drop_down),
          isExpanded: true,
          hint: widget.placeholder,
          items: widget.config.options!.map((option) {
            return DropdownMenuItem(
              value: option.value,
              child: widget.itemBuilder != null
                ? widget.itemBuilder!(context, option)
                : Row(
                    children: [
                      if (widget.showIcons) ...[
                        Icon(
                          widget.defaultIcon,
                          size: 18,
                          color: _value == option.value ? _theme.primaryColor : null,
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(option.label),
                      ),
                    ],
                  ),
            );
          }).toList(),
          selectedItemBuilder: widget.selectedItemBuilder != null
            ? (context) {
                return widget.config.options!.map((option) {
                  return widget.selectedItemBuilder!(context, option.value);
                }).toList();
              }
            : null,
          onChanged: widget.readOnly ? null : (value) {
            setState(() {
              _value = value;
            });
            field.didChange(value); // Now field is properly in scope
            widget.controller.updateField(widget.config.name, value);
          },
          validator: null, // Validation is handled by the parent FormField
        );
      },
    );
  }
}