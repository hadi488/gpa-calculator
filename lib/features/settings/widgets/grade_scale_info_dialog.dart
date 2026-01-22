import 'package:cgpacalculator/features/settings/logic/grade_scale_provider.dart';
import 'package:cgpacalculator/features/settings/screens/grade_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cgpacalculator/data/services/grade_scale_service.dart';

class GradeScaleInfoDialog extends StatelessWidget {
  final String? scaleId;
  final VoidCallback? onChange;

  const GradeScaleInfoDialog({super.key, this.scaleId, this.onChange});

  @override
  Widget build(BuildContext context) {
    return Consumer<GradeScaleProvider>(
      builder: (context, provider, _) {
        // Determine which scale to show
        final List<GradeInfo> currentScale;
        final String scaleName;

        if (scaleId != null) {
          currentScale = provider.getScaleById(scaleId!);
          scaleName = provider.getScaleName(scaleId!);
        } else {
          currentScale = provider.currentScale;
          scaleName = provider.currentScaleName;
        }

        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Grading Criteria'),
              const SizedBox(height: 4),
              Text(
                'Currently Active : $scaleName',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 20,
                headingRowHeight: 40,
                dataRowMinHeight: 32,
                dataRowMaxHeight: 32,
                columns: const [
                  DataColumn(label: Text('Marks')),
                  DataColumn(label: Text('GPA')),
                  DataColumn(label: Text('Grade')),
                ],
                rows: currentScale.map((g) {
                  return DataRow(
                    cells: [
                      DataCell(Text('${g.minMarks} - ${g.maxMarks}')),
                      DataCell(Text(g.gradePoint.toStringAsFixed(2))),
                      DataCell(
                        Text(
                          g.letterGrade,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                if (onChange != null) {
                  onChange!();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GradeSettingsScreen(),
                    ),
                  );
                }
              },
              child: const Text('Change'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
