import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../models/form_field_config.dart';
import '../auto_form_controller.dart';
import '../themes/form_theme.dart';

/// Automatically generated text field based on configuration.
class AutoTextField extends StatefulWidget {
  /// The field configuration.
  final FormFieldConfig config;
  
  /// The form controller.
  final AutoFormController controller;
  
  /// Whether the field is read-only.
  final bool readOnly;
  
  /// Whether to validate on field changes.
  final bool validateOnChange;

  /// Theme for the text field.
  final FormTheme? theme;
  
  /// Text input type (email, number, phone, etc.)
  final TextInputType? keyboardType;
  
  /// Auto-capitalization behavior
  final TextCapitalization textCapitalization;
  
  /// Input formatters for restricting/formatting input
  final List<TextInputFormatter>? inputFormatters;
  
  /// Whether this is a password field with toggleable visibility
  final bool isPassword;
  
  /// Whether to show character count
  final bool showCharacterCount;
  
  /// Leading icon for the text field
  final IconData? leadingIcon;
  
  /// Trailing icon for the text field
  final IconData? trailingIcon;
  
  /// Callback when trailing icon is pressed
  final VoidCallback? onTrailingIconPressed;
  
  /// Prefix text to display before the input
  final String? prefixText;
  
  /// Suffix text to display after the input
  final String? suffixText;
  
  /// Maximum length of input
  final int? maxLength;
  
  /// Whether to show a counter for maxLength
  final bool showCounter;
  
  /// Debounce duration for onChanged events
  final Duration debounceDuration;
  
  /// Callback when the value changes, with debounce
  final Function(String)? onDebouncedChanged;
  
  /// Whether to show a success indicator when valid
  final bool showSuccessIndicator;
  
  /// Whether to enable autocomplete suggestions
  final bool enableSuggestions;
  
  /// List of autocomplete suggestions
  final List<String>? suggestions;
  
  /// Mask for the text field (e.g., phone, credit card)
  final String? mask;
  
  /// Mask character (default: _)
  final String maskChar;
  
  /// Focus node for the text field
  final FocusNode? focusNode;
  
  /// Callback when text field gains focus
  final Function()? onFocusGained;
  
  /// Callback when text field loses focus
  final Function()? onFocusLost;

  const AutoTextField({
    super.key,
    required this.config,
    required this.controller,
    this.readOnly = false,
    this.validateOnChange = false,
    this.theme,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.isPassword = false,
    this.showCharacterCount = false,
    this.leadingIcon,
    this.trailingIcon,
    this.onTrailingIconPressed,
    this.prefixText,
    this.suffixText,
    this.maxLength,
    this.showCounter = true,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.onDebouncedChanged,
    this.showSuccessIndicator = false,
    this.enableSuggestions = false,
    this.suggestions,
    this.mask,
    this.maskChar = '_',
    this.focusNode,
    this.onFocusGained,
    this.onFocusLost,
  });

  @override
  State<AutoTextField> createState() => _AutoTextFieldState();
}

class _AutoTextFieldState extends State<AutoTextField> {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  late FormTheme _theme;
  bool _passwordVisible = false;
  Timer? _debounceTimer;
  bool _isFocused = false;
  String _previousValue = '';
  OverlayEntry? _suggestionsOverlay;
  final LayerLink _layerLink = LayerLink();
  
