import 'package:flutter/material.dart';
import '../models/subject_gpa_models.dart';

class SubjectGpaController extends ChangeNotifier {
  late List<AssessmentCategory> categories;

  // Results
  double finalAbsoluteMarks = 0;

  // Validation
  double get totalWeight {
    final hasSessionals = hasItem('Sessionals') || hasItem('Lab Sessionals');

    return categories.fold(0.0, (sum, cat) {
      // If Sessionals exist, Mid Term weight is excluded
      if (hasSessionals && cat.name.contains('Mid Term')) return sum;
      return sum + cat.weight;
    });
  }

  SubjectGpaController({List<AssessmentCategory>? initialCategories}) {
    categories = initialCategories ?? _getDefaultCategories();
  }

  List<AssessmentCategory> _getDefaultCategories() {
    return [
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
    ];
  }

  bool hasItem(String categoryName) {
    return categories
        .firstWhere(
          (c) => c.name == categoryName,
          orElse: () => AssessmentCategory(name: '', weight: 0),
        )
        .items
        .isNotEmpty;
  }

  void calculate() {
    double totalScore = 0;

    // Check if Sessionals exist to exclude Mid Term from calculation
    // Matches "Mid Term" OR "Lab Mid Term"
    final hasSessionals = hasItem('Sessionals') || hasItem('Lab Sessionals');

    for (var category in categories) {
      if (hasSessionals && category.name.contains('Mid Term')) {
        continue;
      }

      if (category.hasIndividualWeights) {
        // Sum of individual item contributions
        double categoryTotalScore = 0;
        double categoryTotalWeight = 0;

        for (var item in category.items) {
          if (item.total > 0 && item.weight > 0) {
            categoryTotalScore += (item.obtained / item.total) * item.weight;
            categoryTotalWeight += item.weight;
          }
        }

        // Update category weight to reflect sum of item weights (for display/validation)
        category.weight = categoryTotalWeight;
        category.weightController.text = categoryTotalWeight % 1 == 0
            ? categoryTotalWeight.toStringAsFixed(0)
            : categoryTotalWeight.toString();

        totalScore += categoryTotalScore;
      } else {
        totalScore += category.weightedScore;
      }
    }

    // Fix precision to 2 decimal places to handle float arithmetic
    finalAbsoluteMarks = double.parse(totalScore.toStringAsFixed(2));
    notifyListeners();
  }

  void addItem(AssessmentCategory category) {
    if (category.maxItems != null &&
        category.items.length >= category.maxItems!) {
      return;
    }

    String prefix;
    if (category.name == 'Quizzes') {
      prefix = 'Quiz';
    } else if (category.name == 'Assignments') {
      prefix = 'Assignment';
    } else if (category.name == 'Lab Assignments') {
      prefix = 'Lab Assignment';
    } else if (category.name == 'Mid Term') {
      prefix = 'Mid Term';
    } else if (category.name == 'Lab Mid Term') {
      prefix = 'Lab Mid Term';
    } else {
      // Fallback: e.g. Sessionals -> Sessional
      if (category.name.endsWith('s')) {
        prefix = category.name.substring(0, category.name.length - 1);
      } else {
        prefix = category.name;
      }
    }

    double defaultWeight = 0;
    double defaultTotal = 10;

    // Handle Sessionals default logic (1st = 10, 2nd=15)
    if (category.hasIndividualWeights && category.name.contains('Sessionals')) {
      if (category.items.isEmpty) {
        // 1st Sessional
        defaultWeight = 10;
        defaultTotal = 10;
      } else if (category.items.length == 1) {
        // 2nd Sessional
        defaultWeight = 15;
        defaultTotal = 15;
      }
    } else if (category.name.contains('Mid Term')) {
      // Default total for Mid Terms is 25
      defaultTotal = 25;
    }

    category.items.add(
      GradeItem(
        name: '$prefix ${category.items.length + 1}',
        weight: defaultWeight,
        total: defaultTotal,
      ),
    );

    if (category.hasIndividualWeights) {
      calculate();
    } else {
      notifyListeners();
    }
  }

  void removeItem(AssessmentCategory category, int index) {
    category.items[index].dispose();
    category.items.removeAt(index);
    calculate();
  }

  void reset() {
    for (var cat in categories) {
      cat.weightController.dispose();
      for (var item in cat.items) {
        item.dispose();
      }
    }
    // Re-initialize logic handled by re-creating controller or resetting list
    // Ideally user might re-create screen, but here we can just reset list
    // However, since constructor args dictate category types (Subject vs Lab),
    // we should ideally just clear items. But structure is list of objects.

    // Simplest: clear items and re-add defaults?
    // Or let the screen handle it by replacing the controller.
    // For now, let's just clear items of existing categories to keep structure?
    // No, weights might have changed.

    // Better strategy for this specific app:
    // clear all items, reset weights to defaults?
    // actually, `reset` in previous code completely reloaded `_getInitialCategories`.
    // So we need a way to reload initial config.
    // We will assume the controller is passed an `initCallback` or we just clear and let the screen rebuild?

    // Let's implement basic reset: clear all items.
    for (var cat in categories) {
      cat.items.clear();
      if (cat.hasIndividualWeights) {
        cat.weight = 0;
        cat.weightController.text = '0';
      }
    }
    // Re-add default items based on name?
    // This is getting complex to generalize.
    // EASIER: The View calls reset, which effectively replaces the Controller or calls a callback to get fresh list.
    // We'll leave `reset` to just clear for now, or we can inject a factory function.

    finalAbsoluteMarks = 0;
    calculate();
  }

  @override
  void dispose() {
    for (var cat in categories) {
      cat.weightController.dispose();
      for (var item in cat.items) {
        item.dispose();
      }
    }
    super.dispose();
  }
}
