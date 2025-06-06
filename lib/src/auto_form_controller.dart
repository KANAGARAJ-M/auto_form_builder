import 'package:flutter/material.dart';
import 'dart:async';
import 'models/form_config.dart';
import 'models/form_field_config.dart';
import 'widgets/auto_text_field.dart';
import 'widgets/auto_dropdown.dart';
import 'widgets/auto_date_picker.dart';
import 'widgets/auto_checkbox.dart';
import 'storage/form_storage.dart';
import 'themes/form_theme.dart';

/// Form state enumeration
enum AutoFormState {
  /// Initial state
  pristine,
  
  /// Changed from initial values
  dirty,
  
  /// Being submitted
  submitting,
  
  /// Successfully submitted
  submitted,
  
  /// Submission failed
  failed
}

/// Controller for the auto form builder.
class AutoFormController {
  late FormConfig _config;
  final Map<String, dynamic> _formData = {};
  final Map<String, dynamic> _initialFormData = {};
  final FormStorage _storage = FormStorage();
  
  // Controllers for managing form state
  final List<GlobalKey<FormState>> _formKeys = [];
  final Map<String, StreamController<dynamic>> _fieldControllers = {};
  
  // Form state management
  AutoFormState _formState = AutoFormState.pristine;
  String? _formError;
  
  // Listeners for form events
  final List<Function(String, dynamic)> _fieldChangeListeners = [];
  final List<Function(Map<String, dynamic>)> _formChangeListeners = [];
  final List<Function(AutoFormState)> _formStateListeners = [];
  
  /// Gets the current form state
  AutoFormState get formState => _formState;
  
  /// Gets the current form error if any
  String? get formError => _formError;
  
  /// Whether the form has been changed from its initial state
  bool get isDirty => _formState == AutoFormState.dirty;
  
  /// Whether the form is currently being submitted
  bool get isSubmitting => _formState == AutoFormState.submitting;
  
  /// Sets the form configuration.
  void setConfig(FormConfig config) {
    _config = config;
    _formKeys.clear();
    // Create form keys for each section if using wizard
    if (config.sections != null) {
      for (int i = 0; i < config.sections!.length; i++) {
        _formKeys.add(GlobalKey<FormState>());
      }
    } else {
      _formKeys.add(GlobalKey<FormState>());
    }
    _initializeFormData();
  }
  
  /// Initializes form data with default values.
  void _initializeFormData() {
    for (var field in _config.fields) {
      _formData[field.name] = field.defaultValue;
      _initialFormData[field.name] = field.defaultValue;
      
      // Create stream controller for this field
      _fieldControllers[field.name] = StreamController<dynamic>.broadcast();
    }
  }
  
