// ignore_for_file: invalid_use_of_protected_member
part of '../student_provider.dart';

extension StudentActions on StudentProvider {
  // ============================================================
  // STUDENT OPERATIONS
  // ============================================================

  /// Adds a new student
  ///
  /// [fullName] - The student's full name
  /// Returns: The created Student object
  /// Throws: Exception if name is empty or duplicate
  Future<Student> addStudent(String fullName, {String? programType}) async {
    _clearError();

    // Validate name
    final trimmedName = fullName.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Student name cannot be empty');
    }

    // Check for duplicate name
    if (_students.any(
      (s) => s.fullName.toLowerCase() == trimmedName.toLowerCase(),
    )) {
      throw ArgumentError('A student with this name already exists');
    }

    // Create new student
    final student = Student(
      id: _uuid.v4(),
      fullName: trimmedName,
      createdAt: DateTime.now(),
      // Capture current grade scale ID at creation time
      gradeScaleId: _gradeScaleProvider?.currentScaleId,
      programType: programType,
    );

    // Save to storage
    await _storageService.saveStudent(student);

    // Update local state
    _students.insert(0, student); // Add to beginning of list
    notifyListeners();

    return student;
  }

  /// Updates an existing student
  ///
  /// [student] - The student to update
  Future<void> updateStudent(Student student) async {
    _clearError();

    await _storageService.saveStudent(student);

    // Update local state
    final index = _students.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      _students[index] = student;
    }

    // Update selected student if it's the same one
    if (_selectedStudent?.id == student.id) {
      _selectedStudent = student;
    }

    notifyListeners();
  }

  /// Deletes a student permanently
  ///
  /// [studentId] - ID of the student to delete
  Future<void> deleteStudent(String studentId) async {
    _clearError();

    await _storageService.deleteStudent(studentId);

    // Update local state
    _students.removeWhere((s) => s.id == studentId);

    // Clear selected student if deleted
    if (_selectedStudent?.id == studentId) {
      _selectedStudent = null;
    }

    notifyListeners();
  }

  /// Restores a deleted student
  ///
  /// [student] - The student object to restore
  Future<void> restoreStudent(Student student) async {
    _clearError();

    await _storageService.saveStudent(student);

    // Add back to local state (at the beginning properly or sort later)
    // For now, adding to top is fine as standard behavior
    _students.insert(0, student);

    notifyListeners();
  }

  /// Selects a student for viewing details
  ///
  /// [student] - The student to select (null to deselect)
  void selectStudent(Student? student) {
    _selectedStudent = student;
    notifyListeners();
  }
}
