import 'package:flutter/material.dart';

import 'package:cgpacalculator/features/settings/widgets/grade_scale_info_dialog.dart';

import 'logic/mid_term_screen_controller.dart';
import 'components/assessment_list_section.dart';
import 'components/combined_result_section.dart';

class MidTermGpaCalculatorScreen extends StatefulWidget {
  const MidTermGpaCalculatorScreen({super.key});

  @override
  State<MidTermGpaCalculatorScreen> createState() =>
      _MidTermGpaCalculatorScreenState();
}

class _MidTermGpaCalculatorScreenState
    extends State<MidTermGpaCalculatorScreen> {
  late MidTermScreenController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MidTermScreenController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _reset() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            const MidTermGpaCalculatorScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mid Term GPA Calculator'),
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
                  isLabSubject: _controller.isLabSubject,
                  onLabSwitchChanged: _controller.setLabSubject,
                  onCreditChanged: () {},
                ),
              ),
              CombinedResultSection(controller: _controller),
            ],
          );
        },
      ),
    );
  }
}
