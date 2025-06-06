import 'package:flutter/material.dart';
import 'package:auto_form_builder/auto_form_builder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Form Builder Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SimpleFormPage(),
    const AdvancedFormPage(),
    const WizardFormPage(),
    const ConditionalFormPage(),
    const FormThemingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Form Builder Demo'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Auto Form Builder',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Powerful forms with minimal code'),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Simple Form'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.design_services),
              title: const Text('Advanced Form'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Multi-Step Wizard'),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Conditional Fields'),
              selected: _selectedIndex == 3,
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Theming'),
              selected: _selectedIndex == 4,
              onTap: () {
                setState(() {
                  _selectedIndex = 4;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Auto Form Builder v0.1.0',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}

// 1. Simple Form Example
class SimpleFormPage extends StatefulWidget {
  const SimpleFormPage({super.key});

  @override
  State<SimpleFormPage> createState() => _SimpleFormPageState();
}

class _SimpleFormPageState extends State<SimpleFormPage> {
  final _formController = AutoFormController();
  String _result = '';

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Simple contact form configuration
    final formConfig = FormConfig(
      fields: [
        FormFieldConfig(
          name: 'name',
          type: FormFieldType.text,
          label: 'Full Name',
          hint: 'Enter your full name',
          validators: [
            FieldValidator(type: 'required', message: 'Name is required'),
          ],
        ),
        FormFieldConfig(
          name: 'email',
          type: FormFieldType.text,
          label: 'Email Address',
          hint: 'Enter your email address',
          validators: [
            FieldValidator(type: 'required', message: 'Email is required'),
            FieldValidator(type: 'email', message: 'Enter a valid email address'),
          ],
        ),
        FormFieldConfig(
          name: 'phone',
          type: FormFieldType.text,
          label: 'Phone Number',
          hint: 'Enter your phone number',
          mask: '###-###-####',
        ),
        FormFieldConfig(
          name: 'message',
          type: FormFieldType.text,
          label: 'Message',
          hint: 'Enter your message',
        ),
      ],
      submitButtonText: 'Send Message',
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Simple Contact Form',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'This example shows a basic form with validation and masking.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: AutoForm(
              config: formConfig,
              controller: _formController,
              validateOnChange: true,
              onSubmit: (data) async {
                // Simulate API call
                await Future.delayed(const Duration(seconds: 1));
                setState(() {
                  _result = 'Form submitted with data:\n${data.entries.map((e) => '${e.key}: ${e.value}').join('\n')}';
                });
                // Don't return the data when Future<void> is expected
              },
              showLoadingDuringSubmission: true,
              useCardContainer: true,
            ),
          ),
          if (_result.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(25), // 0.1 opacity ≈ alpha 25
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Success!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(_result),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// 2. Advanced Form Example
class AdvancedFormPage extends StatefulWidget {
  const AdvancedFormPage({super.key});

  @override
  State<AdvancedFormPage> createState() => _AdvancedFormPageState();
}

class _AdvancedFormPageState extends State<AdvancedFormPage> {
  final _formController = AutoFormController();

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Advanced form with multiple field types and computed values
    final formConfig = FormConfig(
      formId: 'advanced_form',
      autoSave: true,
      fields: [
        FormFieldConfig(
          name: 'title',
          type: FormFieldType.dropdown,
          label: 'Title',
          options: [
            FieldOption(label: 'Mr.', value: 'Mr.'),
            FieldOption(label: 'Mrs.', value: 'Mrs.'),
            FieldOption(label: 'Ms.', value: 'Ms.'),
            FieldOption(label: 'Dr.', value: 'Dr.'),
          ],
        ),
        FormFieldConfig(
          name: 'firstName',
          type: FormFieldType.text,
          label: 'First Name',
          validators: [
            FieldValidator(type: 'required', message: 'First name is required'),
          ],
        ),
        FormFieldConfig(
          name: 'lastName',
          type: FormFieldType.text,
          label: 'Last Name',
          validators: [
            FieldValidator(type: 'required', message: 'Last name is required'),
          ],
        ),
        FormFieldConfig(
          name: 'fullName',
          type: FormFieldType.text,
          label: 'Full Name',
          computeFrom: ['title', 'firstName', 'lastName'],
          computeValue: (data) {
            final title = data['title'] ?? '';
            final firstName = data['firstName'] ?? '';
            final lastName = data['lastName'] ?? '';
            return '$title $firstName $lastName'.trim();
          },
        ),
        FormFieldConfig(
          name: 'birthDate',
          type: FormFieldType.datePicker,
          label: 'Date of Birth',
        ),
        FormFieldConfig(
          name: 'newsletterOptIn',
          type: FormFieldType.checkbox,
          label: 'Subscribe to newsletter',
          defaultValue: true,
        ),
        FormFieldConfig(
          name: 'acceptTerms',
          type: FormFieldType.checkbox,
          label: 'I accept the terms and conditions',
          validators: [
            FieldValidator(
              type: 'required',
              message: 'You must accept the terms to continue',
            ),
          ],
        ),
      ],
      layout: FormLayout.grid,
      gridColumns: 2,
      submitButtonText: 'Register',
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Advanced Form',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Demonstrates multiple field types, computed values, and auto-saving drafts.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: AutoForm(
              config: formConfig,
              controller: _formController,
              onSubmit: (data) async {
                // Simulate API call
                await Future.delayed(const Duration(seconds: 1));
                
                // Show success dialog
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Registration Complete'),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Thank you for registering!'),
                            const SizedBox(height: 16),
                            const Text('Submitted data:'),
                            const SizedBox(height: 8),
                            ...data.entries.map((e) => Text('${e.key}: ${e.value}')),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _formController.resetForm();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              showResetButton: true,
              useCardContainer: true,
            ),
          ),
        ],
      ),
    );
  }
}

