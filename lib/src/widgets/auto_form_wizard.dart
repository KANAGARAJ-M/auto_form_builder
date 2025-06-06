import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/form_config.dart';
import '../auto_form_controller.dart';
import '../auto_form.dart';
import '../themes/form_theme.dart';
import '../storage/form_storage.dart';
import 'dart:async';
import '../models/form_field_config.dart'; // Add import for FormFieldConfig

/// Step validation strategy
enum StepValidationMode {
  /// Validate on next button press
  onNext,
  
  /// Validate on field change
  onChange,
  
  /// Validate after a delay when user stops typing
  debounce,
  
  /// Validate on step exit
  onExit,
  
  /// Never automatically validate (manual validation only)
  manual
}

/// A multi-step form wizard component with advanced features.
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
  
  /// Whether to animate transitions between steps
  final bool animateTransitions;
  
  /// Duration for step transitions
  final Duration transitionDuration;
  
  /// Curve for step transitions
  final Curve transitionCurve;
  
  /// Type of transition animation
  final PageTransitionsBuilder? transitionBuilder;
  
  /// Whether to allow skipping validation on previous step
  final bool skipValidationOnBack;
  
  /// Whether to automatically save form progress
  final bool autosaveProgress;
  
  /// Form ID for auto-saving progress
  final String? formId;
  
  /// Whether to show a summary step at the end
  final bool showSummaryStep;
  
  /// Custom builder for the summary step
  final Widget Function(BuildContext, Map<String, dynamic>)? summaryBuilder;
  
  /// Whether to enable keyboard navigation (arrow keys)
  final bool enableKeyboardNavigation;
  
  /// Step validation mode
  final StepValidationMode validationMode;
  
  /// Validation debounce delay when using StepValidationMode.debounce
  final Duration validationDebounce;
  
  /// Custom step condition function - return false to prevent navigation to next step
  final bool Function(int currentStep, Map<String, dynamic> formData)? canContinue;
  
  /// Callback for when a step changes
  final void Function(int previousStep, int currentStep)? onStepChanged;
  
  /// Style of submit button text
  final TextStyle? submitButtonTextStyle;
  
  /// Style of previous button text
  final TextStyle? previousButtonTextStyle;
  
  /// Custom submit button text
  final String submitButtonText;
  
  /// Custom previous button text
  final String previousButtonText;
  
  /// Whether to show a cancel button
  final bool showCancelButton;
  
  /// Custom cancel button text
  final String cancelButtonText;
  
  /// Callback when cancel is pressed
  final VoidCallback? onCancel;
  
  /// Whether to confirm before canceling
  final bool confirmCancel;
  
  /// Initial step to show (default: 0)
  final int initialStep;

  const AutoFormWizard({
    super.key,
    required this.steps,
    this.controller,
    this.onComplete,
    this.showStepIndicator = true,
    this.stepTitles,
    this.readOnly = false,
    this.theme,
    this.animateTransitions = true,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionCurve = Curves.easeInOut,
    this.transitionBuilder,
    this.skipValidationOnBack = true,
    this.autosaveProgress = false,
    this.formId,
    this.showSummaryStep = false,
    this.summaryBuilder,
    this.enableKeyboardNavigation = true,
    this.validationMode = StepValidationMode.onNext,
    this.validationDebounce = const Duration(milliseconds: 500),
    this.canContinue,
    this.onStepChanged,
    this.submitButtonTextStyle,
    this.previousButtonTextStyle,
    this.submitButtonText = 'Submit',
    this.previousButtonText = 'Previous',
    this.showCancelButton = false,
    this.cancelButtonText = 'Cancel',
    this.onCancel,
    this.confirmCancel = true,
    this.initialStep = 0,
  }) : assert(
         !autosaveProgress || (autosaveProgress && formId != null),
         'formId must be provided when autosaveProgress is true'
       );

  @override
  State<AutoFormWizard> createState() => _AutoFormWizardState();
}

class _AutoFormWizardState extends State<AutoFormWizard> with SingleTickerProviderStateMixin {
  late int _currentStep;
  late AutoFormController _controller;
  final List<GlobalKey<FormState>> _formKeys = [];
  late FormTheme _theme;
  final FormStorage _storage = FormStorage();
  Timer? _debounceTimer;
  late PageController _pageController;
  late FocusNode _keyboardFocusNode;
  bool _isCompleting = false;
  bool _isAnimating = false;
  
  // Tracks if each step has been visited
  late List<bool> _stepVisited;
  
  // Animation controller for page transitions
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    _controller = widget.controller ?? AutoFormController();
    _theme = widget.theme ?? FormTheme();
    _stepVisited = List.filled(widget.steps.length, false);
    _stepVisited[_currentStep] = true;
    
