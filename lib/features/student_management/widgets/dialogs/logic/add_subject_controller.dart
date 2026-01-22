import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cgpacalculator/data/models/subject.dart';
import 'package:cgpacalculator/data/services/grade_scale_service.dart';
import 'package:cgpacalculator/features/settings/logic/grade_scale_provider.dart';
import 'package:cgpacalculator/features/student_management/logic/student_provider.dart';

class AddSubjectController extends ChangeNotifier {
  final BuildContext context;
  final String studentId;
  final Subject? existingSubject;

  // Controllers
  final courseCodeController = TextEditingController();
  final courseNameController = TextEditingController();
  final marksController = TextEditingController();
  final gpaController = TextEditingController();

  // State
  bool useMarksInput = true;
  int creditHours = 3;
  GradeInfo? gradePreview;
  double? gpaPreview;
  bool isLoading = false;
  String? errorMessage;
  String? _studentScaleId;
  bool _wasSubmittedSuccessfully = false; // Flag to skip draft save on success

  // Cached provider reference for use in cleanUp during dispose
  late final StudentProvider _studentProvider;

  AddSubjectController({
    required this.context,
    required this.studentId,
    this.existingSubject,
  }) {
    // Cache provider reference early (context may not be valid during dispose)
    _studentProvider = context.read<StudentProvider>();
    _init();
  }

  void _init() {
    // Fetch student's scale ID
    try {
      final student = _studentProvider.getStudentById(studentId);
      _studentScaleId = student?.gradeScaleId;
    } catch (e) {
      // safe validation if provider not ready (though init calls are usually safe)
    }

    if (existingSubject != null) {
      _loadExistingSubject();
    } else {
      _loadDraftAndSettings();
    }
  }

  void _loadExistingSubject() {
    final subject = existingSubject!;
    courseCodeController.text = subject.courseCode;
    courseNameController.text = subject.courseName;
    creditHours = subject.creditHours;

    if (subject.marks != null) {
      marksController.text = subject.marks.toString();
      useMarksInput = true;
      updateGradePreviewFromMarks(subject.marks.toString());
      gpaController.text = subject.gradePoint.toStringAsFixed(2);
    } else if (subject.hasGrade) {
      gpaController.text = subject.gradePoint.toStringAsFixed(2);
      gpaPreview = subject.gradePoint;
      useMarksInput = false;
    }
    notifyListeners();
  }

  Future<void> _loadDraftAndSettings() async {
    // Use cached provider reference
    final credits = await _studentProvider.getLastSelectedCreditHours();
    final draft = await _studentProvider.getSubjectDraft();

    debugPrint('📝 DRAFT LOAD: credits=$credits, draft=$draft');

    creditHours = credits;

    // Check if draft has actual content (map always has keys with defaults)
    final code = draft['courseCode'] as String? ?? '';
    final name = draft['courseName'] as String? ?? '';
    final grade = draft['grade'] as String? ?? '';
    final isMarksMode = draft['isMarksMode'] as bool? ?? true;

    debugPrint(
      '📝 DRAFT VALUES: code="$code", name="$name", grade="$grade", isMarksMode=$isMarksMode',
    );

    // Only load if there's actual data
    if (code.isNotEmpty || name.isNotEmpty || grade.isNotEmpty) {
      debugPrint('📝 DRAFT: Loading values into controllers');
      if (code.isNotEmpty) courseCodeController.text = code;
      if (name.isNotEmpty) courseNameController.text = name;

      useMarksInput = isMarksMode;
      if (grade.isNotEmpty) {
        if (isMarksMode) {
          marksController.text = grade;
          updateGradePreviewFromMarks(grade);
        } else {
          gpaController.text = grade;
          updateGradePreviewFromGpa(grade);
        }
      }
    } else {
      debugPrint('📝 DRAFT: No data to load');
    }
    notifyListeners();
  }

  void setCreditHours(int hours) {
    creditHours = hours;
    notifyListeners();
  }

  void setInputMode(bool isMarks) {
    useMarksInput = isMarks;
    notifyListeners();
  }

  void updateGradePreviewFromMarks(String value) {
    final marksDouble = double.tryParse(value);

    if (marksDouble != null && marksDouble >= 0 && marksDouble <= 100) {
      final marks = marksDouble.round();
      final provider = context.read<GradeScaleProvider>();

      if (_studentScaleId != null) {
        gpaPreview = provider.marksToGpaForScale(marks, _studentScaleId!);
        gradePreview = GradeInfo(
          minMarks: marks,
          maxMarks: marks,
          gradePoint: gpaPreview!,
          letterGrade: provider.marksToLetterGradeForScale(
            marks,
            _studentScaleId!,
          ),
        );
      } else {
        gpaPreview = provider.marksToGpa(marks);
        gradePreview = GradeInfo(
          minMarks: marks,
          maxMarks: marks,
          gradePoint: gpaPreview!,
          letterGrade: provider.marksToLetterGrade(marks),
        );
      }
    } else {
      gradePreview = null;
      gpaPreview = null;
    }
    notifyListeners();
  }

  void updateGradePreviewFromGpa(String value) {
    final gpa = double.tryParse(value);
    if (gpa != null && gpa >= 0.0 && gpa <= 4.0) {
      gpaPreview = gpa;
      gradePreview = null;
    } else {
      gpaPreview = null;
      gradePreview = null;
    }
    notifyListeners();
  }

  double? getGpaValue() {
    if (useMarksInput) {
      if (marksController.text.trim().isEmpty) return null;
      final marksDouble = double.tryParse(marksController.text);
      if (marksDouble == null) return null;
      final marks = marksDouble.round();

      final provider = context.read<GradeScaleProvider>();
      if (_studentScaleId != null) {
        return provider.marksToGpaForScale(marks, _studentScaleId!);
      } else {
        return provider.marksToGpa(marks);
      }
    } else {
      if (gpaController.text.trim().isEmpty) return null;
      return double.tryParse(gpaController.text);
    }
  }

  String getDisplayLetterGrade(GradeScaleProvider provider) {
    if (gpaPreview == null) return 'F';

    if (_studentScaleId != null) {
      return provider.getLetterGradeForScale(gpaPreview!, _studentScaleId!);
    } else {
      return provider.getLetterGrade(gpaPreview!);
    }
  }

  /// Call this before successful submission to prevent cleanUp from saving draft
  void markAsSubmitted() {
    _wasSubmittedSuccessfully = true;
  }

  void cleanUp() {
    // Only save draft if: not editing existing subject AND not successfully submitted
    if (existingSubject == null && !_wasSubmittedSuccessfully) {
      final draftCode = courseCodeController.text;
      final draftName = courseNameController.text;
      final draftGrade = useMarksInput
          ? marksController.text
          : gpaController.text;

      debugPrint(
        '💾 DRAFT SAVE: code="$draftCode", name="$draftName", grade="$draftGrade", isMarksMode=$useMarksInput',
      );

      _studentProvider.saveSubjectDraft(
        courseCode: draftCode,
        courseName: draftName,
        grade: draftGrade,
        isMarksMode: useMarksInput,
      );
    } else if (_wasSubmittedSuccessfully) {
      debugPrint('💾 DRAFT SAVE: Skipped (submitted successfully)');
    } else {
      debugPrint('💾 DRAFT SAVE: Skipped (editing existing subject)');
    }

    courseCodeController.dispose();
    courseNameController.dispose();
    marksController.dispose();
    gpaController.dispose();
  }
}
