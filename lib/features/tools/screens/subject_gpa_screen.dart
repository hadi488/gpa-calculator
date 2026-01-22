import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/subject_gpa_models.dart';
import '../logic/subject_gpa_controller.dart';
import '../widgets/assessment_category_card.dart';
import '../widgets/gpa_result_bar.dart';

import 'package:cgpacalculator/features/settings/widgets/grade_scale_info_dialog.dart';

class SubjectGpaScreen extends StatelessWidget {
  const SubjectGpaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          SubjectGpaController(initialCategories: _getInitialCategories()),
      child: const _SubjectGpaScreenContent(),
    );
  }

  List<AssessmentCategory> _getInitialCategories() {
    return [
      AssessmentCategory(
        name: 'Quizzes',
        weight: 15,
        items: [GradeItem(name: 'Quiz 1')],
      ),
      AssessmentCategory(
        name: 'Assignments',
        weight: 10,
        items: [GradeItem(name: 'Assignment 1')],
      ),
      AssessmentCategory(
        name: 'Mid Term',
        weight: 25,
        maxItems: 1,
        items: [GradeItem(name: 'Mid Term', total: 25)],
      ),
      AssessmentCategory(
        name: 'Final Term',
        weight: 50,
        maxItems: 1,
        items: [GradeItem(name: 'Final Exam', total: 50)],
      ),
      AssessmentCategory(
        name: 'Sessionals',
        weight: 0,
        items: [],
        hasIndividualWeights: true,
      ),
    ];
  }
}

class _SubjectGpaScreenContent extends StatelessWidget {
  const _SubjectGpaScreenContent();

  void _reset(BuildContext context) {
    // To reset, we can simply pop and push, or rebuild.
    // Or we can ask controller to reset.
    // Given the complex state (TextControllers), a full rebuild is cleanest for "Reset".
    // But let's try calling controller.reset() which clears items.
    // However, default items (like Quiz 1) need to be re-added.
    // A clean way is to replace the controller or just navigate replacement.

    // For now: Just use the controller's reset mechanism (clearing) + re-adding defaults Manually?
    // Actually, simple solution for this specific screen:
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            const SubjectGpaScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch controller for changes
    final controller = context.watch<SubjectGpaController>();
    final isWeightValid = controller.totalWeight == 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subject GPA Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Grading Criteria',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const GradeScaleInfoDialog(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _reset(context),
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Column(
        children: [
          // Weight Warning Banner
          if (!isWeightValid)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.orange.withOpacity(0.2),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total Weight: ${controller.totalWeight.toStringAsFixed(0)}% (Should be 100%)',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.green.withOpacity(0.2),
              child: const Center(
                child: Text(
                  "Total Weight: 100%",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Main List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              cacheExtent: 2000,
              itemCount: controller.categories.length,
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                bool isDisabled = false;

                // Check if Sessionals exist to disable Mid Term
                if (category.name.contains('Mid Term')) {
                  // Logic handled in controller for calculation,
                  // but UI needs to look disabled.
                  final hasSessionals =
                      controller.hasItem('Sessionals') ||
                      controller.hasItem('Lab Sessionals');
                  if (hasSessionals) isDisabled = true;
                }

                return RepaintBoundary(
                  child: AssessmentCategoryCard(
                    category: category,
                    isDisabled: isDisabled,
                    onUpdate: controller.calculate,
                    onAdd: () => controller.addItem(category),
                    onRemove: (itemIndex) =>
                        controller.removeItem(category, itemIndex),
                  ),
                );
              },
            ),
          ),

          // Bottom Result Bar
          GpaResultBar(finalAbsoluteMarks: controller.finalAbsoluteMarks),
        ],
      ),
    );
  }
}
