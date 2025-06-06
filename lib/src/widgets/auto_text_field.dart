import 'package:flutter/material.dart';
import '../models/form_field_config.dart';
import '../auto_form_controller.dart';
import '../themes/form_theme.dart';

/// Automatically generated text field based on configuration.
class AutoTextField extends StatefulWidget {
  /// The field configuration.
  final FormFieldConfig config;
  
  /// The form controller.
  final AutoFormController controller;
  
  /// Whether the field is read-only.
  final bool readOnly;
  
  /// Whether to validate on field changes.
  final bool validateOnChange;

  /// Theme for the text field.
  final FormTheme? theme;

  const AutoTextField({
    super.key,
    required this.config,
    required this.controller,
    this.readOnly = false,
    this.validateOnChange = false,
    this.theme,
  });

  @override
  State<AutoTextField> createState() => _AutoTextFieldState();
}

class _AutoTextFieldState extends State<AutoTextField> {
  late TextEditingController _textController;
  late FormTheme _theme;
  
  @override
  void initState() {
    super.initState();
    final initialValue = widget.controller.getFieldValue(widget.config.name) as String? ?? '';
    _textController = TextEditingController(text: initialValue);
    _theme = widget.theme ?? FormTheme();
  }
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use theme-specific decoration for text fields or fall back to the default
    final decoration = _theme.inputDecoration.copyWith(
      labelText: widget.config.label,
      hintText: widget.config.hint,
      labelStyle: _theme.labelStyle,
      errorStyle: _theme.errorStyle,
    );

    return TextFormField(
      controller: _textController,
      decoration: decoration,
      style: _theme.inputStyle,
      readOnly: widget.readOnly,
      onChanged: (value) {
        widget.controller.updateField(widget.config.name, value);
        if (widget.validateOnChange) {
          Form.of(context).validate();
        }
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