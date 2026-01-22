/// Storage Service Interface - Abstract contract for storage operations
///
/// This interface follows the Dependency Inversion Principle (DIP) by
/// defining an abstraction that high-level modules can depend on,
/// rather than depending on concrete implementations.
///
/// Benefits:
/// - Easy to swap storage implementations (e.g., Hive to SQLite)
/// - Facilitates unit testing with mock implementations
/// - Decouples business logic from storage details
library;

import '../models/student.dart';

/// Abstract interface for storage operations
///
/// Implementations must provide methods for CRUD operations on Student data.
/// This follows the Interface Segregation Principle (ISP) by keeping
/// the interface focused on student-related storage operations.
abstract class IStorageService {
  /// Initializes the storage system
  ///
  /// Must be called before any other operations.
  /// Returns a Future that completes when initialization is done.
  Future<void> init();

  /// Retrieves all students from storage
  ///
  /// Returns an empty list if no students exist.
  Future<List<Student>> getAllStudents();

  /// Retrieves a specific student by ID
  ///
  /// Returns null if student is not found.
  Future<Student?> getStudentById(String id);

  /// Saves a student to storage (create or update)
  ///
  /// If a student with the same ID exists, it will be updated.
  /// Otherwise, a new student will be created.
  Future<void> saveStudent(Student student);

  /// Deletes a student from storage permanently
  ///
  /// Returns true if deletion was successful, false otherwise.
  Future<bool> deleteStudent(String id);

  /// Retrieves the saved theme mode preference
  ///
  /// Returns 0 for System, 1 for Light, 2 for Dark
  Future<int> getThemeMode();

  /// Saves the theme mode preference
  ///
  /// [mode] - 0 for System, 1 for Light, 2 for Dark
  Future<void> saveThemeMode(int mode);

  /// Retrieves the last selected credit hours (default: 3)
  Future<int> getLastSelectedCreditHours();

  /// Saves the last selected credit hours
  Future<void> saveLastSelectedCreditHours(int credits);

  /// Saves a draft of the subject being added (for persistence across cancels)
  Future<void> saveSubjectDraft({
    required String courseCode,
    required String courseName,
    required String grade,
    required bool isMarksMode,
  });

  /// Retrieves the saved subject draft
  /// Returns a map with keys: 'courseCode', 'courseName', 'grade', 'isMarksMode'
  Future<Map<String, dynamic>> getSubjectDraft();

  /// Clears the saved subject draft
  Future<void> clearSubjectDraft();

  /// Closes the storage connection
  ///
  /// Should be called when the app is closing to ensure data integrity.
  Future<void> close();
}
