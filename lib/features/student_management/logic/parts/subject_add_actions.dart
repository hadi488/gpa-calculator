// ignore_for_file: invalid_use_of_protected_member
part of '../student_provider.dart';

extension SubjectAddActions on StudentProvider {
  /// Adds a subject to a semester
  ///
  ///Returns: The created Subject, or null if cancelled
  Future<Subject?> addSubject({
    required String studentId,
    required String semesterId,
    required String courseCode,
    required String courseName,
    required int marks,
    required int creditHours,
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

    // Validate inputs
    if (courseCode.trim().isEmpty) {
      throw ArgumentError('Course code cannot be empty');
    }

    if (!GradeScaleService.isValidMarks(marks)) {
      throw ArgumentError('Marks must be between 0 and 100');
    }
    if (creditHours < 1 || creditHours > 6) {
      throw ArgumentError('Credit hours must be between 1 and 6');
    }

    // Check for same-semester duplicates
    if (semester.hasSubjectWithCode(courseCode.trim())) {
      throw ArgumentError(
        'Subject with code ${courseCode.trim()} already exists in this semester',
      );
    }

    // Check for HIDDEN duplicates in same semester
    // Warn user to restore instead of adding new
    if (semester.subjects.any(
      (s) =>
          s.isTemporarilyRemoved &&
          s.courseCode.toUpperCase() == courseCode.trim().toUpperCase(),
    )) {
      throw ArgumentError(
        'Subject ${courseCode.trim()} is hidden in this semester. Restore it from options.',
      );
    }

    // Check for duplicates in earlier semesters
    final duplicateCheck = SubjectReplacementService.checkForDuplicate(
      student,
      courseCode,
      semesterId,
      checkAllSemesters: true,
    );

    if (duplicateCheck.hasDuplicate && handleDuplicate != null) {
      // Ask user how to handle the duplicate
      final removalType = await handleDuplicate(duplicateCheck);

      if (removalType == null) {
        // User cancelled
        return null;
      }

      // Handle the duplicate based on user's choice
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

    // Convert marks to GPA
    final gradePoint = GradeScaleService.marksToGpa(marks);

    // Create the subject
    final subject = Subject(
      id: _uuid.v4(),
      courseCode: courseCode.trim().toUpperCase(),
      courseName: courseName.trim(),
      gradePoint: gradePoint,
      creditHours: creditHours,
      marks: marks,
    );

    // Add to semester
    semester.addSubject(subject);

    // Save to storage
    await _storageService.saveStudent(student);
    notifyListeners();

    return subject;
  }

  /// Adds a subject with direct GPA input
  Future<Subject?> addSubjectWithGpa({
    required String studentId,
    required String semesterId,
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

    // Validate inputs
    if (courseCode.trim().isEmpty) {
      throw ArgumentError('Course code cannot be empty');
    }
    if (gradePoint < 0.0 || gradePoint > 4.0) {
      throw ArgumentError('GPA must be between 0.0 and 4.0');
    }
    if (creditHours < 1 || creditHours > 6) {
      throw ArgumentError('Credit hours must be between 1 and 6');
    }

    // Check for same-semester duplicates
    if (semester.hasSubjectWithCode(courseCode.trim())) {
      throw ArgumentError(
        'Subject with code ${courseCode.trim()} already exists in this semester',
      );
    }

    // Check for HIDDEN duplicates in same semester
    // Warn user to restore instead of adding new
    if (semester.subjects.any(
      (s) =>
          s.isTemporarilyRemoved &&
          s.courseCode.toUpperCase() == courseCode.trim().toUpperCase(),
    )) {
      throw ArgumentError(
        'Subject ${courseCode.trim()} is hidden in this semester. Restore it from options.',
      );
    }

    // Check for duplicates in earlier semesters
    final duplicateCheck = SubjectReplacementService.checkForDuplicate(
      student,
      courseCode,
      semesterId,
      checkAllSemesters: true,
    );

    if (duplicateCheck.hasDuplicate && handleDuplicate != null) {
      final removalType = await handleDuplicate(duplicateCheck);

      if (removalType == null) {
        return null;
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

    // Create the subject with direct GPA
    final subject = Subject(
      id: _uuid.v4(),
      courseCode: courseCode.trim().toUpperCase(),
      courseName: courseName.trim(),
      gradePoint: gradePoint,
      creditHours: creditHours,
      hasGrade: hasGrade,
      marks: marks,
    );

    semester.addSubject(subject);

    await _storageService.saveStudent(student);
    notifyListeners();

    return subject;
  }
}
