import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cgpacalculator/data/models/subject.dart';
import 'package:cgpacalculator/features/student_management/logic/student_provider.dart';
import 'package:cgpacalculator/data/services/subject_replacement_service.dart';
import 'logic/add_subject_controller.dart';
import 'components/subject_details_form.dart';
import 'components/credit_hours_selector.dart';
import 'components/grade_input_section.dart';
import 'subject_replacement_dialog.dart';

/// Dialog for adding or editing a subject
class AddSubjectDialog extends StatefulWidget {
  final String studentId;
  final String semesterId;
  final Subject? existingSubject;

  const AddSubjectDialog({
    super.key,
    required this.studentId,
    required this.semesterId,
    this.existingSubject,
  });

  @override
  State<AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<AddSubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late AddSubjectController _controller;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _errorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AddSubjectController(
      context: context,
      studentId: widget.studentId,
      existingSubject: widget.existingSubject,
    );
    // Listen to controller changes to rebuild UI
    _controller.addListener(_onControllerChange);
  }

  String? _lastErrorMessage;

  void _onControllerChange() {
    if (mounted) {
      setState(() {});
      // Auto-scroll to error message when it appears (only when it's a new error)
      final currentError = _controller.errorMessage;
      if (currentError != null && currentError != _lastErrorMessage) {
        _lastErrorMessage = currentError;

        // Dismiss keyboard first
        FocusScope.of(context).unfocus();

        // Use post-frame callback to ensure the error widget is rendered
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Wait for keyboard to start closing
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted && _errorKey.currentContext != null) {
              Scrollable.ensureVisible(
                _errorKey.currentContext!,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                alignment: 0.0, // Align to top
              );
            }
          });
        });
      } else if (currentError == null) {
        _lastErrorMessage = null;
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    _controller.cleanUp();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingSubject != null;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            isEditing ? Icons.edit : Icons.book_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(isEditing ? 'Edit Subject' : 'Add Subject'),
        ],
      ),
      content: SingleChildScrollView(
        controller: _scrollController,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Error message
              if (_controller.errorMessage != null) ...[
                Text(
                  key: _errorKey,
                  _controller.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Warning for excluded subjects
              if (isEditing &&
                  (widget.existingSubject?.isExcludedFromCalculations ?? false))
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This subject is currently excluded. Saving changes will include it in calculation.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Credit Hours
              CreditHoursSelector(
                selectedCredits: _controller.creditHours,
                onSelected: _controller.setCreditHours,
              ),
              const SizedBox(height: 16),

              // Subject Details (Code, Name)
              SubjectDetailsForm(controller: _controller),
              const SizedBox(height: 16),

              // Grade Input (Marks/GPA/Preview)
              GradeInputSection(controller: _controller),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _controller.isLoading
              ? null
              : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _controller.isLoading ? null : _submit,
          child: _controller.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Update' : 'Add Subject'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _controller.isLoading = true;
      _controller.errorMessage = null;
    });

    try {
      final provider = context.read<StudentProvider>();
      final gradePoint = _controller.getGpaValue();
      final hasGrade = gradePoint != null;
      final isMarksEmpty =
          _controller.useMarksInput &&
          _controller.marksController.text.trim().isEmpty;

      // Prepare common data
      final courseCode = _controller.courseCodeController.text;
      final courseName = _controller.courseNameController.text;
      final credits = _controller.creditHours;
      final marks = (!isMarksEmpty && _controller.useMarksInput)
          ? int.tryParse(_controller.marksController.text)?.round()
          : null;

      if (widget.existingSubject != null) {
        // UPDATE
        await provider.updateSubjectWithGpa(
          studentId: widget.studentId,
          semesterId: widget.semesterId,
          subjectId: widget.existingSubject!.id,
          courseCode: courseCode,
          courseName: courseName,
          gradePoint: gradePoint ?? 0.0,
          creditHours: credits,
          hasGrade: hasGrade,
          marks: marks,
          handleDuplicate: _handleDuplicate,
        );

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subject updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // ADD
        await provider.addSubjectWithGpa(
          studentId: widget.studentId,
          semesterId: widget.semesterId,
          courseCode: courseCode,
          courseName: courseName,
          gradePoint: gradePoint ?? 0.0,
          creditHours: credits,
          hasGrade: hasGrade,
          marks: marks,
          handleDuplicate: _handleDuplicate,
        );

        if (mounted) {
          // Mark as submitted FIRST to prevent cleanUp from re-saving draft
          _controller.markAsSubmitted();
          // Clear draft and save credit hours on successful add
          await provider.clearSubjectDraft();
          await provider.saveLastSelectedCreditHours(credits);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subject added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Dismiss keyboard first
        FocusScope.of(context).unfocus();

        setState(() {
          _controller.isLoading = false;
          _controller.errorMessage = e.toString();
        });

        // Scroll to error message after it's rendered
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted && _errorKey.currentContext != null) {
              Scrollable.ensureVisible(
                _errorKey.currentContext!,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                alignment: 0.0,
              );
            }
          });
        });
      }
    }
  }

  Future<RemovalType?> _handleDuplicate(
    DuplicateCheckResult duplicateResult,
  ) async {
    // Handle hidden/removed subject warning
    if (duplicateResult.isHidden) {
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hidden Duplicate Found'),
          content: Text(
            'This subject exists in history (Semester ${duplicateResult.existingSemester?.name ?? '?'}) but is currently hidden.\n\nDo you want to add this new one anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Add Anyway'),
            ),
          ],
        ),
      );
      // If proceeding, cleanup the old hidden one (permanent removal) to avoid ghosts
      return (shouldProceed ?? false) ? RemovalType.permanent : null;
    }

    // Show replacement dialog for ACTIVE duplicates
    return await showDialog<RemovalType>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          SubjectReplacementDialog(duplicateResult: duplicateResult),
    );
  }
}
