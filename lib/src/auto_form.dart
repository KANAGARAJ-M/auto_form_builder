import 'package:flutter/material.dart';
import 'models/form_config.dart';
import 'auto_form_controller.dart';
import 'themes/form_theme.dart';

/// A widget that automatically builds a form based on a configuration.
class AutoForm extends StatefulWidget {
  /// The configuration for the form.
  final FormConfig config;
  
  /// The controller for the form.
  final AutoFormController? controller;
  
  /// Callback when the form is submitted.
  final void Function(Map<String, dynamic> data)? onSubmit;
  
  /// Whether the form should validate on field changes.
  final bool validateOnChange;
  
  /// Whether the form is read-only.
  final bool readOnly;
  
  /// Theme for the form.
  final FormTheme? theme;

  const AutoForm({
    super.key,
    required this.config,
    this.controller,
    this.onSubmit,
    this.validateOnChange = false,
    this.readOnly = false,
    this.theme,
  });

  @override
  State<AutoForm> createState() => _AutoFormState();
}

class _AutoFormState extends State<AutoForm> {
  late AutoFormController _controller;
  final _formKey = GlobalKey<FormState>();
  late FormTheme _theme;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AutoFormController();
    _controller.setConfig(widget.config);
    _theme = widget.theme ?? FormTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Build form fields from configuration
          ...widget.config.fields.map((fieldConfig) {
            final fieldWidget = _controller.buildField(
              context,
              fieldConfig,
              readOnly: widget.readOnly,
              validateOnChange: widget.validateOnChange,
              theme: _theme,
            );
            
            // Apply spacing between fields
            return Padding(
              padding: EdgeInsets.only(bottom: _theme.fieldSpacing),
              child: fieldWidget,
            );
          }),

          // Submit button if onSubmit is provided
          if (widget.onSubmit != null)
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onSubmit?.call(_controller.getFormData());
                }
              },
              style: _theme.submitButtonStyle,
              child: Text(widget.config.submitButtonText ?? 'Submit'),
            ),
        ],
      ),
    );
  }
}