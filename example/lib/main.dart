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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Auto Form Builder Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Create a controller to interact with the form
  final _controller = AutoFormController();
  
  // Sample form result
  Map<String, dynamic>? _formResult;

  // Create form configuration
  FormConfig _createSampleForm() {
    return FormConfig(
      submitButtonText: 'Submit Form',
      fields: [
        FormFieldConfig(
          name: 'name',
          type: FormFieldType.text,
          label: 'Full Name',
          hint: 'Enter your full name',
          required: true,
          validators: [RequiredValidator()],
        ),
        FormFieldConfig(
          name: 'email',
          type: FormFieldType.text,
          label: 'Email Address',
          hint: 'Enter your email address',
          validators: [EmailValidator()],
        ),
        FormFieldConfig(
          name: 'birthdate',
          type: FormFieldType.datePicker,
          label: 'Date of Birth',
          hint: 'Select your date of birth',
        ),
        FormFieldConfig(
          name: 'gender',
          type: FormFieldType.dropdown,
          label: 'Gender',
          options: [
            FieldOption(label: 'Male', value: 'male'),
            FieldOption(label: 'Female', value: 'female'),
            FieldOption(label: 'Other', value: 'other'),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Show the auto-generated form
            AutoForm(
              config: _createSampleForm(),
              controller: _controller,
              onSubmit: (data) {
                setState(() {
                  _formResult = data;
                });
              },
            ),
            
            // Display form results if available
            if (_formResult != null) ...[
              const SizedBox(height: 32),
              const Text(
                'Form Results:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _formResult!.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}