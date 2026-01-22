import 'package:flutter/material.dart';

import '../../../../data/models/student.dart';
import '../../../../data/models/semester.dart';
import '../semester_card.dart';

class SemestersList extends StatelessWidget {
  final Student student;
  final String studentId;
  final void Function(Semester semester) onDeleteSemester;

  const SemestersList({
    super.key,
    required this.student,
    required this.studentId,
    required this.onDeleteSemester,
  });

  @override
  Widget build(BuildContext context) {
    final sortedSemesters = student.sortedSemesters;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      physics: const BouncingScrollPhysics(),
      itemCount: sortedSemesters.length,
      // Performance optimizations for smooth scrolling
      cacheExtent: 2000, // Pre-render items ahead
      addRepaintBoundaries: true, // Isolate repaint regions
      addAutomaticKeepAlives: true, // Keep state of items
      itemBuilder: (context, index) {
        final semester = sortedSemesters[index];
        return SemesterCard(
          key: ValueKey(semester.id), // Stable key for efficient rebuilds
          semester: semester,
          studentId: studentId,
          onDelete: () => onDeleteSemester(semester),
        );
      },
    );
  }
}
