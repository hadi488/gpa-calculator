import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cgpacalculator/data/models/student.dart';
import 'package:cgpacalculator/features/student_management/logic/student_provider.dart';
import 'package:cgpacalculator/features/student_management/widgets/dialogs/student_form_dialog.dart';
import 'package:cgpacalculator/features/student_management/widgets/cards/student_card.dart';
import 'package:cgpacalculator/features/student_management/widgets/states/student_empty_state.dart';
import 'package:cgpacalculator/features/settings/widgets/grade_scale_info_dialog.dart';

/// Home screen displaying list of all students
///
/// Features:
/// - List of student cards with name and CGPA
/// - FAB to add new student
/// - Swipe to delete
/// - Empty state when no students
class StudentListScreen extends StatefulWidget {
  /// Calculator type being used (e.g., "BS GPA", "MS GPA")
  final String? calculatorType;

  const StudentListScreen({super.key, this.calculatorType});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  Timer? _snackBarTimer;

  @override
  void dispose() {
    _snackBarTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.calculatorType ?? 'GPA Calculator'),
        actions: [
          // Info button showing grade scale
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Grade Scale',
            onPressed: () => _showGradeScaleDialog(context),
          ),
        ],
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!provider.hasStudents) {
            return StudentEmptyState(
              onAddStudent: () => _showStudentForm(context),
            );
          }

          return _buildStudentList(context, provider);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStudentForm(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Student'),
      ),
    );
  }

  /// Builds the list of students
  Future<void> _handleDeleteStudent(
    BuildContext context,
    Student student,
    StudentProvider provider,
  ) async {
    // 1. Delete the student
    await provider.deleteStudent(student.id);

    // 2. Show Undo SnackBar if context is still valid
    if (mounted) {
      // Cancel previous timer
      _snackBarTimer?.cancel();

      // Clear any existing snackbars immediately so new one shows
      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.black87,
          content: Text(
            '${student.fullName} deleted',
            style: const TextStyle(color: Colors.white),
          ),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: Colors.yellowAccent,
            onPressed: () async {
              // Restore the student
              await provider.restoreStudent(student);
              // Cancel timer on manual interaction
              _snackBarTimer?.cancel();
            },
          ),
        ),
      );

      // Force hide after 5 seconds (overcoming accessibility/OS sticky behaviors)
      _snackBarTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
      });
    }
  }

  /// Gets the program type based on calculator type
  String? _getProgramType() {
    if (widget.calculatorType == 'BS CGPA') return 'BS';
    if (widget.calculatorType == 'MS CGPA') return 'MS';
    return null; // Fallback or show all
  }

  /// Shows dialog to add or edit a student
  Future<void> _showStudentForm(
    BuildContext context, [
    Student? student,
  ]) async {
    await showDialog(
      context: context,
      builder: (context) =>
          StudentFormDialog(student: student, programType: _getProgramType()),
    );
  }

  Widget _buildStudentList(BuildContext context, StudentProvider provider) {
    // Filter students based on program type
    final programType = _getProgramType();

    // If no specific program type is selected (e.g. general list), show all
    // Otherwise filter for exact match or null (legacy support if needed, but strict is better)
    final filteredStudents = programType == null
        ? provider.students
        : provider.students.where((s) => s.programType == programType).toList();

    if (filteredStudents.isEmpty) {
      return StudentEmptyState(onAddStudent: () => _showStudentForm(context));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      physics: const BouncingScrollPhysics(),
      cacheExtent: 2000,
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        return StudentCard(
          student: student,
          provider: provider,
          onDelete: (s) => _handleDeleteStudent(context, s, provider),
        );
      },
    );
  }

  /// Shows grade scale information dialog
  void _showGradeScaleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const GradeScaleInfoDialog(),
    );
  }
}
