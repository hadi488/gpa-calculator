import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../logic/add_subject_controller.dart';

class SubjectDetailsForm extends StatelessWidget {
  final AddSubjectController controller;

  const SubjectDetailsForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Course code input
        TextFormField(
          controller: controller.courseCodeController,
          autofocus: true,
          keyboardAppearance: Theme.of(context).brightness,
          decoration: const InputDecoration(
            labelText: 'Course Code',
            hintText: 'e.g., CS101, MATH201',
            prefixIcon: Icon(Icons.code),
          ),
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter course code';
            }
            if (value.trim().length < 2) {
              return 'Course code too short';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Course name input
        TextFormField(
          controller: controller.courseNameController,
          keyboardAppearance: Theme.of(context).brightness,
          decoration: const InputDecoration(
            labelText: 'Course Name (Optional)',
            hintText: 'e.g., Introduction to Programming',
            prefixIcon: Icon(Icons.book),
          ),
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }
}
