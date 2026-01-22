import 'package:flutter/material.dart';
import 'package:cgpacalculator/core/theme/app_theme.dart';

class CgpaPercentageScreen extends StatefulWidget {
  const CgpaPercentageScreen({super.key});

  @override
  State<CgpaPercentageScreen> createState() => _CgpaPercentageScreenState();
}

class _CgpaPercentageScreenState extends State<CgpaPercentageScreen> {
  final _cgpaController = TextEditingController();
  final _scaleController = TextEditingController(text: '4.0');
  double? _result;

  void _calculate() {
    final cgpa = double.tryParse(_cgpaController.text);
    final scale = double.tryParse(_scaleController.text);

    if (cgpa != null && scale != null && scale > 0) {
      setState(() {
        _result = (cgpa / scale) * 100;
      });
    } else {
      setState(() {
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CGPA to Percentage')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _cgpaController,
                      keyboardType: TextInputType.number,
                      keyboardAppearance: Theme.of(context).brightness,
                      decoration: const InputDecoration(
                        labelText: 'Your CGPA',
                        hintText: 'e.g. 3.5',
                        prefixIcon: Icon(Icons.school),
                      ),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _scaleController,
                      keyboardType: TextInputType.number,
                      keyboardAppearance: Theme.of(context).brightness,
                      decoration: const InputDecoration(
                        labelText: 'Total Scale',
                        hintText: 'e.g. 4.0 or 5.0',
                        prefixIcon: Icon(Icons.linear_scale),
                      ),
                      onChanged: (_) => _calculate(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_result != null)
              Card(
                color: AppTheme.primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        'Percentage',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_result!.toStringAsFixed(2)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cgpaController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
}
