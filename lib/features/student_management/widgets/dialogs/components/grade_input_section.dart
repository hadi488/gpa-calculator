import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cgpacalculator/data/services/grade_scale_service.dart';
import 'package:cgpacalculator/features/settings/logic/grade_scale_provider.dart';
import '../logic/add_subject_controller.dart';

class GradeInputSection extends StatelessWidget {
  final AddSubjectController controller;

  const GradeInputSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle between marks and GPA input
        Row(
          children: [
            Text(
              'Grade (optional):',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 12),
            ChoiceChip(
              label: const Text('Marks'),
              selected: controller.useMarksInput,
              onSelected: (selected) {
                if (selected) controller.setInputMode(true);
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('GPA'),
              selected: !controller.useMarksInput,
              onSelected: (selected) {
                if (selected) controller.setInputMode(false);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Info text
        Text(
          'Leave empty if grade not yet available',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 12),

        // Marks or GPA input with preview
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input field
            Expanded(
              flex: 2,
              child: controller.useMarksInput
                  ? _buildMarksInput(context)
                  : _buildGpaInput(context),
            ),
            const SizedBox(width: 12),

            // Grade preview
            Expanded(flex: 1, child: _buildGradePreview(context)),
          ],
        ),
      ],
    );
  }

  Widget _buildMarksInput(BuildContext context) {
    return TextFormField(
      controller: controller.marksController,
      keyboardAppearance: Theme.of(context).brightness,
      decoration: const InputDecoration(
        labelText: 'Marks (0-100)',
        hintText: 'Optional',
        prefixIcon: Icon(Icons.score),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        LengthLimitingTextInputFormatter(5),
      ],
      onChanged: controller.updateGradePreviewFromMarks,
      validator: controller.useMarksInput
          ? (value) {
              if (value == null || value.isEmpty) return null;
              final marks = int.tryParse(value);
              if (marks == null || marks < 0 || marks > 100) {
                return '0-100';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildGpaInput(BuildContext context) {
    return TextFormField(
      controller: controller.gpaController,
      keyboardAppearance: Theme.of(context).brightness,
      decoration: const InputDecoration(
        labelText: 'GPA (0.00-4.00)',
        hintText: 'Optional',
        prefixIcon: Icon(Icons.grade),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        LengthLimitingTextInputFormatter(4),
      ],
      onChanged: controller.updateGradePreviewFromGpa,
      validator: !controller.useMarksInput
          ? (value) {
              if (value == null || value.isEmpty) return null;
              final gpa = double.tryParse(value);
              if (gpa == null || gpa < 0.0 || gpa > 4.0) {
                return '0.00-4.00';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildGradePreview(BuildContext context) {
    final gpaPreview = controller.gpaPreview;
    final gradePreview = controller.gradePreview;

    if (gpaPreview == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            Text('Grade', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text(
              'N/A',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Text('Pending', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      );
    }

    final color = Color(GradeScaleService.getGradeColor(gpaPreview));
    String letterGrade;

    if (gradePreview != null) {
      letterGrade = gradePreview.letterGrade;
    } else {
      // Logic for getting letter from provider based on student's scale
      // Since controller logic handles this, we might want to expose it there?
      // Actually, the preview logic inside controller sets gradePreview.
      // If gradePreview is null but gpaPreview is NOT null, it implies direct GPA mode
      // where we might not have a specific 'minMarks' but we can still guess letter.

      // We need access to provider to reuse the exact 'getLetterGrade' logic.
      final provider = context.read<GradeScaleProvider>();
      // We can use the scale ID from controller if public, or just rely on global default?
      // Ideally controller should expose 'predictedLetter'.
      // For now, let's replicate the simple fetch roughly or access provider.
      // The original code did:
      /*
        if (_studentScaleId != null) {
            letterGrade = provider.getLetterGradeForScale(
            _gpaPreview!,
            _studentScaleId!,
            );
        } else {
            letterGrade = provider.getLetterGrade(_gpaPreview!);
        }
       */
      // We can add a helper in Controller "getPredictedLetter(context)" or similar.
      // Or simpler: Just calculate it here assuming context is valid.
      // But 'studentScaleId' is private in controller.
      // Let's make it public getter in controller? No, let's add a method to controller "getDisplayLetterGrade(provider)".
      letterGrade = controller.getDisplayLetterGrade(provider);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(
            letterGrade,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            gpaPreview.toStringAsFixed(2),
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
}
