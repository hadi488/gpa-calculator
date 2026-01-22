import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/subject.dart';
import '../../../../features/student_management/logic/student_provider.dart';
import '../../../../features/settings/logic/grade_scale_provider.dart';
import '../../../../data/services/grade_scale_service.dart';
import '../dialogs/add_subject_dialog.dart';

class SubjectDataTable extends StatelessWidget {
  final List<Subject> subjects;
  final String studentId;
  final String semesterId;

  const SubjectDataTable({
    super.key,
    required this.subjects,
    required this.studentId,
    required this.semesterId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        headingRowHeight: 48,
        dataRowMinHeight: 48,
        dataRowMaxHeight: 60,
        columns: const [
          DataColumn(
            label: Text('Code', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text(
              'Course Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text('Marks', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Grade', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('GPA', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text(
              'Credits',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Actions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: subjects
            .map((subject) => _buildSubjectRow(context, subject))
            .toList(),
      ),
    );
  }

  /// Builds a single subject row
  DataRow _buildSubjectRow(BuildContext context, Subject subject) {
    // Dynamic Letter Grade from Provider
    final provider = context.read<GradeScaleProvider>();
    final isExcluded = subject.isExcludedFromCalculations;

    String letterGrade;
    Color gradeColor;

    if (subject.hasGrade) {
      letterGrade = provider.getLetterGrade(subject.gradePoint);
      gradeColor = Color(GradeScaleService.getGradeColor(subject.gradePoint));
    } else {
      letterGrade = '-';
      gradeColor = Colors.grey;
    }

    // Override style if excluded
    final textStyle = isExcluded
        ? const TextStyle(
            color: Colors.grey,
            decoration: TextDecoration.lineThrough,
          )
        : null;

    // Dim the grade color if excluded
    if (isExcluded) {
      gradeColor = Colors.grey.withOpacity(0.5);
    }

    return DataRow(
      cells: [
        // Course code
        DataCell(
          Text(
            subject.courseCode,
            style: (textStyle ?? const TextStyle(fontWeight: FontWeight.w600))
                .copyWith(
                  decoration: isExcluded ? TextDecoration.lineThrough : null,
                ),
          ),
        ),

        // Course name
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(
              subject.courseName,
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
          ),
        ),

        // Marks (Numeric)
        DataCell(
          Text(
            subject.marks?.toString() ?? '-',
            style: (textStyle ?? const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ),

        // Letter grade with color
        DataCell(
          Opacity(
            opacity: isExcluded ? 0.6 : 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: gradeColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                letterGrade,
                style: TextStyle(
                  color: gradeColor,
                  fontWeight: FontWeight.bold,
                  decoration: isExcluded ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ),
        ),

        // GPA
        DataCell(
          Text(
            subject.hasGrade ? subject.gradePoint.toStringAsFixed(2) : '-',
            style: (textStyle ?? const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ),

        // Credits centered
        DataCell(
          Center(child: Text(subject.creditHours.toString(), style: textStyle)),
        ),

        // Actions (Edit/Delete)
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                color: Colors.blue,
                onPressed: () => _showEditSubjectDialog(context, subject),
                tooltip: isExcluded ? 'Edit to Reactivate' : 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                color: Colors.red.withValues(alpha: 0.8),
                onPressed: () => _confirmDeleteSubject(context, subject),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Shows dialog to edit a subject
  Future<void> _showEditSubjectDialog(
    BuildContext context,
    Subject subject,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AddSubjectDialog(
        studentId: studentId,
        semesterId: semesterId,
        existingSubject: subject,
      ),
    );
  }

  /// Confirms deletion of a subject
  Future<void> _confirmDeleteSubject(
    BuildContext context,
    Subject subject,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject?'),
        content: Text(
          'Are you sure you want to delete "${subject.courseCode} - ${subject.courseName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<StudentProvider>().deleteSubject(
        studentId,
        semesterId,
        subject.id,
      );
    }
  }
}
