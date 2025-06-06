import 'package:flutter/material.dart';
import '../models/form_config.dart';
import '../auto_form_controller.dart';
import '../auto_form.dart';
import '../themes/form_theme.dart';

/// A multi-step form wizard component.
class AutoFormWizard extends StatefulWidget {
  /// List of form configurations for each step.
  final List<FormConfig> steps;
  
  /// The form controller.
  final AutoFormController? controller;
  
  /// Callback when the wizard is completed.
  final void Function(Map<String, dynamic> data)? onComplete;
  
  /// Whether to show step indicators.
  final bool showStepIndicator;
  
  /// Custom titles for each step.
  final List<String>? stepTitles;
  
  /// Whether the form is read-only.
  final bool readOnly;
  
  /// Theme for the form.
  final FormTheme? theme;

  const AutoFormWizard({
    super.key,
    required this.steps,
    this.controller,
    this.onComplete,
    this.showStepIndicator = true,
    this.stepTitles,
    this.readOnly = false,
    this.theme,
  });

  @override
  State<AutoFormWizard> createState() => _AutoFormWizardState();
}

class _AutoFormWizardState extends State<AutoFormWizard> {
  late int _currentStep;
  late AutoFormController _controller;
  final List<GlobalKey<FormState>> _formKeys = [];
  late FormTheme _theme;
  
  @override
  void initState() {
    super.initState();
    _currentStep = 0;
    _controller = widget.controller ?? AutoFormController();
    _theme = widget.theme ?? FormTheme();
    
    // Create form keys for each step
    for (int i = 0; i < widget.steps.length; i++) {
      _formKeys.add(GlobalKey<FormState>());
    }
  }
  
  void _nextStep() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      if (_currentStep < widget.steps.length - 1) {
        setState(() {
          _currentStep++;
        });
      } else {
        // This is the final step
        widget.onComplete?.call(_controller.getFormData());
      }
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stepTheme = _theme.stepIndicatorTheme;
    
    return Column(
      children: [
        // Step indicator
        if (widget.showStepIndicator)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.steps.length, (index) {
                final isActive = index == _currentStep;
                final isCompleted = index < _currentStep;
                
                return Row(
                  children: [
                    if (index > 0)
                      Container(
                        width: stepTheme.connectorWidth,
                        height: stepTheme.connectorHeight,
                        color: isCompleted ? stepTheme.activeColor : stepTheme.connectorColor,
                      ),
                    Container(
                      width: stepTheme.stepSize,
                      height: stepTheme.stepSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive 
                            ? stepTheme.activeColor 
                            : (isCompleted ? stepTheme.completedColor : stepTheme.inactiveColor),
                      ),
                      child: Center(
                        child: isCompleted 
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        
        // Step title
        if (widget.stepTitles != null && widget.stepTitles!.length > _currentStep)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              widget.stepTitles![_currentStep],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        
        // Current form step
        AutoForm(
          key: _formKeys[_currentStep],
          config: widget.steps[_currentStep],
          controller: _controller,
          readOnly: widget.readOnly,
        ),
        
        // Navigation buttons
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                ElevatedButton(
                  onPressed: _previousStep,
                  style: _theme.secondaryButtonStyle,
                  child: const Text('Previous'),
                )
              else
                const SizedBox(),
                
              ElevatedButton(
                onPressed: widget.readOnly ? null : _nextStep,
                style: _theme.submitButtonStyle,
                child: Text(_currentStep < widget.steps.length - 1 ? 'Next' : 'Submit'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}