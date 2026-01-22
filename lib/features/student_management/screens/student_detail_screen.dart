/// Student Detail Screen - Shows semesters and subjects for a student
///
/// Refactored to use modular components:
/// - CgpaCard
/// - StudentEmptyState
/// - SemestersList
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cgpacalculator/data/models/student.dart';
import 'package:cgpacalculator/data/models/semester.dart';
import 'package:cgpacalculator/features/student_management/logic/student_provider.dart';
import 'package:cgpacalculator/features/settings/logic/grade_scale_provider.dart';
import 'package:cgpacalculator/data/services/gpa_calculator_service.dart';
import 'package:cgpacalculator/features/student_management/widgets/dialogs/add_semester_dialog.dart';
import 'package:cgpacalculator/features/settings/widgets/grade_scale_info_dialog.dart';
import 'package:cgpacalculator/features/settings/screens/grade_settings_screen.dart';
import 'removed_subjects_screen.dart';

import '../widgets/cards/cgpa_card.dart';
import '../widgets/states/semester_empty_state.dart';
import '../widgets/lists/semesters_list.dart';

/// Detail screen showing all semesters and subjects for a student
class StudentDetailScreen extends StatelessWidget {
  final String studentId;

  const StudentDetailScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        final student = provider.getStudentById(studentId);

        if (student == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Student Not Found')),
            body: const Center(child: Text('Student not found')),
          );
        }

        final cgpa = GpaCalculatorService.calculateCgpa(student);
        final hasRemovedSubjects = provider.hasTemporarilyRemovedSubjects(
          studentId,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(student.fullName),
            actions: [
              // Show removed subjects if any exist
              if (hasRemovedSubjects)
                IconButton(
                  icon: const Badge(
                    label: Text('!'),
                    child: Icon(Icons.restore),
                  ),
                  tooltip: 'Removed Subjects',
                  onPressed: () => _navigateToRemovedSubjects(context),
                ),
              // Grade Scale Info
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: 'Grade Scale',
                onPressed: () => _showStudentGradeScale(context, student),
              ),
            ],
          ),
          body: Column(
            children: [
              // CGPA Card
              CgpaCard(student: student, cgpa: cgpa),

              // Semesters list
              Expanded(
                child: student.semesters.isEmpty
                    ? const SemesterEmptyState()
                    : SemestersList(
                        student: student,
                        studentId: studentId,
                        onDeleteSemester: (semester) =>
                            _confirmDeleteSemester(context, semester, provider),
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddSemesterDialog(context, provider),
            icon: const Icon(Icons.add),
            label: const Text('Add Semester'),
          ),
        );
      },
    );
  }

  /// Shows dialog to add a new semester
  Future<void> _showAddSemesterDialog(
    BuildContext context,
    StudentProvider provider,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AddSemesterDialog(studentId: studentId),
    );
  }

  /// Confirms deletion of a semester
  Future<void> _confirmDeleteSemester(
    BuildContext context,
    Semester semester,
    StudentProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Semester?'),
        content: Text(
          'Are you sure you want to delete "${semester.name}"? '
          'This will permanently remove all subjects in this semester.',
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

    if (confirmed == true) {
      await provider.deleteSemester(studentId, semester.id);
    }
  }

  /// Shows the grade scale used for this student
  void _showStudentGradeScale(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (context) => GradeScaleInfoDialog(
        scaleId: student.gradeScaleId,
        onChange: () => _updateStudentScale(context, student),
      ),
    );
  }

  /// Navigates to Grade Settings to select a scale for the student
  void _updateStudentScale(BuildContext context, Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GradeSettingsScreen(
          onScaleApplied: (newScaleId) async {
            // Get providers
            final studentProvider = context.read<StudentProvider>();
            final gradeProvider = context.read<GradeScaleProvider>();

            // recalculate GPA for all subjects that have marks using the new scale
            final updatedSemesters = student.semesters.map((semester) {
              final updatedSubjects = semester.subjects.map((subject) {
                // If subject has marks, recalculate GPA based on new scale
                if (subject.marks != null) {
                  final newGradePoint = gradeProvider.marksToGpaForScale(
                    subject.marks!,
                    newScaleId,
                  );
                  return subject.copyWith(gradePoint: newGradePoint);
                }
                return subject;
              }).toList();

              return semester.copyWith(subjects: updatedSubjects);
            }).toList();

            // Update student with new scale AND recalculated grades
            final updatedStudent = student.copyWith(
              gradeScaleId: newScaleId,
              semesters: updatedSemesters,
            );

            await studentProvider.updateStudent(updatedStudent);

            if (context.mounted) {
              final scaleName = gradeProvider.getScaleName(newScaleId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Grade scale changed to $scaleName')),
              );
            }
          },
        ),
      ),
    );
  }

  /// Navigates to removed subjects screen
  void _navigateToRemovedSubjects(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RemovedSubjectsScreen(studentId: studentId),
      ),
    );
  }
}
