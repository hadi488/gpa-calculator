import 'package:flutter/material.dart';

class StudentEmptyState extends StatelessWidget {
  final VoidCallback? onAddStudent;

  const StudentEmptyState({super.key, this.onAddStudent});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Students Yet',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Add a student to start tracking grades',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
            if (onAddStudent != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAddStudent,
                icon: const Icon(Icons.person_add),
                label: const Text('Add Student'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
