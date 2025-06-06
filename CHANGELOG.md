# Changelog

## 1.0.0 - 2025-06-06

### Bug Fixes
* Fixed `MinLengthValidator` to correctly validate strings of exact minimum length.
* Added `isFieldVisible` method to `AutoFormController` for conditional field visibility.
* Improved text field mask logic: better cursor handling and support for various mask formats.
* Fixed parameter naming in `AutoFormWizard` for consistency with documentation and usage.
* Fixed non-POSIX path format in `pubspec.yaml` for cross-platform compatibility.
* Replaced deprecated `withOpacity` calls with `withAlpha` to avoid precision loss and warnings.

### Improvements
* Enhanced test suite with proper mocking for `FormStorage`.
* Added comprehensive unit tests for validators, controllers, and widgets.
* Improved error handling and messaging for form field validation.
* Expanded documentation for mask pattern formats and usage.
* Optimized form state management for better performance and reliability.

## 0.1.0 - 2025-05-11

Initial public release of Auto Form Builder.

### Features

#### Core Functionality
* Dynamic form generation from configuration objects.
* JSON/Map-based form definition support.
* Automatic form state management.
* Form validation system with real-time feedback.
* Form data persistence with draft saving/loading.

#### Form Fields
* AutoTextField with masking and autocomplete.
* AutoDropdown with searchable options.
* AutoDatePicker with date/time selection.
* AutoCheckbox with tristate support.
* Support for custom field widgets.

#### Advanced Form Features
* Multi-step form wizard with navigation.
* Conditional field visibility based on other field values.
* Computed fields that derive values from other fields.
* Form sections and grouping.
* Grid, vertical, and custom layouts.

#### Validation
* Built-in validators (required, email, length, numeric, etc.).
* Custom validation support.
* Cross-field validation.
* Specialized validators for credit cards, phone numbers, URLs, etc.
* Validation timing control (onChange, onSubmit, debounce).

#### User Experience
* Animated transitions between form steps.
* Form progress indicators.
* Loading states during submission.
* Keyboard navigation support.
* Accessibility features.

#### Theming and Styling
* Customizable form themes.
* Dark/light mode support.
* Style overrides for all components.
* Card container options.

### Getting Started
* See `example/` folder for sample implementations.
* Refer to `README.md` for usage instructions.
