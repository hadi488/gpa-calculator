// ignore_for_file: invalid_use_of_protected_member
part of '../student_provider.dart';

extension RestorationActions on StudentProvider {
  // ============================================================
  // RESTORATION OPERATIONS
  // ============================================================

  /// Gets all temporarily removed subjects for a student
  ///
  /// [studentId] - ID of the student
  /// Returns: List of removed subjects with their semester info
  List<({Subject subject, Semester semester})> getTemporarilyRemovedSubjects(
    String studentId,
  ) {
    final student = getStudentById(studentId);
    if (student == null) return [];

    return SubjectReplacementService.getTemporarilyRemovedSubjects(student);
  }

  /// Restores a temporarily removed subject
  ///
  /// [studentId] - ID of the student
  /// [subjectId] - ID of the subject to restore
  Future<void> restoreSubject(String studentId, String subjectId) async {
    _clearError();

    final student = getStudentById(studentId);
    if (student == null) return;

    // Find the subject across all semesters
    for (final semester in student.semesters) {
      final subject = semester.getSubjectById(subjectId);
      if (subject != null && subject.isTemporarilyRemoved) {
        SubjectReplacementService.restoreSubject(subject);
        await _storageService.saveStudent(student);
        notifyListeners();
        return;
      }
    }
  }

  /// Restores all temporarily removed subjects for a student
  ///
  /// [studentId] - ID of the student
  /// Returns: Number of subjects restored
  Future<int> restoreAllSubjects(String studentId) async {
    _clearError();

    final student = getStudentById(studentId);
    if (student == null) return 0;

    final count = SubjectReplacementService.restoreAllTemporarilyRemoved(
      student,
    );

    if (count > 0) {
      await _storageService.saveStudent(student);
      notifyListeners();
    }

    return count;
  }

  /// Checks if a student has temporarily removed subjects
  ///
  /// [studentId] - ID of the student
  bool hasTemporarilyRemovedSubjects(String studentId) {
    final student = getStudentById(studentId);
    if (student == null) return false;

    return SubjectReplacementService.hasTemporarilyRemovedSubjects(student);
  }
}
