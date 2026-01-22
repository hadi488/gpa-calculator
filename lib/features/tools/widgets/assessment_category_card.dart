import 'package:flutter/material.dart';
import '../models/subject_gpa_models.dart';

class AssessmentCategoryCard extends StatefulWidget {
  final AssessmentCategory category;
  final bool isDisabled;
  final VoidCallback onUpdate;
  final VoidCallback onAdd;
  final Function(int) onRemove;

  const AssessmentCategoryCard({
    super.key,
    required this.category,
    required this.isDisabled,
    required this.onUpdate,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<AssessmentCategoryCard> createState() => _AssessmentCategoryCardState();
}

class _AssessmentCategoryCardState extends State<AssessmentCategoryCard> {
  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final isDisabled = widget.isDisabled;
    final canAdd =
        category.maxItems == null || category.items.length < category.maxItems!;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isDisabled ? 0 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDisabled
            ? BorderSide(color: Colors.grey.shade300, width: 1)
            : BorderSide.none,
      ),
      color: isDisabled ? Colors.grey.shade300 : null,
      child: ExpansionTile(
        key: ValueKey(
          isDisabled,
        ), // Force rebuild to reset expansion state when disabled changes
        initiallyExpanded: category.isExpanded && !isDisabled,
        onExpansionChanged: (expanded) {
          category.isExpanded = expanded;
        },
        shape: const Border(), // Remove default borders
        title: Row(
          children: [
            Text(
              category.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDisabled ? Colors.grey.shade500 : null,
                decoration: isDisabled ? TextDecoration.lineThrough : null,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 50,
              child: TextField(
                controller: category.weightController,
                keyboardType: TextInputType.number,
                keyboardAppearance: Theme.of(context).brightness,
                textAlign: TextAlign.center,
                // Disable editing if weights are individual OR category is disabled
                readOnly: category.hasIndividualWeights || isDisabled,
                style: TextStyle(
                  color: isDisabled ? Colors.grey.shade500 : null,
                ),
                decoration: const InputDecoration(
                  labelText: 'Wgt',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  floatingLabelAlignment: FloatingLabelAlignment.center,
                  isDense: true,
                  border: OutlineInputBorder(),
                  suffixText: '%',
                ),
                onChanged: (val) {
                  category.weight = double.tryParse(val) ?? 0;
                  widget.onUpdate();
                },
              ),
            ),
          ],
        ),
        subtitle: Text(
          'Score: ${category.weightedScore.toStringAsFixed(2)} / ${category.weight}',
          style: TextStyle(
            color: isDisabled
                ? Colors.grey.shade500
                : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.6)
                      : Theme.of(context).primaryColor.withValues()),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        enabled: !isDisabled,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...category.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _GradeItemRow(
                    key: ValueKey(item),
                    item: item,
                    index: index,
                    showWeight: category.hasIndividualWeights,
                    canDelete: category.maxItems != 1,
                    onUpdate: widget.onUpdate,
                    onRemove: widget.onRemove,
                  );
                }),
                const SizedBox(height: 8),
                if (canAdd)
                  OutlinedButton.icon(
                    onPressed: widget.onAdd,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      'Add ${category.name == 'Quizzes' ? 'Quiz' : category.name.substring(0, category.name.length - 1)}',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeItemRow extends StatelessWidget {
  final GradeItem item;
  final int index;
  final bool showWeight;
  final bool canDelete;
  final VoidCallback onUpdate;
  final Function(int) onRemove;

  const _GradeItemRow({
    required Key key,
    required this.item,
    required this.index,
    required this.showWeight,
    required this.canDelete,
    required this.onUpdate,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(item.name)),
          const SizedBox(width: 8),
          // Weight Input
          if (showWeight) ...[
            SizedBox(
              width: 50,
              child: TextFormField(
                controller: item.weightController,
                keyboardType: TextInputType.number,
                keyboardAppearance: Theme.of(context).brightness,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'Wgt',
                  suffixText: '%',
                  isDense: true,
                  border: OutlineInputBorder(),
                  floatingLabelAlignment: FloatingLabelAlignment.center,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 12,
                  ),
                ),
                onChanged: (val) {
                  item.weight = double.tryParse(val) ?? 0;
                  onUpdate();
                },
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Obtained
          SizedBox(
            width: 70,
            child: TextFormField(
              controller: item.obtainedController,
              keyboardType: TextInputType.number,
              keyboardAppearance: Theme.of(context).brightness,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                labelText: 'Obt',
                hintText: 'Obt',
                isDense: true,
                border: OutlineInputBorder(),
                floatingLabelAlignment: FloatingLabelAlignment.center,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 14,
                ),
              ),
              onChanged: (val) {
                double newObtained = double.tryParse(val) ?? 0;
                if (newObtained > item.total) {
                  newObtained = item.total;
                  item.obtainedController.text = item.total % 1 == 0
                      ? item.total.toStringAsFixed(0)
                      : item.total.toString();
                  item
                      .obtainedController
                      .selection = TextSelection.fromPosition(
                    TextPosition(offset: item.obtainedController.text.length),
                  );
                }
                item.obtained = newObtained;
                onUpdate();
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text('/'),
          ),
          // Total
          SizedBox(
            width: 70,
            child: TextFormField(
              controller: item.totalController,
              keyboardType: TextInputType.number,
              keyboardAppearance: Theme.of(context).brightness,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                labelText: 'Tot',
                isDense: true,
                border: OutlineInputBorder(),
                floatingLabelAlignment: FloatingLabelAlignment.center,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 14,
                ),
              ),
              onChanged: (val) {
                double newTotal = double.tryParse(val) ?? 0;
                item.total = newTotal;

                if (item.obtained > newTotal) {
                  item.obtained = newTotal;
                  item.obtainedController.text = newTotal % 1 == 0
                      ? newTotal.toStringAsFixed(0)
                      : newTotal.toString();
                }
                onUpdate();
              },
            ),
          ),
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.grey),
              onPressed: () => onRemove(index),
            ),
        ],
      ),
    );
  }
}
