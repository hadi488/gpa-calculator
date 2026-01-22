/// Semester Model - Represents a semester containing multiple subjects
///
/// This model follows Single Responsibility Principle (SRP) by handling
/// only semester-related data and computed properties. The GPA calculation
/// logic is delegated to a separate service (Separation of Concerns).
///
/// Part of the Domain Layer in Clean Architecture.
library;

import 'package:hive/hive.dart';
import 'subject.dart';

part 'semester.g.dart';

/// Hive Type ID for Semester model
const int semesterTypeId = 1;

/// Represents a semester containing multiple subjects
///
/// Example usage:
/// ```dart
/// final semester = Semester(
///   id: uuid.v4(),
///   name: 'Fall 2024',
///   subjects: [],
///   orderIndex: 0,
/// );
/// ```
@HiveType(typeId: semesterTypeId)
class Semester extends HiveObject {
  /// Unique identifier for this semester (UUID format)
  @HiveField(0)
  final String id;

  /// Display name of the semester (e.g., "Fall 2024", "Semester 1")
  @HiveField(1)
  String name;

  /// List of subjects in this semester
  /// Stored as HiveList for efficient relationship management
  @HiveField(2)
  List<Subject> subjects;

  /// Order index for maintaining semester sequence
  /// Lower index = earlier semester
  @HiveField(3)
  int orderIndex;

  /// Creates a new Semester instance
  ///
  /// [id] - Unique identifier (required)
  /// [name] - Display name (required)
  /// [subjects] - List of subjects (defaults to empty)
  /// [orderIndex] - Position in semester list (defaults to 0)
  Semester({
    required this.id,
    required this.name,
    List<Subject>? subjects,
    this.orderIndex = 0,
  }) : subjects = subjects ?? [];

  /// Returns only active (not temporarily removed) subjects
  ///
  /// Used for GPA calculations - temporarily removed subjects
  /// should not count toward semester GPA
  List<Subject> get activeSubjects =>
      subjects.where((s) => !s.isTemporarilyRemoved).toList();

  /// Returns temporarily removed subjects
  ///
  /// Used for the restore functionality UI
  List<Subject> get removedSubjects =>
      subjects.where((s) => s.isTemporarilyRemoved).toList();

  /// Calculates total credit hours for active subjects (for display)
  /// Excludes subjects that are restored/hidden from calculations
  int get totalCreditHours => activeSubjects.fold(
    0,
    (sum, subject) =>
        sum + (subject.isExcludedFromCalculations ? 0 : subject.creditHours),
  );

  /// Returns count of valid subjects (excluding restored ones)
  int get validSubjectsCount =>
      activeSubjects.where((s) => !s.isExcludedFromCalculations).length;

  /// Calculates effective credit hours (only subjects WITH grades count)
  int get effectiveCreditHours => activeSubjects.fold(
    0,
    (sum, subject) => sum + subject.effectiveCreditHours,
  );

  /// Returns only subjects that have grades entered
  List<Subject> get subjectsWithGrade =>
      activeSubjects.where((s) => s.hasGrade).toList();

  /// Returns subjects without grades (shown but not counted)
  List<Subject> get subjectsWithoutGrade =>
      activeSubjects.where((s) => !s.hasGrade).toList();

  /// Calculates total quality points for active subjects WITH grades
  /// Quality Points = Σ(gradePoint × creditHours)
  double get totalQualityPoints =>
      activeSubjects.fold(0.0, (sum, subject) => sum + subject.qualityPoints);

  /// Calculates GPA for this semester
  ///
  /// Formula: GPA = Total Quality Points / Effective Credit Hours
  /// Only subjects with grades are included in calculation
  /// Returns 0.0 if no effective credit hours to avoid division by zero
  double get gpa {
    if (effectiveCreditHours == 0) return 0.0;
    return totalQualityPoints / effectiveCreditHours;
  }

  /// Checks if a subject with the given course code exists in this semester
  bool hasSubjectWithCode(String courseCode) {
    return subjects.any(
      (s) =>
          s.courseCode.toUpperCase() == courseCode.toUpperCase() &&
          !s.isTemporarilyRemoved,
    );
  }

  /// Gets a subject by its ID
  Subject? getSubjectById(String subjectId) {
    try {
      return subjects.firstWhere((s) => s.id == subjectId);
    } catch (e) {
      return null;
    }
  }

  /// Adds a subject to this semester
  void addSubject(Subject subject) {
    subjects.add(subject);
  }

  /// Removes a subject from this semester
  void removeSubject(String subjectId) {
    subjects.removeWhere((s) => s.id == subjectId);
  }

  /// Creates a copy of this semester with optional field overrides
  Semester copyWith({
    String? id,
    String? name,
    List<Subject>? subjects,
    int? orderIndex,
  }) {
    return Semester(
      id: id ?? this.id,
      name: name ?? this.name,
      subjects: subjects ?? List.from(this.subjects),
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  /// Equality comparison based on ID
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Semester && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// String representation for debugging
  @override
  String toString() {
    return 'Semester{id: $id, name: $name, subjects: ${subjects.length}, '
        'orderIndex: $orderIndex, gpa: ${gpa.toStringAsFixed(2)}}';
  }
}
