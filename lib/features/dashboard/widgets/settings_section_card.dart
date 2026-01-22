import 'package:flutter/material.dart';
import 'package:cgpacalculator/core/theme/app_theme.dart';

class SettingsSectionCard extends StatelessWidget {
  final VoidCallback onTap;

  const SettingsSectionCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.tune, color: AppTheme.primaryColor),
          ),
          title: const Text('General Settings'),
          subtitle: const Text('Theme, Grading, and more'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}
