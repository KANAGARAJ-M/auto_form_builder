import 'package:flutter/material.dart';
import 'form_field_config.dart';

/// Layout options for form fields
enum FormLayout {
  /// Vertical layout (fields stacked)
  vertical,
  
  /// Grid layout (fields in columns)
  grid,
  
  /// Grouped layout (fields in titled sections)
  grouped,
  
  /// Custom layout (requires builder)
  custom,
}

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

  /// Sections for multi-step forms or wizards.
  /// If provided, this overrides the fields property.
  final List<FormConfig>? sections;
  
  /// Title for this form section (used in wizards).
  final String? sectionTitle;
  
  /// Description text for this form/section
  final String? description;
  
  /// Icon to display with the section title
  final IconData? icon;
  
  /// Layout type for this form
  final FormLayout layout;
  
  /// Number of columns when using grid layout
  final int gridColumns;
  
  /// Field groups for grouping related fields
  final Map<String, String>? fieldGroups;
  
  /// Whether this form/section is initially collapsed
  final bool initiallyCollapsed;
  
  /// Conditions that determine when this section is visible
  final List<VisibilityCondition>? visibleWhen;
  
  /// Custom widget to show before form fields
  final Widget Function(BuildContext)? headerBuilder;
  
  /// Custom widget to show after form fields
  final Widget Function(BuildContext)? footerBuilder;
  
  /// Custom class name for CSS styling (web)
  final String? className;
  
  /// Whether to show a reset button
  final bool showResetButton;
  
  /// Text for the reset button
  final String? resetButtonText;
  
  /// Whether to show a cancel button
  final bool showCancelButton;
  
  /// Text for the cancel button
  final String? cancelButtonText;

  FormConfig({
    required this.fields,
    this.submitButtonText,
    this.autoSave = false,
    this.formId,
    this.sections,
    this.sectionTitle,
    this.description,
    this.icon,
    this.layout = FormLayout.vertical,
    this.gridColumns = 2,
    this.fieldGroups,
    this.initiallyCollapsed = false,
    this.visibleWhen,
    this.headerBuilder,
    this.footerBuilder,
    this.className,
    this.showResetButton = false,
    this.resetButtonText,
    this.showCancelButton = false,
    this.cancelButtonText,
  });
  
  /// Creates a FormConfig from a JSON map.
  factory FormConfig.fromJson(Map<String, dynamic> json) {
    return FormConfig(
      fields: (json['fields'] as List? ?? [])
          .map((field) => FormFieldConfig.fromJson(field))
          .toList(),
      submitButtonText: json['submitButtonText'],
      autoSave: json['autoSave'] ?? false,
      formId: json['formId'],
      sectionTitle: json['sectionTitle'],
      description: json['description'],
      icon: json['icon'] != null ? IconData(json['icon'], fontFamily: 'MaterialIcons') : null,
      layout: _parseLayout(json['layout']),
      gridColumns: json['gridColumns'] ?? 2,
      fieldGroups: json['fieldGroups'] != null 
          ? Map<String, String>.from(json['fieldGroups']) 
          : null,
      initiallyCollapsed: json['initiallyCollapsed'] ?? false,
      visibleWhen: json['visibleWhen'] != null
          ? (json['visibleWhen'] as List).map((c) => VisibilityCondition.fromJson(c)).toList()
          : null,
      showResetButton: json['showResetButton'] ?? false,
      resetButtonText: json['resetButtonText'],
      showCancelButton: json['showCancelButton'] ?? false,
      cancelButtonText: json['cancelButtonText'],
      sections: json['sections'] != null
          ? (json['sections'] as List)
              .map((section) => FormConfig.fromJson(section))
              .toList()
          : null,
    );
  }
  
  /// Converts this form configuration to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {
      'fields': fields.map((field) => field.toJson()).toList(),
      'submitButtonText': submitButtonText,
      'autoSave': autoSave,
      'formId': formId,
      'sectionTitle': sectionTitle,
      'description': description,
      'layout': _layoutToString(layout),
      'gridColumns': gridColumns,
      'initiallyCollapsed': initiallyCollapsed,
      'showResetButton': showResetButton,
      'showCancelButton': showCancelButton,
    };
    
    if (icon != null) {
      result['icon'] = icon!.codePoint;
    }
    
    if (fieldGroups != null) {
      result['fieldGroups'] = fieldGroups;
    }
    
    if (visibleWhen != null) {
      result['visibleWhen'] = visibleWhen!.map((c) => c.toJson()).toList();
    }
    
    if (resetButtonText != null) {
      result['resetButtonText'] = resetButtonText;
    }
    
    if (cancelButtonText != null) {
      result['cancelButtonText'] = cancelButtonText;
    }
    
    if (className != null) {
      result['className'] = className;
    }
    
    if (sections != null) {
      result['sections'] = sections!.map((section) => section.toJson()).toList();
    }
    
    return result;
  }
  
  /// Creates a copy of this form config with modified properties.
  FormConfig copyWith({
    List<FormFieldConfig>? fields,
    String? submitButtonText,
    bool? autoSave,
    String? formId,
    List<FormConfig>? sections,
    String? sectionTitle,
    String? description,
    IconData? icon,
    FormLayout? layout,
    int? gridColumns,
    Map<String, String>? fieldGroups,
    bool? initiallyCollapsed,
    List<VisibilityCondition>? visibleWhen,
    Widget Function(BuildContext)? headerBuilder,
    Widget Function(BuildContext)? footerBuilder,
    String? className,
    bool? showResetButton,
    String? resetButtonText,
    bool? showCancelButton,
    String? cancelButtonText,
  }) {
    return FormConfig(
      fields: fields ?? this.fields,
      submitButtonText: submitButtonText ?? this.submitButtonText,
      autoSave: autoSave ?? this.autoSave,
      formId: formId ?? this.formId,
      sections: sections ?? this.sections,
      sectionTitle: sectionTitle ?? this.sectionTitle,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      layout: layout ?? this.layout,
      gridColumns: gridColumns ?? this.gridColumns,
      fieldGroups: fieldGroups ?? this.fieldGroups,
      initiallyCollapsed: initiallyCollapsed ?? this.initiallyCollapsed,
      visibleWhen: visibleWhen ?? this.visibleWhen,
      headerBuilder: headerBuilder ?? this.headerBuilder,
      footerBuilder: footerBuilder ?? this.footerBuilder,
      className: className ?? this.className,
      showResetButton: showResetButton ?? this.showResetButton,
      resetButtonText: resetButtonText ?? this.resetButtonText,
      showCancelButton: showCancelButton ?? this.showCancelButton,
      cancelButtonText: cancelButtonText ?? this.cancelButtonText,
    );
  }
  
  /// Gets all fields from this form, including those in sections.
  List<FormFieldConfig> getAllFields() {
    if (sections == null) {
      return fields;
    }
    
    final allFields = <FormFieldConfig>[];
    allFields.addAll(fields);
    
    for (final section in sections!) {
      allFields.addAll(section.getAllFields());
    }
    
    return allFields;
  }
  
  /// Gets a field by name from this form or any of its sections.
  FormFieldConfig? getField(String name) {
    // Check in direct fields
    for (final field in fields) {
      if (field.name == name) {
        return field;
      }
    }
    
    // Check in sections
    if (sections != null) {
      for (final section in sections!) {
        final field = section.getField(name);
        if (field != null) {
          return field;
        }
      }
    }
    
    return null;
  }
  
  /// Gets all fields in a specific group.
  List<FormFieldConfig> getFieldsInGroup(String groupName) {
    final result = <FormFieldConfig>[];
    
    if (fieldGroups == null) {
      return result;
    }
    
    for (final field in fields) {
      final fieldGroupName = fieldGroups![field.name];
      if (fieldGroupName == groupName) {
        result.add(field);
      }
    }
    
    return result;
  }
  
  /// Gets the names of all groups in this form.
  List<String> getGroupNames() {
    if (fieldGroups == null) {
      return [];
    }
    
    return fieldGroups!.values.toSet().toList();
  }
  
  /// Validates this form configuration.
  List<String> validate() {
    final errors = <String>[];
    
    // Check for duplicate field names
    final fieldNames = <String>{};
    for (final field in getAllFields()) {
      if (fieldNames.contains(field.name)) {
        errors.add('Duplicate field name: ${field.name}');
      }
      fieldNames.add(field.name);
    }
    
    // Check for required properties
    if (fields.isEmpty && sections == null) {
      errors.add('Form must have fields or sections');
    }
    
    // Check for fields with invalid configurations
    for (final field in getAllFields()) {
      if (field.type == FormFieldType.dropdown && (field.options == null || field.options!.isEmpty)) {
        errors.add('Dropdown field ${field.name} must have options');
      }
    }
    
    // Check for circular dependencies in computed fields
    _validateComputedFields(errors);
    
    return errors;
  }
  
  /// Validates computed fields for circular dependencies.
  void _validateComputedFields(List<String> errors) {
    final dependencies = <String, Set<String>>{};
    
    // Build dependency map
    for (final field in getAllFields()) {
      if (field.computeFrom != null && field.computeFrom!.isNotEmpty) {
        dependencies[field.name] = field.computeFrom!.toSet();
      }
    }
    
    // Check for circular dependencies
    for (final field in dependencies.keys) {
      final visited = <String>{};
      final stack = <String>[];
      
      if (_hasCycleDFS(field, dependencies, visited, stack)) {
        errors.add('Circular dependency detected: ${stack.join(' -> ')}');
      }
    }
  }
  
  /// Depth-first search to detect cycles in computed field dependencies.
  bool _hasCycleDFS(
    String current,
    Map<String, Set<String>> dependencies,
    Set<String> visited,
    List<String> stack,
  ) {
    if (stack.contains(current)) {
      stack.add(current);
      return true;
    }
    
    if (visited.contains(current)) {
      return false;
    }
    
    visited.add(current);
    stack.add(current);
    
    final deps = dependencies[current];
    if (deps != null) {
      for (final dep in deps) {
        if (dependencies.containsKey(dep)) {
          if (_hasCycleDFS(dep, dependencies, visited, stack)) {
            return true;
          }
        }
      }
    }
    
    stack.removeLast();
    return false;
  }
  
  /// Parses layout type from string.
  static FormLayout _parseLayout(String? layout) {
    switch (layout) {
      case 'grid':
        return FormLayout.grid;
      case 'grouped':
        return FormLayout.grouped;
      case 'custom':
        return FormLayout.custom;
      case 'vertical':
      default:
        return FormLayout.vertical;
    }
  }
  
  /// Converts layout enum to string.
  static String _layoutToString(FormLayout layout) {
    switch (layout) {
      case FormLayout.grid:
        return 'grid';
      case FormLayout.grouped:
        return 'grouped';
      case FormLayout.custom:
        return 'custom';
      case FormLayout.vertical:
        return 'vertical';
    }
  }
}