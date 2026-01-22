import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cgpacalculator/features/settings/logic/grade_scale_provider.dart';
import 'package:cgpacalculator/core/theme/app_theme.dart';
import 'package:cgpacalculator/features/settings/widgets/grade_scale_info_dialog.dart';

class GpaPredictionScreen extends StatefulWidget {
  const GpaPredictionScreen({super.key});

  @override
  State<GpaPredictionScreen> createState() => _GpaPredictionScreenState();
}

class _GpaPredictionScreenState extends State<GpaPredictionScreen> {
  // Input: Marks obtained BEFORE final (out of 50)
  final _preFinalMarksCtrl = TextEditingController();

  // Constants based on user request
  static const double _maxPreFinal = 50.0;
  static const double _maxFinal = 50.0;

  @override
  void dispose() {
    _preFinalMarksCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the currently active grade scale dynamically
    final gradeScale = context.watch<GradeScaleProvider>().currentScale;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPA Predictor'),
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
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Instructions Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'How it works',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your total marks obtained before the Final Exam (Mid + Cloud + Sessional). '
                      'Reference is 50 marks. We will calculate what you need in the Final (out of 50) for each grade.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Input Field
            TextField(
              controller: _preFinalMarksCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              keyboardAppearance: Theme.of(context).brightness,
              decoration: InputDecoration(
                labelText: 'Pre-Final Marks (Out of $_maxPreFinal)',
                hintText: 'e.g. 35.5',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.history_edu),
                suffixText: '/ $_maxPreFinal',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),

            // Results Header
            if (_preFinalMarksCtrl.text.isNotEmpty)
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Required Final Marks (Out of 50)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            // Prediction List
            if (_preFinalMarksCtrl.text.isNotEmpty)
              ...gradeScale.map((gradeInfo) => _buildPredictionRow(gradeInfo)),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionRow(dynamic gradeInfo) {
    final preFinalObtained = double.tryParse(_preFinalMarksCtrl.text) ?? 0;

    // Safety check for invalid input
    if (preFinalObtained > _maxPreFinal) {
      return const SizedBox.shrink(); // Don't show if input exceeds max
    }

    // Calculation:
    // Min Total for Grade = gradeInfo.minMarks
    // Required Final = Min Total - PreFinalObtained
    final minTotalRequired = gradeInfo.minMarks.toDouble();
    final requiredFinal = minTotalRequired - preFinalObtained;

    // Status logic
    bool isImpossible = requiredFinal > _maxFinal;
    bool isAchieved = requiredFinal <= 0;
    bool isHard =
        requiredFinal > 40 &&
        !isImpossible; // Just a visual hint for high marks

    Color cardColor;
    Color textColor;
    String statusText;
    IconData statusIcon;

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isImpossible) {
      // Impossible: Muted/Disabled look
      cardColor = isDark
          ? colorScheme.surfaceContainerHighest
          : Colors.grey.shade100;
      textColor = isDark ? Colors.grey.shade400 : Colors.grey;
      statusText = 'Impossible';
      statusIcon = Icons.cancel;
    } else if (isAchieved) {
      // Achieved: Success look
      cardColor = isDark
          ? Colors.green.shade900.withOpacity(0.3)
          : Colors.green.shade50;
      textColor = isDark ? Colors.green.shade200 : Colors.green.shade800;
      statusText = 'Already Secured';
      statusIcon = Icons.check_circle;
    } else {
      // Needed: Standard look
      cardColor = Theme.of(context).cardColor;
      // High marks warning (orange) vs normal text
      textColor = isHard
          ? (isDark ? Colors.orange.shade300 : Colors.orange.shade800)
          : (isDark ? Colors.white : Colors.black87);

      statusText = 'Need ${requiredFinal.toStringAsFixed(1)} / $_maxFinal';
      statusIcon = Icons.flag;
    }

    return Card(
      elevation: isImpossible ? 0 : 2,
      margin: const EdgeInsets.only(bottom: 10),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isAchieved
            ? BorderSide(color: Colors.green.withOpacity(0.5))
            : BorderSide.none,
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isImpossible
                ? (isDark ? Colors.grey.shade800 : Colors.grey.shade300)
                : AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Text(
            gradeInfo.letterGrade,
            style: TextStyle(
              color: isImpossible
                  ? (isDark ? Colors.grey.shade400 : Colors.grey.shade600)
                  : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          statusText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 16,
          ),
        ),
        subtitle: isImpossible
            ? const Text('Required > 50 in Final')
            : Text('Total ${gradeInfo.minMarks}+ for ${gradeInfo.letterGrade}'),
        trailing: Icon(statusIcon, color: textColor),
      ),
    );
  }
}
