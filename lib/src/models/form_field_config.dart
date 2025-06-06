import 'package:flutter/material.dart';
import '../validators/validators.dart';

/// Types of form fields supported by the form builder.
enum FormFieldType {
  text,
  dropdown,
  datePicker,
  checkbox,
  radio,
  multiSelect,
  custom
}

/// Configuration for a form field.
class FormFieldConfig {
  /// The name of the field (used as key in form data).
  final String name;
  
  /// The type of the field.
  final FormFieldType type;
  
  /// The label to display for the field.
  final String label;
  
  /// The hint text to display for the field.
  final String? hint;
  
  /// Whether the field is required.
  final bool required;
  
  /// The default value for the field.
  final dynamic defaultValue;
  
  /// Validators for the field.
  final List<FieldValidator> validators;
  
  /// Additional options for dropdown, radio, etc.
  final List<FieldOption>? options;
  
  /// Custom builder for custom field types.
  final Widget Function(BuildContext, FormFieldConfig, dynamic, void Function(dynamic))? customBuilder;

  FormFieldConfig({
    required this.name,
    required this.type,
    required this.label,
    this.hint,
    this.required = false,
    this.defaultValue,
    this.validators = const [],
    this.options,
    this.customBuilder,
  });
  
  /// Creates a FormFieldConfig from a JSON map.
  factory FormFieldConfig.fromJson(Map<String, dynamic> json) {
    return FormFieldConfig(
      name: json['name'],
      type: _parseFieldType(json['type']),
      label: json['label'],
      hint: json['hint'],
      required: json['required'] ?? false,
      defaultValue: json['defaultValue'],
      validators: _parseValidators(json['validators']),
      options: json['options'] != null 
          ? (json['options'] as List).map((e) => FieldOption.fromJson(e)).toList() 
          : null,
    );
  }
  
  static FormFieldType _parseFieldType(String type) {
    switch (type) {
      case 'text': return FormFieldType.text;
      case 'dropdown': return FormFieldType.dropdown;
      case 'datePicker': return FormFieldType.datePicker;
      case 'checkbox': return FormFieldType.checkbox;
      case 'radio': return FormFieldType.radio;
      case 'multiSelect': return FormFieldType.multiSelect;
      case 'custom': return FormFieldType.custom;
      default: return FormFieldType.text;
    }
  }
  
  static List<FieldValidator> _parseValidators(List? validatorsList) {
    if (validatorsList == null) return [];
    
    return validatorsList.map((v) {
      if (v is String) {
        switch (v) {
          case 'required': return RequiredValidator();
          case 'email': return EmailValidator();
          default: return RequiredValidator();
        }
      } else if (v is Map) {
        if (v['type'] == 'minLength') {
          return MinLengthValidator(v['value']);
        } else if (v['type'] == 'maxLength') {
          return MaxLengthValidator(v['value']);
        }
      }
      return RequiredValidator();
    }).toList();
  }
}

/// Option for dropdown, radio, etc.
class FieldOption {
  final String label;
  final dynamic value;
  
  FieldOption({required this.label, required this.value});
  
  factory FieldOption.fromJson(Map<String, dynamic> json) {
    return FieldOption(
      label: json['label'],
      value: json['value'],
    );
  }
}