import 'package:flutter/material.dart';
import '../models/form_field_config.dart';
import '../auto_form_controller.dart';
import '../themes/form_theme.dart';

/// Automatically generated date picker field based on configuration.
class AutoDatePicker extends StatefulWidget {
  /// The field configuration.
  final FormFieldConfig config;
  
  /// The form controller.
  final AutoFormController controller;
  
  /// Whether the field is read-only.
  final bool readOnly;
  
  /// Theme for the date picker.
  final FormTheme? theme;

  const AutoDatePicker({
    super.key,
    required this.config,
    required this.controller,
    this.readOnly = false,
    this.theme,
  });

  @override
  State<AutoDatePicker> createState() => _AutoDatePickerState();
}

class _AutoDatePickerState extends State<AutoDatePicker> {
  DateTime? _selectedDate;
  late TextEditingController _textController;
  late FormTheme _theme;
  
  @override
  void initState() {
    super.initState();
    final initialValue = widget.controller.getFieldValue(widget.config.name);
    if (initialValue is DateTime) {
      _selectedDate = initialValue;
    } else if (initialValue is String && initialValue.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(initialValue);
      } catch (_) {
        _selectedDate = null;
      }
    }
    
    _textController = TextEditingController(
      text: _selectedDate != null 
          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
          : '',
    );
    
    _theme = widget.theme ?? FormTheme();
  }
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    if (widget.readOnly) return;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _theme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _textController.text = '${picked.day}/${picked.month}/${picked.year}';
        widget.controller.updateField(widget.config.name, picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use theme-specific decoration for date pickers or fall back to the default
    final decoration = (_theme.datePickerDecoration ?? _theme.inputDecoration).copyWith(
      labelText: widget.config.label,
      hintText: widget.config.hint ?? 'Select date',
      suffixIcon: Icon(_theme.datePickerIcon),
      labelStyle: _theme.labelStyle,
      errorStyle: _theme.errorStyle,
    );
    
    return TextFormField(
      controller: _textController,
      decoration: decoration,
      style: _theme.inputStyle,
      readOnly: true,
      onTap: () => _selectDate(context),
      validator: (value) {
        for (var validator in widget.config.validators) {
          final error = validator.validate(_selectedDate);
          if (error != null) return error;
        }
        return null;
      },
    );
  }
}