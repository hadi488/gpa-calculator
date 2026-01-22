import 'package:flutter/material.dart';

/// Represents a single grade item (e.g., Quiz 1)
class GradeItem {
  String name;
  double obtained;
  double total;
  double weight; // For items with individual weights
  TextEditingController obtainedController;
  TextEditingController totalController;
  TextEditingController weightController;

  GradeItem({
    required this.name,
    this.obtained = 0,
    this.total = 10,
    this.weight = 0,
  }) : obtainedController = TextEditingController(
         text: obtained > 0 ? obtained.toString() : '',
       ),
       totalController = TextEditingController(text: total.toStringAsFixed(0)),
       weightController = TextEditingController(
         text: weight > 0 ? weight.toStringAsFixed(0) : '',
       );

  void dispose() {
    obtainedController.dispose();
    totalController.dispose();
    weightController.dispose();
  }
}

/// Represents a category of assessments (e.g., Quizzes)
class AssessmentCategory {
  String name;
  double weight;
  List<GradeItem> items;
  bool isExpanded;
  bool hasIndividualWeights; // If true, items define their own weights
  TextEditingController weightController;
  int? maxItems; // Null means unlimited

  AssessmentCategory({
    required this.name,
    required this.weight,
    this.items = const [],
    this.isExpanded = true,
    this.hasIndividualWeights = false,
    this.maxItems,
  }) : weightController = TextEditingController(
         text: weight.toStringAsFixed(0),
       ); // Integer weights usually

  double get totalObtained {
    if (items.isEmpty) return 0;
    return items.fold(0, (sum, item) => sum + item.obtained);
  }

  double get totalMax {
    if (items.isEmpty) return 0;
    return items.fold(0, (sum, item) => sum + item.total);
  }

  /// Calculates weighted score for this category
  /// Formula: (TotalObtained / TotalMax) * Weight
  double get weightedScore {
    if (hasIndividualWeights) {
      return items.fold(0.0, (sum, item) {
        if (item.total == 0 || item.weight == 0) return sum;
        return sum + (item.obtained / item.total) * item.weight;
      });
    }

    if (items.isEmpty || totalMax == 0) return 0;
    return (totalObtained / totalMax) * weight;
  }
}
