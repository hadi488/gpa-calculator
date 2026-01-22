import 'package:flutter/material.dart';
import 'package:cgpacalculator/core/theme/app_theme.dart';
import 'grade_settings_screen.dart';
import 'theme_settings_screen.dart';

/// Main settings screen linking to various configuration options
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsCard(
            context,
            icon: Icons.tune,
            title: 'Grade Criteria',
            subtitle: 'Customize grading scale and ranges',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GradeSettingsScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context,
            icon: Icons.brightness_6,
            title: 'Theme & Appearance',
            subtitle: 'Choose between Light and Dark mode',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ThemeSettingsScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
