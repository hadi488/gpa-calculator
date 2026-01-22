import 'package:flutter/material.dart';
import '../logic/lab_screen_controller.dart';
import '../../widgets/projected_gpa_result_bar.dart'; // Reusing this generic result bar

class LabResultSection extends StatelessWidget {
  final LabScreenController controller;

  const LabResultSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final theoryCH =
            double.tryParse(controller.theoryCHController.text) ?? 0;
        final labCH = double.tryParse(controller.labCHController.text) ?? 0;

        final theoryObt = controller.theoryController.finalAbsoluteMarks;
        final labObt = controller.labController.finalAbsoluteMarks;

        double finalAbsoluteMarks = 0;
        if ((theoryCH + labCH) > 0) {
          finalAbsoluteMarks =
              ((theoryObt * theoryCH) + (labObt * labCH)) / (theoryCH + labCH);
        }

        // Strict Fail Rule: If either Theory or Lab is < 50 (after rounding), the subject is Failed.
        double? overrideGpa;
        String? overrideGrade;

        if (theoryObt.round() < 50 || labObt.round() < 50) {
          overrideGpa = 0.0;
          overrideGrade = 'F';
        }

        return ProjectedGpaResultBar(
          normalizedScore: finalAbsoluteMarks,
          detail1: theoryObt,
          detail2: labObt,
          isComposite: true, // Treating as composite (Th + Lab) display style
          overrideGpa: overrideGpa,
          overrideGrade: overrideGrade,
          maxDetail1: 100,
          maxDetail2: 100,
          totalMaxScore: 100,
        );
      },
    );
  }
}
