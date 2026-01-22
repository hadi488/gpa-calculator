import 'package:flutter/material.dart';
import '../../logic/subject_gpa_controller.dart';
import '../../models/subject_gpa_models.dart';

class LabScreenController extends ChangeNotifier {
  late SubjectGpaController theoryController;
  late SubjectGpaController labController;

  final TextEditingController theoryCHController = TextEditingController(
    text: '3',
  );
  final TextEditingController labCHController = TextEditingController(
    text: '1',
  );

  LabScreenController() {
    _initializeControllers();
  }

  void _initializeControllers() {
    // Theory Controller (Standard Categories)
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
          name: 'Final Term',
          weight: 50,
          maxItems: 1,
          items: [GradeItem(name: 'Final Exam', total: 50)],
        ),
        AssessmentCategory(
          name: 'Sessionals',
          weight: 0,
          items: [],
          hasIndividualWeights: true,
        ),
      ],
    );

    // Lab Controller (Lab Categories)
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
          name: 'Lab Final Term',
          weight: 50,
          maxItems: 1,
          items: [GradeItem(name: 'Lab Final Exam', total: 50)],
        ),
        AssessmentCategory(
          name: 'Lab Sessionals',
          weight: 0,
          items: [],
          hasIndividualWeights: true,
        ),
      ],
    );

    // Listen to changes to notify UI
    theoryController.addListener(notifyListeners);
    labController.addListener(notifyListeners);
  }

  void calculate() {
    theoryController.calculate();
    labController.calculate();
    notifyListeners();
  }

  void reset() {
    theoryController.dispose();
    labController.dispose();
    _initializeControllers();
    notifyListeners();
  }

  @override
  void dispose() {
    theoryController.dispose();
    labController.dispose();
    theoryCHController.dispose();
    labCHController.dispose();
    super.dispose();
  }
}
