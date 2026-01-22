import 'package:flutter/material.dart';
import 'package:cgpacalculator/data/services/grade_scale_service.dart';
import 'package:cgpacalculator/features/settings/logic/grade_scale_provider.dart';

import 'grade_form_dialogs.dart';

class GradeScaleTable extends StatelessWidget {
  final GradeScaleProvider provider;
  final List<GradeInfo> grades;
  final bool isCustom;
  final bool isActive;
  final String scaleId;

  const GradeScaleTable({
    super.key,
    required this.provider,
    required this.grades,
    required this.isCustom,
    required this.isActive,
    required this.scaleId,
  });

  @override
  Widget build(BuildContext context) {
    if (grades.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('No grades defined for this scale.'),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header Row
          Container(
            color: Theme.of(
              context,
            ).colorScheme.surfaceVariant.withOpacity(0.3),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      'Marks',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Grade',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'GPA',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Fixed width for actions/alignment
                SizedBox(width: 96),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          // Data Rows
          ...grades.asMap().entries.map((entry) {
            final index = entry.key;
            final g = entry.value;
            final canEdit = isCustom;

            return InkWell(
              onTap: canEdit
                  ? () => GradeFormDialogs.showEditGradeDialog(
                      context,
                      provider,
                      index,
                      g,
                      scaleId,
                    )
                  : null,
              hoverColor: Theme.of(context).primaryColor.withOpacity(0.05),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: canEdit ? 0.0 : 8.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Text('${g.minMarks} - ${g.maxMarks}'),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          g.letterGrade,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(g.gradePoint.toStringAsFixed(2)),
                      ),
                    ),
                    // Action Buttons / Alignment Spacer
                    SizedBox(
                      width: 96,
                      child: isCustom
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  color: Colors.blue,
                                  onPressed: () {
                                    GradeFormDialogs.showEditGradeDialog(
                                      context,
                                      provider,
                                      index,
                                      g,
                                      scaleId,
                                    );
                                  },
                                  tooltip: 'Edit Range',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 24,
                                  ),
                                  splashRadius: 20,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                  ),
                                  color: Colors.red,
                                  onPressed: () {
                                    GradeFormDialogs.confirmDeleteRow(
                                      context,
                                      provider,
                                      index,
                                      scaleId,
                                    );
                                  },
                                  tooltip: 'Delete Row',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 24,
                                  ),
                                  splashRadius: 20,
                                ),
                              ],
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
