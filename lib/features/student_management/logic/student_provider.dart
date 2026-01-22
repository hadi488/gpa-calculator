library;

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:cgpacalculator/data/models/student.dart';
import 'package:cgpacalculator/data/models/semester.dart';
import 'package:cgpacalculator/data/models/subject.dart';
import 'package:cgpacalculator/data/services/storage_service.dart';
import 'package:cgpacalculator/data/services/gpa_calculator_service.dart';
import 'package:cgpacalculator/data/services/subject_replacement_service.dart';
import 'package:cgpacalculator/data/services/grade_scale_service.dart';

import 'package:cgpacalculator/features/settings/logic/grade_scale_provider.dart';

part 'parts/student_actions.dart';
part 'parts/semester_actions.dart';
part 'parts/subject_add_actions.dart';
part 'parts/subject_update_actions.dart';
part 'parts/subject_misc_actions.dart';
part 'parts/restoration_actions.dart';
part 'parts/gpa_actions.dart';

/// UUID generator for creating unique IDs
const _uuid = Uuid();

/// Main state provider for the GPA Calculator app
class StudentProvider extends ChangeNotifier {
  /// Storage service for persistence (injected dependency)
  final StorageService _storageService;

  /// Grade Scale Provider (injected via ProxyProvider)
  GradeScaleProvider? _gradeScaleProvider;

  /// List of all students
  List<Student> _students = [];

  /// Currently selected student (for detail view)
  Student? _selectedStudent;

  /// Loading state flag
  bool _isLoading = false;

  /// Error message (null if no error)
  String? _errorMessage;

  /// Creates a new StudentProvider
  ///
  /// [storageService] - Injected storage service for data persistence
  StudentProvider({required StorageService storageService})
    : _storageService = storageService;

  /// Updates the Grade Scale Provider (called by ProxyProvider)
  void updateGradeScaleProvider(GradeScaleProvider gradeScaleProvider) {
    _gradeScaleProvider = gradeScaleProvider;
  }

  /// Helper to get current Grade Scale Provider
  GradeScaleProvider? get gradeScaleProvider => _gradeScaleProvider;

  // ============================================================
  // GETTERS - Expose state immutably
  // ============================================================

  /// All students (unmodifiable view)
  List<Student> get students => List.unmodifiable(_students);

  /// Currently selected student
  Student? get selectedStudent => _selectedStudent;

  /// Whether data is currently loading
  bool get isLoading => _isLoading;

  /// Current error message (null if no error)
  String? get errorMessage => _errorMessage;

  /// Whether there are any students
  bool get hasStudents => _students.isNotEmpty;

  // ============================================================
  // CORE OPERATIONS
  // ============================================================

  /// Loads all students from storage
  Future<void> loadStudents() async {
    _setLoading(true);
    _clearError();

    try {
      _students = await _storageService.getAllStudents();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load students: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Gets a student by ID
  Student? getStudentById(String studentId) {
    try {
      return _students.firstWhere((s) => s.id == studentId);
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // PRIVATE HELPERS
  // ============================================================

  /// Sets the loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Sets an error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clears any error message
  void _clearError() {
    _errorMessage = null;
  }

  /// Refreshes a student from storage
  Future<void> refreshStudent(String studentId) async {
    final freshStudent = await _storageService.getStudentById(studentId);
    if (freshStudent != null) {
      final index = _students.indexWhere((s) => s.id == studentId);
      if (index != -1) {
        _students[index] = freshStudent;
      }
      if (_selectedStudent?.id == studentId) {
        _selectedStudent = freshStudent;
      }
      notifyListeners();
    }
  }

  /// Retrieves the last selected credit hours
  Future<int> getLastSelectedCreditHours() {
    return _storageService.getLastSelectedCreditHours();
  }

  /// Saves the last selected credit hours
  Future<void> saveLastSelectedCreditHours(int credits) {
    return _storageService.saveLastSelectedCreditHours(credits);
  }

  /// Saves subject draft
  Future<void> saveSubjectDraft({
    required String courseCode,
    required String courseName,
    required String grade,
    required bool isMarksMode,
  }) {
    return _storageService.saveSubjectDraft(
      courseCode: courseCode,
      courseName: courseName,
      grade: grade,
      isMarksMode: isMarksMode,
    );
  }

  /// Retrieves subject draft
  Future<Map<String, dynamic>> getSubjectDraft() {
    return _storageService.getSubjectDraft();
  }

  /// Clears subject draft
  Future<void> clearSubjectDraft() {
    return _storageService.clearSubjectDraft();
  }
}
