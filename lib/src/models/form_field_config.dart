import 'package:flutter/material.dart';

/// Type of form field
enum FormFieldType {
  /// Text input field
  text,
  
  /// Dropdown select field
  dropdown,
  
  /// Date picker field
  datePicker,
  
  /// Checkbox field
  checkbox,
  
  /// Custom field (using builder)
  custom,
}

/// Option for dropdown fields
class FieldOption {
  /// Display label
  final String label;
  
  /// Actual value
  final dynamic value;
  
  /// Optional icon
  final IconData? icon;

  FieldOption({
    required this.label,
    required this.value,
    this.icon,
  });
  
  /// Creates a FieldOption from a JSON map.
  factory FieldOption.fromJson(Map<String, dynamic> json) {
    return FieldOption(
      label: json['label'],
      value: json['value'],
      icon: json['icon'] != null ? IconData(json['icon'], fontFamily: 'MaterialIcons') : null,
    );
  }
}

/// Field validator
class FieldValidator {
  /// Type of validation (required, email, min, max, etc.)
  final String type;
  
  /// Custom error message
  final String? message;
  
  /// Value for validators that need a value (min, max, etc.)
  final dynamic value;

  FieldValidator({
    required this.type,
    this.message,
    this.value,
  });
  
  /// Creates a FieldValidator from a JSON map.
  factory FieldValidator.fromJson(Map<String, dynamic> json) {
    return FieldValidator(
      type: json['type'],
      message: json['message'],
      value: json['value'],
    );
  }
  
  /// Validates a value against this validator.
  String? validate(dynamic value) {
    switch (type) {
      case 'required':
        if (value == null || value == '') {
          return message ?? 'This field is required';
        }
        break;
      case 'email':
        if (value != null && value != '') {
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(value)) {
            return message ?? 'Enter a valid email address';
          }
        }
        break;
      case 'min':
        if (value != null) {
          if (value is String && value.length < this.value) {
            return message ?? 'Enter at least ${this.value} characters';
          } else if (value is num && value < this.value) {
            return message ?? 'Value must be at least ${this.value}';
          }
        }
        break;
      case 'max':
        if (value != null) {
          if (value is String && value.length > this.value) {
            return message ?? 'Enter no more than ${this.value} characters';
          } else if (value is num && value > this.value) {
            return message ?? 'Value must be no more than ${this.value}';
          }
        }
        break;
      // Add more validation types as needed
    }
    return null;
  }
}

/// Condition for field visibility
class VisibilityCondition {
  /// Name of the field this condition depends on
  final String fieldName;
  
  /// Comparison operator (equals, notEquals, contains, etc.)
  final String operator;
  
  /// Value to compare against
  final dynamic value;
  
  VisibilityCondition({
    required this.fieldName,
    required this.operator,
    required this.value,
  });
  
  /// Creates a VisibilityCondition from a JSON map.
  factory VisibilityCondition.fromJson(Map<String, dynamic> json) {
    return VisibilityCondition(
      fieldName: json['fieldName'],
      operator: json['operator'],
      value: json['value'],
    );
  }

  /// Converts this visibility condition to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'fieldName': fieldName,
      'operator': operator,
      'value': value,
    };
  }
}

/// Configuration for a form field.
class FormFieldConfig {
  /// Unique name for the field.
  final String name;
  
  /// Type of field.
  final FormFieldType type;
  
  /// Display label.
  final String label;
  
  /// Optional hint text.
  final String? hint;
  
  /// Default value.
  final dynamic defaultValue;
  
  /// List of validators.
  final List<FieldValidator> validators;
  
  /// List of options for dropdown fields.
  final List<FieldOption>? options;
  
  /// Custom builder for custom fields.
  final Widget Function(BuildContext, FormFieldConfig, dynamic, Function(dynamic))? customBuilder;
  
  /// List of fields this field depends on for computed values
  final List<String>? computeFrom;
  
  /// Function to compute value based on other fields
  final dynamic Function(Map<String, dynamic>)? computeValue;

