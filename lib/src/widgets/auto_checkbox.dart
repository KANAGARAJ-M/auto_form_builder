import 'package:flutter/material.dart';
import '../models/form_field_config.dart';
import '../auto_form_controller.dart';
import '../themes/form_theme.dart';

/// Automatically generated checkbox field based on configuration.
class AutoCheckbox extends StatefulWidget {
  /// The field configuration.
  final FormFieldConfig config;
  
  /// The form controller.
  final AutoFormController controller;
  
  /// Whether the field is read-only.
  final bool readOnly;
  
  /// Theme for the checkbox.
  final FormTheme? theme;
  
  /// Position of the label relative to the checkbox (left or right).
  final TextDirection labelDirection;
  
  /// Whether to show a ripple effect when toggling.
  final bool enableFeedback;
  
  /// Custom checkbox icons for checked, unchecked, and indeterminate states.
  final Widget? checkedIcon;
  final Widget? uncheckedIcon;
  final Widget? indeterminateIcon;
  
  /// Spacing between checkbox and label.
  final double spacing;
  
  /// Additional helper text to display below the checkbox.
  final String? helperText;
  
  /// Whether to support indeterminate state (null value).
  final bool tristate;

  const AutoCheckbox({
    super.key,
    required this.config,
    required this.controller,
    this.readOnly = false,
    this.theme,
    this.labelDirection = TextDirection.ltr,
    this.enableFeedback = true,
    this.checkedIcon,
    this.uncheckedIcon,
    this.indeterminateIcon,
    this.spacing = 8.0,
    this.helperText,
    this.tristate = false,
  });

  @override
  State<AutoCheckbox> createState() => _AutoCheckboxState();
}

class _AutoCheckboxState extends State<AutoCheckbox> with SingleTickerProviderStateMixin {
  bool? _value = false;
  bool? _initialValue = false;
  late FormTheme _theme;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    // Initialize animation controller for feedback effect
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    final initialValue = widget.controller.getFieldValue(widget.config.name);
    if (initialValue is bool) {
      _value = initialValue;
      _initialValue = initialValue;
    } else if (initialValue == null && widget.tristate) {
      _value = null;
      _initialValue = null;
    }
    _theme = widget.theme ?? FormTheme();
    _theme = widget.theme ?? FormTheme();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleValue() {
    if (widget.readOnly) return;
    
    if (widget.enableFeedback) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
    
    setState(() {
      if (widget.tristate) {
        if (_value == false) {
          _value = true;
        } else if (_value == true) {
          _value = null;
        } else {
          _value = false;
        }
      } else {
        _value = !(_value ?? false);
      }
      widget.controller.updateField(widget.config.name, _value);
    });
  }

  // Builds a custom checkbox if custom icons are provided
  Widget _buildCustomCheckbox() {
    if (widget.checkedIcon != null || widget.uncheckedIcon != null || widget.indeterminateIcon != null) {
      Widget icon;
      if (_value == true && widget.checkedIcon != null) {
        icon = widget.checkedIcon!;
      } else if (_value == false && widget.uncheckedIcon != null) {
        icon = widget.uncheckedIcon!;
      } else if (_value == null && widget.indeterminateIcon != null) {
        icon = widget.indeterminateIcon!;
      } else {
        // Fall back to standard checkbox
        return _buildStandardCheckbox();
      }
      
      return IconButton(
        onPressed: widget.readOnly ? null : _toggleValue,
        icon: icon,
        splashRadius: 20,
        color: _value == true ? _theme.primaryColor : null,
      );
    }
    
    return _buildStandardCheckbox();
  }
  
  // Builds a standard checkbox with theme
  Widget _buildStandardCheckbox() {
    return Theme(
      data: Theme.of(context).copyWith(
        checkboxTheme: _theme.checkboxTheme ?? CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.disabled)) {
              return _theme.primaryColor.withOpacity(0.5);
            }
            return _theme.primaryColor;
          }),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          // Add a subtle animation for state changes
          splashRadius: 20,
          materialTapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      child: Checkbox(
        value: _value ?? false,
        tristate: widget.tristate,
        onChanged: widget.readOnly ? null : (value) {
          setState(() {
            _value = value;
            widget.controller.updateField(widget.config.name, _value);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      initialValue: _value ?? false,
      validator: (value) {
        for (var validator in widget.config.validators) {
          final error = validator.validate(value);
          if (error != null) return error;
        }
        return null;
      },
      builder: (FormFieldState<bool> field) {
        // Set up a tooltip if hint is provided
        final String? tooltip = widget.config.hint;
        
        // Create the checkbox with its wrapper
        Widget checkboxWidget = _buildCustomCheckbox();
        
        // Create the label with proper styling
        Widget labelWidget = Text(
          widget.config.label,
          style: widget.readOnly 
            ? _theme.labelStyle.copyWith(color: _theme.labelStyle.color?.withOpacity(0.5))
            : _theme.labelStyle,
        );
        
        // Create list of row children based on label direction
        List<Widget> rowChildren = [];
        if (widget.labelDirection == TextDirection.rtl) {
          // Label on the left, checkbox on the right
          rowChildren = [
            Expanded(child: labelWidget),
            SizedBox(width: widget.spacing),
            checkboxWidget,
          ];
        } else {
          // Default: Checkbox on the left, label on the right
          rowChildren = [
            checkboxWidget,
            SizedBox(width: widget.spacing),
            Expanded(child: labelWidget),
          ];
        }
        
        // Make the whole row clickable to toggle checkbox
        Widget checkboxRow = ScaleTransition(
          scale: _scaleAnimation,
          child: InkWell(
            onTap: widget.readOnly ? null : _toggleValue,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: rowChildren,
              ),
            ),
          ),
        );
        
        // Add tooltip if available
        if (tooltip != null) {
          checkboxRow = Tooltip(
            message: tooltip,
            child: checkboxRow,
          );
        }
        
        // Helper text widget if provided
        Widget? helperTextWidget;
        if (widget.helperText != null) {
          helperTextWidget = Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 4.0),
            child: Text(
              widget.helperText!,
              style: TextStyle(
                color: _theme.secondaryColor.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          );
        }
        
        // Build the final column with all elements
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Make widget accessible with semantic labels
            Semantics(
              checked: _value ?? false,
              label: widget.config.label,
              enabled: !widget.readOnly,
              child: checkboxRow,
            ),
            
            // Helper text if available
            if (helperTextWidget != null) helperTextWidget,
            
            // Error message
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                child: Text(
                  field.errorText!,
                  style: _theme.errorStyle,
                ),
              ),
            
            // Success indicator when field is valid and has been touched
            if (!field.hasError && field.value != _initialValue)
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: _theme.successColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Saved',
                      style: TextStyle(
                        color: _theme.successColor,
                        fontSize: _theme.errorStyle.fontSize,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}