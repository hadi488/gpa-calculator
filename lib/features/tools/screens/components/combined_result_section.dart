import 'package:flutter/material.dart';
import '../logic/mid_term_screen_controller.dart';
import '../../widgets/projected_gpa_result_bar.dart';

class CombinedResultSection extends StatelessWidget {
  final MidTermScreenController controller;

  const CombinedResultSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    double totalObtainedWeighted =
        controller.theoryController.finalAbsoluteMarks;
    double totalPossibleWeight = controller.theoryController.totalWeight;

    if (controller.isLabSubject) {
      final theoryObt = controller.theoryController.finalAbsoluteMarks;
      final theoryMax = controller.theoryController.totalWeight;

      final labObt = controller.labController.finalAbsoluteMarks;
      final labMax = controller.labController.totalWeight;

      // Calculation: Each part contributes 50 towards the final 100
      final theoryContrib = (theoryMax > 0)
          ? (theoryObt / theoryMax) * 50
          : 0.0;
      final labContrib = (labMax > 0) ? (labObt / labMax) * 50 : 0.0;

      final normalizedScore = theoryContrib + labContrib;

      // Strict Fail Rule: If either Theory or Lab contrib is < 25 (out of 50) after rounding, subject Fails.
      double? overrideGpa;
      String? overrideGrade;

      if (theoryContrib.round() < 25 || labContrib.round() < 25) {
        overrideGpa = 0.0;
        overrideGrade = 'F';
      }

      return ProjectedGpaResultBar(
        normalizedScore: normalizedScore,
        detail1: theoryContrib,
        detail2: labContrib,
        isComposite: true,
        overrideGpa: overrideGpa,
        overrideGrade: overrideGrade,
      );
    } else {
      // Simple Normalization
      final normalizedScore = (totalPossibleWeight > 0)
          ? (totalObtainedWeighted / totalPossibleWeight) * 100
          : 0.0;

      return ProjectedGpaResultBar(
        normalizedScore: normalizedScore,
        detail1: totalObtainedWeighted,
        detail2: totalPossibleWeight,
        isComposite: false,
      );
    }
  }
}
