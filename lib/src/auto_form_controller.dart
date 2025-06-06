import 'package:flutter/material.dart';
import 'models/form_config.dart';
import 'models/form_field_config.dart';
import 'widgets/auto_text_field.dart';
import 'widgets/auto_dropdown.dart';
import 'widgets/auto_date_picker.dart';
import 'widgets/auto_checkbox.dart';
import 'storage/form_storage.dart';
import 'themes/form_theme.dart';

/// Controller for the auto form builder.
class AutoFormController {
  late FormConfig _config;
  final Map<String, dynamic> _formData = {};
  final FormStorage _storage = FormStorage();
  
  /// Sets the form configuration.
  void setConfig(FormConfig config) {
    _config = config;
    _initializeFormData();
  }
  
  /// Initializes form data with default values.
  void _initializeFormData() {
    for (var field in _config.fields) {
      _formData[field.name] = field.defaultValue;
    }
  }
  
  /// Builds a form field widget based on its configuration.
  Widget buildField(
    BuildContext context,
    FormFieldConfig fieldConfig,
    {bool readOnly = false, bool validateOnChange = false, FormTheme? theme}
  ) {
    final formTheme = theme ?? FormTheme();
    
    switch (fieldConfig.type) {
      case FormFieldType.text:
        return AutoTextField(
          config: fieldConfig,
          controller: this,
          readOnly: readOnly,
          validateOnChange: validateOnChange,
          theme: formTheme,
        );
      case FormFieldType.dropdown:
        return AutoDropdown(
          config: fieldConfig,
          controller: this,
          readOnly: readOnly,
          theme: formTheme,
        );
      case FormFieldType.datePicker:
        return AutoDatePicker(
          config: fieldConfig,
          controller: this,
          readOnly: readOnly,
          theme: formTheme,
        );
      case FormFieldType.checkbox:
        return AutoCheckbox(
          config: fieldConfig,
          controller: this,
          readOnly: readOnly,
          theme: formTheme,
        );
      case FormFieldType.custom:
        if (fieldConfig.customBuilder != null) {
          return fieldConfig.customBuilder!(
            context, 
            fieldConfig, 
            getFieldValue(fieldConfig.name),
            (value) => updateField(fieldConfig.name, value),
          );
        }
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }
  
  /// Updates a field value in the form data.
  void updateField(String fieldName, dynamic value) {
    _formData[fieldName] = value;
  }
  
  /// Gets the current value of a field.
  dynamic getFieldValue(String fieldName) {
    return _formData[fieldName];
  }
  
  /// Gets all form data.
  Map<String, dynamic> getFormData() {
    return Map.from(_formData);
  }
  
  /// Saves the current form state to local storage.
  Future<bool> saveFormDraft(String formId) async {
    return await _storage.saveForm(formId, _formData);
  }
  
  /// Loads a form draft from local storage.
  Future<bool> loadFormDraft(String formId) async {
    final data = await _storage.loadForm(formId);
    if (data != null) {
      _formData.clear();
      _formData.addAll(data);
      return true;
    }
    return false;
  }
}