    // Initialize animation controller
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: widget.transitionDuration,
    );
    // Initialize page controller
    _pageController = PageController(initialPage: _currentStep);
    
    // Initialize keyboard focus node
    _keyboardFocusNode = FocusNode();
    
    // Create form keys for each step
    for (int i = 0; i < widget.steps.length; i++) {
      _formKeys.add(GlobalKey<FormState>());
    }
    
    // Load saved data if autosave is enabled
    if (widget.autosaveProgress && widget.formId != null) {
      _loadSavedProgress();
    }
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    _pageController.dispose();
    _keyboardFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadSavedProgress() async {
    if (widget.formId != null) {
      final success = await _controller.loadFormDraft(widget.formId!);
      if (success) {
        if (mounted) {
          setState(() {});
        }
      }
    }
  }
  
  Future<void> _saveProgress() async {
    if (widget.autosaveProgress && widget.formId != null) {
      await _controller.saveFormDraft(widget.formId!);
    }
  }
  
  bool _validateCurrentStep() {
    return _formKeys[_currentStep].currentState?.validate() ?? false;
  }
  
  bool _canMoveToNextStep() {
    // Check if current step is valid
    if (!_validateCurrentStep()) {
      return false;
    }
    
    // Check custom condition if provided
    if (widget.canContinue != null) {
      return widget.canContinue!(_currentStep, _controller.getFormData());
    }
    
    return true;
  }
  
  Future<void> _nextStep() async {
    if (!_canMoveToNextStep()) {
      return;
    }
    
    if (_currentStep < widget.steps.length - 1) {
      await _saveProgress();
      
      final previousStep = _currentStep;
      setState(() {
        _currentStep++;
        _stepVisited[_currentStep] = true;
        _isAnimating = true;
      });
      
      if (widget.animateTransitions) {
        _pageController.animateToPage(
          _currentStep,
          duration: widget.transitionDuration,
          curve: widget.transitionCurve,
        ).then((_) {
          setState(() {
            _isAnimating = false;
          });
        });
      }
      
      widget.onStepChanged?.call(previousStep, _currentStep);
    } else {
      // This is the final step
      if (widget.showSummaryStep) {
        _showSummary();
      } else {
        _completeForm();
      }
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      final previousStep = _currentStep;
      setState(() {
        _currentStep--;
        _isAnimating = true;
      });
      
      if (widget.animateTransitions) {
        _pageController.animateToPage(
          _currentStep,
          duration: widget.transitionDuration,
          curve: widget.transitionCurve,
        ).then((_) {
          setState(() {
            _isAnimating = false;
          });
        });
      }
      
      widget.onStepChanged?.call(previousStep, _currentStep);
    }
  }
  
  void _showSummary() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Summary'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: widget.summaryBuilder != null
                ? widget.summaryBuilder!(context, _controller.getFormData())
                : _buildDefaultSummary(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Edit'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _completeForm();
              },
              style: _theme.submitButtonStyle,
              child: Text(widget.submitButtonText),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildDefaultSummary() {
    final data = _controller.getFormData();
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...data.entries.map((entry) {
            // Try to find field config to get label
            String label = entry.key;
            for (var step in widget.steps) {
              final field = step.fields.firstWhere(
                (f) => f.name == entry.key,
                orElse: () => FormFieldConfig(
                  name: entry.key,
                  type: FormFieldType.text,
                  label: entry.key,
                ),
              );
              if (field.name == entry.key) {
                label = field.label;
                break;
              }
            }
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatSummaryValue(entry.value),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Divider(),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
  
  String _formatSummaryValue(dynamic value) {
    if (value == null) return 'Not provided';
    if (value is DateTime) {
      return '${value.day}/${value.month}/${value.year}';
    }
    if (value is bool) {
      return value ? 'Yes' : 'No';
    }
    return value.toString();
  }
  
  void _completeForm() {
    if (_isCompleting) return;
    
    setState(() {
      _isCompleting = true;
    });
    
    // Clean up saved progress if needed
    if (widget.autosaveProgress && widget.formId != null) {
      _storage.deleteForm(widget.formId!);
    }
    
    widget.onComplete?.call(_controller.getFormData());
    
    setState(() {
      _isCompleting = false;
    });
  }
  
  void _handleKeyEvent(RawKeyEvent event) {
    if (!widget.enableKeyboardNavigation) return;
    
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.tab && !event.isShiftPressed) {
        _nextStep();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                 event.logicalKey == LogicalKeyboardKey.tab && event.isShiftPressed) {
        _previousStep();
      }
    }
  }
  
  Future<bool> _confirmCancel() async {
    if (!widget.confirmCancel) return true;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Form?'),
        content: const Text('Are you sure you want to cancel? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  void _handleCancel() async {
    final shouldCancel = await _confirmCancel();
    if (shouldCancel) {
      widget.onCancel?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final stepTheme = _theme.stepIndicatorTheme;
    
    return Focus(
      focusNode: _keyboardFocusNode,
      onKey: (_, event) {
        _handleKeyEvent(event);
        return KeyEventResult.ignored;
      },
      child: Column(
        children: [
          // Step indicator
          if (widget.showStepIndicator)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Container(
                height: stepTheme.stepSize + 16,
                alignment: Alignment.center,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.steps.length, (index) {
                        final isActive = index == _currentStep;
                        final isCompleted = index < _currentStep;
                        final isVisited = _stepVisited[index];
                        
                        return Row(
                          children: [
                            if (index > 0)
                              AnimatedContainer(
                                duration: widget.transitionDuration,
                                width: stepTheme.connectorWidth,
                                height: stepTheme.connectorHeight,
                                color: isCompleted ? stepTheme.activeColor : stepTheme.connectorColor,
                              ),
                            InkWell(
                              onTap: isVisited && !_isAnimating 
                                  ? () {
                                      if (index < _currentStep || _canMoveToNextStep()) {
                                        final previousStep = _currentStep;
                                        setState(() {
                                          _currentStep = index;
                                          _isAnimating = true;
                                        });
                                        
                                        if (widget.animateTransitions) {
                                          _pageController.animateToPage(
                                            index,
                                            duration: widget.transitionDuration,
                                            curve: widget.transitionCurve,
                                          ).then((_) {
                                            setState(() {
                                              _isAnimating = false;
                                            });
                                          });
                                        }
                                        
                                        widget.onStepChanged?.call(previousStep, index);
                                      }
                                    }
                                  : null,
                              borderRadius: BorderRadius.circular(stepTheme.stepSize / 2),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedContainer(
                                    duration: widget.transitionDuration,
                                    width: stepTheme.stepSize,
                                    height: stepTheme.stepSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isActive 
                                          ? stepTheme.activeColor 
                                          : (isCompleted ? stepTheme.completedColor : stepTheme.inactiveColor),
                                      boxShadow: isActive 
                                          ? [
                                              BoxShadow(
                                                color: stepTheme.activeColor.withOpacity(0.3),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              )
                                            ]
                                          : null,
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
                                  if (widget.stepTitles != null && widget.stepTitles!.length > index)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        widget.stepTitles![index],
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                          color: isActive ? stepTheme.activeColor : Colors.grey,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          
          // Step title
          if (widget.stepTitles != null && widget.stepTitles!.length > _currentStep)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: AnimatedSwitcher(
                duration: widget.transitionDuration,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.2, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  widget.stepTitles![_currentStep],
                  key: ValueKey<int>(_currentStep),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          
          // Current form step
          Expanded(
            child: widget.animateTransitions 
                ? PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.steps.length,
                    itemBuilder: (context, index) {
                      return AutoForm(
                        key: _formKeys[index],
                        config: widget.steps[index],
                        controller: _controller,
                        readOnly: widget.readOnly,
                        theme: _theme,
                        validateOnChange: widget.validationMode == StepValidationMode.onChange,
                      );
                    },
                  )
                : AutoForm(
                    key: _formKeys[_currentStep],
                    config: widget.steps[_currentStep],
                    controller: _controller,
                    readOnly: widget.readOnly,
                    theme: _theme,
                    validateOnChange: widget.validationMode == StepValidationMode.onChange,
                  ),
          ),
          
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (widget.showCancelButton)
                      TextButton(
                        onPressed: _handleCancel,
                        child: Text(
                          widget.cancelButtonText,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    if (_currentStep > 0)
                      ElevatedButton(
                        onPressed: !_isAnimating ? _previousStep : null,
                        style: _theme.secondaryButtonStyle,
                        child: Text(
                          widget.previousButtonText,
                          style: widget.previousButtonTextStyle,
                        ),
                      ),
                  ],
                ),
                
                ElevatedButton(
                  onPressed: widget.readOnly || _isAnimating || _isCompleting ? null : _nextStep,
                  style: _theme.submitButtonStyle,
                  child: _isCompleting 
                      ? const SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ) 
                      : Text(
                          _currentStep < widget.steps.length - 1 
                              ? 'Next' 
                              : widget.submitButtonText,
                          style: widget.submitButtonTextStyle,
                        ),
                ),
              ],
            ),
          ),
          
          // Linear progress indicator
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ((_currentStep + 1) / widget.steps.length),
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(_theme.primaryColor),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}