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
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
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
      return message.contains('$minLength') 
          ? message 
          : 'Must be at least $minLength characters';
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
      return message.contains('$maxLength') 
          ? message 
          : 'Must be at most $maxLength characters';
    }
    return null;
  }
}

/// Validator that checks if a value matches a specific pattern.
class PatternValidator extends FieldValidator {
  final RegExp pattern;
  final String message;
  
  PatternValidator(this.pattern, {this.message = 'Invalid format'});
  
  PatternValidator.fromString(String pattern, {this.message = 'Invalid format'})
      : pattern = RegExp(pattern);
  
  @override
  String? validate(dynamic value) {
    if (value == null || value is! String || value.isEmpty) return null;
    if (!pattern.hasMatch(value)) return message;
    return null;
  }
}

/// Validator that checks if a value is numeric.
class NumericValidator extends FieldValidator {
  final String message;
  final bool allowDecimal;
  
  NumericValidator({
    this.message = 'Please enter a valid number',
    this.allowDecimal = true,
  });
  
  @override
  String? validate(dynamic value) {
    if (value == null || (value is String && value.isEmpty)) return null;
    
    if (value is num) return null; // Already a number
    
    if (value is String) {
      final pattern = allowDecimal 
          ? RegExp(r'^-?\d*\.?\d+$') 
          : RegExp(r'^-?\d+$');
      
      if (!pattern.hasMatch(value)) return message;
      return null;
    }
    
    return message;
  }
}

/// Validator that checks if a numeric value is at least a minimum value.
class MinValueValidator extends FieldValidator {
  final num minValue;
  final String message;
  
  MinValueValidator(this.minValue, {this.message = 'Value is too small'});
  
  @override
  String? validate(dynamic value) {
    if (value == null) return null;
    
    num? numValue;
    if (value is num) {
      numValue = value;
    } else if (value is String && value.isNotEmpty) {
      numValue = num.tryParse(value);
    }
    
    if (numValue == null) return null; // Let other validators handle this
    if (numValue < minValue) {
      return message.contains('$minValue') 
          ? message 
          : 'Value must be at least $minValue';
    }
    
    return null;
  }
}

/// Validator that checks if a numeric value is at most a maximum value.
class MaxValueValidator extends FieldValidator {
  final num maxValue;
  final String message;
  
  MaxValueValidator(this.maxValue, {this.message = 'Value is too large'});
  
  @override
  String? validate(dynamic value) {
    if (value == null) return null;
    
    num? numValue;
    if (value is num) {
      numValue = value;
    } else if (value is String && value.isNotEmpty) {
      numValue = num.tryParse(value);
    }
    
    if (numValue == null) return null; // Let other validators handle this
    if (numValue > maxValue) {
      return message.contains('$maxValue') 
          ? message 
          : 'Value must be at most $maxValue';
    }
    
    return null;
  }
}

/// Validator that checks if a value is a valid phone number.
class PhoneValidator extends FieldValidator {
  final String message;
  final RegExp? customPattern;
  
  PhoneValidator({
    this.message = 'Please enter a valid phone number',
    this.customPattern,
  });
  
  @override
  String? validate(dynamic value) {
    if (value == null || value is! String || value.isEmpty) return null;
    
    // Use custom pattern or default international phone pattern
    final pattern = customPattern ?? RegExp(r'^\+?[0-9]{10,15}$');
    
    if (!pattern.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return message;
    }
    return null;
  }
}

/// Validator that checks if a value is a valid URL.
class URLValidator extends FieldValidator {
  final String message;
  final bool requireProtocol;
  
  URLValidator({
    this.message = 'Please enter a valid URL',
    this.requireProtocol = true,
  });
  
  @override
  String? validate(dynamic value) {
    if (value == null || value is! String || value.isEmpty) return null;
    
    final pattern = requireProtocol
        ? RegExp(r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$')
        : RegExp(r'^[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$');
    
    if (!pattern.hasMatch(value)) return message;
    return null;
  }
}

/// Validator that checks if a password meets strength requirements.
class PasswordValidator extends FieldValidator {
  final int minLength;
  final bool requireUppercase;
  final bool requireLowercase;
  final bool requireDigits;
  final bool requireSpecialChars;
  final String message;
  
  PasswordValidator({
    this.minLength = 8,
    this.requireUppercase = true,
    this.requireLowercase = true,
    this.requireDigits = true,
    this.requireSpecialChars = true,
    this.message = 'Password does not meet requirements',
  });
  
