# Auto Form Builder

Auto Form Builder is a robust Flutter package for building dynamic, configuration-driven forms with advanced features such as multi-step wizards, conditional field visibility, computed fields, input masking, validation, and persistent draft saving—all with minimal boilerplate.

---

## Features

- **Dynamic Form Generation**: Build forms from JSON/Map configuration or Dart objects.
- **Multi-Step Wizard**: Easily create multi-step forms with progress indicators and animated transitions.
- **Conditional Visibility**: Show/hide fields based on other field values.
- **Computed Fields**: Automatically update fields based on other inputs.
- **Input Masking**: Support for phone, date, and custom masks with proper cursor handling.
- **Validation**: Built-in and custom validators (required, email, length, numeric, etc.), cross-field validation, and real-time feedback.
- **Draft Saving**: Persist form data locally and restore drafts.
- **Custom Widgets**: Plug in your own field widgets.
- **Theming**: Full support for custom themes, dark/light mode, and style overrides.
- **Accessibility**: Keyboard navigation and screen reader support.
- **Comprehensive Testing**: Includes robust unit and widget tests.

---

## Installation

1. **Add the dependency to your `pubspec.yaml`:**

   ```yaml
   dependencies:
     auto_form_builder: ^1.0.0
   ```

2. **Install the package:**

   ```sh
   flutter pub get
   ```

3. **Import the package in your Dart code:**

   ```dart
   import 'package:auto_form_builder/auto_form_builder.dart';
   ```

---

## Getting Started

Auto Form Builder lets you define forms using configuration objects or JSON, and renders them as fully functional Flutter forms. You can use built-in field types, validators, and advanced features like conditional visibility and computed fields.

---

## Usage

### Basic Example

```dart
final config = FormConfig(
  fields: [
    FormFieldConfig(
      name: 'email',
      type: FormFieldType.text,
      label: 'Email Address',
      validators: [
        FieldValidator(type: 'required', message: 'Email is required'),
        FieldValidator(type: 'email', message: 'Invalid email format'),
      ],
    ),
    FormFieldConfig(
      name: 'phone',
      type: FormFieldType.text,
      label: 'Phone Number',
      mask: '###-###-####',
    ),
  ],
  submitButtonText: 'Submit',
);

AutoForm(
  config: config,
  onSubmit: (data) async {
    print('Form submitted: $data');
  },
);
```

### Multi-Step Wizard Example

```dart
AutoFormWizard(
  steps: [
    FormSectionConfig(
      sectionTitle: 'Personal Info',
      fields: [
        FormFieldConfig(
          name: 'firstName',
          type: FormFieldType.text,
          label: 'First Name',
        ),
        FormFieldConfig(
          name: 'lastName',
          type: FormFieldType.text,
          label: 'Last Name',
        ),
      ],
    ),
    FormSectionConfig(
      sectionTitle: 'Contact',
      fields: [
        FormFieldConfig(
          name: 'email',
          type: FormFieldType.text,
          label: 'Email Address',
        ),
        FormFieldConfig(
          name: 'phone',
          type: FormFieldType.text,
          label: 'Phone Number',
        ),
      ],
    ),
  ],
  onComplete: (data) async {
    print('Wizard completed: $data');
  },
);
```

### Conditional Visibility

Show a field only if another field matches a value:

```dart
FormFieldConfig(
  name: 'company',
  type: FormFieldType.text,
  label: 'Company Name',
  visibleWhen: [
    VisibilityCondition(
      fieldName: 'isEmployed',
      operator: 'equals',
      value: true,
    ),
  ],
)
```

### Computed Fields

Automatically update a field based on other fields:

```dart
FormFieldConfig(
  name: 'fullName',
  type: FormFieldType.text,
  label: 'Full Name',
  computeFrom: ['firstName', 'lastName'],
  computeValue: (data) {
    final first = data['firstName'] ?? '';
    final last = data['lastName'] ?? '';
    return '$first $last'.trim();
  },
)
```

### Input Masking

```dart
FormFieldConfig(
  name: 'phone',
  type: FormFieldType.text,
  label: 'Phone Number',
  mask: '###-###-####',
)
```

---

## API Reference

### FormConfig

- `fields`: List of `FormFieldConfig` objects.
- `submitButtonText`: Text for the submit button.
- `sections`: For wizards, list of `FormSectionConfig`.

### FormFieldConfig

- `name`: Field identifier.
- `type`: Field type (text, dropdown, date, checkbox, etc.).
- `label`: Field label.
- `hint`: Optional hint text.
- `validators`: List of `FieldValidator`.
- `mask`: Input mask pattern (e.g., `'###-###-####'`).
- `visibleWhen`: List of `VisibilityCondition` for conditional display.
- `computeFrom`: List of field names this field depends on.
- `computeValue`: Function to compute value from other fields.

### FieldValidator

- `type`: Validator type (`required`, `email`, `minLength`, etc.).
- `message`: Error message to display.

### VisibilityCondition

- `fieldName`: Name of the field to check.
- `operator`: Comparison operator (`equals`, `notEquals`, etc.).
- `value`: Value to compare against.

### AutoForm

- `config`: The `FormConfig` object.
- `onSubmit`: Callback when form is submitted.
- `validateOnChange`: Validate fields on every change.
- `submitButtonText`: Text for the submit button.

### AutoFormWizard

- `steps`: List of `FormSectionConfig`.
- `onComplete`: Callback when wizard is completed.
- `stepTitles`: Optional list of step titles.
- `showStepIndicator`: Show progress indicator.
- `showSummaryStep`: Show summary before submit.

### FormStorage

- `saveForm(formId, data)`: Save form data locally.
- `loadForm(formId)`: Load saved form data.
- `hasForm(formId)`: Check if a draft exists.
- `deleteForm(formId)`: Remove saved draft.

### AutoFormController

- `updateField(name, value)`: Update a field's value.
- `getFieldValue(name)`: Get the value of a field.
- `resetForm()`: Reset all fields to initial state.
- `isFieldVisible(name)`: Check if a field is visible based on conditions.
- `formState`: Current state (`pristine`, `dirty`, etc.).

---

## Example

See the [`example/`](example/) directory for a complete working app.

---

## Best Practices

- **Validation**: Use built-in validators for common cases and implement custom validators for domain-specific rules.
- **Draft Saving**: Enable autosave for long forms or wizards to prevent data loss.
- **Conditional Logic**: Use `visibleWhen` and `computeValue` for dynamic, user-friendly forms.
- **Testing**: Write unit and widget tests for custom logic and UI.

---

## FAQ

### How do I add custom field widgets?

You can extend the form by providing your own widget builders and registering them with the form configuration.

### How do I persist form data?

Use the `FormStorage` API to save, load, and delete drafts. You can implement your own storage backend if needed.

### How do I validate fields on submit only?

Set `validateOnChange: false` in `AutoForm` and validation will only occur on submit.

---

## Additional information

- [API Reference](https://pub.dev/documentation/auto_form_builder/latest/)
- [Issue Tracker](https://github.com/KANAGARAJ-M/auto_form_builder/issues)
- Contributions and pull requests are welcome!
- For questions or support, please open an issue on GitHub.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.