  void initState() {
    super.initState();
    final initialValue = widget.controller.getFieldValue(widget.config.name) as String? ?? '';
    _textController = TextEditingController(text: initialValue);
    _previousValue = initialValue;
    _focusNode = widget.focusNode ?? FocusNode();
    _theme = widget.theme ?? FormTheme();
    
    _focusNode.addListener(_handleFocusChange);
    
    // Apply mask if needed
    if (widget.mask != null && initialValue.isNotEmpty) {
      _textController.text = _applyMask(initialValue);
    }
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.focusNode == null) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode.dispose();
    }
    _textController.dispose();
    _hideSuggestions();
    super.dispose();
  }
  
  void _handleFocusChange() {
    if (_focusNode.hasFocus && !_isFocused) {
      setState(() {
        _isFocused = true;
      });
      widget.onFocusGained?.call();
      
      if (widget.enableSuggestions && widget.suggestions != null && widget.suggestions!.isNotEmpty) {
        _showSuggestions();
      }
    } else if (!_focusNode.hasFocus && _isFocused) {
      setState(() {
        _isFocused = false;
      });
      widget.onFocusLost?.call();
      _hideSuggestions();
    }
  }
  
  void _showSuggestions() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    
    _suggestionsOverlay = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: 200,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _getFilteredSuggestions().length,
                itemBuilder: (context, index) {
                  final suggestion = _getFilteredSuggestions()[index];
                  return ListTile(
                    dense: true,
                    title: Text(suggestion),
                    onTap: () {
                      _textController.text = suggestion;
                      _updateValue(suggestion);
                      _hideSuggestions();
                      _focusNode.unfocus();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_suggestionsOverlay!);
  }
  
  void _hideSuggestions() {
    _suggestionsOverlay?.remove();
    _suggestionsOverlay = null;
  }
  
  List<String> _getFilteredSuggestions() {
    if (widget.suggestions == null || widget.suggestions!.isEmpty) {
      return [];
    }
    
    final currentText = _textController.text.toLowerCase();
    if (currentText.isEmpty) {
      return widget.suggestions!;
    }
    
    return widget.suggestions!.where(
      (suggestion) => suggestion.toLowerCase().contains(currentText)
    ).toList();
  }
  
  String _applyMask(String text) {
    if (widget.mask == null) return text;
    
    // Clean input of any non-alphanumeric characters
    final cleanText = text.replaceAll(RegExp(r'[^0-9a-zA-Z]'), '');
    final mask = widget.mask!;
    
    String result = '';
    int textIndex = 0;
    
    // Apply mask
    for (int i = 0; i < mask.length && textIndex < cleanText.length; i++) {
      if (mask[i] == '#') {
        // Add character from input text
        result += cleanText[textIndex];
        textIndex++;
      } else if (mask[i] == 'A' || mask[i] == 'a') {
        // Only allow letters
        if (RegExp(r'[a-zA-Z]').hasMatch(cleanText[textIndex])) {
          result += cleanText[textIndex];
          textIndex++;
        } else {
          // Skip non-letter characters for this position
          textIndex++;
          // Adjust for skipped character
          if (textIndex < cleanText.length && i < mask.length - 1) {
            i--;
          }
        }
      } else if (mask[i] == '0' || mask[i] == '9') {
        // Only allow digits
        if (RegExp(r'[0-9]').hasMatch(cleanText[textIndex])) {
          result += cleanText[textIndex];
          textIndex++;
        } else {
          // Skip non-digit characters for this position
          textIndex++;
          // Adjust for skipped character
          if (textIndex < cleanText.length && i < mask.length - 1) {
            i--;
          }
        }
      } else {
        // Add mask character
        result += mask[i];
      }
    }
    
    return result;
  }
  
  void _handleMaskedInputChange(String value) {
    // Don't apply mask if deleting (comparing lengths)
    if (value.length < _previousValue.length) {
      _previousValue = value;
      _updateValue(value);
      return;
    }
    
    // Store selection to restore after mask application
    final currentSelection = _textController.selection;
    final oldText = _textController.text;
    
    // Apply mask
    final maskedValue = _applyMask(value);
    if (maskedValue != value) {
      // Calculate new cursor position
      int cursorOffset = 0;
      if (maskedValue.length > oldText.length) {
        // If we've added a mask character (like '-'), adjust cursor
        for (int i = 0; i < maskedValue.length && i < currentSelection.baseOffset + cursorOffset; i++) {
          if (i >= oldText.length || maskedValue[i] != oldText[i]) {
            if (i <= currentSelection.baseOffset) {
              cursorOffset++;
            }
          }
        }
      }
      
      // Update text and cursor position
      _textController.value = TextEditingValue(
        text: maskedValue,
        selection: TextSelection.collapsed(
          offset: min(currentSelection.baseOffset + cursorOffset, maskedValue.length)
        ),
      );
    }
    
    _previousValue = maskedValue;
    _updateValue(maskedValue);
  }
  
  String _stripMask(String maskedText) {
    if (widget.mask == null) return maskedText;
    
    // Strip all non-alphanumeric characters
    return maskedText.replaceAll(RegExp(r'[^0-9a-zA-Z]'), '');
  }
  
  void _updateValue(String value) {
    final actualValue = widget.mask != null ? _stripMask(value) : value;
    widget.controller.updateField(widget.config.name, actualValue);
    
    if (widget.validateOnChange) {
      Form.of(context).validate();
    }
    
    // Handle debounced change
    if (widget.onDebouncedChanged != null) {
      if (_debounceTimer?.isActive ?? false) {
        _debounceTimer!.cancel();
      }
      
      _debounceTimer = Timer(widget.debounceDuration, () {
        widget.onDebouncedChanged!(actualValue);
      });
    }
    
    _previousValue = value;
  }

  @override
  Widget build(BuildContext context) {
    // Use theme-specific decoration for text fields or fall back to the default
    final decoration = _theme.inputDecoration.copyWith(
      labelText: widget.config.label,
      hintText: widget.config.hint,
      labelStyle: _theme.labelStyle,
      errorStyle: _theme.errorStyle,
      prefixIcon: widget.leadingIcon != null 
          ? Icon(widget.leadingIcon, color: _isFocused ? _theme.primaryColor : null) 
          : null,
      prefixText: widget.prefixText,
      suffixText: widget.suffixText,
      suffixIcon: _buildSuffixIcon(),
      counterText: widget.showCharacterCount ? null : '',
    );

    return CompositedTransformTarget(
      link: _layerLink,
      child: FormField<String>(
        initialValue: _textController.text,
        validator: (value) {
          for (var validator in widget.config.validators) {
            final error = validator.validate(value);
            if (error != null) return error;
          }
          return null;
        },
        builder: (FormFieldState<String> field) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _textController,
                focusNode: _focusNode,
                decoration: decoration.copyWith(
                  errorText: field.errorText,
                  // Show success icon if specified and field is valid and not empty
                  suffixIcon: field.hasError 
                      ? Icon(Icons.error_outline, color: Colors.red)
                      : (widget.showSuccessIndicator && 
                         _textController.text.isNotEmpty && 
                         field.value != null &&
                         field.value != _previousValue)
                          ? Icon(Icons.check_circle_outline, color: _theme.successColor)
                          : _buildSuffixIcon(),
                ),
                style: _theme.inputStyle,
                readOnly: widget.readOnly,
                obscureText: widget.isPassword && !_passwordVisible,
                keyboardType: widget.keyboardType,
                textCapitalization: widget.textCapitalization,
                inputFormatters: [
                  ...?widget.inputFormatters,
                  if (widget.maxLength != null)
                    LengthLimitingTextInputFormatter(widget.maxLength),
                ],
                maxLength: widget.showCounter ? widget.maxLength : null,
                enableSuggestions: widget.enableSuggestions,
                onChanged: (value) {
                  if (widget.mask != null) {
                    _handleMaskedInputChange(value);
                  } else {
                    _updateValue(value);
                  }
                  
                  field.didChange(value);
                },
              ),
              
              // Helper text if this field has requirements
              if (widget.maxLength != null && !widget.showCounter)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12),
                  child: Text(
                    '${_textController.text.length}/${widget.maxLength}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _textController.text.length > (widget.maxLength ?? 0)
                          ? Colors.red.shade700
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
  
  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _passwordVisible ? Icons.visibility : Icons.visibility_off,
          color: _isFocused ? _theme.primaryColor : Colors.grey,
        ),
        onPressed: () {
          setState(() {
            _passwordVisible = !_passwordVisible;
          });
        },
        splashRadius: 20,
      );
    } else if (widget.trailingIcon != null) {
      return IconButton(
        icon: Icon(
          widget.trailingIcon,
          color: _isFocused ? _theme.primaryColor : Colors.grey,
        ),
        onPressed: widget.onTrailingIconPressed,
        splashRadius: 20,
      );
    }
    
    return null;
  }
}