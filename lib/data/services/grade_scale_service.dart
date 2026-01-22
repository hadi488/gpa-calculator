/// Grade Scale Service - Handles marks to GPA conversion
///
/// This service follows the Single Responsibility Principle (SRP) by
/// focusing solely on grade scale conversions.
///
/// Grade Scale (as specified):
/// - 85-100: 4.00 (A)
/// - 80-84:  3.66 (A-)
/// - 75-79:  3.33 (B+)
/// - 71-74:  3.00 (B)
/// - 68-70:  2.66 (B-)
/// - 64-67:  2.33 (C+)
/// - 61-63:  2.00 (C)
/// - 58-60:  1.66 (C-)
/// - 54-57:  1.33 (D+)
/// - 50-53:  1.00 (D)
/// - 0-49:   0.00 (F)
///
/// Rounding Rule: If decimal digit >= 5, round up; otherwise keep as is
library;

/// Represents a grade with its associated marks range, GPA, and letter
class GradeInfo {
  final int minMarks;
  final int maxMarks;
  final double gradePoint;
  final String letterGrade;
  final String description;

  const GradeInfo({
    required this.minMarks,
    required this.maxMarks,
    required this.gradePoint,
    required this.letterGrade,
    this.description = '',
  });

  /// Checks if the given marks fall within this grade range
  bool containsMarks(int marks) => marks >= minMarks && marks <= maxMarks;

  @override
  String toString() => '$letterGrade ($minMarks-$maxMarks) = $gradePoint';
}

/// Service for grade scale conversions
///
/// Example usage:
/// ```dart
/// final gpa = GradeScaleService.marksToGpa(87); // Returns 4.00
/// final letter = GradeScaleService.marksToLetterGrade(87); // Returns 'A'
/// ```
class GradeScaleService {
  // Private constructor to prevent instantiation
  GradeScaleService._();

  /// The complete grade scale definition
  /// Ordered from highest to lowest for efficient lookup
  static const List<GradeInfo> gradeScale = [
    GradeInfo(
      minMarks: 85,
      maxMarks: 100,
      gradePoint: 4.00,
      letterGrade: 'A',
      description: 'Excellent',
    ),
    GradeInfo(
      minMarks: 80,
      maxMarks: 84,
      gradePoint: 3.66,
      letterGrade: 'A-',
      description: 'Very Good',
    ),
    GradeInfo(
      minMarks: 75,
      maxMarks: 79,
      gradePoint: 3.33,
      letterGrade: 'B+',
      description: 'Good',
    ),
    GradeInfo(
      minMarks: 71,
      maxMarks: 74,
      gradePoint: 3.00,
      letterGrade: 'B',
      description: 'Above Average',
    ),
    GradeInfo(
      minMarks: 68,
      maxMarks: 70,
      gradePoint: 2.66,
      letterGrade: 'B-',
      description: 'Average',
    ),
    GradeInfo(
      minMarks: 64,
      maxMarks: 67,
      gradePoint: 2.33,
      letterGrade: 'C+',
      description: 'Satisfactory',
    ),
    GradeInfo(
      minMarks: 61,
      maxMarks: 63,
      gradePoint: 2.00,
      letterGrade: 'C',
      description: 'Pass',
    ),
    GradeInfo(
      minMarks: 58,
      maxMarks: 60,
      gradePoint: 1.66,
      letterGrade: 'C-',
      description: 'Below Average',
    ),
    GradeInfo(
      minMarks: 54,
      maxMarks: 57,
      gradePoint: 1.33,
      letterGrade: 'D+',
      description: 'Poor',
    ),
    GradeInfo(
      minMarks: 50,
      maxMarks: 53,
      gradePoint: 1.00,
      letterGrade: 'D',
      description: 'Minimum Pass',
    ),
    GradeInfo(
      minMarks: 0,
      maxMarks: 49,
      gradePoint: 0.00,
      letterGrade: 'F',
      description: 'Fail',
    ),
  ];

  /// Converts marks (0-100) to grade point
  ///
  /// [marks] - The marks obtained (0 to 100)
  /// Returns: Corresponding grade point
  /// Throws: ArgumentError if marks is out of range
  static double marksToGpa(int marks) {
    if (marks < 0 || marks > 100) {
      throw ArgumentError('Marks must be between 0 and 100, got: $marks');
    }

    for (final grade in gradeScale) {
      if (grade.containsMarks(marks)) {
        return grade.gradePoint;
      }
    }

    // Should never reach here, but return 0 as fallback
    return 0.0;
  }

