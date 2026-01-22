/// Student Model - Represents a student with their complete academic record
///
/// This model follows Single Responsibility Principle (SRP) by handling
/// only student-related data. CGPA calculation logic is delegated to
/// the GpaCalculatorService (Separation of Concerns).
///
/// Part of the Domain Layer in Clean Architecture.
library;

import 'package:hive/hive.dart';
import 'semester.dart';
import 'subject.dart';

part 'student.g.dart';

/// Hive Type ID for Student model
const int studentTypeId = 2;

/// Represents a student with their complete academic record
///
/// Example usage:
/// ```dart
/// final student = Student(
///   id: uuid.v4(),
///   fullName: 'John Doe',
///   semesters: [],
///   createdAt: DateTime.now(),
/// );
/// ```
@HiveType(typeId: studentTypeId)
class Student extends HiveObject {
  /// Unique identifier for this student (UUID format)
  @HiveField(0)
  final String id;

  /// Student's full name - used for identification
  @HiveField(1)
  String fullName;

  /// List of semesters for this student
  /// Ordered by orderIndex for proper semester sequencing
  @HiveField(2)
  List<Semester> semesters;

  /// Timestamp when this student record was created
  @HiveField(3)
  final DateTime createdAt;

  /// ID of the grade scale used for this student
  /// Allows students to retain their specific grading criteria
  @HiveField(4)
  final String? gradeScaleId;

  /// Program type (e.g., 'BS', 'MS') to separate student lists
  @HiveField(5)
  final String? programType;

  /// Creates a new Student instance
  ///
  /// [id] - Unique identifier (required)
  /// [fullName] - Student's full name (required)
  /// [semesters] - List of semesters (defaults to empty)
  /// [createdAt] - Creation timestamp (defaults to now)
  /// [gradeScaleId] - ID of the grading scale active for this student
  /// [programType] - Type of program the student belongs to
  Student({
    required this.id,
    required this.fullName,
    List<Semester>? semesters,
    DateTime? createdAt,
    this.gradeScaleId,
    this.programType,
  }) : semesters = semesters ?? [],
       createdAt = createdAt ?? DateTime.now();

  /// Returns semesters sorted by order index (earliest first)
  List<Semester> get sortedSemesters {
    final sorted = List<Semester>.from(semesters);
    sorted.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return sorted;
  }

  /// Returns the next available order index for new semesters
  int get nextSemesterIndex {
    if (semesters.isEmpty) return 0;
    return semesters.map((s) => s.orderIndex).reduce((a, b) => a > b ? a : b) +
        1;
  }

  /// Returns all active (not temporarily removed) subjects across all semesters
  List<Subject> get allActiveSubjects {
    return semesters.expand((semester) => semester.activeSubjects).toList();
  }

  /// Returns all temporarily removed subjects across all semesters
  List<Subject> get allRemovedSubjects {
    return semesters.expand((semester) => semester.removedSubjects).toList();
  }

  /// Returns total credit hours across all active subjects
  /// Note: This counts ALL active subjects, not just latest occurrences
  int get totalCreditHours {
    return semesters.fold(
      0,
      (sum, semester) => sum + semester.totalCreditHours,
    );
  }

  /// Gets a semester by its ID
  Semester? getSemesterById(String semesterId) {
    try {
      return semesters.firstWhere((s) => s.id == semesterId);
    } catch (e) {
      return null;
    }
  }

  /// Finds a subject across all semesters by course code
  /// Returns the subject and its semester, or null if not found
  ({Subject subject, Semester semester})? findSubjectByCourseCode(
    String courseCode, {
    String? excludeSemesterId,
  }) {
    for (final semester in sortedSemesters) {
      if (excludeSemesterId != null && semester.id == excludeSemesterId) {
        continue;
      }
      for (final subject in semester.subjects) {
        if (subject.courseCode.toUpperCase() == courseCode.toUpperCase() &&
            !subject.isTemporarilyRemoved) {
          return (subject: subject, semester: semester);
        }
      }
    }
    return null;
  }

  /// Finds all occurrences of a subject by course code across all semesters
  List<({Subject subject, Semester semester})> findAllSubjectsByCourseCode(
    String courseCode,
  ) {
    final results = <({Subject subject, Semester semester})>[];
    for (final semester in sortedSemesters) {
      for (final subject in semester.subjects) {
        if (subject.courseCode.toUpperCase() == courseCode.toUpperCase()) {
          results.add((subject: subject, semester: semester));
        }
      }
    }
    return results;
  }

  /// Adds a semester to this student
  void addSemester(Semester semester) {
    semesters.add(semester);
  }

  /// Removes a semester from this student
  void removeSemester(String semesterId) {
    semesters.removeWhere((s) => s.id == semesterId);
  }

  /// Creates a copy of this student with optional field overrides
  Student copyWith({
    String? id,
    String? fullName,
    List<Semester>? semesters,
    DateTime? createdAt,
    String? gradeScaleId,
    String? programType,
  }) {
    return Student(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      semesters: semesters ?? List.from(this.semesters),
      createdAt: createdAt ?? this.createdAt,
      gradeScaleId: gradeScaleId ?? this.gradeScaleId,
      programType: programType ?? this.programType,
    );
  }

  /// Equality comparison based on ID
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Student && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// String representation for debugging
  @override
  String toString() {
    return 'Student{id: $id, fullName: $fullName, '
        'semesters: ${semesters.length}, createdAt: $createdAt}';
  }
}
