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

  const AutoDropdown({
    super.key,
    required this.config,
    required this.controller,
    this.readOnly = false,
    this.theme,
  });

  @override
  State<AutoDropdown> createState() => _AutoDropdownState();
}

class _AutoDropdownState extends State<AutoDropdown> {
  dynamic _value;
  late FormTheme _theme;
  
  @override
  void initState() {
    super.initState();
    _value = widget.controller.getFieldValue(widget.config.name);
    _theme = widget.theme ?? FormTheme();
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
    
    return DropdownButtonFormField<dynamic>(
      decoration: decoration,
      value: _value,
      style: _theme.inputStyle,
      dropdownColor: _theme.secondaryColor.withOpacity(0.1),
      items: widget.config.options!.map((option) {
        return DropdownMenuItem(
          value: option.value,
          child: Text(option.label),
        );
      }).toList(),
      onChanged: widget.readOnly ? null : (value) {
        setState(() {
          _value = value;
        });
        widget.controller.updateField(widget.config.name, value);
      },
      validator: (value) {
        for (var validator in widget.config.validators) {
          final error = validator.validate(value);
          if (error != null) return error;
        }
        return null;
      },
    );
  }
}