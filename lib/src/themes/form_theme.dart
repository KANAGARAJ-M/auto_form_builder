import 'package:flutter/material.dart';

/// Theme configuration for form builder.
class FormTheme {
  /// Primary color for the form.
  final Color primaryColor;
  
  /// Secondary color for accents and highlights.
  final Color secondaryColor;
  
  /// Text style for form labels.
  final TextStyle labelStyle;
  
  /// Text style for form inputs.
  final TextStyle inputStyle;
  
  /// Decoration for form fields.
  final InputDecoration inputDecoration;
  
  /// Button style for the submit button.
  final ButtonStyle submitButtonStyle;
  
  /// Button style for the previous/cancel button.
  final ButtonStyle secondaryButtonStyle;
  
  /// Error text style.
  final TextStyle errorStyle;
  
  /// Success color for validation feedback.
  final Color successColor;
  
  /// Warning color for validation feedback.
  final Color warningColor;
  
  /// Spacing between form fields.
  final double fieldSpacing;
  
  /// Specific decoration for dropdown fields.
  final InputDecoration? dropdownDecoration;
  
  /// Specific decoration for date picker fields.
  final InputDecoration? datePickerDecoration;
  
  /// Icon for date picker fields.
  final IconData datePickerIcon;
  
  /// Style for checkbox fields.
  final CheckboxThemeData? checkboxTheme;
  
  /// Style for radio button fields.
  final RadioThemeData? radioTheme;
  
  /// Style for the form wizard steps indicator.
  final StepIndicatorTheme stepIndicatorTheme;

