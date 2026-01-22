/// Subject Replacement Service - Handles duplicate course detection and replacement
///
/// This service follows the Single Responsibility Principle (SRP) by
/// focusing solely on subject replacement logic. It handles:
/// - Detecting duplicate courses across semesters
/// - Temporary removal (hide but keep data)
/// - Permanent removal (delete data)
/// - Restoration of temporarily removed subjects
///
/// Key Business Rules:
/// - If a course code appears in a later semester, the earlier occurrence
///   should be removed (either temporarily or permanently)
/// - Only the latest occurrence counts toward CGPA
library;

import '../models/student.dart';
import '../models/subject.dart';
import '../models/semester.dart';

/// Represents the result of checking for a duplicate subject
class DuplicateCheckResult {
  /// Whether a duplicate was found
  final bool hasDuplicate;

  /// The existing subject that would be replaced (null if no duplicate)
  final Subject? existingSubject;

  /// The semester containing the existing subject (null if no duplicate)
  final Semester? existingSemester;

  const DuplicateCheckResult({
    required this.hasDuplicate,
    this.existingSubject,
    this.existingSemester,
  });

  /// Check if the duplicate subject is hidden/temporarily removed
  bool get isHidden => existingSubject?.isTemporarilyRemoved ?? false;

  /// Factory for when no duplicate is found
  factory DuplicateCheckResult.noDuplicate() {
    return const DuplicateCheckResult(hasDuplicate: false);
  }

  /// Factory for when a duplicate is found
  factory DuplicateCheckResult.duplicate({
    required Subject existingSubject,
    required Semester existingSemester,
  }) {
    return DuplicateCheckResult(
      hasDuplicate: true,
      existingSubject: existingSubject,
      existingSemester: existingSemester,
    );
  }
}

/// Enum representing the removal type options
enum RemovalType {
  /// Subject is hidden but data is kept for potential restoration
  temporary,

  /// Subject is permanently deleted from storage
  permanent,
}

/// Service for handling subject replacement logic
///
/// This is a utility class with static methods.
///
/// Example usage:
/// ```dart
/// final result = SubjectReplacementService.checkForDuplicate(
///   student,
///   'CS101',
///   currentSemesterId,
/// );
///
/// if (result.hasDuplicate) {
///   // Show dialog to user, then either:
///   SubjectReplacementService.temporarilyRemoveSubject(
///     student,
///     result.existingSubject!,
///     result.existingSemester!,
///   );
///   // OR
///   SubjectReplacementService.permanentlyRemoveSubject(
///     student,
///     result.existingSubject!,
///     result.existingSemester!,
///   );
/// }
/// ```
class SubjectReplacementService {
  // Private constructor to prevent instantiation
  SubjectReplacementService._();

  /// Checks if a course code already exists in an earlier semester
  ///
  /// Only checks semesters with a lower orderIndex than the target semester.
  /// Only checks active (not temporarily removed) subjects.
  ///
  /// [student] - The student to check
  /// [courseCode] - The course code to look for
  /// [targetSemesterId] - The semester where the new subject will be added
  ///
  /// Returns: DuplicateCheckResult indicating if duplicate found and its location
  static DuplicateCheckResult checkForDuplicate(
    Student student,
    String courseCode,
    String targetSemesterId, {
    bool checkAllSemesters = false,
  }) {
    // Find the target semester to get its order index
    final targetSemester = student.getSemesterById(targetSemesterId);
    if (targetSemester == null) {
      return DuplicateCheckResult.noDuplicate();
    }

    final normalizedCode = courseCode.toUpperCase().trim();

    // Check semesters based on flag
    for (final semester in student.semesters) {
      // If checking all, skip only the target semester itself
      if (checkAllSemesters) {
        if (semester.id == targetSemesterId) continue;
      } else {
        // Original behavior: Skip target and later semesters
        if (semester.orderIndex >= targetSemester.orderIndex) {
          continue;
        }
      }

      // Look for active subjects with matching course code
      for (final subject in semester.activeSubjects) {
        if (subject.courseCode.toUpperCase().trim() == normalizedCode) {
          return DuplicateCheckResult.duplicate(
            existingSubject: subject,
            existingSemester: semester,
          );
        }
      }
    }

    return DuplicateCheckResult.noDuplicate();
  }

  /// Temporarily removes a subject (hides but keeps data)
  ///
  /// The subject is marked as temporarily removed and can be restored later.
  /// The semester ID is stored for reference.
  ///
  /// [student] - The student whose subject to remove
  /// [subject] - The subject to temporarily remove
  /// [semester] - The semester containing the subject
  static void temporarilyRemoveSubject(
    Student student,
    Subject subject,
    Semester semester,
  ) {
    subject.isTemporarilyRemoved = true;
    subject.removedFromSemesterId = semester.id;
  }

  /// Permanently removes a subject from storage
  ///
  /// The subject is completely deleted and cannot be recovered.
  ///
  /// [student] - The student whose subject to remove
  /// [subject] - The subject to permanently remove
  /// [semester] - The semester containing the subject
  static void permanentlyRemoveSubject(
    Student student,
    Subject subject,
    Semester semester,
  ) {
    semester.removeSubject(subject.id);
  }

  /// Restores a temporarily removed subject
  ///
  /// Marks the subject as active again.
  ///
  /// [subject] - The subject to restore
  static void restoreSubject(Subject subject) {
    subject.isTemporarilyRemoved = false;
    subject.removedFromSemesterId = null;
    subject.isExcludedFromCalculations = true;
  }

  /// Gets all temporarily removed subjects for a student
  ///
  /// Returns a list of records containing the subject and its original semester.
  ///
  /// [student] - The student to check
  /// Returns: List of (subject, semester) pairs
  static List<({Subject subject, Semester semester})>
  getTemporarilyRemovedSubjects(Student student) {
    final results = <({Subject subject, Semester semester})>[];

    for (final semester in student.semesters) {
      for (final subject in semester.removedSubjects) {
        results.add((subject: subject, semester: semester));
      }
    }

    return results;
  }

  /// Restores all temporarily removed subjects for a student
  ///
  /// [student] - The student whose subjects to restore
  /// Returns: Number of subjects restored
  static int restoreAllTemporarilyRemoved(Student student) {
    int count = 0;

    for (final semester in student.semesters) {
      for (final subject in semester.removedSubjects) {
        restoreSubject(subject);
        count++;
      }
    }

    return count;
  }

  /// Checks if there are any temporarily removed subjects
  ///
  /// [student] - The student to check
  /// Returns: true if there are any temporarily removed subjects
  static bool hasTemporarilyRemovedSubjects(Student student) {
    for (final semester in student.semesters) {
      if (semester.removedSubjects.isNotEmpty) {
        return true;
      }
    }
    return false;
  }
}
