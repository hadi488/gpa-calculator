import 'package:cgpacalculator/data/services/grade_scale_service.dart';

/// Static data for grade scale presets
class GradePresets {
  /// Preset Names Map
  static final Map<String, String> names = {
    'default': 'BS Default',
    'ms_default': 'MS Default',
    'comsats': 'BS COMSATS',
    'nust': 'BS NUST',
    'hec': 'BS HEC',
  };

  /// Get preset scale data by ID
  static List<GradeInfo> getScaleData(String scaleId) {
    switch (scaleId) {
      case 'nust':
        return [
          const GradeInfo(
            minMarks: 90,
            maxMarks: 100,
            gradePoint: 4.00,
            letterGrade: 'A',
          ),
          const GradeInfo(
            minMarks: 85,
            maxMarks: 89,
            gradePoint: 3.67,
            letterGrade: 'A-',
          ),
          const GradeInfo(
            minMarks: 80,
            maxMarks: 84,
            gradePoint: 3.33,
            letterGrade: 'B+',
          ),
          const GradeInfo(
            minMarks: 75,
            maxMarks: 79,
            gradePoint: 3.00,
            letterGrade: 'B',
          ),
          const GradeInfo(
            minMarks: 70,
            maxMarks: 74,
            gradePoint: 2.67,
            letterGrade: 'B-',
          ),
          const GradeInfo(
            minMarks: 65,
            maxMarks: 69,
            gradePoint: 2.33,
            letterGrade: 'C+',
          ),
          const GradeInfo(
            minMarks: 60,
            maxMarks: 64,
            gradePoint: 2.00,
            letterGrade: 'C',
          ),
          const GradeInfo(
            minMarks: 55,
            maxMarks: 59,
            gradePoint: 1.67,
            letterGrade: 'C-',
          ),
          const GradeInfo(
            minMarks: 50,
            maxMarks: 54,
            gradePoint: 1.00,
            letterGrade: 'D',
          ),
          const GradeInfo(
            minMarks: 0,
            maxMarks: 49,
            gradePoint: 0.00,
            letterGrade: 'F',
          ),
        ];
      case 'hec':
        return [
          const GradeInfo(
            minMarks: 85,
            maxMarks: 100,
            gradePoint: 4.00,
            letterGrade: 'A',
          ),
          const GradeInfo(
            minMarks: 80,
            maxMarks: 84,
            gradePoint: 3.70,
            letterGrade: 'A-',
          ),
          const GradeInfo(
            minMarks: 75,
            maxMarks: 79,
            gradePoint: 3.30,
            letterGrade: 'B+',
          ),
          const GradeInfo(
            minMarks: 70,
            maxMarks: 74,
            gradePoint: 3.00,
            letterGrade: 'B',
          ),
          const GradeInfo(
            minMarks: 65,
            maxMarks: 69,
            gradePoint: 2.70,
            letterGrade: 'B-',
          ),
          const GradeInfo(
            minMarks: 61,
            maxMarks: 64,
            gradePoint: 2.30,
            letterGrade: 'C+',
          ),
          const GradeInfo(
            minMarks: 58,
            maxMarks: 60,
            gradePoint: 2.00,
            letterGrade: 'C',
          ),
          const GradeInfo(
            minMarks: 55,
            maxMarks: 57,
            gradePoint: 1.70,
            letterGrade: 'C-',
          ),
          const GradeInfo(
            minMarks: 50,
            maxMarks: 54,
            gradePoint: 1.00,
            letterGrade: 'D',
          ),
          const GradeInfo(
            minMarks: 0,
            maxMarks: 49,
            gradePoint: 0.00,
            letterGrade: 'F',
          ),
        ];
      case 'comsats':
      case 'default':
      case 'ms_default':
      default:
        // Default / COMSATS
        return [
          const GradeInfo(
            minMarks: 85,
            maxMarks: 100,
            gradePoint: 4.00,
            letterGrade: 'A',
          ),
          const GradeInfo(
            minMarks: 80,
            maxMarks: 84,
            gradePoint: 3.66,
            letterGrade: 'A-',
          ),
          const GradeInfo(
            minMarks: 75,
            maxMarks: 79,
            gradePoint: 3.33,
            letterGrade: 'B+',
          ),
          const GradeInfo(
            minMarks: 71,
            maxMarks: 74,
            gradePoint: 3.00,
            letterGrade: 'B',
          ),
          const GradeInfo(
            minMarks: 68,
            maxMarks: 70,
            gradePoint: 2.66,
            letterGrade: 'B-',
          ),
          const GradeInfo(
            minMarks: 64,
            maxMarks: 67,
            gradePoint: 2.33,
            letterGrade: 'C+',
          ),
          const GradeInfo(
            minMarks: 61,
            maxMarks: 63,
            gradePoint: 2.00,
            letterGrade: 'C',
          ),
          const GradeInfo(
            minMarks: 58,
            maxMarks: 60,
            gradePoint: 1.66,
            letterGrade: 'C-',
          ),
          const GradeInfo(
            minMarks: 54,
            maxMarks: 57,
            gradePoint: 1.33,
            letterGrade: 'D+',
          ),
          const GradeInfo(
            minMarks: 50,
            maxMarks: 53,
            gradePoint: 1.00,
            letterGrade: 'D',
          ),
          const GradeInfo(
            minMarks: 0,
            maxMarks: 49,
            gradePoint: 0.00,
            letterGrade: 'F',
          ),
        ];
    }
  }
}