  @override
  String? validate(dynamic value) {
    if (value == null || value is! String || value.isEmpty) return null;
    
    final List<String> requirements = [];
    
    if (value.length < minLength) {
      requirements.add('at least $minLength characters');
    }
    
    if (requireUppercase && !RegExp(r'[A-Z]').hasMatch(value)) {
      requirements.add('uppercase letter');
    }
    
    if (requireLowercase && !RegExp(r'[a-z]').hasMatch(value)) {
      requirements.add('lowercase letter');
    }
    
    if (requireDigits && !RegExp(r'[0-9]').hasMatch(value)) {
      requirements.add('number');
    }
    
    if (requireSpecialChars && !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      requirements.add('special character');
    }
    
    if (requirements.isEmpty) return null;
    
    if (requirements.length == 1) {
      return 'Password must contain $requirements';
    }
    
    final lastRequirement = requirements.removeLast();
    return 'Password must contain ${requirements.join(', ')} and $lastRequirement';
  }
}

/// Validator that checks if a value matches another field's value.
class MatchValidator extends FieldValidator {
  final String fieldToMatch;
  final Map<String, dynamic> Function() getFormData;
  final String message;
  
  MatchValidator({
    required this.fieldToMatch,
    required this.getFormData,
    this.message = 'Fields do not match',
  });
  
  @override
  String? validate(dynamic value) {
    if (value == null) return null;
    
    final formData = getFormData();
    final fieldValue = formData[fieldToMatch];
    
    if (value != fieldValue) return message;
    return null;
  }
}

/// Validator that checks if a date is valid and within a specified range.
class DateValidator extends FieldValidator {
  final DateTime? minDate;
  final DateTime? maxDate;
  final String message;
  
  DateValidator({
    this.minDate,
    this.maxDate,
    this.message = 'Please enter a valid date',
  });
  
  @override
  String? validate(dynamic value) {
    if (value == null) return null;
    
    DateTime? date;
    if (value is DateTime) {
      date = value;
    } else if (value is String && value.isNotEmpty) {
      try {
        date = DateTime.parse(value);
      } catch (_) {
        return 'Invalid date format';
      }
    }
    
    if (date == null) return null;
    
    if (minDate != null && date.isBefore(minDate!)) {
      final formattedDate = '${minDate!.day}/${minDate!.month}/${minDate!.year}';
      return 'Date must be on or after $formattedDate';
    }
    
    if (maxDate != null && date.isAfter(maxDate!)) {
      final formattedDate = '${maxDate!.day}/${maxDate!.month}/${maxDate!.year}';
      return 'Date must be on or before $formattedDate';
    }
    
    return null;
  }
}

/// Validator that creates a composite validation from multiple validators.
class CompositeValidator extends FieldValidator {
  final List<FieldValidator> validators;
  
  CompositeValidator(this.validators);
  
  @override
  String? validate(dynamic value) {
    for (final validator in validators) {
      final error = validator.validate(value);
      if (error != null) return error;
    }
    return null;
  }
}

/// Factory class to create common validators
class Validators {
  /// Creates a required field validator
  static FieldValidator required([String? message]) {
    return RequiredValidator(message: message ?? 'This field is required');
  }
  
  /// Creates an email validator
  static FieldValidator email([String? message]) {
    return EmailValidator(message: message ?? 'Please enter a valid email address');
  }
  
  /// Creates a minimum length validator
  static FieldValidator minLength(int length, [String? message]) {
    return MinLengthValidator(length, message: message ?? 'Input is too short');
  }
  
  /// Creates a maximum length validator
  static FieldValidator maxLength(int length, [String? message]) {
    return MaxLengthValidator(length, message: message ?? 'Input is too long');
  }
  
  /// Creates a phone number validator
  static FieldValidator phone([String? message]) {
    return PhoneValidator(message: message ?? 'Please enter a valid phone number');
  }
  
  /// Creates a URL validator
  static FieldValidator url([String? message, bool requireProtocol = true]) {
    return URLValidator(
      message: message ?? 'Please enter a valid URL',
      requireProtocol: requireProtocol,
    );
  }
  
  /// Creates a numeric validator
  static FieldValidator numeric([String? message, bool allowDecimal = true]) {
    return NumericValidator(
      message: message ?? 'Please enter a valid number',
      allowDecimal: allowDecimal,
    );
  }
  
  /// Creates a minimum value validator
  static FieldValidator min(num value, [String? message]) {
    return MinValueValidator(value, message: message ?? 'Value is too small');
  }
  
  /// Creates a maximum value validator
  static FieldValidator max(num value, [String? message]) {
    return MaxValueValidator(value, message: message ?? 'Value is too large');
  }
  
