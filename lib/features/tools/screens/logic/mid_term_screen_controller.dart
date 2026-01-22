import 'package:flutter/material.dart';
import '../../models/subject_gpa_models.dart';
import '../../logic/subject_gpa_controller.dart';

class MidTermScreenController extends ChangeNotifier {
  late SubjectGpaController theoryController;
  late SubjectGpaController labController;

  final theoryCHController = TextEditingController(text: '3');
  final labCHController = TextEditingController(text: '1');

  bool _isLabSubject = false;
  bool get isLabSubject => _isLabSubject;

  MidTermScreenController() {
    _initializeControllers();
  }

  void _initializeControllers() {
    // Theory Controller
    theoryController = SubjectGpaController(
      initialCategories: [
        AssessmentCategory(
          name: 'Quizzes',
          weight: 15,
          items: [GradeItem(name: 'Quiz 1')],
        ),
        AssessmentCategory(
          name: 'Assignments',
          weight: 10,
          items: [GradeItem(name: 'Assignment 1')],
        ),
        AssessmentCategory(
          name: 'Mid Term',
          weight: 25,
          maxItems: 1,
          items: [GradeItem(name: 'Mid Term', total: 25)],
        ),
        AssessmentCategory(
          name: 'Sessionals',
          weight: 0,
          items: [],
          hasIndividualWeights: true,
        ),
      ],
    );

    // Lab Controller
    labController = SubjectGpaController(
      initialCategories: [
        AssessmentCategory(
          name: 'Lab Assignments',
          weight: 25,
          items: [GradeItem(name: 'Lab Assignment 1')],
        ),
        AssessmentCategory(
          name: 'Lab Mid Term',
          weight: 25,
          maxItems: 1,
          items: [GradeItem(name: 'Lab Mid Term', total: 25)],
        ),
        AssessmentCategory(
          name: 'Lab Sessionals',
          weight: 0,
          items: [],
          hasIndividualWeights: true,
        ),
      ],
    );

    // Listen to sub-controllers to propagate updates
    theoryController.addListener(notifyListeners);
    labController.addListener(notifyListeners);
  }

  void setLabSubject(bool value) {
    _isLabSubject = value;
    notifyListeners();
  }

  @override
  void dispose() {
    theoryController.removeListener(notifyListeners);
    labController.removeListener(notifyListeners);
    theoryController.dispose();
    labController.dispose();
    theoryCHController.dispose();
    labCHController.dispose();
    super.dispose();
  }
}
