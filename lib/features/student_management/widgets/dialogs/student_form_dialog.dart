/// Student Form Dialog - Unified dialog for creating and editing students
///
/// This dialog allows users to:
/// - Add a new student (when [student] is null)
/// - Edit an existing student (when [student] is provided)
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cgpacalculator/data/models/student.dart';
import 'package:cgpacalculator/features/student_management/logic/student_provider.dart';

/// Dialog for creating or updating a student
class StudentFormDialog extends StatefulWidget {
  /// The student to edit (null if creating new)
  final Student? student;

  /// The program type (e.g., 'BS', 'MS') for the new student
  final String? programType;

  const StudentFormDialog({super.key, this.student, this.programType});

  @override
  State<StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends State<StudentFormDialog> {
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Controller for name input
  late TextEditingController _nameController;

  /// Loading state
  bool _isLoading = false;

  /// Error message
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize controller with existing name if editing
    _nameController = TextEditingController(text: widget.student?.fullName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Whether we are in edit mode
  bool get _isEditing => widget.student != null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _isEditing ? Icons.edit : Icons.person_add,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(_isEditing ? 'Edit Student' : 'Add Student'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name input
            TextFormField(
              controller: _nameController,
              keyboardAppearance: Theme.of(context).brightness,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter student\'s full name',
                prefixIcon: Icon(Icons.person),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
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
              : Text(_isEditing ? 'Save Changes' : 'Add Student'),
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
      final name = _nameController.text.trim();

      if (_isEditing) {
        // Update existing student
        final updatedStudent = widget.student!.copyWith(fullName: name);
        await provider.updateStudent(updatedStudent);
      } else {
        // Create new student with program type
        await provider.addStudent(name, programType: widget.programType);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Student updated successfully'
                  : 'Student added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
