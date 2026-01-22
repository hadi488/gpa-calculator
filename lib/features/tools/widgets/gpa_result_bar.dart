import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cgpacalculator/features/settings/logic/grade_scale_provider.dart';

class GpaResultBar extends StatelessWidget {
  final double finalAbsoluteMarks;

  const GpaResultBar({super.key, required this.finalAbsoluteMarks});

  @override
  Widget build(BuildContext context) {
    // Watch provider to rebuild when grading scale changes
    final provider = context.watch<GradeScaleProvider>();
    final int roundedMarks = finalAbsoluteMarks.round();
    final double? finalGpa = provider.marksToGpa(roundedMarks);
    final String? finalGrade = provider.marksToLetterGrade(roundedMarks);

    // Determine color based on grade
    Color resultColor;
    if (finalGrade == 'F') {
      resultColor = Colors.red;
    } else if ((finalGrade?.contains('A') ?? false) ||
        (finalGrade?.contains('B') ?? false)) {
      resultColor = Colors.green;
    } else {
      resultColor = Colors.orange;
    }

    // Determine label color based on brightness
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? Colors.grey : Colors.grey[700];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total Absolute', style: TextStyle(color: labelColor)),
                  Text(
                    finalAbsoluteMarks.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 50, color: Colors.grey[300]),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('GPA', style: TextStyle(color: labelColor)),
                  Text(
                    finalGpa?.toStringAsFixed(2) ?? '-',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: resultColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 50, color: Colors.grey[300]),
            Expanded(
              child: Column(
                // Centered as requested in previous steps
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Grade', style: TextStyle(color: labelColor)),
                  Text(
                    finalGrade ?? '-',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: resultColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
