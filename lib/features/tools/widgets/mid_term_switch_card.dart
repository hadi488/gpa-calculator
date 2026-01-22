import 'package:flutter/material.dart';

class MidTermSwitchCard extends StatelessWidget {
  final bool isLabSubject;
  final ValueChanged<bool> onLabSwitchChanged;

  const MidTermSwitchCard({
    super.key,
    required this.isLabSubject,
    required this.onLabSwitchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lab Subject',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Switch(value: isLabSubject, onChanged: onLabSwitchChanged),
            ],
          ),
        ),
      ),
    );
  }
}
