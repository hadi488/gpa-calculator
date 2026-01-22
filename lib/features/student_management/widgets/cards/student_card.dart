import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cgpacalculator/features/settings/logic/grade_scale_provider.dart';
import 'package:cgpacalculator/data/models/student.dart';
import 'package:cgpacalculator/features/student_management/logic/student_provider.dart';
import 'package:cgpacalculator/data/services/gpa_calculator_service.dart';
import 'package:cgpacalculator/core/theme/app_theme.dart';
import 'package:cgpacalculator/features/student_management/screens/student_detail_screen.dart';
import 'package:cgpacalculator/features/student_management/widgets/sheets/student_options_sheet.dart';
import 'package:cgpacalculator/features/student_management/widgets/dialogs/student_form_dialog.dart';

class StudentCard extends StatefulWidget {
  final Student student;
  final StudentProvider provider;
  final Function(Student) onDelete;

  const StudentCard({
    super.key,
    required this.student,
    required this.provider,
    required this.onDelete,
  });

  @override
  State<StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> {
  @override
  Widget build(BuildContext context) {
    final cgpa = GpaCalculatorService.calculateCgpa(widget.student);
    final totalCredits = GpaCalculatorService.calculateTotalCreditHours(
      widget.student,
    );

    // Watch GradeScaleProvider for changes to update letter grade dynamically
    final gradeProvider = context.watch<GradeScaleProvider>();
    String letterGrade;

    if (widget.student.gradeScaleId != null) {
      letterGrade = gradeProvider.getLetterGradeForScale(
        cgpa,
        widget.student.gradeScaleId!,
      );
    } else {
      letterGrade = gradeProvider.getLetterGrade(cgpa);
    }

    return Dismissible(
      key: Key(widget.student.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _confirmDelete(context, widget.student),
      onDismissed: (direction) => widget.onDelete(widget.student),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      child: RepaintBoundary(
        child: Card(
          child: InkWell(
            onTap: () =>
                _navigateToDetail(context, widget.student, widget.provider),
            onLongPress: () =>
                _showStudentOptions(context, widget.student, widget.provider),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar with initials
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      _getInitials(widget.student.fullName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Student info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.student.fullName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.student.semesters.length} Semester${widget.student.semesters.length != 1 ? 's' : ''} • $totalCredits Credits',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // CGPA display
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.getGpaGradient(cgpa),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          cgpa.toStringAsFixed(2),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          letterGrade,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Confirms deletion of a student
  Future<bool> _confirmDelete(BuildContext context, Student student) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student?'),
        content: Text(
          'Are you sure you want to delete "${student.fullName}"? '
          'This will permanently remove all their data including semesters and subjects.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Note: Do NOT call deleteStudent here. It is handled in onDismissed.
              Navigator.pop(context, true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Navigates to student detail screen
  void _navigateToDetail(
    BuildContext context,
    Student student,
    StudentProvider provider,
  ) {
    provider.selectStudent(student);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentDetailScreen(studentId: student.id),
      ),
    );
  }

  /// Shows options for a student (Delete, etc.)
  void _showStudentOptions(
    BuildContext context,
    Student student,
    StudentProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StudentOptionsSheet(
        student: student,
        provider: provider,
        onEdit: (s) => _showStudentForm(context, s),
        onDelete: (s) async {
          final confirm = await _confirmDelete(context, s);
          if (confirm) {
            provider.deleteStudent(s.id);
          }
        },
      ),
    );
  }

  /// Shows dialog to add or edit a student
  Future<void> _showStudentForm(
    BuildContext context, [
    Student? student,
  ]) async {
    await showDialog(
      context: context,
      builder: (context) => StudentFormDialog(student: student),
    );
  }

  /// Gets initials from full name
  String _getInitials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.substring(0, fullName.length >= 2 ? 2 : 1).toUpperCase();
  }
}
