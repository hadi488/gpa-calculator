import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../settings/logic/grade_scale_provider.dart';

class ProjectedGpaResultBar extends StatelessWidget {
  final double normalizedScore;
  final double detail1;
  final double detail2;
  final bool isComposite;
  final double? overrideGpa;
  final String? overrideGrade;
  final double maxDetail1;
  final double maxDetail2;
  final double totalMaxScore;

  const ProjectedGpaResultBar({
    super.key,
    required this.normalizedScore,
    required this.detail1,
    required this.detail2,
    required this.isComposite,
    this.overrideGpa,
    this.overrideGrade,
    this.maxDetail1 = 50,
    this.maxDetail2 = 50,
    this.totalMaxScore = 50,
  });

  @override
  Widget build(BuildContext context) {
    // Use GradeScaleProvider for final grade
    final provider = context.watch<GradeScaleProvider>();
    final int roundedMarks = normalizedScore.round();

    // Use overrides if provided, otherwise calculate
    final double? finalGpa = overrideGpa ?? provider.marksToGpa(roundedMarks);
    final String? finalGrade =
        overrideGrade ?? provider.marksToLetterGrade(roundedMarks);

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
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Projected Value',
                      style: TextStyle(color: labelColor),
                    ),
                    Text(
                      normalizedScore.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isComposite) ...[
                      Text(
                        'Obt: ${(normalizedScore * (totalMaxScore / 100)).toStringAsFixed(1)} / ${totalMaxScore.toStringAsFixed(0)}',
                        style: TextStyle(color: labelColor, fontSize: 11),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Th: ${detail1.toStringAsFixed(1)}/${maxDetail1.toStringAsFixed(0)} | Lab: ${detail2.toStringAsFixed(1)}/${maxDetail2.toStringAsFixed(0)}',
                        style: TextStyle(color: labelColor, fontSize: 10),
                      ),
                    ] else
                      Text(
                        'Obt: ${detail1.toStringAsFixed(1)} / ${detail2.toStringAsFixed(0)}',
                        style: TextStyle(color: labelColor, fontSize: 11),
                      ),
                  ],
                ),
              ),
              Container(width: 1, color: Colors.grey[300]),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
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
              Container(width: 1, color: Colors.grey[300]),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
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
      ),
    );
  }
}