  /// Builds a form field widget based on its configuration.
  Widget buildField(
    BuildContext context,
    FormFieldConfig fieldConfig,
    {bool readOnly = false, bool validateOnChange = false, FormTheme? theme}
  ) {
    // Check if field should be hidden based on conditions
    if (!_evaluateFieldVisibility(fieldConfig)) {
      return const SizedBox.shrink();
    }
    
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
    }
  }
  
  /// Evaluates whether a field should be visible based on its conditions
  bool _evaluateFieldVisibility(FormFieldConfig fieldConfig) {
    if (fieldConfig.visibleWhen == null) return true;
    
    // Evaluate each condition
    for (final condition in fieldConfig.visibleWhen!) {
      final dependentValue = getFieldValue(condition.fieldName);
      
      switch (condition.operator) {
        case 'equals':
          if (dependentValue != condition.value) return false;
          break;
        case 'notEquals':
          if (dependentValue == condition.value) return false;
          break;
        case 'contains':
          if (dependentValue is String && !dependentValue.contains(condition.value.toString())) {
            return false;
          }
          break;
        case 'greaterThan':
          if (dependentValue is num && dependentValue <= condition.value) {
            return false;
          }
          break;
        case 'lessThan':
          if (dependentValue is num && dependentValue >= condition.value) {
            return false;
          }
          break;
        case 'isNotEmpty':
          if (dependentValue == null || dependentValue == '' || 
              (dependentValue is List && dependentValue.isEmpty)) {
            return false;
          }
          break;
        case 'isEmpty':
          if (dependentValue != null && dependentValue != '' && 
              !(dependentValue is List && dependentValue.isEmpty)) {
            return false;
          }
          break;
      }
    }
    
    return true;
  }
  
  /// Checks if a field should be visible based on its visibility conditions.
  bool isFieldVisible(String fieldName) {
    // Find the field configuration
    final fieldConfig = _config.getField(fieldName);
    if (fieldConfig == null) {
      return false; // Field doesn't exist
    }
    
    // If no visibility conditions, field is always visible
    if (fieldConfig.visibleWhen == null || fieldConfig.visibleWhen!.isEmpty) {
      return true;
    }
    
    // Evaluate visibility conditions
    return _evaluateFieldVisibility(fieldConfig);
  }
  
  /// Updates a field value in the form data.
  void updateField(String fieldName, dynamic value) {
    final oldValue = _formData[fieldName];
    if (oldValue != value) {
      _formData[fieldName] = value;
      
      // Update form state
      if (_formState == AutoFormState.pristine || _formState == AutoFormState.submitted) {
        _setFormState(AutoFormState.dirty);
      }
      
      // Notify field listeners
      _notifyFieldChange(fieldName, value);
      
      // Check for computed fields that depend on this field
      _updateComputedFields(fieldName);
      
      // Notify form change listeners
      _notifyFormChange();
      
      // Broadcast to field stream
      if (_fieldControllers.containsKey(fieldName)) {
        _fieldControllers[fieldName]!.add(value);
      }
    }
  }
  
  /// Update fields that compute their values from other fields
  void _updateComputedFields(String changedField) {
    for (var field in _config.fields) {
      if (field.computeFrom != null && field.computeFrom!.contains(changedField)) {
        if (field.computeValue != null) {
          final computedValue = field.computeValue!(getFormData());
          updateField(field.name, computedValue);
        }
      }
    }
  }
  
  /// Gets the current value of a field.
  dynamic getFieldValue(String fieldName) {
    return _formData[fieldName];
  }
  
  /// Gets all form data.
  Map<String, dynamic> getFormData() {
    return Map.from(_formData);
  }
  
  /// Gets a stream of values for a specific field
  Stream<dynamic>? getFieldStream(String fieldName) {
    return _fieldControllers[fieldName]?.stream;
  }
  
  /// Validates the entire form
  bool validateForm() {
    bool isValid = true;
    
    for (var formKey in _formKeys) {
      if (!(formKey.currentState?.validate() ?? true)) {
        isValid = false;
      }
    }
    
    return isValid;
  }
  
  /// Validates a specific form section by index
  bool validateSection(int sectionIndex) {
    if (sectionIndex < 0 || sectionIndex >= _formKeys.length) {
      return false;
    }
    
    return _formKeys[sectionIndex].currentState?.validate() ?? false;
  }
  
  /// Transforms form data before submission
  Map<String, dynamic> transformFormData(Map<String, dynamic> Function(Map<String, dynamic>) transformer) {
    return transformer(getFormData());
  }
  
  /// Resets the form to initial values
  void resetForm() {
    _formData.clear();
    _formData.addAll(Map.from(_initialFormData));
    _setFormState(AutoFormState.pristine);
    _notifyFormChange();
  }
  
  /// Clears all form data
  void clearForm() {
    _formData.clear();
    for (var field in _config.fields) {
      _formData[field.name] = null;
    }
    _setFormState(AutoFormState.dirty);
    _notifyFormChange();
  }
  
  /// Adds a listener for field changes
  void addFieldChangeListener(Function(String, dynamic) listener) {
    _fieldChangeListeners.add(listener);
  }
  
  /// Removes a field change listener
  void removeFieldChangeListener(Function(String, dynamic) listener) {
    _fieldChangeListeners.remove(listener);
  }
  
  /// Adds a listener for form changes
  void addFormChangeListener(Function(Map<String, dynamic>) listener) {
    _formChangeListeners.add(listener);
  }
  
  /// Removes a form change listener
  void removeFormChangeListener(Function(Map<String, dynamic>) listener) {
    _formChangeListeners.remove(listener);
  }
  
  /// Adds a listener for form state changes
  void addFormStateListener(Function(AutoFormState) listener) {
    _formStateListeners.add(listener);
  }
  
  /// Removes a form state listener
  void removeFormStateListener(Function(AutoFormState) listener) {
    _formStateListeners.remove(listener);
  }
  
  /// Notifies all field change listeners
  void _notifyFieldChange(String fieldName, dynamic value) {
    for (var listener in _fieldChangeListeners) {
      listener(fieldName, value);
    }
  }
  
  /// Notifies all form change listeners
  void _notifyFormChange() {
    for (var listener in _formChangeListeners) {
      listener(getFormData());
    }
  }
  
  /// Updates the form state and notifies listeners
  void _setFormState(AutoFormState state) {
    _formState = state;
    for (var listener in _formStateListeners) {
      listener(state);
    }
  }
  
  /// Submits the form with handling for async operations
  Future<Map<String, dynamic>> submitForm({
    bool validateBeforeSubmit = true,
    Future<Map<String, dynamic>> Function(Map<String, dynamic>)? onSubmit,
  }) async {
    if (validateBeforeSubmit && !validateForm()) {
      _formError = 'Please fix the errors in the form';
      _setFormState(AutoFormState.failed);
      return {};
    }
    
    _formError = null;
    _setFormState(AutoFormState.submitting);
    
    try {
      final data = getFormData();
      if (onSubmit != null) {
        final result = await onSubmit(data);
        _setFormState(AutoFormState.submitted);
        return result;
      }
      _setFormState(AutoFormState.submitted);
      return data;
    } catch (e) {
      _formError = e.toString();
      _setFormState(AutoFormState.failed);
      rethrow;
    }
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
      _notifyFormChange();
      return true;
    }
    return false;
  }
  
  /// Checks if there's a draft for this form
  Future<bool> hasDraft(String formId) async {
    return await _storage.hasForm(formId);
  }
  
  /// Deletes a form draft
  Future<bool> deleteDraft(String formId) async {
    return await _storage.deleteForm(formId);
  }
  
  /// Gets a list of all field names
  List<String> getFieldNames() {
    return _formData.keys.toList();
  }
  
  /// Batch updates multiple fields at once
  void batchUpdate(Map<String, dynamic> updates) {
    for (final entry in updates.entries) {
      _formData[entry.key] = entry.value;
    }
    _setFormState(AutoFormState.dirty);
    _notifyFormChange();
    
    // Update computed fields after batch update
    for (final fieldName in updates.keys) {
      _updateComputedFields(fieldName);
    }
  }
  
  /// Dispose the controller and clean up resources
  void dispose() {
    // Close all field stream controllers
    for (var controller in _fieldControllers.values) {
      controller.close();
    }
    _fieldControllers.clear();
    
    // Clear listeners
    _fieldChangeListeners.clear();
    _formChangeListeners.clear();
    _formStateListeners.clear();
  }
}