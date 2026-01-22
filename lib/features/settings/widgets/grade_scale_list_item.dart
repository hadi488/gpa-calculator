import 'package:flutter/material.dart';
import 'package:cgpacalculator/data/services/grade_scale_service.dart';
import 'package:cgpacalculator/features/settings/logic/grade_scale_provider.dart';
import 'package:cgpacalculator/features/settings/widgets/smooth_expansion_tile.dart';

import 'grade_scale_table.dart';
import 'grade_form_dialogs.dart';
import 'scale_management_dialogs.dart';

class GradeScaleListItem extends StatelessWidget {
  final ({String id, String name, bool isCustom}) scale;
  final bool isActive;
  final GradeScaleProvider provider;
  final List<GradeInfo> gradeList;
  final Function(String)? onScaleApplied;

  const GradeScaleListItem({
    super.key,
    required this.scale,
    required this.isActive,
    required this.provider,
    required this.gradeList,
    this.onScaleApplied,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isActive
              ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
              : BorderSide.none,
        ),
        child: SmoothExpansionTile(
          key: PageStorageKey(scale.id),
          leading: CircleAvatar(
            backgroundColor: isActive
                ? Theme.of(context).primaryColor
                : Colors.grey[200],
            child: Icon(
              scale.isCustom ? Icons.edit_note : Icons.school,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
          ),
          title: Text(
            scale.name,
            maxLines: 3,
            overflow: TextOverflow.visible,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: isActive
              ? const Text(
                  'Active Scale',
                  style: TextStyle(color: Colors.green),
                )
              : null,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).scaffoldBackgroundColor.withOpacity(0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Grade Table
                  GradeScaleTable(
                    provider: provider,
                    grades: gradeList,
                    isCustom: scale.isCustom,
                    isActive: isActive,
                    scaleId: scale.id,
                  ),
                  const SizedBox(height: 12),

                  // Add Grade Row Button (Custom Only - always editable)
                  if (scale.isCustom)
                    Align(
                      alignment: Alignment.center,
                      child: OutlinedButton.icon(
                        onPressed: () => GradeFormDialogs.showAddGradeDialog(
                          context,
                          provider,
                          scale.id,
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Grade Row'),
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Delete Button (Custom Only)
                      if (scale.isCustom)
                        TextButton.icon(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () => ScaleManagementDialogs.confirmDelete(
                            context,
                            scale.id,
                            scale.name,
                          ),
                        ),
                      if (scale.isCustom)
                        TextButton.icon(
                          icon: const Icon(Icons.restore),
                          label: const Text('Reset'),
                          onPressed: () => ScaleManagementDialogs.confirmReset(
                            context,
                            scale.id,
                            scale.name,
                          ),
                        ),

                      const Spacer(),

                      // Select/Active Button
                      if (!isActive)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Use this Scale'),
                          onPressed: () {
                            provider.selectScale(scale.id);
                            onScaleApplied?.call(scale.id);
                          },
                        )
                      else
                        Chip(
                          label: const Text(
                            'Currently Active',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                    ],
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
