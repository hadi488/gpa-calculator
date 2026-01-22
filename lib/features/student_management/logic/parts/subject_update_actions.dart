// ignore_for_file: invalid_use_of_protected_member
part of '../student_provider.dart';

extension SubjectUpdateActions on StudentProvider {
  /// Updates a subject
  Future<void> updateSubject({
    required String studentId,
    required String semesterId,
    required String subjectId,
    required String courseCode,
    required String courseName,
    required int marks,
    required int creditHours,
  }) async {
    _clearError();

    final student = getStudentById(studentId);
    if (student == null) {
      throw ArgumentError('Student not found');
    }

    final semester = student.getSemesterById(semesterId);
    if (semester == null) {
      throw ArgumentError('Semester not found');
    }

    final subject = semester.getSubjectById(subjectId);
    if (subject == null) {
      throw ArgumentError('Subject not found');
    }

    // Convert marks to GPA
    final gradePoint = GradeScaleService.marksToGpa(marks);

    // Update subject fields (Subject is mutable for Hive)
    // Create a new subject with updated values
    final index = semester.subjects.indexWhere((s) => s.id == subjectId);
    if (index != -1) {
      semester.subjects[index] = Subject(
        id: subjectId,
        courseCode: courseCode.trim().toUpperCase(),
        courseName: courseName.trim(),
        gradePoint: gradePoint,
        creditHours: creditHours,
        isTemporarilyRemoved: subject.isTemporarilyRemoved,
        removedFromSemesterId: subject.removedFromSemesterId,
        marks: marks,
      );
    }

    // Save to storage
    await _storageService.saveStudent(student);
    notifyListeners();
  }

  /// Updates a subject with direct GPA input
  Future<void> updateSubjectWithGpa({
    required String studentId,
    required String semesterId,
    required String subjectId,
    required String courseCode,
    required String courseName,
    required double gradePoint,
    required int creditHours,
    int? marks,
    bool hasGrade = true,
    Future<RemovalType?> Function(DuplicateCheckResult)? handleDuplicate,
  }) async {
    _clearError();

    final student = getStudentById(studentId);
    if (student == null) {
      throw ArgumentError('Student not found');
    }

    final semester = student.getSemesterById(semesterId);
    if (semester == null) {
      throw ArgumentError('Semester not found');
    }

    final subject = semester.getSubjectById(subjectId);
    if (subject == null) {
      throw ArgumentError('Subject not found');
    }

    // Validate GPA
    if (gradePoint < 0.0 || gradePoint > 4.0) {
      throw ArgumentError('GPA must be between 0.0 and 4.0');
    }

    // Check for duplicates if Code Changed
    // Or just always check (to be safe if they changed semesters order?)
    // But checking even if code same is redundant unless the duplicate is in *another* semester.
    // If code is same, duplicate check will find *itself*?
    // checkForDuplicate skips target semester. So it won't find itself.
    // So safe to call always.
    final duplicateCheck = SubjectReplacementService.checkForDuplicate(
      student,
      courseCode,
      semesterId,
      checkAllSemesters: true,
    );

    if (duplicateCheck.hasDuplicate && handleDuplicate != null) {
      final removalType = await handleDuplicate(duplicateCheck);

      if (removalType == null) {
        return; // Cancelled
      }

      if (removalType == RemovalType.temporary) {
        SubjectReplacementService.temporarilyRemoveSubject(
          student,
          duplicateCheck.existingSubject!,
          duplicateCheck.existingSemester!,
        );
      } else {
        SubjectReplacementService.permanentlyRemoveSubject(
          student,
          duplicateCheck.existingSubject!,
          duplicateCheck.existingSemester!,
        );
      }
    }

    final index = semester.subjects.indexWhere((s) => s.id == subjectId);
    if (index != -1) {
      semester.subjects[index] = Subject(
        id: subjectId,
        courseCode: courseCode.trim().toUpperCase(),
        courseName: courseName.trim(),
        gradePoint: gradePoint,
        creditHours: creditHours,
        isTemporarilyRemoved: subject.isTemporarilyRemoved,
        removedFromSemesterId: subject.removedFromSemesterId,
        hasGrade: hasGrade,
        marks: marks,
        isExcludedFromCalculations: false,
      );
    }

    await _storageService.saveStudent(student);
    notifyListeners();
  }
}