// 3. Wizard Form Example
class WizardFormPage extends StatefulWidget {
  const WizardFormPage({super.key});

  @override
  State<WizardFormPage> createState() => _WizardFormPageState();
}

class _WizardFormPageState extends State<WizardFormPage> {
  final _formController = AutoFormController();

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Multi-step wizard form configuration
    final personalInfoSection = FormConfig(
      sectionTitle: 'Personal Information',
      description: 'Please provide your basic personal information',
      icon: Icons.person,
      fields: [
        FormFieldConfig(
          name: 'firstName',
          type: FormFieldType.text,
          label: 'First Name',
          validators: [
            FieldValidator(type: 'required', message: 'First name is required'),
          ],
        ),
        FormFieldConfig(
          name: 'lastName',
          type: FormFieldType.text,
          label: 'Last Name',
          validators: [
            FieldValidator(type: 'required', message: 'Last name is required'),
          ],
        ),
        FormFieldConfig(
          name: 'email',
          type: FormFieldType.text,
          label: 'Email',
          validators: [
            FieldValidator(type: 'required', message: 'Email is required'),
            FieldValidator(type: 'email', message: 'Enter a valid email'),
          ],
        ),
      ],
    );

    final addressSection = FormConfig(
      sectionTitle: 'Address',
      description: 'Please provide your address details',
      icon: Icons.home,
      fields: [
        FormFieldConfig(
          name: 'street',
          type: FormFieldType.text,
          label: 'Street Address',
          validators: [
            FieldValidator(type: 'required', message: 'Street address is required'),
          ],
        ),
        FormFieldConfig(
          name: 'city',
          type: FormFieldType.text,
          label: 'City',
          validators: [
            FieldValidator(type: 'required', message: 'City is required'),
          ],
        ),
        FormFieldConfig(
          name: 'state',
          type: FormFieldType.dropdown,
          label: 'State',
          options: [
            FieldOption(label: 'California', value: 'CA'),
            FieldOption(label: 'New York', value: 'NY'),
            FieldOption(label: 'Texas', value: 'TX'),
            FieldOption(label: 'Florida', value: 'FL'),
            // Add more states
          ],
          validators: [
            FieldValidator(type: 'required', message: 'State is required'),
          ],
        ),
        FormFieldConfig(
          name: 'zipCode',
          type: FormFieldType.text,
          label: 'ZIP Code',
          validators: [
            FieldValidator(type: 'required', message: 'ZIP code is required'),
          ],
        ),
      ],
    );

    final preferencesSection = FormConfig(
      sectionTitle: 'Preferences',
      description: 'Tell us about your preferences',
      icon: Icons.settings,
      fields: [
        FormFieldConfig(
          name: 'preferredContact',
          type: FormFieldType.dropdown,
          label: 'Preferred Contact Method',
          options: [
            FieldOption(label: 'Email', value: 'email'),
            FieldOption(label: 'Phone', value: 'phone'),
            FieldOption(label: 'Mail', value: 'mail'),
          ],
        ),
        FormFieldConfig(
          name: 'receiveUpdates',
          type: FormFieldType.checkbox,
          label: 'Receive Updates',
          defaultValue: true,
        ),
        FormFieldConfig(
          name: 'privacyPolicy',
          type: FormFieldType.checkbox,
          label: 'I agree to the Privacy Policy',
          validators: [
            FieldValidator(type: 'required', message: 'You must agree to the privacy policy'),
          ],
        ),
      ],
    );

