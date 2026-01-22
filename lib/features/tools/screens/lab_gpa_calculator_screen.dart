import 'package:flutter/material.dart';

import 'logic/lab_screen_controller.dart';
import 'components/assessment_list_section.dart';
import 'components/lab_result_section.dart';
import 'package:cgpacalculator/features/settings/widgets/grade_scale_info_dialog.dart';

class LabGpaCalculatorScreen extends StatefulWidget {
  const LabGpaCalculatorScreen({super.key});

  @override
  State<LabGpaCalculatorScreen> createState() => _LabGpaCalculatorScreenState();
}

class _LabGpaCalculatorScreenState extends State<LabGpaCalculatorScreen> {
  final _controller = LabScreenController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _reset() {
    // Re-initialize controller logic
    setState(() {
      _controller.reset();
    });
    // Or just simple navigation reset if preferred, but controller reset is cleaner.
    // However, existing pattern used pushReplacement, which is a bit abrupt.
    // Let's stick to controller reset if possible, but the simplest way to match previous behavior:
    // Actually, simple provider reset is enough since we rebuild.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Subject GPA'),
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
            onPressed: _reset,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return Column(
            children: [
              Expanded(
                child: AssessmentListSection(
                  theoryController: _controller.theoryController,
                  labController: _controller.labController,
                  theoryCHController: _controller.theoryCHController,
                  labCHController: _controller.labCHController,
                  isLabSubject:
                      true, // Lab Calculator always has Lab Subject active
                  showLabSwitch: false,
                  onLabSwitchChanged:
                      (val) {}, // No switch in Lab Screen, implies always true
                  onCreditChanged: () => setState(
                    () {},
                  ), // Trigger local set state if needed, but ListenableBuilder handles it.
                  // Wait, AssessmentListSection expects 'onCreditChanged'.
                  // Actually, the ListenableBuilder wraps the whole body, so any notifyListeners()rebuilds it.
                ),
              ),
              LabResultSection(controller: _controller),
            ],
          );
        },
      ),
    );
  }
}
