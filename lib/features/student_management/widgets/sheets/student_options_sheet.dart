/// Student Options Sheet - Bottom sheet for student context menu
///
/// Displays options like Edit and Delete when a student card is long-pressed.
library;

import 'package:flutter/material.dart';

import 'package:cgpacalculator/data/models/student.dart';
import 'package:cgpacalculator/features/student_management/logic/student_provider.dart';

/// Bottom sheet showing options for a student
class StudentOptionsSheet extends StatelessWidget {
  final Student student;
  final StudentProvider provider;
  final Function(Student) onEdit;
  final Function(Student) onDelete;

  const StudentOptionsSheet({
    super.key,
    required this.student,
    required this.provider,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Edit Option
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Name'),
            onTap: () {
              Navigator.pop(context); // Close sheet
              onEdit(student);
            },
          ),

          // Delete Option
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Delete Student',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context); // Close sheet
              onDelete(student);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
