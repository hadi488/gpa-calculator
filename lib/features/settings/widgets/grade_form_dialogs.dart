import 'package:flutter/material.dart';
import 'package:cgpacalculator/data/services/grade_scale_service.dart';
import 'package:cgpacalculator/features/settings/logic/grade_scale_provider.dart';

class GradeFormDialogs {
  static void showAddGradeDialog(
    BuildContext context,
    GradeScaleProvider provider,
    String scaleId,
  ) {
    final minCtrl = TextEditingController();
    final maxCtrl = TextEditingController();
    final letterCtrl = TextEditingController();
    final gpaCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Grade Row'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minCtrl,
                      decoration: const InputDecoration(labelText: 'Min Marks'),
                      keyboardType: TextInputType.number,
                      keyboardAppearance: Theme.of(context).brightness,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: maxCtrl,
                      decoration: const InputDecoration(labelText: 'Max Marks'),
                      keyboardType: TextInputType.number,
                      keyboardAppearance: Theme.of(context).brightness,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: letterCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Letter Grade',
                      ),
                      textCapitalization: TextCapitalization.characters,
                      keyboardAppearance: Theme.of(context).brightness,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: gpaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'GPA Points',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      keyboardAppearance: Theme.of(context).brightness,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final min = int.tryParse(minCtrl.text);
              final max = int.tryParse(maxCtrl.text);
              final gpa = double.tryParse(gpaCtrl.text);
              final letter = letterCtrl.text.trim();

              if (min != null &&
                  max != null &&
                  gpa != null &&
                  letter.isNotEmpty) {
                provider.addCustomGrade(
                  scaleId,
                  minMarks: min,
                  maxMarks: max,
                  gpa: gpa,
                  letterGrade: letter,
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  static void showEditGradeDialog(
    BuildContext context,
    GradeScaleProvider provider,
    int index,
    GradeInfo grade,
    String scaleId,
  ) {
    final minCtrl = TextEditingController(text: grade.minMarks.toString());
    final maxCtrl = TextEditingController(text: grade.maxMarks.toString());
    final letterCtrl = TextEditingController(text: grade.letterGrade);
    final gpaCtrl = TextEditingController(text: grade.gradePoint.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Grade Criteria'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minCtrl,
                      decoration: const InputDecoration(labelText: 'Min Marks'),
                      keyboardType: TextInputType.number,
                      keyboardAppearance: Theme.of(context).brightness,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: maxCtrl,
                      decoration: const InputDecoration(labelText: 'Max Marks'),
                      keyboardType: TextInputType.number,
                      keyboardAppearance: Theme.of(context).brightness,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: letterCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Letter Grade',
                      ),
                      textCapitalization: TextCapitalization.characters,
                      keyboardAppearance: Theme.of(context).brightness,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: gpaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'GPA Points',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      keyboardAppearance: Theme.of(context).brightness,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final min = int.tryParse(minCtrl.text) ?? grade.minMarks;
              final max = int.tryParse(maxCtrl.text) ?? grade.maxMarks;
              final gpa = double.tryParse(gpaCtrl.text) ?? grade.gradePoint;
              final letter = letterCtrl.text.trim().isEmpty
                  ? grade.letterGrade
                  : letterCtrl.text.trim();

              provider.updateGrade(
                scaleId,
                index,
                GradeInfo(
                  minMarks: min,
                  maxMarks: max,
                  gradePoint: gpa,
                  letterGrade: letter,
                ),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  static void confirmDeleteRow(
    BuildContext context,
    GradeScaleProvider provider,
    int index,
    String scaleId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Row?'),
        content: const Text('Are you sure you want to remove this grade row?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.removeGradeAt(scaleId, index);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
