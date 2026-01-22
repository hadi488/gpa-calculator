// ignore_for_file: invalid_use_of_protected_member
part of '../student_provider.dart';

extension SubjectMiscActions on StudentProvider {
  // ============================================================
  // SUBJECT OPERATIONS - Duplicate Check & Delete
  // ============================================================

  /// Checks if adding a subject would create a duplicate
  ///
  /// [studentId] - ID of the student
  /// [courseCode] - Course code to check
  /// [semesterId] - Semester where the subject will be added
  /// Returns: DuplicateCheckResult with details
  DuplicateCheckResult checkForDuplicateSubject(
    String studentId,
    String courseCode,
    String semesterId,
  ) {
    final student = getStudentById(studentId);
    if (student == null) {
      return DuplicateCheckResult.noDuplicate();
    }

    return SubjectReplacementService.checkForDuplicate(
      student,
      courseCode,
      semesterId,
      checkAllSemesters: true,
    );
  }

  /// Deletes a subject permanently
  Future<void> deleteSubject(
    String studentId,
    String semesterId,
    String subjectId,
  ) async {
    _clearError();

    final student = getStudentById(studentId);
    if (student == null) return;

    final semester = student.getSemesterById(semesterId);
    if (semester == null) return;

    semester.removeSubject(subjectId);

    await _storageService.saveStudent(student);
    notifyListeners();
  }
}
