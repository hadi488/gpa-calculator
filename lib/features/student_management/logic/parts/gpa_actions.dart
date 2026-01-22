// ignore_for_file: invalid_use_of_protected_member
part of '../student_provider.dart';

extension GpaActions on StudentProvider {
  // ============================================================
  // GPA/CGPA CALCULATIONS
  // ============================================================

  /// Calculates CGPA for a student
  ///
  /// [studentId] - ID of the student
  /// Returns: CGPA value (0.0 - 4.0)
  double calculateCgpa(String studentId) {
    final student = getStudentById(studentId);
    if (student == null) return 0.0;

    return GpaCalculatorService.calculateCgpa(student);
  }

  /// Calculates GPA for a specific semester
  ///
  /// [studentId] - ID of the student
  /// [semesterId] - ID of the semester
  /// Returns: GPA value (0.0 - 4.0)
  double calculateSemesterGpa(String studentId, String semesterId) {
    final student = getStudentById(studentId);
    if (student == null) return 0.0;

    final semester = student.getSemesterById(semesterId);
    if (semester == null) return 0.0;

    return GpaCalculatorService.calculateSemesterGpa(semester);
  }
}