  FormTheme({
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.blueAccent,
    this.labelStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    this.inputStyle = const TextStyle(fontSize: 16),
    this.errorStyle = const TextStyle(color: Colors.red, fontSize: 12),
    this.successColor = Colors.green,
    this.warningColor = Colors.orange,
    this.fieldSpacing = 16.0,
    this.datePickerIcon = Icons.calendar_today,
    InputDecoration? inputDecoration,
    ButtonStyle? submitButtonStyle,
    ButtonStyle? secondaryButtonStyle,
    this.dropdownDecoration,
    this.datePickerDecoration,
    this.checkboxTheme,
    this.radioTheme,
    StepIndicatorTheme? stepIndicatorTheme,
  }) : 
    inputDecoration = inputDecoration ?? const InputDecoration(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    submitButtonStyle = submitButtonStyle ?? ButtonStyle(
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      backgroundColor: MaterialStateProperty.all(Colors.blue),
      foregroundColor: MaterialStateProperty.all(Colors.white),
    ),
    secondaryButtonStyle = secondaryButtonStyle ?? ButtonStyle(
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      backgroundColor: MaterialStateProperty.all(Colors.grey.shade200),
      foregroundColor: MaterialStateProperty.all(Colors.black87),
    ),
    stepIndicatorTheme = stepIndicatorTheme ?? StepIndicatorTheme(
      activeColor: Colors.blue,
      inactiveColor: Colors.grey,
      completedColor: Colors.blue.withOpacity(0.5),
      connectorColor: Colors.grey,
      stepSize: 30.0,
      connectorWidth: 20.0,
      connectorHeight: 1.0,
    );
  
  /// Gets the dark theme version.
  factory FormTheme.dark() {
    return FormTheme(
      primaryColor: Colors.tealAccent,
      secondaryColor: Colors.teal,
      labelStyle: const TextStyle(
        fontSize: 16, 
        fontWeight: FontWeight.bold,
        color: Colors.white70,
      ),
      inputStyle: const TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
      errorStyle: const TextStyle(
        color: Colors.redAccent,
        fontSize: 12,
      ),
      successColor: Colors.greenAccent,
      warningColor: Colors.orangeAccent,
      inputDecoration: const InputDecoration(
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.tealAccent),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      submitButtonStyle: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.tealAccent),
        foregroundColor: MaterialStateProperty.all(Colors.black87),
      ),
      secondaryButtonStyle: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.grey.shade800),
        foregroundColor: MaterialStateProperty.all(Colors.white),
      ),
      stepIndicatorTheme: StepIndicatorTheme(
        activeColor: Colors.tealAccent,
        inactiveColor: Colors.grey.shade700,
        completedColor: Colors.tealAccent.withOpacity(0.5),
        connectorColor: Colors.grey.shade700,
      ),
    );
  }

  /// Gets a modern, flat theme.
  factory FormTheme.modern() {
    return FormTheme(
      primaryColor: Colors.indigo,
      secondaryColor: Colors.indigoAccent,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      inputStyle: const TextStyle(
        fontSize: 16,
      ),
      errorStyle: TextStyle(
        color: Colors.red.shade300,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      inputDecoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        errorStyle: TextStyle(
          color: Colors.red.shade300,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      submitButtonStyle: ButtonStyle(
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        backgroundColor: MaterialStateProperty.all(Colors.indigo),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      fieldSpacing: 20.0,
      stepIndicatorTheme: StepIndicatorTheme(
        activeColor: Colors.indigo,
        inactiveColor: Colors.grey.shade300,
        completedColor: Colors.indigoAccent,
        connectorColor: Colors.grey.shade300,
        stepSize: 24.0,
        connectorHeight: 2.0,
      ),
    );
  }
  
  /// Gets a compact theme with smaller components.
  factory FormTheme.compact() {
    return FormTheme(
      labelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      inputStyle: const TextStyle(fontSize: 14),
      errorStyle: const TextStyle(
        color: Colors.red, 
        fontSize: 10,
      ),
      inputDecoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      submitButtonStyle: ButtonStyle(
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        textStyle: MaterialStateProperty.all(
          const TextStyle(fontSize: 14),
        ),
      ),
      fieldSpacing: 8.0,
      stepIndicatorTheme: StepIndicatorTheme(
        stepSize: 20.0,
        connectorWidth: 12.0,
        connectorHeight: 1.0,
      ),
    );
  }
  
  /// Apply this theme to all form widgets in the app
  static void applyToApp(BuildContext context, FormTheme theme) {
    // This would update the app's theme to incorporate form styling
    // In a real implementation, this would modify the app's ThemeData
  }

  /// Gets a Material You-inspired theme.
  factory FormTheme.materialYou(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return FormTheme(
      primaryColor: colorScheme.primary,
      secondaryColor: colorScheme.secondary,
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      inputStyle: TextStyle(
        fontSize: 16,
        color: colorScheme.onSurface,
      ),
      errorStyle: TextStyle(
        color: colorScheme.error,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      successColor: colorScheme.tertiary,
      warningColor: Colors.orange,
      inputDecoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      submitButtonStyle: ButtonStyle(
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return colorScheme.primary.withOpacity(0.5);
          }
          return colorScheme.primary;
        }),
        foregroundColor: MaterialStateProperty.all(colorScheme.onPrimary),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevation: MaterialStateProperty.all(0),
      ),
      secondaryButtonStyle: ButtonStyle(
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
        foregroundColor: MaterialStateProperty.all(colorScheme.primary),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.primary),
          ),
        ),
        elevation: MaterialStateProperty.all(0),
      ),
      stepIndicatorTheme: StepIndicatorTheme(
        activeColor: colorScheme.primary,
        inactiveColor: colorScheme.surfaceVariant,
        completedColor: colorScheme.tertiary,
        connectorColor: colorScheme.surfaceVariant,
        stepSize: 28.0,
        connectorHeight: 2.0,
      ),
    );
  }

  /// Gets a colorful, playful theme.
  factory FormTheme.colorful() {
    return FormTheme(
      primaryColor: Colors.deepPurple,
      secondaryColor: Colors.pink,
      labelStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.deepPurple,
      ),
      inputStyle: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      errorStyle: const TextStyle(
        color: Colors.redAccent,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      successColor: Colors.greenAccent.shade700,
      warningColor: Colors.amber,
      inputDecoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        prefixIconColor: Colors.deepPurple,
        suffixIconColor: Colors.pink,
      ),
      submitButtonStyle: ButtonStyle(
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        elevation: MaterialStateProperty.all(4),
        shadowColor: MaterialStateProperty.all(Colors.deepPurple.withOpacity(0.5)),
      ),
      secondaryButtonStyle: ButtonStyle(
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        backgroundColor: MaterialStateProperty.all(Colors.pink.shade100),
        foregroundColor: MaterialStateProperty.all(Colors.pink.shade800),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        elevation: MaterialStateProperty.all(0),
      ),
      fieldSpacing: 18.0,
      datePickerIcon: Icons.event,
      stepIndicatorTheme: StepIndicatorTheme(
        activeColor: Colors.deepPurple,
        inactiveColor: Colors.grey.shade300,
        completedColor: Colors.pink,
        connectorColor: Colors.grey.shade300,
        stepSize: 28.0,
        connectorHeight: 3.0,
        connectorWidth: 15.0,
      ),
    );
  }
  
  /// Gets a minimal, clean theme.
  factory FormTheme.minimal() {
    return FormTheme(
      primaryColor: Colors.black,
      secondaryColor: Colors.black54,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: Colors.black87,
      ),
      inputStyle: const TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
      errorStyle: const TextStyle(
        color: Colors.redAccent,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      successColor: Colors.teal,
      warningColor: Colors.amber.shade700,
      inputDecoration: InputDecoration(
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black26),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black26),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
        isDense: true,
        filled: false,
        labelStyle: const TextStyle(
          fontSize: 14,
          color: Colors.black54,
        ),
      ),
      submitButtonStyle: ButtonStyle(
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
        backgroundColor: MaterialStateProperty.all(Colors.black),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        elevation: MaterialStateProperty.all(0),
        textStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
      secondaryButtonStyle: ButtonStyle(
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
        foregroundColor: MaterialStateProperty.all(Colors.black),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: Colors.black),
          ),
        ),
        elevation: MaterialStateProperty.all(0),
        textStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
      fieldSpacing: 24.0,
      stepIndicatorTheme: StepIndicatorTheme(
        activeColor: Colors.black,
        inactiveColor: Colors.grey.shade300,
        completedColor: Colors.black54,
        connectorColor: Colors.grey.shade300,
        stepSize: 24.0,
        connectorHeight: 1.0,
      ),
    );
  }

  /// Gets a responsive theme that adapts to the screen size.
  static FormTheme responsive(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Mobile theme (smaller components, less padding)
    if (screenWidth < 600) {
      return FormTheme(
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        inputStyle: const TextStyle(fontSize: 14),
        fieldSpacing: 12.0,
        inputDecoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          isDense: true,
        ),
        submitButtonStyle: ButtonStyle(
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        secondaryButtonStyle: ButtonStyle(
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        stepIndicatorTheme: StepIndicatorTheme(
          stepSize: 24.0,
          connectorWidth: 16.0,
        ),
      );
    }
    
    // Tablet theme (medium sized components)
    if (screenWidth < 1024) {
      return FormTheme(
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        inputStyle: const TextStyle(fontSize: 15),
        fieldSpacing: 16.0,
        inputDecoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        submitButtonStyle: ButtonStyle(
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ),
        secondaryButtonStyle: ButtonStyle(
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ),
        stepIndicatorTheme: StepIndicatorTheme(
          stepSize: 28.0,
          connectorWidth: 18.0,
        ),
      );
    }
    
    // Desktop theme (larger components, more spacing)
    return FormTheme(
      labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      inputStyle: const TextStyle(fontSize: 16),
      fieldSpacing: 20.0,
      inputDecoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      submitButtonStyle: ButtonStyle(
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      secondaryButtonStyle: ButtonStyle(
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      stepIndicatorTheme: StepIndicatorTheme(
        stepSize: 32.0,
        connectorWidth: 20.0,
      ),
    );
  }

  /// Creates a copy of this theme with the given fields replaced.
  FormTheme copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    TextStyle? labelStyle,
    TextStyle? inputStyle,
    InputDecoration? inputDecoration,
    ButtonStyle? submitButtonStyle,
    ButtonStyle? secondaryButtonStyle,
    TextStyle? errorStyle,
    Color? successColor,
    Color? warningColor,
    double? fieldSpacing,
    InputDecoration? dropdownDecoration,
    InputDecoration? datePickerDecoration,
    IconData? datePickerIcon,
    CheckboxThemeData? checkboxTheme,
    RadioThemeData? radioTheme,
    StepIndicatorTheme? stepIndicatorTheme,
  }) {
    return FormTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      labelStyle: labelStyle ?? this.labelStyle,
      inputStyle: inputStyle ?? this.inputStyle,
      inputDecoration: inputDecoration ?? this.inputDecoration,
      submitButtonStyle: submitButtonStyle ?? this.submitButtonStyle,
      secondaryButtonStyle: secondaryButtonStyle ?? this.secondaryButtonStyle,
      errorStyle: errorStyle ?? this.errorStyle,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      fieldSpacing: fieldSpacing ?? this.fieldSpacing,
      dropdownDecoration: dropdownDecoration ?? this.dropdownDecoration,
      datePickerDecoration: datePickerDecoration ?? this.datePickerDecoration,
      datePickerIcon: datePickerIcon ?? this.datePickerIcon,
      checkboxTheme: checkboxTheme ?? this.checkboxTheme,
      radioTheme: radioTheme ?? this.radioTheme,
      stepIndicatorTheme: stepIndicatorTheme ?? this.stepIndicatorTheme,
    );
  }

  /// Merges this theme with another theme, preferring the other theme's properties when available.
  FormTheme merge(FormTheme? other) {
    if (other == null) return this;
    
    return copyWith(
      primaryColor: other.primaryColor,
      secondaryColor: other.secondaryColor,
      labelStyle: labelStyle.merge(other.labelStyle),
      inputStyle: inputStyle.merge(other.inputStyle),
      inputDecoration: inputDecoration.copyWith(
        labelStyle: other.inputDecoration.labelStyle,
        hintStyle: other.inputDecoration.hintStyle,
        helperStyle: other.inputDecoration.helperStyle,
        errorStyle: other.inputDecoration.errorStyle,
        // Add more properties as needed
      ),
      submitButtonStyle: other.submitButtonStyle,
      secondaryButtonStyle: other.secondaryButtonStyle,
      errorStyle: errorStyle.merge(other.errorStyle),
      successColor: other.successColor,
      warningColor: other.warningColor,
      fieldSpacing: other.fieldSpacing,
      dropdownDecoration: other.dropdownDecoration,
      datePickerDecoration: other.datePickerDecoration,
      datePickerIcon: other.datePickerIcon,
      checkboxTheme: other.checkboxTheme,
      radioTheme: other.radioTheme,
      stepIndicatorTheme: other.stepIndicatorTheme,
    );
  }
}

/// Theme configuration for step indicators in form wizards.
class StepIndicatorTheme {
  /// Color for the active step.
  final Color activeColor;
  
  /// Color for inactive steps.
  final Color inactiveColor;
  
  /// Color for completed steps.
  final Color completedColor;
  
  /// Color for connectors between steps.
  final Color connectorColor;
  
  /// Size of each step indicator.
  final double stepSize;
  
  /// Width of the connector between steps.
  final double connectorWidth;
  
  /// Height of the connector between steps.
  final double connectorHeight;
  
  StepIndicatorTheme({
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.completedColor = Colors.green,
    this.connectorColor = Colors.grey,
    this.stepSize = 30.0,
    this.connectorWidth = 20.0,
    this.connectorHeight = 1.0,
  });
}