    final wizardConfig = FormConfig(
      formId: 'wizard_form',
      autoSave: true,
      fields: [], // Required parameter even when using sections
      sections: [personalInfoSection, addressSection, preferencesSection],
      submitButtonText: 'Complete',
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Multi-Step Form Wizard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'This example shows a multi-step form with progress tracking.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: AutoFormWizard(
              steps: wizardConfig.sections!,
              controller: _formController,
              formId: wizardConfig.formId,
              autosaveProgress: wizardConfig.autoSave,
              showStepIndicator: true,
              stepTitles: wizardConfig.sections!.map((s) => s.sectionTitle ?? '').toList(),
              validationMode: StepValidationMode.onNext,
              animateTransitions: true,
              showSummaryStep: true,
              submitButtonText: wizardConfig.submitButtonText ?? 'Complete',
              onComplete: (data) async {
                // Simulate API call
                await Future.delayed(const Duration(seconds: 1));
                
                // Show success snackbar
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Form submitted successfully!'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                      action: SnackBarAction(
                        label: 'View',
                        textColor: Colors.white,
                        onPressed: () {
                          // Show form data dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Submitted Data'),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: data.entries.map((e) => 
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Text('${e.key}: ${e.value}'),
                                    )
                                  ).toList(),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 4. Conditional Form Example
class ConditionalFormPage extends StatefulWidget {
  const ConditionalFormPage({super.key});

  @override
  State<ConditionalFormPage> createState() => _ConditionalFormPageState();
}

class _ConditionalFormPageState extends State<ConditionalFormPage> {
  final _formController = AutoFormController();

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Form with conditional visibility based on field values
    final formConfig = FormConfig(
      fields: [
        FormFieldConfig(
          name: 'hasAccount',
          type: FormFieldType.dropdown,
          label: 'Do you have an account?',
          options: [
            FieldOption(label: 'Yes', value: 'yes'),
            FieldOption(label: 'No', value: 'no'),
          ],
          defaultValue: 'no',
        ),
        // Fields shown only when hasAccount = 'yes'
        FormFieldConfig(
          name: 'username',
          type: FormFieldType.text,
          label: 'Username',
          validators: [
            FieldValidator(type: 'required', message: 'Username is required'),
          ],
          visibleWhen: [
            VisibilityCondition(
              fieldName: 'hasAccount',
              operator: 'equals',
              value: 'yes',
            ),
          ],
        ),
        FormFieldConfig(
          name: 'password',
          type: FormFieldType.text,
          label: 'Password',
          validators: [
            FieldValidator(type: 'required', message: 'Password is required'),
          ],
          visibleWhen: [
            VisibilityCondition(
              fieldName: 'hasAccount',
              operator: 'equals',
              value: 'yes',
            ),
          ],
        ),
        // Fields shown only when hasAccount = 'no'
        FormFieldConfig(
          name: 'contactMethod',
          type: FormFieldType.dropdown,
          label: 'Preferred Contact Method',
          options: [
            FieldOption(label: 'Email', value: 'email'),
            FieldOption(label: 'Phone', value: 'phone'),
          ],
          visibleWhen: [
            VisibilityCondition(
              fieldName: 'hasAccount',
              operator: 'equals',
              value: 'no',
            ),
          ],
        ),
        // Email field shown when contactMethod = 'email'
        FormFieldConfig(
          name: 'email',
          type: FormFieldType.text,
          label: 'Email Address',
          validators: [
            FieldValidator(type: 'required', message: 'Email is required'),
            FieldValidator(type: 'email', message: 'Enter a valid email'),
          ],
          visibleWhen: [
            VisibilityCondition(
              fieldName: 'hasAccount',
              operator: 'equals',
              value: 'no',
            ),
            VisibilityCondition(
              fieldName: 'contactMethod',
              operator: 'equals',
              value: 'email',
            ),
          ],
        ),
        // Phone field shown when contactMethod = 'phone'
        FormFieldConfig(
          name: 'phone',
          type: FormFieldType.text,
          label: 'Phone Number',
          mask: '###-###-####',
          validators: [
            FieldValidator(type: 'required', message: 'Phone number is required'),
          ],
          visibleWhen: [
            VisibilityCondition(
              fieldName: 'hasAccount',
              operator: 'equals',
              value: 'no',
            ),
            VisibilityCondition(
              fieldName: 'contactMethod',
              operator: 'equals',
              value: 'phone',
            ),
          ],
        ),
      ],
      submitButtonText: 'Continue',
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Conditional Fields',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Fields appear or disappear based on the values of other fields.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: AutoForm(
              config: formConfig,
              controller: _formController,
              validateOnChange: true,
              onSubmit: (data) async {
                await Future.delayed(const Duration(seconds: 1));
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Form Submitted'),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: data.entries
                              .where((e) => e.value != null)
                              .map((e) => Text('${e.key}: ${e.value}'))
                              .toList(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
                // Don't return anything for Future<void>
              },
              useCardContainer: true,
            ),
          ),
        ],
      ),
    );
  }
}

