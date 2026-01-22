import 'package:flutter/material.dart';

class WeightWarningBanner extends StatelessWidget {
  final double totalWeight;
  final String label;

  const WeightWarningBanner({
    super.key,
    required this.totalWeight,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 1),
      color: Colors.blue.withOpacity(0.1), // Blue for informational
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label Weight: ${totalWeight.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
