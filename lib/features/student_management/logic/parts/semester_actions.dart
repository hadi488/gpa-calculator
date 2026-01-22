// ignore_for_file: invalid_use_of_protected_member
part of '../student_provider.dart';

extension SemesterActions on StudentProvider {
  // ============================================================
  // SEMESTER OPERATIONS
  // ============================================================

  /// Adds a new semester to a student
  ///
  /// [studentId] - ID of the student
  /// [semesterName] - Name of the semester
  /// Returns: The created Semester object
  Future<Semester> addSemester(String studentId, String semesterName) async {
    _clearError();

    final student = getStudentById(studentId);
    if (student == null) {
      throw ArgumentError('Student not found');
    }

    final trimmedName = semesterName.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Semester name cannot be empty');
    }

    // Create new semester with next order index
    final semester = Semester(
      id: _uuid.v4(),
      name: trimmedName,
      orderIndex: student.nextSemesterIndex,
    );

    // Add to student
    student.addSemester(semester);

    // Save to storage
    await _storageService.saveStudent(student);
    notifyListeners();

    return semester;
  }

  /// Updates a semester
  ///
  /// [studentId] - ID of the student
  /// [semester] - The semester to update
  Future<void> updateSemester(String studentId, Semester semester) async {
    _clearError();

    final student = getStudentById(studentId);
    if (student == null) {
      throw ArgumentError('Student not found');
    }

    // Find and update the semester
    final index = student.semesters.indexWhere((s) => s.id == semester.id);
    if (index != -1) {
      student.semesters[index] = semester;
      await _storageService.saveStudent(student);
      notifyListeners();
    }
  }

  /// Deletes a semester
  ///
  /// [studentId] - ID of the student
  /// [semesterId] - ID of the semester to delete
  Future<void> deleteSemester(String studentId, String semesterId) async {
    _clearError();

    final student = getStudentById(studentId);
    if (student == null) {
      throw ArgumentError('Student not found');
    }

    student.removeSemester(semesterId);
    await _storageService.saveStudent(student);
    notifyListeners();
  }
}