  /// Creates a pattern validator
  static FieldValidator pattern(RegExp pattern, [String? message]) {
    return PatternValidator(pattern, message: message ?? 'Invalid format');
  }
  
  /// Creates a password strength validator
  static FieldValidator password({
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireDigits = true,
    bool requireSpecialChars = true,
    String? message,
  }) {
    return PasswordValidator(
      minLength: minLength,
      requireUppercase: requireUppercase,
      requireLowercase: requireLowercase,
      requireDigits: requireDigits,
      requireSpecialChars: requireSpecialChars,
      message: message ?? 'Password does not meet requirements',
    );
  }
  
  /// Creates a date range validator
  static FieldValidator dateRange({
    DateTime? minDate,
    DateTime? maxDate,
    String? message,
  }) {
    return DateValidator(
      minDate: minDate,
      maxDate: maxDate,
      message: message ?? 'Please enter a valid date',
    );
  }
}

/// Validator that checks if a value is a valid credit card number.
class CreditCardValidator extends FieldValidator {
  final String message;
  final bool validateType;
  
  CreditCardValidator({
    this.message = 'Please enter a valid credit card number',
    this.validateType = true,
  });
  
  @override
  String? validate(dynamic value) {
    if (value == null || value is! String || value.isEmpty) return null;
    
    // Remove spaces and dashes
    final cleanNumber = value.replaceAll(RegExp(r'[\s-]'), '');
    
    // Check if it contains only digits
    if (!RegExp(r'^\d+$').hasMatch(cleanNumber)) return message;
    
    // Check length (most cards are between 13-19 digits)
    if (cleanNumber.length < 13 || cleanNumber.length > 19) return message;
    
    // Luhn algorithm (checksum)
    int sum = 0;
    bool alternate = false;
    for (int i = cleanNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cleanNumber[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }
    
    if (sum % 10 != 0) return message;
    
    // Card type validation (basic patterns)
    if (validateType) {
      final visa = RegExp(r'^4[0-9]{12}(?:[0-9]{3})?$');
      final mastercard = RegExp(r'^5[1-5][0-9]{14}$');
      final amex = RegExp(r'^3[47][0-9]{13}$');
      final discover = RegExp(r'^6(?:011|5[0-9]{2})[0-9]{12}$');
      
      if (!visa.hasMatch(cleanNumber) && 
          !mastercard.hasMatch(cleanNumber) && 
          !amex.hasMatch(cleanNumber) && 
          !discover.hasMatch(cleanNumber)) {
        return 'Unrecognized card type';
      }
    }
    
    return null;
  }
}

/// Validator that checks if a value is a valid zip/postal code.
class ZipCodeValidator extends FieldValidator {
  final String message;
  final String? countryCode;
  
  ZipCodeValidator({
    this.message = 'Please enter a valid zip/postal code',
    this.countryCode, // ISO country code (US, CA, UK, etc.)
  });
  
  @override
  String? validate(dynamic value) {
    if (value == null || value is! String || value.isEmpty) return null;
    
    // Country-specific patterns
    final patterns = {
      'US': RegExp(r'^\d{5}(-\d{4})?$'), // 12345 or 12345-6789
      'CA': RegExp(r'^[A-Za-z]\d[A-Za-z][ -]?\d[A-Za-z]\d$'), // A1A 1A1 or A1A-1A1
      'UK': RegExp(r'^[A-Z]{1,2}[0-9][A-Z0-9]? ?[0-9][A-Z]{2}$'), // UK postal code
      'AU': RegExp(r'^\d{4}$'), // 4 digits
      'DE': RegExp(r'^\d{5}$'), // 5 digits
      'IN': RegExp(r'^\d{6}$'), // 6 digits
      'BR': RegExp(r'^\d{5}-\d{3}$'), // 12345-678
    };
    
    if (countryCode != null && patterns.containsKey(countryCode!.toUpperCase())) {
      final pattern = patterns[countryCode!.toUpperCase()]!;
      if (!pattern.hasMatch(value)) {
        return '$message for ${countryCode!.toUpperCase()}';
      }
    } else {
      // Generic validation (at least 3 characters, alphanumeric with optional dash/space)
      if (!RegExp(r'^[A-Za-z0-9]{3,}([ -][A-Za-z0-9]+)*$').hasMatch(value)) {
        return message;
      }
    }
    
    return null;
  }
}

/// Validator that checks if a value is a valid IP address.
class IPAddressValidator extends FieldValidator {
  final String message;
  final bool allowIPv4;
  final bool allowIPv6;
  
  IPAddressValidator({
    this.message = 'Please enter a valid IP address',
    this.allowIPv4 = true,
    this.allowIPv6 = true,
  });
  