  /// Converts marks to letter grade
  ///
  /// [marks] - The marks obtained (0 to 100)
  /// Returns: Letter grade (A, A-, B+, B, B-, C+, C, C-, D+, D, F)
  static String marksToLetterGrade(int marks) {
    if (marks < 0 || marks > 100) {
      return 'N/A';
    }

    for (final grade in gradeScale) {
      if (grade.containsMarks(marks)) {
        return grade.letterGrade;
      }
    }

    return 'F';
  }

  /// Gets the full grade info for given marks
  ///
  /// [marks] - The marks obtained (0 to 100)
  /// Returns: GradeInfo object with all details
  static GradeInfo? getGradeInfo(int marks) {
    if (marks < 0 || marks > 100) {
      return null;
    }

    for (final grade in gradeScale) {
      if (grade.containsMarks(marks)) {
        return grade;
      }
    }

    return gradeScale.last; // Return F grade as fallback
  }

  /// Converts GPA back to an approximate marks range (midpoint)
  ///
  /// [gpa] - The grade point
  /// Returns: Approximate marks (midpoint of the range)
  static int gpaToApproximateMarks(double gpa) {
    for (final grade in gradeScale) {
      if ((grade.gradePoint - gpa).abs() < 0.01) {
        return (grade.minMarks + grade.maxMarks) ~/ 2;
      }
    }
    return 0;
  }

  /// Rounds a GPA value according to the rounding rule:
  /// If decimal digit >= 5, round up; otherwise keep as is
  ///
  /// [gpa] - The GPA value to round
  /// [decimalPlaces] - Number of decimal places (default 2)
  /// Returns: Rounded GPA value
  static double roundGpa(double gpa, {int decimalPlaces = 2}) {
    final multiplier = _pow10(decimalPlaces);
    final shifted = gpa * multiplier;
    final decimal = shifted - shifted.floor();

    if (decimal >= 0.5) {
      return (shifted.floor() + 1) / multiplier;
    } else {
      return shifted.floor() / multiplier;
    }
  }

  /// Helper to calculate 10^n
  static double _pow10(int n) {
    double result = 1;
    for (int i = 0; i < n; i++) {
      result *= 10;
    }
    return result;
  }

  /// Formats a GPA value for display with proper rounding
  ///
  /// [gpa] - The GPA value
  /// Returns: Formatted string (e.g., "3.66")
  static String formatGpa(double gpa) {
    final rounded = roundGpa(gpa);
    return rounded.toStringAsFixed(2);
  }

  /// Gets the color for a grade
  ///
  /// Returns appropriate color code based on performance
  static int getGradeColor(double gpa) {
    if (gpa >= 3.66) return 0xFF4CAF50; // Green - Excellent
    if (gpa >= 3.00) return 0xFF8BC34A; // Light Green - Good
    if (gpa >= 2.33) return 0xFFFFEB3B; // Yellow - Satisfactory
    if (gpa >= 1.66) return 0xFFFF9800; // Orange - Below Average
    if (gpa >= 1.00) return 0xFFFF5722; // Deep Orange - Poor
    return 0xFFF44336; // Red - Fail
  }

  /// Gets letter grade from GPA value
  static String gpaToLetterGrade(double gpa) {
    if (gpa >= 4.00) return 'A';
    if (gpa >= 3.66) return 'A-';
    if (gpa >= 3.33) return 'B+';
    if (gpa >= 3.00) return 'B';
    if (gpa >= 2.66) return 'B-';
    if (gpa >= 2.33) return 'C+';
    if (gpa >= 2.00) return 'C';
    if (gpa >= 1.66) return 'C-';
    if (gpa >= 1.33) return 'D+';
    if (gpa >= 1.00) return 'D';
    return 'F';
  }

  /// Validates if marks are in valid range
  static bool isValidMarks(int marks) {
    return marks >= 0 && marks <= 100;
  }

  /// Gets a formatted string showing marks and corresponding grade
  ///
  /// [marks] - The marks obtained
  /// Returns: Formatted string like "87 marks → A (4.00)"
  static String formatMarksWithGrade(int marks) {
    final grade = getGradeInfo(marks);
    if (grade == null) return '$marks marks → N/A';
    return '$marks marks → ${grade.letterGrade} (${grade.gradePoint.toStringAsFixed(2)})';
  }
}
