import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cgpacalculator/features/settings/logic/grade_scale_provider.dart';
import '../widgets/scale_management_dialogs.dart';
import '../widgets/grade_scale_list_item.dart';

class GradeSettingsScreen extends StatefulWidget {
  final Function(String)? onScaleApplied;

  const GradeSettingsScreen({super.key, this.onScaleApplied});

  @override
  State<GradeSettingsScreen> createState() => _GradeSettingsScreenState();
}

class _GradeSettingsScreenState extends State<GradeSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade Scaling'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Custom Scale',
            onPressed: () =>
                ScaleManagementDialogs.showCreateScaleDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.restore_page),
            tooltip: 'Reset to Default Scale',
            onPressed: () => ScaleManagementDialogs.confirmResetToDefault(
              context,
              widget.onScaleApplied,
            ),
          ),
        ],
      ),
      body: Consumer<GradeScaleProvider>(
        builder: (context, provider, child) {
          final scales = provider.availableScales;

          if (scales.isEmpty) {
            return const Center(child: Text('No grade scales available.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: scales.length,
            cacheExtent: 1000,
            itemBuilder: (context, index) {
              final scale = scales[index];
              return GradeScaleListItem(
                scale: scale,
                isActive: scale.id == provider.currentScaleId,
                provider: provider,
                gradeList: provider.getScaleById(scale.id),
                onScaleApplied: widget.onScaleApplied,
              );
            },
          );
        },
      ),
    );
  }
}
