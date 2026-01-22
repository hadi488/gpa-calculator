import 'package:flutter/material.dart';
import '../../widgets/assessment_category_card.dart';
import '../../widgets/mid_term_switch_card.dart';
import '../../widgets/mid_term_credits_card.dart';
import '../../widgets/weight_warning_banner.dart';
import '../../models/subject_gpa_models.dart';
import '../../logic/subject_gpa_controller.dart';
// Note: MidTermScreenController import removed as we use generic SubjectGpaController

class AssessmentListSection extends StatelessWidget {
  final SubjectGpaController theoryController;
  final SubjectGpaController labController;
  final TextEditingController theoryCHController;
  final TextEditingController labCHController;
  final bool isLabSubject;
  final Function(bool)? onLabSwitchChanged;
  final VoidCallback? onCreditChanged;
  final bool showLabSwitch;

  const AssessmentListSection({
    super.key,
    required this.theoryController,
    required this.labController,
    required this.theoryCHController,
    required this.labCHController,
    required this.isLabSubject,
    this.onLabSwitchChanged,
    this.onCreditChanged,
    this.showLabSwitch = true,
  });

  @override
  Widget build(BuildContext context) {
    final theoryCats = theoryController.categories;
    final labCats = labController.categories;

    // Warnings Logic
    bool showTheoryWarning = false;
    bool showLabWarning = false;

    if (theoryController.hasItem('Sessionals') &&
        theoryController.totalWeight != 50) {
      showTheoryWarning = true;
    }

    if (isLabSubject &&
        labController.hasItem('Lab Sessionals') &&
        labController.totalWeight != 50) {
      showLabWarning = true;
    }

    // Item Count Calculation
    int itemCount = 0;

    if (showLabSwitch) itemCount++; // 0: Switch

    if (isLabSubject) {
      itemCount++; // 1: Credits (if Lab is ON)
    }

    itemCount++; // Theory Header
    itemCount += theoryCats.length; // Theory Cats

    if (isLabSubject) {
      itemCount++; // Divider
      itemCount++; // Lab Header
      itemCount += labCats.length; // Lab Cats
    }

    return Column(
      children: [
        // Sticky Warnings
        if (showTheoryWarning || showLabWarning)
          Column(
            children: [
              if (showTheoryWarning)
                WeightWarningBanner(
                  totalWeight: theoryController.totalWeight,
                  label: 'Theory',
                ),
              if (showLabWarning)
                WeightWarningBanner(
                  totalWeight: labController.totalWeight,
                  label: 'Lab',
                ),
            ],
          ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            cacheExtent: 2000,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              // 0: Switch Card
              if (showLabSwitch) {
                if (index == 0) {
                  return MidTermSwitchCard(
                    isLabSubject: isLabSubject,
                    onLabSwitchChanged: onLabSwitchChanged!,
                  );
                }
              }

              // Adjust logical index base depending on if switch is shown
              // if switch is visible, index 0 is switch.
              // if switch is hidden, index 0 is first item (Credits or Theory Header)

              // Let's use a cleaner flow or just adjust offsets.
              // Current index being rendered
              // If switch is shown, and index was 0, we returned.

              int currentIndex = showLabSwitch ? 1 : 0;

              // 1: Credits Card (Conditional)
              if (isLabSubject) {
                if (index == currentIndex) {
                  return MidTermCreditsCard(
                    isLabSubject: isLabSubject,
                    onCreditChanged: () {
                      onCreditChanged?.call();
                    },
                    theoryCHController: theoryCHController,
                    labCHController: labCHController,
                  );
                }
                currentIndex++;
              }

              // Theory Header
              if (index == currentIndex) {
                return _buildSectionHeader(context, 'Theory Marks');
              }
              currentIndex++;

              final theoryStart = currentIndex;
              final theoryEnd = theoryStart + theoryCats.length;

              // Theory Categories
              if (index >= theoryStart && index < theoryEnd) {
                final catIndex = index - theoryStart;
                final category = theoryCats[catIndex];

                return _buildCategoryItem(
                  context,
                  category,
                  'theory',
                  theoryController,
                  theoryController.hasItem('Sessionals'),
                  'Mid Term',
                );
              }

              // Only proceed if Lab is ON (Logic check)
              // But if isLabSubject is false, itemCount wouldn't include these, so index shouldn't reach here.
              // However, safe check:
              if (!isLabSubject) return const SizedBox.shrink();

              // Divider
              if (index == theoryEnd) {
                return const Divider(height: 48, thickness: 2);
              }

              // Lab Header
              if (index == theoryEnd + 1) {
                return _buildSectionHeader(context, 'Lab Marks');
              }

              // Lab Categories
              final labStart = theoryEnd + 2;
              final labIndex = index - labStart;

              if (labIndex >= 0 && labIndex < labCats.length) {
                final category = labCats[labIndex];
                return _buildCategoryItem(
                  context,
                  category,
                  'lab',
                  labController,
                  labController.hasItem('Lab Sessionals'),
                  'Lab Mid Term',
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    AssessmentCategory category,
    String keyPrefix,
    SubjectGpaController logicController,
    bool hasSessionals,
    String midTermName,
  ) {
    bool isDisabled = false;
    if (category.name.contains(midTermName)) {
      if (hasSessionals) isDisabled = true;
    }

    return RepaintBoundary(
      child: AssessmentCategoryCard(
        key: ValueKey('${keyPrefix}_${category.name}'),
        category: category,
        isDisabled: isDisabled,
        onUpdate: logicController.calculate,
        onAdd: () => logicController.addItem(category),
        onRemove: (idx) => logicController.removeItem(category, idx),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Column(
      children: [
        Center(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
