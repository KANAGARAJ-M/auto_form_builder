/// Base class for field validators.
abstract class FieldValidator {
  /// Validates a field value and returns an error message if invalid.
  String? validate(dynamic value);
}

/// Validator that requires a field to be non-empty.
class RequiredValidator extends FieldValidator {
  final String message;
  
  RequiredValidator({this.message = 'This field is required'});
  
  @override
  String? validate(dynamic value) {
    if (value == null) return message;
    if (value is String && value.isEmpty) return message;
    if (value is List && value.isEmpty) return message;
    return null;
  }
}

/// Validator that checks for a valid email format.
class EmailValidator extends FieldValidator {
  final String message;
  
  EmailValidator({this.message = 'Please enter a valid email address'});
  
  @override
  String? validate(dynamic value) {
    if (value == null || value is! String || value.isEmpty) return null;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    
    if (!emailRegex.hasMatch(value)) return message;
    return null;
  }
}

/// Validator that checks for minimum string length.
class MinLengthValidator extends FieldValidator {
  final int minLength;
  final String message;
  
  MinLengthValidator(this.minLength, {this.message = 'Input is too short'});
  
  @override
  String? validate(dynamic value) {
    if (value == null || value is! String) return null;
    if (value.length < minLength) {
      return 'Must be at least $minLength characters';
    }
    return null;
  }
}

/// Validator that checks for maximum string length.
class MaxLengthValidator extends FieldValidator {
  final int maxLength;
  final String message;
  
  MaxLengthValidator(this.maxLength, {this.message = 'Input is too long'});
  
  @override
  String? validate(dynamic value) {
    if (value == null || value is! String) return null;
    if (value.length > maxLength) {
      return 'Must be at most $maxLength characters';
    }
    return null;
  }
}