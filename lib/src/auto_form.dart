import 'package:flutter/material.dart';
import 'models/form_config.dart';
import 'models/form_field_config.dart';
import 'auto_form_controller.dart';
import 'themes/form_theme.dart';

/// Layout type for form fields
enum FormLayout {
  /// Fields arranged vertically (default)
  vertical,
  
  /// Fields arranged in a grid
  grid,
  
  /// Fields arranged in groups
  grouped,
  
  /// Custom layout using the provided builder
  custom,
}

/// A widget that automatically builds a form based on a configuration.
class AutoForm extends StatefulWidget {
  /// The configuration for the form.
  final FormConfig config;
  
  /// The controller for the form.
  final AutoFormController? controller;
  
  /// Callback when the form is submitted.
  final Future<void> Function(Map<String, dynamic> data)? onSubmit;
  
  /// Whether the form should validate on field changes.
  final bool validateOnChange;
  
  /// Whether the form is read-only.
  final bool readOnly;
  
  /// Theme for the form.
  final FormTheme? theme;
  
  /// Whether to make the form scrollable.
  final bool scrollable;
  
  /// Padding around the form.
  final EdgeInsetsGeometry padding;
  
  /// Layout type for form fields.
  final FormLayout layout;
  
  /// Number of columns for grid layout.
  final int gridColumns;
  
  /// Custom builder for form fields when using custom layout.
  final Widget Function(BuildContext, List<Widget>)? fieldBuilder;
  
  /// Whether to show a loading indicator during submission.
  final bool showLoadingDuringSubmission;
  
  /// Whether to automatically save form drafts.
  final bool autosaveDrafts;
  
  /// Custom text for the submit button.
  final String? submitButtonText;
  
  /// Whether to show a reset button.
  final bool showResetButton;
  
  /// Text for the reset button.
  final String resetButtonText;
  
  /// Callback when form state changes.
  final void Function(AutoFormState)? onStateChanged;
  
  /// Whether to use a card container for the form.
  final bool useCardContainer;
  
  /// Whether to show field labels in bold.
  final bool boldLabels;
  
  /// Whether to show validation errors inline or in a tooltip.
  final bool inlineValidationErrors;

  const AutoForm({
    super.key,
    required this.config,
    this.controller,
    this.onSubmit,
    this.validateOnChange = false,
    this.readOnly = false,
    this.theme,
    this.scrollable = true,
    this.padding = const EdgeInsets.all(16.0),
    this.layout = FormLayout.vertical,
    this.gridColumns = 2,
    this.fieldBuilder,
    this.showLoadingDuringSubmission = true,
    this.autosaveDrafts = false,
    this.submitButtonText,
    this.showResetButton = false,
    this.resetButtonText = 'Reset',
    this.onStateChanged,
    this.useCardContainer = false,
    this.boldLabels = false,
    this.inlineValidationErrors = true,
  });

  @override
  State<AutoForm> createState() => _AutoFormState();
}

class _AutoFormState extends State<AutoForm> {
  late AutoFormController _controller;
  final _formKey = GlobalKey<FormState>();
  late FormTheme _theme;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AutoFormController();
    _controller.setConfig(widget.config);
    _theme = widget.theme ?? FormTheme();
    
    // Listen for form state changes
    if (widget.onStateChanged != null) {
      _controller.addFormStateListener(_handleFormStateChange);
    }
    
    // Set up autosave if enabled
    if (widget.autosaveDrafts && widget.config.formId != null) {
      _controller.addFormChangeListener((_) => _autosave());
    }
    