  @override
  String? validate(dynamic value) {
    if (value == null || value is! String || value.isEmpty) return null;
    
    bool isValid = false;
    
    if (allowIPv4) {
      // IPv4 pattern
      final ipv4Pattern = RegExp(
        r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
      );
      
      if (ipv4Pattern.hasMatch(value)) {
        isValid = true;
      }
    }
    
    if (!isValid && allowIPv6) {
      // IPv6 pattern (simplified)
      final ipv6Pattern = RegExp(
        r'^(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]+|::(ffff(:0{1,4})?:)?((25[0-5]|(2[0-4]|1?[0-9])?[0-9])\.){3}(25[0-5]|(2[0-4]|1?[0-9])?[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1?[0-9])?[0-9])\.){3}(25[0-5]|(2[0-4]|1?[0-9])?[0-9]))$'
      );
      
      if (ipv6Pattern.hasMatch(value)) {
        isValid = true;
      }
    }
    
    if (!isValid) return message;
    return null;
  }
}

/// Validator that checks if a value is one of a set of allowed values.
class EnumValidator extends FieldValidator {
  final List<dynamic> allowedValues;
  final String message;
  final bool caseSensitive;
  
  EnumValidator({
    required this.allowedValues,
    this.message = 'Value is not in the allowed list',
    this.caseSensitive = true,
  });
  
  @override
  String? validate(dynamic value) {
    if (value == null) return null;
    
    if (!caseSensitive && value is String) {
      // Case-insensitive comparison for strings
      final valueStr = value.toLowerCase();
      final matchFound = allowedValues.any((allowed) {
        if (allowed is String) {
          return allowed.toLowerCase() == valueStr;
        }
        return allowed == value;
      });
      
      if (!matchFound) return message;
    } else {
      // Regular comparison
      if (!allowedValues.contains(value)) return message;
    }
    
    return null;
  }
}

/// Validator that checks if a value is within a specified range.
class RangeValidator extends FieldValidator {
  final num min;
  final num max;
  final bool inclusive;
  final String message;
  
  RangeValidator({
    required this.min,
    required this.max,
    this.inclusive = true,
    this.message = 'Value must be between min and max',
  });
  
  @override
  String? validate(dynamic value) {
    if (value == null) return null;
    
    num? numValue;
    if (value is num) {
      numValue = value;
    } else if (value is String && value.isNotEmpty) {
      numValue = num.tryParse(value);
    }
    
    if (numValue == null) return null; // Let other validators handle this
    
    if (inclusive) {
      if (numValue < min || numValue > max) {
        return message.contains('$min') && message.contains('$max')
            ? message
            : 'Value must be between $min and $max';
      }
    } else {
      if (numValue <= min || numValue >= max) {
        return message.contains('$min') && message.contains('$max')
            ? message
            : 'Value must be between $min and $max (exclusive)';
      }
    }
    
    return null;
  }
}

/// Validator that checks if a value equals a specific value.
class EqualToValidator extends FieldValidator {
  final dynamic targetValue;
  final String message;
  final bool caseSensitive;
  
  EqualToValidator({
    required this.targetValue,
    this.message = 'Value must equal the specified value',
    this.caseSensitive = true,
  });
  
  @override
  String? validate(dynamic value) {
    if (value == null) return null;
    
    if (!caseSensitive && value is String && targetValue is String) {
      if (value.toLowerCase() != targetValue.toLowerCase()) return message;
    } else {
      if (value != targetValue) return message;
    }
    
    return null;
  }
}

/// Validator that checks if a value does not equal a specific value.
class NotEqualToValidator extends FieldValidator {
  final dynamic targetValue;
  final String message;
  final bool caseSensitive;
  
  NotEqualToValidator({
    required this.targetValue,
    this.message = 'Value must not equal the specified value',
    this.caseSensitive = true,
  });
  
  @override
  String? validate(dynamic value) {
    if (value == null) return null;
    
    if (!caseSensitive && value is String && targetValue is String) {
      if (value.toLowerCase() == targetValue.toLowerCase()) return message;
    } else {
      if (value == targetValue) return message;
    }
    
    return null;
  }
}

/// Validator that checks if a file extension is allowed.
class FileExtensionValidator extends FieldValidator {
  final List<String> allowedExtensions;
  final String message;
  final bool caseSensitive;
  
  FileExtensionValidator({
    required this.allowedExtensions,
    this.message = 'File type not allowed',
    this.caseSensitive = false,
  });
  
