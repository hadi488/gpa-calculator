import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cgpacalculator/features/settings/logic/grade_scale_provider.dart';

class ScaleManagementDialogs {
  static void showCreateScaleDialog(BuildContext context) {
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Custom Scale'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Scale Name',
            hintText: 'e.g., My University',
          ),
          keyboardAppearance: Theme.of(context).brightness,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                context.read<GradeScaleProvider>().createCustomScale(
                  nameCtrl.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  static void confirmDelete(
    BuildContext context,
    String scaleId,
    String scaleName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Scale?'),
        content: Text(
          'Are you sure you want to delete "$scaleName"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<GradeScaleProvider>().deleteCustomScale(scaleId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  static void confirmReset(
    BuildContext context,
    String scaleId,
    String scaleName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Scale?'),
        content: Text(
          'Reset "$scaleName" to default values? Current edits will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<GradeScaleProvider>().resetCustomScale(scaleId);
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  static void confirmResetToDefault(
    BuildContext context,
    Function(String)? onScaleApplied,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Use Default Scale?'),
        content: const Text(
          'This will switch your active grading criteria back to the Default Standard (85-100 = 4.0, etc.).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<GradeScaleProvider>()
                  .resetToDefault(); // Uses 'default'
              onScaleApplied?.call('default');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Switched to Default Scale')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