    // Try to load draft if available
    if (widget.autosaveDrafts && widget.config.formId != null) {
      _loadDraft();
    }
  }
  
  @override
  void dispose() {
    // Clean up listeners if we created the controller
    if (widget.controller == null) {
      _controller.dispose();
    } else if (widget.onStateChanged != null) {
      _controller.removeFormStateListener(_handleFormStateChange);
    }
    super.dispose();
  }
  
  void _handleFormStateChange(AutoFormState state) {
    widget.onStateChanged?.call(state);
    if (state == AutoFormState.submitting) {
      setState(() {
        _isSubmitting = true;
      });
    } else if (_isSubmitting) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
  
  Future<void> _autosave() async {
    if (widget.config.formId != null) {
      await _controller.saveFormDraft(widget.config.formId!);
    }
  }
  
  Future<void> _loadDraft() async {
    if (widget.config.formId != null) {
      final hasDraft = await _controller.hasDraft(widget.config.formId!);
      if (hasDraft) {
        await _controller.loadFormDraft(widget.config.formId!);
        if (mounted) {
          setState(() {});
        }
      }
    }
  }
  
  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (widget.showLoadingDuringSubmission) {
        setState(() {
          _isSubmitting = true;
        });
      }
      
      try {
        await widget.onSubmit?.call(_controller.getFormData());
        
        // Clear draft after successful submission
        if (widget.autosaveDrafts && widget.config.formId != null) {
          await _controller.deleteDraft(widget.config.formId!);
        }
      } finally {
        if (mounted && widget.showLoadingDuringSubmission) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
  
  void _handleReset() {
    _controller.resetForm();
    _formKey.currentState?.reset();
    setState(() {});
  }
  
  List<Widget> _buildFormFields() {
    return widget.config.fields.map((fieldConfig) {
      final fieldWidget = _controller.buildField(
        context,
        fieldConfig,
        readOnly: widget.readOnly || _isSubmitting,
        validateOnChange: widget.validateOnChange,
        theme: widget.boldLabels ? _theme.copyWith(
          labelStyle: _theme.labelStyle.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ) : _theme,
      );
      
      // Apply spacing between fields
      return Padding(
        padding: EdgeInsets.only(bottom: _theme.fieldSpacing),
        child: fieldWidget,
      );
    }).toList();
  }
  
  Widget _buildFormContent() {
    final formFields = _buildFormFields();
    
    // Apply different layouts
    Widget fieldsWidget;
    switch (widget.layout) {
      case FormLayout.grid:
        fieldsWidget = GridView.builder(
          shrinkWrap: true,
          physics: widget.scrollable ? null : const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.gridColumns,
            crossAxisSpacing: _theme.fieldSpacing,
            mainAxisSpacing: _theme.fieldSpacing,
            childAspectRatio: 3,
          ),
          itemCount: formFields.length,
          itemBuilder: (context, index) => formFields[index],
        );
        break;
      
      case FormLayout.grouped:
        fieldsWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildGroupedFields(),
        );
        break;
      
      case FormLayout.custom:
        if (widget.fieldBuilder != null) {
          fieldsWidget = widget.fieldBuilder!(context, formFields);
        } else {
          fieldsWidget = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: formFields,
          );
        }
        break;
      
      case FormLayout.vertical:
        fieldsWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: formFields,
        );
        break;
    }
    
    // Add buttons
    final buttonsRow = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.showResetButton)
          TextButton(
            onPressed: widget.readOnly || _isSubmitting ? null : _handleReset,
            child: Text(widget.resetButtonText),
          ),
        const SizedBox(width: 16),
        if (widget.onSubmit != null)
          ElevatedButton(
            onPressed: widget.readOnly || _isSubmitting ? null : _handleSubmit,
            style: _theme.submitButtonStyle,
            child: _isSubmitting 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(widget.submitButtonText ?? widget.config.submitButtonText ?? 'Submit'),
          ),
      ],
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: fieldsWidget),
        buttonsRow,
      ],
    );
  }
  
  List<Widget> _buildGroupedFields() {
    // Group fields by their group property if available
    final groups = <String, List<Widget>>{};
    final ungroupedFields = <Widget>[];
    
    for (final fieldConfig in widget.config.fields) {
      final fieldWidget = _controller.buildField(
        context,
        fieldConfig,
        readOnly: widget.readOnly || _isSubmitting,
        validateOnChange: widget.validateOnChange,
        theme: _theme,
      );
      
      final paddedWidget = Padding(
        padding: EdgeInsets.only(bottom: _theme.fieldSpacing),
        child: fieldWidget,
      );
      
      // Add to appropriate group or ungrouped list
      final group = fieldConfig.group;
      if (group != null && group.isNotEmpty) {
        if (!groups.containsKey(group)) {
          groups[group] = [];
        }
        groups[group]!.add(paddedWidget);
      } else {
        ungroupedFields.add(paddedWidget);
      }
    }
    
    // Build the grouped UI
    final result = <Widget>[];
    
    // Add groups
    groups.forEach((groupName, fields) {
      result.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  groupName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _theme.primaryColor,
                  ),
                ),
              ),
              // Optional divider
              Divider(color: _theme.primaryColor.withOpacity(0.2)),
              // Group fields
              ...fields,
            ],
          ),
        ),
      );
    });
    
    // Add ungrouped fields
    result.addAll(ungroupedFields);
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    Widget formWidget = Form(
      key: _formKey,
      child: Padding(
        padding: widget.padding,
        child: widget.scrollable
            ? _buildFormContent()
            : SingleChildScrollView(child: _buildFormContent()),
      ),
    );
    
    // Apply card container if requested
    if (widget.useCardContainer) {
      formWidget = Card(
        elevation: 4,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: formWidget,
      );
    }
    
    return formWidget;
  }
}

// Extension to support the 'group' property in FormFieldConfig
extension FormFieldConfigGrouping on FormFieldConfig {
  String? get group => null; // Will need to be implemented in FormFieldConfig
}