  @override
  String? validate(dynamic value) {
    if (value == null || value is! String || value.isEmpty) return null;
    
    // Extract extension
    final parts = value.split('.');
    if (parts.length < 2) return message;
    
    String extension = parts.last;
    
    // Check if extension is in allowed list
    if (!caseSensitive) {
      extension = extension.toLowerCase();
      final lowerAllowed = allowedExtensions.map((e) => e.toLowerCase()).toList();
      if (!lowerAllowed.contains(extension)) return message;
    } else {
      if (!allowedExtensions.contains(extension)) return message;
    }
    
    return null;
  }
}

/// Validator that checks if a string contains a specific substring.
class ContainsValidator extends FieldValidator {
  final String substring;
  final String message;
  final bool caseSensitive;
  
  ContainsValidator({
    required this.substring,
    this.message = 'Value must contain the specified substring',
    this.caseSensitive = false,
  });
  
  @override
  String? validate(dynamic value) {
    if (value == null || value is! String || value.isEmpty) return null;
    
    if (caseSensitive) {
      if (!value.contains(substring)) return message;
    } else {
      if (!value.toLowerCase().contains(substring.toLowerCase())) return message;
    }
    
    return null;
  }
}

/// Validator that checks if a string does not contain a specific substring.
class NotContainsValidator extends FieldValidator {
  final String substring;
  final String message;
  final bool caseSensitive;
  
  NotContainsValidator({
    required this.substring,
    this.message = 'Value must not contain the specified substring',
    this.caseSensitive = false,
  });
  
  @override
  String? validate(dynamic value) {
    if (value == null || value is! String || value.isEmpty) return null;
    
    if (caseSensitive) {
      if (value.contains(substring)) return message;
    } else {
      if (value.toLowerCase().contains(substring.toLowerCase())) return message;
    }
    
    return null;
  }
}

// Add new factory methods to the Validators class
extension ValidatorsExtension on Validators {
  /// Creates a credit card validator
  static FieldValidator creditCard([String? message]) {
    return CreditCardValidator(message: message ?? 'Please enter a valid credit card number');
  }
  
  /// Creates a zip code validator
  static FieldValidator zipCode([String? message, String? countryCode]) {
    return ZipCodeValidator(
      message: message ?? 'Please enter a valid zip/postal code',
      countryCode: countryCode,
    );
  }
  
  /// Creates an IP address validator
  static FieldValidator ipAddress([String? message, bool allowIPv4 = true, bool allowIPv6 = true]) {
    return IPAddressValidator(
      message: message ?? 'Please enter a valid IP address',
      allowIPv4: allowIPv4,
      allowIPv6: allowIPv6,
    );
  }
  
  /// Creates an enum validator
  static FieldValidator inList(List<dynamic> allowedValues, [String? message, bool caseSensitive = true]) {
    return EnumValidator(
      allowedValues: allowedValues,
      message: message ?? 'Value is not in the allowed list',
      caseSensitive: caseSensitive,
    );
  }
  
  /// Creates a range validator
  static FieldValidator range(num min, num max, [String? message, bool inclusive = true]) {
    return RangeValidator(
      min: min,
      max: max,
      message: message ?? 'Value must be between $min and $max',
      inclusive: inclusive,
    );
  }
  
  /// Creates an equalTo validator
  static FieldValidator equalTo(dynamic value, [String? message, bool caseSensitive = true]) {
    return EqualToValidator(
      targetValue: value,
      message: message ?? 'Value must equal the specified value',
      caseSensitive: caseSensitive,
    );
  }
  
  /// Creates a notEqualTo validator
  static FieldValidator notEqualTo(dynamic value, [String? message, bool caseSensitive = true]) {
    return NotEqualToValidator(
      targetValue: value,
      message: message ?? 'Value must not equal the specified value',
      caseSensitive: caseSensitive,
    );
  }
  
  /// Creates a file extension validator
  static FieldValidator fileExtension(List<String> allowedExtensions, [String? message]) {
    return FileExtensionValidator(
      allowedExtensions: allowedExtensions,
      message: message ?? 'File type not allowed',
    );
  }
  
  /// Creates a contains validator
  static FieldValidator contains(String substring, [String? message, bool caseSensitive = false]) {
    return ContainsValidator(
      substring: substring,
      message: message ?? 'Value must contain "$substring"',
      caseSensitive: caseSensitive,
    );
  }
  
  /// Creates a notContains validator
  static FieldValidator notContains(String substring, [String? message, bool caseSensitive = false]) {
    return NotContainsValidator(
      substring: substring,
      message: message ?? 'Value must not contain "$substring"',
      caseSensitive: caseSensitive,
    );
  }
}