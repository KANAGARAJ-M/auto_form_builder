import 'form_field_config.dart';

/// Configuration for the entire form.
class FormConfig {
  /// List of field configurations.
  final List<FormFieldConfig> fields;
  
  /// Text for the submit button.
  final String? submitButtonText;
  
  /// Whether to save form progress automatically.
  final bool autoSave;
  
  /// The ID for the form (used for saving/loading drafts).
  final String? formId;

  FormConfig({
    required this.fields,
    this.submitButtonText,
    this.autoSave = false,
    this.formId,
  });
  
  /// Creates a FormConfig from a JSON map.
  factory FormConfig.fromJson(Map<String, dynamic> json) {
    return FormConfig(
      fields: (json['fields'] as List)
          .map((field) => FormFieldConfig.fromJson(field))
          .toList(),
      submitButtonText: json['submitButtonText'],
      autoSave: json['autoSave'] ?? false,
      formId: json['formId'],
    );
  }
}