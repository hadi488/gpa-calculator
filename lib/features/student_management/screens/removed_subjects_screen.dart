/// Removed Subjects Screen - Shows temporarily removed subjects for restoration
///
/// This screen allows users to view and restore subjects that were
/// temporarily removed due to being replaced by a newer occurrence.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cgpacalculator/data/models/subject.dart';
import 'package:cgpacalculator/data/models/semester.dart';
import 'package:cgpacalculator/features/student_management/logic/student_provider.dart';
import 'package:cgpacalculator/data/services/grade_scale_service.dart';

/// Screen showing all temporarily removed subjects
class RemovedSubjectsScreen extends StatelessWidget {
  /// ID of the student
  final String studentId;

  const RemovedSubjectsScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Removed Subjects'),
        actions: [
          // Restore all button
          Consumer<StudentProvider>(
            builder: (context, provider, child) {
              final removedSubjects = provider.getTemporarilyRemovedSubjects(
                studentId,
              );

              if (removedSubjects.isEmpty) return const SizedBox.shrink();

              return TextButton.icon(
                onPressed: () => _restoreAll(context, provider),
                icon: const Icon(Icons.restore, color: Colors.white),
                label: const Text(
                  'Restore All',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          final removedSubjects = provider.getTemporarilyRemovedSubjects(
            studentId,
          );

          if (removedSubjects.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildRemovedList(context, removedSubjects, provider);
        },
      ),
    );
  }

  /// Builds empty state widget
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Removed Subjects',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'All subjects are currently active',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds list of removed subjects
  Widget _buildRemovedList(
    BuildContext context,
    List<({Subject subject, Semester semester})> removedSubjects,
    StudentProvider provider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: removedSubjects.length,
      itemBuilder: (context, index) {
        final item = removedSubjects[index];
        return _buildRemovedSubjectCard(context, item, provider);
      },
    );
  }

  /// Builds card for a single removed subject
  Widget _buildRemovedSubjectCard(
    BuildContext context,
    ({Subject subject, Semester semester}) item,
    StudentProvider provider,
  ) {
    final subject = item.subject;
    final semester = item.semester;
    final gradeInfo = GradeScaleService.gradeScale.firstWhere(
      (g) => g.gradePoint == subject.gradePoint,
      orElse: () => GradeScaleService.gradeScale.last,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with course code and semester
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subject.courseCode,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    semester.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Course name
            Text(
              subject.courseName,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),

            // Grade and credits info
            Row(
              children: [
                _buildInfoChip(
                  context,
                  'Grade: ${gradeInfo.letterGrade}',
                  Color(GradeScaleService.getGradeColor(subject.gradePoint)),
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  context,
                  'GPA: ${subject.gradePoint.toStringAsFixed(2)}',
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  context,
                  '${subject.creditHours} Credits',
                  Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Restore button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _restoreSubject(context, subject, provider),
                icon: const Icon(Icons.restore),
                label: const Text('Restore Subject'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            // Warning text
            const SizedBox(height: 8),
            Text(
              'Note: Restoring may cause duplicate course codes. '
              'The latest occurrence will still be used for CGPA.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.orange,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an info chip
  Widget _buildInfoChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Restores a single subject
  Future<void> _restoreSubject(
    BuildContext context,
    Subject subject,
    StudentProvider provider,
  ) async {
    await provider.restoreSubject(studentId, subject.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${subject.courseCode} restored'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Restores all removed subjects
  Future<void> _restoreAll(
    BuildContext context,
    StudentProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore All?'),
        content: const Text(
          'This will restore all temporarily removed subjects. '
          'The latest occurrence of each course will still be used for CGPA calculation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final count = await provider.restoreAllSubjects(studentId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$count subject${count != 1 ? 's' : ''} restored'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