  /// Conditions that determine when this field is visible
  final List<VisibilityCondition>? visibleWhen;
  
  /// Input mask pattern for formatting text inputs.
  /// 
  /// Use the following special characters:
  /// - '#': Any alphanumeric character
  /// - '0' or '9': Only digits (0-9)
  /// - 'A': Only letters (a-z, A-Z)
  /// - 'a': Only letters, lowercase forced
  /// - Any other character: Inserted as a literal
  /// 
  /// Examples:
  /// - Phone: '###-###-####' (123-456-7890)
  /// - Date: '##/##/####' (12/31/2023)
  /// - Credit Card: '#### #### #### ####' (4111 1111 1111 1111)
  /// - SSN: '###-##-####' (123-45-6789)
  /// - Currency: '$###,###.##' ($123,456.78)
  final String? mask;

  FormFieldConfig({
    required this.name,
    required this.type,
    required this.label,
    this.hint,
    this.defaultValue,
    this.validators = const [],
    this.options,
    this.customBuilder,
    this.computeFrom,
    this.computeValue,
    this.visibleWhen,
    this.mask,
  });
  
  /// Creates a FormFieldConfig from a JSON map.
  factory FormFieldConfig.fromJson(Map<String, dynamic> json) {
    return FormFieldConfig(
      name: json['name'],
      type: _parseFieldType(json['type']),
      label: json['label'],
      hint: json['hint'],
      defaultValue: json['defaultValue'],
      validators: json['validators'] != null
          ? (json['validators'] as List).map((v) => FieldValidator.fromJson(v)).toList()
          : [],
      options: json['options'] != null
          ? (json['options'] as List).map((o) => FieldOption.fromJson(o)).toList()
          : null,
      visibleWhen: json['visibleWhen'] != null
          ? (json['visibleWhen'] as List).map((c) => VisibilityCondition.fromJson(c)).toList()
          : null,
    );
  }
  
  /// Converts this field configuration to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {
      'name': name,
      'type': _fieldTypeToString(type),
      'label': label,
    };
    
    // Add optional properties if they exist
    if (hint != null) {
      result['hint'] = hint;
    }
    
    if (defaultValue != null) {
      result['defaultValue'] = defaultValue;
    }
    
    if (validators.isNotEmpty) {
      result['validators'] = validators.map((v) => {
        'type': v.type,
        if (v.message != null) 'message': v.message,
        if (v.value != null) 'value': v.value,
      }).toList();
    }
    
    if (options != null && options!.isNotEmpty) {
      result['options'] = options!.map((o) => {
        'label': o.label,
        'value': o.value,
        if (o.icon != null) 'icon': o.icon!.codePoint,
      }).toList();
    }
    
    if (visibleWhen != null && visibleWhen!.isNotEmpty) {
      result['visibleWhen'] = visibleWhen!.map((c) => c.toJson()).toList();
    }
    
    if (computeFrom != null && computeFrom!.isNotEmpty) {
      result['computeFrom'] = computeFrom;
    }
    
    // Note: We don't serialize function references like customBuilder and computeValue
    // as these can't be converted to JSON and back
    
    return result;
  }

  /// Parses field type from string.
  static FormFieldType _parseFieldType(String type) {
    switch (type) {
      case 'text':
        return FormFieldType.text;
      case 'dropdown':
        return FormFieldType.dropdown;
      case 'datePicker':
        return FormFieldType.datePicker;
      case 'checkbox':
        return FormFieldType.checkbox;
      case 'custom':
        return FormFieldType.custom;
      default:
        return FormFieldType.text;
    }
  }

  /// Converts field type enum to string.
  static String _fieldTypeToString(FormFieldType type) {
    switch (type) {
      case FormFieldType.text:
        return 'text';
      case FormFieldType.dropdown:
        return 'dropdown';
      case FormFieldType.datePicker:
        return 'datePicker';
      case FormFieldType.checkbox:
        return 'checkbox';
      case FormFieldType.custom:
        return 'custom';
    }
  }
}