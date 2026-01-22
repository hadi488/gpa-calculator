/// Subject Model - Represents a single course/subject in a semester
///
/// This model follows the Single Responsibility Principle (SRP) by handling
/// only subject-related data and operations. It is immutable by design,
/// promoting safer state management.
///
/// Part of the Domain Layer in Clean Architecture.
library;

import 'package:hive/hive.dart';

part 'subject.g.dart';

/// Hive Type ID for Subject model
/// Using constants for type IDs ensures consistency and avoids magic numbers
const int subjectTypeId = 0;

/// Represents a single course/subject in a semester
///
/// Example usage:
/// ```dart
/// final subject = Subject(
///   courseCode: 'CS101',
///   courseName: 'Introduction to Computer Science',
///   gradePoint: 3.7,
///   creditHours: 3,
/// );
/// ```
@HiveType(typeId: subjectTypeId)
class Subject extends HiveObject {
  /// Unique identifier for this subject (UUID format)
  @HiveField(0)
  final String id;

  /// Course code identifier (e.g., "CS101", "MATH201")
  /// Used to detect duplicate courses across semesters
  @HiveField(1)
  final String courseCode;

  /// Full name of the course
  @HiveField(2)
  final String courseName;

  /// Grade point achieved (typically 0.0 - 4.0 scale)
  /// Used in GPA/CGPA calculations
  @HiveField(3)
  final double gradePoint;

  /// Credit hours/weight of this course
  /// Used as weight in GPA/CGPA weighted average calculations
  @HiveField(4)
  final int creditHours;

  /// Flag indicating if this subject was temporarily removed
  /// due to being replaced by a newer occurrence
  @HiveField(5)
  bool isTemporarilyRemoved;

  /// ID of the semester from which this subject was removed
  /// (stored for restoration purposes)
  @HiveField(6)
  String? removedFromSemesterId;

  /// Flag indicating if a grade was entered for this subject
  /// If false, this subject will NOT be counted in GPA calculation
  /// but will still be displayed (shown as "Pending" or similar)
  @HiveField(7)
  final bool hasGrade;

  /// Raw marks (0-100) if entered
  /// Optional because user might enter direct GPA
  @HiveField(8)
  final int? marks;

  /// Flag indicating if this subject is excluded from GPA calculations
  /// (e.g., when restored after being repeated)
  @HiveField(9)
  bool isExcludedFromCalculations;

  /// Creates a new Subject instance
  ///
  /// [id] - Unique identifier (auto-generated if not provided)
  /// [courseCode] - Course code (required, used for duplicate detection)
  /// [courseName] - Full course name (required)
  /// [gradePoint] - Grade achieved (required, 0.0 - 4.0)
  /// [creditHours] - Credit weight (required, typically 1-6)
  /// [isTemporarilyRemoved] - Whether subject is temporarily hidden
  /// [removedFromSemesterId] - Original semester ID if removed
  /// [hasGrade] - Whether a grade was entered (default true for backward compat)
  /// [marks] - Raw marks obtained (optional)
  /// [isExcludedFromCalculations] - Whether excluded from GPA (default false)
  Subject({
    required this.id,
    required this.courseCode,
    required this.courseName,
    required this.gradePoint,
    required this.creditHours,
    this.isTemporarilyRemoved = false,
    this.removedFromSemesterId,
    this.hasGrade = true,
    this.marks,
    this.isExcludedFromCalculations = false,
  });

  /// Creates a copy of this subject with optional field overrides
  ///
  /// Follows immutability pattern - instead of modifying the object,
  /// create a new one with the desired changes (DRY principle)
  Subject copyWith({
    String? id,
    String? courseCode,
    String? courseName,
    double? gradePoint,
    int? creditHours,
    bool? isTemporarilyRemoved,
    String? removedFromSemesterId,
    bool? hasGrade,
    int? marks,
    bool? isExcludedFromCalculations,
  }) {
    return Subject(
      id: id ?? this.id,
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
      gradePoint: gradePoint ?? this.gradePoint,
      creditHours: creditHours ?? this.creditHours,
      isTemporarilyRemoved: isTemporarilyRemoved ?? this.isTemporarilyRemoved,
      removedFromSemesterId:
          removedFromSemesterId ?? this.removedFromSemesterId,
      hasGrade: hasGrade ?? this.hasGrade,
      marks: marks ?? this.marks,
      isExcludedFromCalculations:
          isExcludedFromCalculations ?? this.isExcludedFromCalculations,
    );
  }

  /// Calculates quality points for this subject
  /// Quality Points = Grade Point × Credit Hours
  /// Returns 0 if no grade was entered OR if excluded from calculations
  double get qualityPoints =>
      (hasGrade && !isExcludedFromCalculations) ? gradePoint * creditHours : 0;

  /// Returns effective credit hours for GPA calculation
  /// Returns 0 if no grade was entered OR if excluded from calculations (doesn't count toward GPA)
  int get effectiveCreditHours =>
      (hasGrade && !isExcludedFromCalculations) ? creditHours : 0;

  /// Equality comparison based on ID
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subject && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// String representation for debugging
  @override
  String toString() {
    return 'Subject{id: $id, courseCode: $courseCode, courseName: $courseName, '
        'gradePoint: $gradePoint, creditHours: $creditHours, '
        'hasGrade: $hasGrade, isTemporarilyRemoved: $isTemporarilyRemoved}';
  }
}
