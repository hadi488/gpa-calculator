/// Storage Service - Hive implementation of IStorageService
///
/// This service handles all persistent storage operations using Hive.
/// It implements IStorageService interface following Dependency Inversion
/// Principle (DIP).
///
/// Responsibilities (Single Responsibility Principle):
/// - Managing Hive boxes
/// - CRUD operations for Student data
/// - Data serialization/deserialization
library;

import 'package:hive_flutter/hive_flutter.dart';
import '../models/student.dart';
import 'i_storage_service.dart';

/// Hive box name constants
/// Using constants avoids magic strings and typos (DRY principle)
const String _studentsBoxName = 'students';
const String _settingsBoxName = 'settings';

/// Concrete implementation of IStorageService using Hive
///
/// Example usage:
/// ```dart
/// final storage = StorageService();
/// await storage.init();
/// await storage.saveStudent(student);
/// final students = await storage.getAllStudents();
/// ```
class StorageService implements IStorageService {
  /// Hive box for storing Student objects
  late Box<Student> _studentsBox;

  /// Hive box for storing settings
  late Box _settingsBox;

  /// Flag to track initialization state
  bool _isInitialized = false;

  /// Checks if the service has been initialized
  bool get isInitialized => _isInitialized;

  /// Initializes Hive and opens required boxes
  ///
  /// This must be called before any other operations.
  /// Safe to call multiple times - subsequent calls are no-ops.
  @override
  Future<void> init() async {
    if (_isInitialized) return;

    // Open the students box
    _studentsBox = await Hive.openBox<Student>(_studentsBoxName);

    // Open settings box
    _settingsBox = await Hive.openBox(_settingsBoxName);

    _isInitialized = true;
  }

  /// Ensures the service is initialized before operations
  ///
  /// Throws StateError if not initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('StorageService not initialized. Call init() first.');
    }
  }

  /// Retrieves all students from storage
  ///
  /// Returns list sorted by creation date (newest first)
  @override
  Future<List<Student>> getAllStudents() async {
    _ensureInitialized();

    final students = _studentsBox.values.toList();
    // Sort by creation date, newest first
    students.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return students;
  }

  /// Retrieves a specific student by ID
  @override
  Future<Student?> getStudentById(String id) async {
    _ensureInitialized();

    try {
      return _studentsBox.values.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Saves a student to storage
  ///
  /// Uses student.id as the key for efficient lookups and updates
  @override
  Future<void> saveStudent(Student student) async {
    _ensureInitialized();
    await _studentsBox.put(student.id, student);
  }

  /// Deletes a student from storage
  ///
  /// Returns true if the student existed and was deleted
  @override
  Future<bool> deleteStudent(String id) async {
    _ensureInitialized();

    if (_studentsBox.containsKey(id)) {
      await _studentsBox.delete(id);
      return true;
    }
    return false;
  }

  /// Closes all Hive boxes
  ///
  /// Call this when disposing the service or closing the app
  @override
  Future<void> close() async {
    if (_isInitialized) {
      await _studentsBox.close();
      await _settingsBox.close();
      _isInitialized = false;
    }
  }

  // ============================================================
  // SETTINGS OPERATIONS
  // ============================================================

  @override
  Future<int> getThemeMode() async {
    _ensureInitialized();
    // Default to 0 (System)
    return _settingsBox.get('themeMode', defaultValue: 0) as int;
  }

  @override
  Future<void> saveThemeMode(int mode) async {
    _ensureInitialized();
    await _settingsBox.put('themeMode', mode);
  }

  @override
  Future<int> getLastSelectedCreditHours() async {
    _ensureInitialized();
    // Default to 3 credit hours
    return _settingsBox.get('lastCreditHours', defaultValue: 3) as int;
  }

  @override
  Future<void> saveLastSelectedCreditHours(int credits) async {
    _ensureInitialized();
    await _settingsBox.put('lastCreditHours', credits);
  }

  @override
  Future<void> saveSubjectDraft({
    required String courseCode,
    required String courseName,
    required String grade,
    required bool isMarksMode,
  }) async {
    _ensureInitialized();
    await _settingsBox.put('draft_courseCode', courseCode);
    await _settingsBox.put('draft_courseName', courseName);
    await _settingsBox.put('draft_grade', grade);
    await _settingsBox.put('draft_isMarksMode', isMarksMode);
  }

  @override
  Future<Map<String, dynamic>> getSubjectDraft() async {
    _ensureInitialized();
    return {
      'courseCode': _settingsBox.get('draft_courseCode', defaultValue: ''),
      'courseName': _settingsBox.get('draft_courseName', defaultValue: ''),
      'grade': _settingsBox.get('draft_grade', defaultValue: ''),
      'isMarksMode': _settingsBox.get('draft_isMarksMode', defaultValue: true),
    };
  }

  @override
  Future<void> clearSubjectDraft() async {
    _ensureInitialized();
    await _settingsBox.delete('draft_courseCode');
    await _settingsBox.delete('draft_courseName');
    await _settingsBox.delete('draft_grade');
    await _settingsBox.delete('draft_isMarksMode');
  }

  /// Clears all data from storage
  ///
  /// WARNING: This permanently deletes all student data.
  /// Use with caution.
  Future<void> clearAll() async {
    _ensureInitialized();
    await _studentsBox.clear();
  }
}
