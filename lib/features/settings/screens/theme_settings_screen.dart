import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/theme_provider.dart';

/// Screen for selecting app theme
class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theme Settings')),
      body: Consumer<ThemeProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildThemeOption(
                context,
                title: 'System Default',
                mode: ThemeMode.system,
                currentMode: provider.themeMode,
                icon: Icons.brightness_auto,
                onSelected: (mode) => provider.setThemeMode(mode),
              ),
              const SizedBox(height: 8),
              _buildThemeOption(
                context,
                title: 'Light Mode',
                mode: ThemeMode.light,
                currentMode: provider.themeMode,
                icon: Icons.light_mode,
                onSelected: (mode) => provider.setThemeMode(mode),
              ),
              const SizedBox(height: 8),
              _buildThemeOption(
                context,
                title: 'Dark Mode',
                mode: ThemeMode.dark,
                currentMode: provider.themeMode,
                icon: Icons.dark_mode,
                onSelected: (mode) => provider.setThemeMode(mode),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required IconData icon,
    required Function(ThemeMode) onSelected,
  }) {
    final isSelected = mode == currentMode;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: RadioListTile<ThemeMode>(
        value: mode,
        groupValue: currentMode,
        onChanged: (value) {
          if (value != null) {
            onSelected(value);
          }
        },
        title: Row(
          children: [
            Icon(icon, color: isSelected ? colorScheme.primary : Colors.grey),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? colorScheme.primary : null,
              ),
            ),
          ],
        ),
        activeColor: colorScheme.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
