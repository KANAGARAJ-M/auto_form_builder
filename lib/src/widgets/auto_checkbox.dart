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

  const AutoCheckbox({
    super.key,
    required this.config,
    required this.controller,
    this.readOnly = false,
    this.theme,
  });

  @override
  State<AutoCheckbox> createState() => _AutoCheckboxState();
}

class _AutoCheckboxState extends State<AutoCheckbox> {
  bool _value = false;
  late FormTheme _theme;
  
  @override
  void initState() {
    super.initState();
    final initialValue = widget.controller.getFieldValue(widget.config.name);
    if (initialValue is bool) {
      _value = initialValue;
    }
    _theme = widget.theme ?? FormTheme();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      initialValue: _value,
      validator: (value) {
        for (var validator in widget.config.validators) {
          final error = validator.validate(value);
          if (error != null) return error;
        }
        return null;
      },
      builder: (FormFieldState<bool> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Theme(
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
                    ),
                  ),
                  child: Checkbox(
                    value: _value,
                    onChanged: widget.readOnly ? null : (value) {
                      setState(() {
                        _value = value ?? false;
                        widget.controller.updateField(widget.config.name, _value);
                      });
                      field.didChange(_value);
                    },
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.config.label,
                    style: _theme.labelStyle,
                  ),
                ),
              ],
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                child: Text(
                  field.errorText!,
                  style: _theme.errorStyle,
                ),
              ),
          ],
        );
      },
    );
  }
}