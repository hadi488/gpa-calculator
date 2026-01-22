/// Home Screen - Main calculator selection screen
///
/// This is the entry point showing different calculator types.
/// Refactored to use modular components for better maintainability.
library;

import 'package:flutter/material.dart';
import 'package:cgpacalculator/features/student_management/screens/student_list_screen.dart';
import 'package:cgpacalculator/features/settings/screens/settings_screen.dart';
import 'package:cgpacalculator/features/tools/screens/cgpa_percentage_screen.dart';
import 'package:cgpacalculator/features/tools/screens/aggregate_calculator_screen.dart';
import 'package:cgpacalculator/features/tools/screens/gpa_prediction_screen.dart';
import 'package:cgpacalculator/features/tools/screens/lab_gpa_calculator_screen.dart';
import 'package:cgpacalculator/features/tools/screens/subject_gpa_screen.dart';
import 'package:cgpacalculator/features/tools/screens/mid_term_gpa_calculator_screen.dart';

// Modular components
import '../models/calculator_type.dart';
import '../widgets/calculator_grid_card.dart';
import '../widgets/settings_section_card.dart';
import '../widgets/home_drawer.dart';

/// Home screen with calculator type selection
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Available calculator types definitions
  static const List<CalculatorType> calculatorTypes = [
    CalculatorType(
      title: 'BS CGPA',
      subtitle: 'Bachelor\'s Degree',
      icon: Icons.school,
      color: Color(0xFF3F51B5),
      description:
          'Calculate GPA for BS/Bachelor programs with semester-wise tracking',
    ),
    CalculatorType(
      title: 'MS CGPA',
      subtitle: 'Master\'s Degree',
      icon: Icons.workspace_premium,
      color: Color(0xFF9C27B0),
      description:
          'Calculate GPA for MS/Master programs with course management',
    ),
    CalculatorType(
      title: 'Subject GPA',
      subtitle: 'Quick Calculation',
      icon: Icons.calculate,
      color: Color(0xFF00BCD4),
      description: 'Calculate GPA for individual subjects quickly',
    ),
    CalculatorType(
      title: 'Lab Subject GPA',
      subtitle: 'Lab Calculation',
      icon: Icons.science,
      color: Colors.teal,
      description: 'Calculate GPA for lab subjects with custom total marks',
    ),
    CalculatorType(
      title: 'Mid Term GPA',
      subtitle: 'Mid Semester',
      icon: Icons.event_note,
      color: Color(0xFFFF9800),
      description: 'Calculate mid-term GPA with partial grades',
    ),
    CalculatorType(
      title: 'CGPA to %',
      subtitle: 'Conversion',
      icon: Icons.percent,
      color: Colors.teal,
      description: 'Convert CGPA to Percentage',
    ),
    CalculatorType(
      title: 'Aggregate',
      subtitle: 'Merit Calc',
      icon: Icons.pie_chart,
      color: Colors.pink,
      description: 'Calculate admission aggregate',
    ),
    CalculatorType(
      title: 'Prediction',
      subtitle: 'Grade Forecaster',
      icon: Icons.trending_up,
      color: Colors.indigo,
      description: 'Predict required marks for target grades',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HomeDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: const Text('GPA Calculator'),
            centerTitle: true,
            pinned: true,
            floating: false,
            actions: [
              IconButton(
                onPressed: () => _openSettings(context),
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Calculator type grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0, // Strictly Square as requested
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => CalculatorGridCard(
                  type: calculatorTypes[index],
                  index: index,
                  onTap: () =>
                      _openCalculator(context, calculatorTypes[index], index),
                ),
                childCount: calculatorTypes.length,
              ),
            ),
          ),

          // Settings Section
          SliverToBoxAdapter(
            child: SettingsSectionCard(onTap: () => _openSettings(context)),
          ),

          // Bottom padding
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 24),
            sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
        ],
      ),
    );
  }

  /// Opens the settings screen
  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  /// Opens the selected calculator
  void _openCalculator(BuildContext context, CalculatorType type, int index) {
    if (type.title == 'Subject GPA') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SubjectGpaScreen()),
      );
      return;
    }
    if (type.title == 'Lab Subject GPA') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LabGpaCalculatorScreen()),
      );
      return;
    }
    if (type.title == 'Mid Term GPA') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MidTermGpaCalculatorScreen()),
      );
      return;
    }
    if (type.title == 'CGPA to %') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CgpaPercentageScreen()),
      );
      return;
    }
    if (type.title == 'Aggregate') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AggregateCalculatorScreen()),
      );
      return;
    }
    if (type.title == 'Prediction') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GpaPredictionScreen()),
      );
      return;
    }

    // Default: Open Student List Screen (BS/MS)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentListScreen(calculatorType: type.title),
      ),
    );
  }
}
