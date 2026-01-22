import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/student.dart';
import '../../../../data/services/gpa_calculator_service.dart';
import '../../../../features/settings/logic/grade_scale_provider.dart';
import '../../../../core/theme/app_theme.dart';

class CgpaCard extends StatelessWidget {
  final Student student;
  final double cgpa;

  const CgpaCard({super.key, required this.student, required this.cgpa});

  @override
  Widget build(BuildContext context) {
    // Get letter grade using the student's specific scale if available
    final gradeProvider = Provider.of<GradeScaleProvider>(
      context,
      listen: false,
    );
    String letterGrade;

    if (student.gradeScaleId != null) {
      letterGrade = gradeProvider.getLetterGradeForScale(
        cgpa,
        student.gradeScaleId!,
      );
    } else {
      letterGrade = gradeProvider.getLetterGrade(cgpa);
    }

    final totalCredits = GpaCalculatorService.calculateTotalCreditHours(
      student,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.getGpaGradient(cgpa),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getGpaColor(cgpa).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // CGPA value
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CGPA',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    cgpa.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      letterGrade,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatChip(
                Icons.school,
                '${student.semesters.length} Semesters',
              ),
              const SizedBox(height: 8),
              _buildStatChip(Icons.credit_card, '$totalCredits Credits'),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a stat chip for the CGPA card
  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
