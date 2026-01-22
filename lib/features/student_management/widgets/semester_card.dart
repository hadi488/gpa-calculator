/// Semester Card Widget - Displays a semester with its subjects in a table
///
/// Refactored to use modular components:
/// - SemesterHeader
/// - SubjectDataTable
library;

import 'package:flutter/material.dart';

import 'package:cgpacalculator/data/models/semester.dart';
import 'package:cgpacalculator/data/services/gpa_calculator_service.dart';
import 'package:cgpacalculator/features/student_management/widgets/dialogs/add_subject_dialog.dart';

import 'components/semester_header.dart';
import 'components/subject_data_table.dart';

/// Card widget displaying a semester with its subjects
class SemesterCard extends StatefulWidget {
  final Semester semester;
  final String studentId;
  final VoidCallback? onDelete;
  final bool initiallyExpanded;

  const SemesterCard({
    super.key,
    required this.semester,
    required this.studentId,
    this.onDelete,
    this.initiallyExpanded = true,
  });

  @override
  State<SemesterCard> createState() => _SemesterCardState();
}

class _SemesterCardState extends State<SemesterCard>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late bool _isExpanded;
  late AnimationController _animationController;
  late Animation<double> _iconRotation;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _iconRotation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _heightFactor = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final storedState = PageStorage.of(
      context,
    ).readState(context, identifier: ValueKey(widget.semester.id));
    if (storedState != null && storedState is bool) {
      _isExpanded = storedState;
      if (_isExpanded) {
        _animationController.value = 1.0;
      } else {
        _animationController.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      PageStorage.of(context).writeState(
        context,
        _isExpanded,
        identifier: ValueKey(widget.semester.id),
      );

      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final gpa = GpaCalculatorService.calculateSemesterGpa(widget.semester);
    final activeSubjects = widget.semester.activeSubjects;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SemesterHeader(
            semester: widget.semester,
            gpa: gpa,
            onTap: _toggleExpanded,
            iconRotation: _iconRotation,
            onDelete: widget.onDelete,
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _heightFactor.value,
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                const Divider(height: 1),
                if (activeSubjects.isEmpty)
                  _buildEmptyState(context)
                else
                  SubjectDataTable(
                    subjects: activeSubjects,
                    studentId: widget.studentId,
                    semesterId: widget.semester.id,
                  ),
                _buildAddSubjectButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.book_outlined,
              size: 48,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No subjects yet',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddSubjectButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _showAddSubjectDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Subject'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddSubjectDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AddSubjectDialog(
        studentId: widget.studentId,
        semesterId: widget.semester.id,
      ),
    );
  }
}
