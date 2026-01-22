import 'package:flutter/material.dart';

class MidTermSettingsCard extends StatelessWidget {
  final bool isLabSubject;
  final ValueChanged<bool> onLabSwitchChanged;
  final VoidCallback? onCreditChanged;
  final TextEditingController theoryCHController;
  final TextEditingController labCHController;

  const MidTermSettingsCard({
    super.key,
    required this.isLabSubject,
    required this.onLabSwitchChanged,
    this.onCreditChanged,
    required this.theoryCHController,
    required this.labCHController,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Lab Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lab Subject',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Switch(value: isLabSubject, onChanged: onLabSwitchChanged),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              // Credit Hours
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: theoryCHController,
                      keyboardType: TextInputType.number,
                      keyboardAppearance: Theme.of(context).brightness,
                      decoration: const InputDecoration(
                        labelText: 'Theory credit hrs',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => onCreditChanged?.call(),
                    ),
                  ),
                  if (isLabSubject) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: labCHController,
                        keyboardType: TextInputType.number,
                        keyboardAppearance: Theme.of(context).brightness,
                        decoration: const InputDecoration(
                          labelText: 'Lab credit hrs',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (_) => onCreditChanged?.call(),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
