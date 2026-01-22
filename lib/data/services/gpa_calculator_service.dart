/// GPA Calculator Service - Handles all GPA and CGPA calculations
///
/// This service follows the Single Responsibility Principle (SRP) by
/// focusing solely on GPA/CGPA calculation logic. It is stateless,
/// making it easy to test and reuse.
///
/// Key Design Decisions:
/// - All methods are static for stateless utility access
/// - CGPA uses only the LATEST occurrence of each course
/// - Temporarily removed subjects are excluded from calculations
library;

import '../models/student.dart';
import '../models/semester.dart';
import '../models/subject.dart';

/// Service for calculating GPA and CGPA
///
/// This is a utility class with static methods following the
/// functional programming paradigm for calculations.
///
/// Example usage:
/// ```dart
/// final gpa = GpaCalculatorService.calculateSemesterGpa(semester);
/// final cgpa = GpaCalculatorService.calculateCgpa(student);
/// ```
class GpaCalculatorService {
  // Private constructor to prevent instantiation (utility class pattern)
  GpaCalculatorService._();

  /// Calculates GPA for a single semester
  ///
  /// Formula: GPA = Σ(gradePoint × creditHours) / Σ(creditHours)
  ///
  /// Only includes active subjects (not temporarily removed).
  /// Returns 0.0 if there are no subjects or no credit hours.
  ///
  /// [semester] - The semester to calculate GPA for
  /// Returns: GPA as a double (0.0 - 4.0 scale)
  static double calculateSemesterGpa(Semester semester) {
    final activeSubjects = semester.activeSubjects;

    if (activeSubjects.isEmpty) return 0.0;

    final totalCreditHours = activeSubjects.fold<int>(
      0,
      (sum, subject) => sum + subject.effectiveCreditHours,
    );

    if (totalCreditHours == 0) return 0.0;

    final totalQualityPoints = activeSubjects.fold<double>(
      0.0,
      (sum, subject) => sum + subject.qualityPoints,
    );

    return totalQualityPoints / totalCreditHours;
  }

  /// Calculates CGPA for a student using the latest occurrence rule
  ///
  /// IMPORTANT: If a course appears in multiple semesters,
  /// only the LATEST occurrence (highest semester orderIndex)
  /// is counted toward CGPA.
  ///
  /// Formula: CGPA = Σ(gradePoint × creditHours) / Σ(creditHours)
  /// (using only latest occurrences of each course)
  ///
  /// [student] - The student to calculate CGPA for
  /// Returns: CGPA as a double (0.0 - 4.0 scale)
  static double calculateCgpa(Student student) {
    // Get only the latest occurrence of each subject
    final latestSubjects = getLatestSubjectOccurrences(student);

    if (latestSubjects.isEmpty) return 0.0;

    final totalCreditHours = latestSubjects.fold<int>(
      0,
      (sum, subject) => sum + subject.effectiveCreditHours,
    );

    if (totalCreditHours == 0) return 0.0;

    final totalQualityPoints = latestSubjects.fold<double>(
      0.0,
      (sum, subject) => sum + subject.qualityPoints,
    );

    return totalQualityPoints / totalCreditHours;
  }

  /// Gets only the latest occurrence of each subject across all semesters
  ///
  /// This is the core logic for the "latest occurrence rule":
  /// - Groups subjects by course code
  /// - Keeps only the subject from the semester with the highest orderIndex
  /// - Excludes temporarily removed subjects
  ///
  /// [student] - The student whose subjects to analyze
  /// Returns: List of subjects (one per course code)
  static List<Subject> getLatestSubjectOccurrences(Student student) {
    // Map to store the latest occurrence of each course code
    // Key: courseCode (uppercase for case-insensitive matching)
    // Value: (subject, semesterOrderIndex)
    final latestOccurrences = <String, ({Subject subject, int orderIndex})>{};

    // Iterate through semesters to find latest occurrences
    for (final semester in student.semesters) {
      // Look for active subjects with matching course code
      for (final subject in semester.activeSubjects) {
        // Skip excluded subjects (they are for display only and shouldn't satisfy "latest" rule)
        // This ensures a valid earlier grade counts if the latest attempt is restored/excluded
        if (subject.isExcludedFromCalculations) continue;

        final courseCodeKey = subject.courseCode.toUpperCase();

        // Check if this is a newer occurrence
        if (!latestOccurrences.containsKey(courseCodeKey) ||
            semester.orderIndex >
                latestOccurrences[courseCodeKey]!.orderIndex) {
          latestOccurrences[courseCodeKey] = (
            subject: subject,
            orderIndex: semester.orderIndex,
          );
        }
      }
    }

    // Extract just the subjects from the map
    return latestOccurrences.values.map((e) => e.subject).toList();
  }

  /// Calculates the total credit hours for CGPA calculation
  ///
  /// Only counts latest occurrences of each course.
  ///
  /// [student] - The student to calculate for
  /// Returns: Total credit hours
  static int calculateTotalCreditHours(Student student) {
    final latestSubjects = getLatestSubjectOccurrences(student);
    return latestSubjects.fold<int>(
      0,
      (sum, subject) => sum + subject.effectiveCreditHours,
    );
  }

  /// Calculates the total quality points for CGPA calculation
  ///
  /// Only counts latest occurrences of each course.
  ///
  /// [student] - The student to calculate for
  /// Returns: Total quality points
  static double calculateTotalQualityPoints(Student student) {
    final latestSubjects = getLatestSubjectOccurrences(student);
    return latestSubjects.fold<double>(
      0.0,
      (sum, subject) => sum + subject.qualityPoints,
    );
  }

  /// Formats a GPA/CGPA value for display
  ///
  /// Returns the value formatted to 2 decimal places.
  ///
  /// [value] - The GPA/CGPA value to format
  /// Returns: Formatted string (e.g., "3.75")
  static String formatGpa(double value) {
    return value.toStringAsFixed(2);
  }

  /// Gets the letter grade for a grade point value
  ///
  /// Based on standard 4.0 scale:
  /// - 4.0: A
  /// - 3.7: A-
  /// - 3.3: B+
  /// - 3.0: B
  /// - etc.
  ///
  /// [gradePoint] - The grade point value
  /// Returns: Letter grade string
  static String getLetterGrade(double gradePoint) {
    if (gradePoint >= 4.0) return 'A';
    if (gradePoint >= 3.7) return 'A-';
    if (gradePoint >= 3.3) return 'B+';
    if (gradePoint >= 3.0) return 'B';
    if (gradePoint >= 2.7) return 'B-';
    if (gradePoint >= 2.3) return 'C+';
    if (gradePoint >= 2.0) return 'C';
    if (gradePoint >= 1.7) return 'C-';
    if (gradePoint >= 1.3) return 'D+';
    if (gradePoint >= 1.0) return 'D';
    return 'F';
  }

  /// Gets the color associated with a GPA value for UI display
  ///
  /// Returns a color code based on GPA performance:
  /// - Green: 3.5+ (Excellent)
  /// - Blue: 3.0-3.49 (Good)
  /// - Orange: 2.5-2.99 (Average)
  /// - Red: Below 2.5 (Needs Improvement)
  ///
  /// [gpa] - The GPA value
  /// Returns: Color code as int (for use with Color class)
  static int getGpaColorCode(double gpa) {
    if (gpa >= 3.5) return 0xFF4CAF50; // Green
    if (gpa >= 3.0) return 0xFF2196F3; // Blue
    if (gpa >= 2.5) return 0xFFFF9800; // Orange
    return 0xFFF44336; // Red
  }
}
