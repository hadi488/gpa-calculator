/// Add Semester Dialog - Form dialog for creating a new semester
///
/// This dialog follows Single Responsibility Principle (SRP) by
/// handling only the semester creation form.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cgpacalculator/features/student_management/logic/student_provider.dart';

/// Dialog for adding a new semester
class AddSemesterDialog extends StatefulWidget {
  /// ID of the student to add semester to
  final String studentId;

  const AddSemesterDialog({super.key, required this.studentId});

  @override
  State<AddSemesterDialog> createState() => _AddSemesterDialogState();
}

class _AddSemesterDialogState extends State<AddSemesterDialog> {
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Controller for name input
  final _nameController = TextEditingController();

  /// Loading state
  bool _isLoading = false;

  /// Error message
  String? _errorMessage;

  /// Suggested semester names
  final List<String> _suggestions = [
    'Semester 1',
    'Semester 2',
    'Semester 3',
    'Semester 4',
    'Semester 5',
    'Semester 6',
    'Semester 7',
    'Semester 8',
    'Fall 2024',
    'Spring 2025',
  ];

  @override
  void initState() {
    super.initState();
    // Set default suggestion based on existing semesters
    _setDefaultName();
  }

  void _setDefaultName() {
    final provider = context.read<StudentProvider>();
    final student = provider.getStudentById(widget.studentId);
    if (student != null) {
      final nextNum = student.semesters.length + 1;
      _nameController.text = 'Semester $nextNum';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          const Text('Add Semester'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name input
            TextFormField(
              controller: _nameController,
              keyboardAppearance: Theme.of(context).brightness,
              decoration: const InputDecoration(
                labelText: 'Semester Name',
                hintText: 'e.g., Semester 1 or Fall 2024',
                prefixIcon: Icon(Icons.edit_calendar),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a semester name';
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),

            const SizedBox(height: 16),

            // Quick suggestions
            Text(
              'Quick Select:',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestions.take(6).map((suggestion) {
                return ActionChip(
                  label: Text(suggestion),
                  onPressed: () {
                    _nameController.text = suggestion;
                  },
                );
              }).toList(),
            ),

            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),

        // Submit button
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add Semester'),
        ),
      ],
    );
  }

  /// Submits the form
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = context.read<StudentProvider>();
      await provider.addSemester(widget.studentId, _nameController.text.trim());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semester added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
