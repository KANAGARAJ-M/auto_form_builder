import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  
  /// Date format pattern (uses intl package DateFormat)
  final String? dateFormat;
  
  /// Whether to include time selection
  final bool includeTime;
  
  /// First selectable date
  final DateTime? firstDate;
  
  /// Last selectable date
  final DateTime? lastDate;
  
  /// Callback when date changes
  final Function(DateTime?)? onDateChanged;
  
  /// Initial date to show if no value exists
  final DateTime? initialDate;
  
  /// Display mode for date selection (calendar, input, dropdown)
  final DatePickerMode initialDatePickerMode;
  
  /// Custom date formatter
  final String Function(DateTime)? dateFormatter;
  
  /// Animation duration for transitions
  final Duration animationDuration;
  
  /// Whether to show a clear button to remove the date
  final bool showClearButton;

  const AutoDatePicker({
    super.key,
    required this.config,
    required this.controller,
    this.readOnly = false,
    this.theme,
    this.dateFormat,
    this.includeTime = false,
    this.firstDate,
    this.lastDate,
    this.onDateChanged,
    this.initialDate,
    this.initialDatePickerMode = DatePickerMode.day,
    this.dateFormatter,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showClearButton = true,
  });

  @override
  State<AutoDatePicker> createState() => _AutoDatePickerState();
}

class _AutoDatePickerState extends State<AutoDatePicker> with SingleTickerProviderStateMixin {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  late TextEditingController _textController;
  late FormTheme _theme;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _focused = false;
  
  @override
  void initState() {
    super.initState();
    _initializeDateValue();
    _initializeAnimations();
    _theme = widget.theme ?? FormTheme();
  }
  
  void _initializeDateValue() {
    final initialValue = widget.controller.getFieldValue(widget.config.name);
    
    if (initialValue is DateTime) {
      _selectedDate = initialValue;
      _selectedTime = TimeOfDay.fromDateTime(initialValue);
    } else if (initialValue is String && initialValue.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(initialValue);
        _selectedTime = TimeOfDay.fromDateTime(_selectedDate!);
      } catch (_) {
        _selectedDate = null;
        _selectedTime = null;
      }
    } else {
      _selectedDate = null;
      _selectedTime = null;
    }
    
    _textController = TextEditingController(
      text: _formatDateTime(),
    );
  }
  
  void _initializeAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  String _formatDateTime() {
    if (_selectedDate == null) return '';
    
    if (widget.dateFormatter != null) {
      return widget.dateFormatter!(_selectedDate!);
    }
    
    final format = widget.dateFormat ?? (widget.includeTime ? 'dd/MM/yyyy HH:mm' : 'dd/MM/yyyy');
    final formatter = DateFormat(format);
    
    if (widget.includeTime && _selectedTime != null) {
      final dateWithTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      return formatter.format(dateWithTime);
    }
    
    return formatter.format(_selectedDate!);
  }
  
  DateTime _getFirstDate() {
    return widget.firstDate ?? DateTime(1900);
  }
  
  DateTime _getLastDate() {
    return widget.lastDate ?? DateTime(2100);
  }
  
  void _updateDateTime() {
    if (_selectedDate == null) {
      widget.controller.updateField(widget.config.name, null);
      return;
    }
    
    if (widget.includeTime && _selectedTime != null) {
      final dateWithTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      widget.controller.updateField(widget.config.name, dateWithTime);
      widget.onDateChanged?.call(dateWithTime);
    } else {
      widget.controller.updateField(widget.config.name, _selectedDate);
      widget.onDateChanged?.call(_selectedDate);
    }
  }
  
  @override
  void dispose() {
    _textController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    if (widget.readOnly) return;
    
    // Start the animation
    _animController.forward().then((_) {
      _animController.reverse();
    });
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? widget.initialDate ?? DateTime.now(),
      firstDate: _getFirstDate(),
      lastDate: _getLastDate(),
      initialDatePickerMode: widget.initialDatePickerMode,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _theme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        
        // Keep existing time if available
        if (widget.includeTime && _selectedTime != null) {
          _selectTime(context);
        } else {
          _textController.text = _formatDateTime();
          _updateDateTime();
        }
      });
    }
  }
  
  Future<void> _selectTime(BuildContext context) async {
    if (widget.readOnly || !widget.includeTime) return;
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _theme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: _theme.primaryColor,
              dayPeriodTextColor: _theme.primaryColor,
              dialHandColor: _theme.primaryColor,
              dialBackgroundColor: _theme.primaryColor.withOpacity(0.1),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _textController.text = _formatDateTime();
        _updateDateTime();
      });
    }
  }
  
  void _clearDate() {
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _textController.text = '';
      _updateDateTime();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use theme-specific decoration for date pickers or fall back to the default
    final decoration = (_theme.datePickerDecoration ?? _theme.inputDecoration).copyWith(
      labelText: widget.config.label,
      hintText: widget.config.hint ?? (widget.includeTime ? 'Select date & time' : 'Select date'),
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedDate != null && widget.showClearButton)
            IconButton(
              icon: const Icon(Icons.clear),
              splashRadius: 20,
              onPressed: _clearDate,
              tooltip: 'Clear date',
            ),
          if (widget.includeTime && _selectedDate != null)
            IconButton(
              icon: const Icon(Icons.access_time),
              splashRadius: 20,
              onPressed: () => _selectTime(context),
              tooltip: 'Select time',
            ),
          IconButton(
            icon: Icon(_theme.datePickerIcon),
            splashRadius: 20,
            onPressed: () => _selectDate(context),
            tooltip: 'Select date',
          ),
        ],
      ),
      labelStyle: _theme.labelStyle,
      errorStyle: _theme.errorStyle,
      focusedBorder: _focused 
        ? OutlineInputBorder(
            borderSide: BorderSide(color: _theme.primaryColor, width: 2),
            borderRadius: BorderRadius.circular(8),
          )
        : null,
    );
    
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _focused = hasFocus;
        });
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FormField<DateTime>(
          initialValue: _selectedDate,
          validator: (value) {
            for (var validator in widget.config.validators) {
              final error = validator.validate(_selectedDate);
              if (error != null) return error;
            }
            return null;
          },
          builder: (FormFieldState<DateTime> field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _textController,
                  decoration: decoration.copyWith(
                    errorText: field.errorText,
                  ),
                  style: _theme.inputStyle,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  onChanged: (value) {
                    field.didChange(_selectedDate);
                  },
                ),
                
                // Helper text for date constraints
                if (widget.firstDate != null || widget.lastDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 12),
                    child: Text(
                      'Valid: ${widget.firstDate != null ? DateFormat('d MMM y').format(widget.firstDate!) : 'Any'} to ${widget.lastDate != null ? DateFormat('d MMM y').format(widget.lastDate!) : 'Any'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: _theme.secondaryColor.withOpacity(0.7),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}