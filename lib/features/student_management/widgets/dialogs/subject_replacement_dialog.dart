/// Subject Replacement Dialog - Handles duplicate course detection
///
/// This dialog is shown when a user tries to add a subject with a course code
/// that already exists in an earlier semester. It provides two options:
/// 1. Temporary Remove: Hide the old subject but keep data for restoration
/// 2. Permanent Remove: Delete the old subject completely
library;

import 'package:flutter/material.dart';

import 'package:cgpacalculator/data/services/subject_replacement_service.dart';
import 'package:cgpacalculator/data/services/grade_scale_service.dart';

/// Dialog for handling duplicate subject replacement
class SubjectReplacementDialog extends StatelessWidget {
  /// The duplicate check result containing existing subject info
  final DuplicateCheckResult duplicateResult;

  const SubjectReplacementDialog({super.key, required this.duplicateResult});

  @override
  Widget build(BuildContext context) {
    final existingSubject = duplicateResult.existingSubject!;
    final existingSemester = duplicateResult.existingSemester!;
    final gradeInfo = GradeScaleService.gradeScale.firstWhere(
      (g) => g.gradePoint == existingSubject.gradePoint,
      orElse: () => GradeScaleService.gradeScale.last,
    );

    return AlertDialog(
      title: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(child: Text('Duplicate Course Found')),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explanation text
            Text(
              'The course "${existingSubject.courseCode}" already exists in "${existingSemester.name}".',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Existing subject details card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Existing Subject:',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    'Course:',
                    '${existingSubject.courseCode} - ${existingSubject.courseName}',
                  ),
                  _buildInfoRow(context, 'Semester:', existingSemester.name),
                  _buildInfoRow(
                    context,
                    'Grade:',
                    '${gradeInfo.letterGrade} (${existingSubject.gradePoint.toStringAsFixed(2)})',
                  ),
                  _buildInfoRow(
                    context,
                    'Credits:',
                    '${existingSubject.creditHours}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Note about CGPA
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Only the latest occurrence of each course is used for CGPA calculation.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Question
            Text(
              'How would you like to handle the existing subject?',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.all(16),
      actions: [
        // Cancel button
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),

        // Options row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Temporary remove option
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context, RemovalType.temporary),
              icon: const Icon(Icons.visibility_off),
              label: const Text('Hide'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
            ),
            const SizedBox(width: 8),

            // Permanent remove option
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, RemovalType.permanent),
              icon: const Icon(Icons.delete_forever),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds an info row for the existing subject details
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
