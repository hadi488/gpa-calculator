import 'package:flutter/material.dart';

/// Calculator type configuration
class CalculatorType {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String description;

  const CalculatorType({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.description,
  });
}