// 5. Theming Example
class FormThemingPage extends StatefulWidget {
  const FormThemingPage({super.key});

  @override
  State<FormThemingPage> createState() => _FormThemingPageState();
}

class _FormThemingPageState extends State<FormThemingPage> {
  final _formController = AutoFormController();
  bool _useDarkTheme = false;
  FormTheme _customTheme = FormTheme();

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Basic form for theme demonstration
    final formConfig = FormConfig(
      fields: [
        FormFieldConfig(
          name: 'name',
          type: FormFieldType.text,
          label: 'Full Name',
          validators: [
            FieldValidator(type: 'required', message: 'Name is required'),
          ],
        ),
        FormFieldConfig(
          name: 'email',
          type: FormFieldType.text,
          label: 'Email Address',
          validators: [
            FieldValidator(type: 'required', message: 'Email is required'),
            FieldValidator(type: 'email', message: 'Enter a valid email'),
          ],
        ),
        FormFieldConfig(
          name: 'category',
          type: FormFieldType.dropdown,
          label: 'Category',
          options: [
            FieldOption(label: 'Business', value: 'business'),
            FieldOption(label: 'Personal', value: 'personal'),
            FieldOption(label: 'Education', value: 'education'),
          ],
        ),
        FormFieldConfig(
          name: 'rememberMe',
          type: FormFieldType.checkbox,
          label: 'Remember me',
          defaultValue: true,
        ),
      ],
      submitButtonText: 'Submit Form',
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Form Theming',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Customize the appearance of your forms with themes.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          
          // Theme controls
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Theme Options',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Use Dark Theme:'),
                      Switch(
                        value: _useDarkTheme,
                        onChanged: (value) {
                          setState(() {
                            _useDarkTheme = value;
                            _updateTheme();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Primary Color:'),
                      const SizedBox(width: 8),
                      PopupMenuButton<Color>(
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _customTheme.primaryColor,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: Colors.blue,
                            child: colorOption(Colors.blue),
                          ),
                          PopupMenuItem(
                            value: Colors.red,
                            child: colorOption(Colors.red),
                          ),
                          PopupMenuItem(
                            value: Colors.green,
                            child: colorOption(Colors.green),
                          ),
                          PopupMenuItem(
                            value: Colors.purple,
                            child: colorOption(Colors.purple),
                          ),
                          PopupMenuItem(
                            value: Colors.orange,
                            child: colorOption(Colors.orange),
                          ),
                        ],
                        onSelected: (color) {
                          setState(() {
                            _customTheme = _customTheme.copyWith(
                              primaryColor: color,
                              successColor: HSLColor.fromColor(color)
                                  .withLightness((HSLColor.fromColor(color).lightness - 0.2).clamp(0.0, 1.0))
                                  .toColor(),
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Form with applied theme
          Expanded(
            child: AutoForm(
              config: formConfig,
              controller: _formController,
              theme: _customTheme,
              onSubmit: (data) async {
                await Future.delayed(const Duration(seconds: 1));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Form submitted successfully!'),
                      backgroundColor: _customTheme.primaryColor,
                    ),
                  );
                }
                // Don't return anything for Future<void>
              },
              useCardContainer: true,
              boldLabels: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget colorOption(Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(colorName(color)),
      ],
    );
  }

  String colorName(Color color) {
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.red) return 'Red';
    if (color == Colors.green) return 'Green';
    if (color == Colors.purple) return 'Purple';
    if (color == Colors.orange) return 'Orange';
    return 'Custom';
  }

  void _updateTheme() {
    if (_useDarkTheme) {
      _customTheme = FormTheme(
        primaryColor: _customTheme.primaryColor,
        successColor: _customTheme.successColor,
        inputStyle: const TextStyle(color: Colors.white),
        labelStyle: const TextStyle(color: Colors.white70),
        errorStyle: const TextStyle(color: Colors.redAccent),
        inputDecoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade800,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      );
    } else {
      _customTheme = FormTheme(
        primaryColor: _customTheme.primaryColor,
        successColor: _customTheme.successColor,
      );
    }
  }
}
