import 'package:flutter/material.dart';
import 'package:cgpacalculator/core/theme/app_theme.dart';

class AggregateCalculatorScreen extends StatefulWidget {
  const AggregateCalculatorScreen({super.key});

  @override
  State<AggregateCalculatorScreen> createState() =>
      _AggregateCalculatorScreenState();
}

class _AggregateItem {
  String name;
  TextEditingController obtainedCtrl = TextEditingController();
  TextEditingController totalCtrl = TextEditingController();
  TextEditingController weightCtrl = TextEditingController();

  _AggregateItem(this.name, String weight) {
    weightCtrl.text = weight;
  }
}

class _AggregateCalculatorScreenState extends State<AggregateCalculatorScreen> {
  final List<_AggregateItem> _items = [
    _AggregateItem('Matric / O-Level', '10'),
    _AggregateItem('Intermediate / A-Level', '40'),
    _AggregateItem('Entry Test', '50'),
  ];

  double? _result;

  void _calculate() {
    double totalAggregate = 0;

    for (var item in _items) {
      final obtained = double.tryParse(item.obtainedCtrl.text) ?? 0;
      final total = double.tryParse(item.totalCtrl.text) ?? 0;
      final weight = double.tryParse(item.weightCtrl.text) ?? 0;

      if (total > 0 && weight > 0) {
        double percentage = (obtained / total) * 100;
        totalAggregate += (percentage * (weight / 100));
      }
    }

    setState(() {
      _result = totalAggregate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aggregate Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ..._items.map((item) => _buildItemCard(item)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate Aggregate'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            if (_result != null)
              Card(
                elevation: 4,
                color: AppTheme.successColor,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        'Total Aggregate',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_result!.toStringAsFixed(3)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
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

  Widget _buildItemCard(_AggregateItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: item.obtainedCtrl,
                    keyboardType: TextInputType.number,
                    keyboardAppearance: Theme.of(context).brightness,
                    decoration: const InputDecoration(labelText: 'Obtained'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: item.totalCtrl,
                    keyboardType: TextInputType.number,
                    keyboardAppearance: Theme.of(context).brightness,
                    decoration: const InputDecoration(labelText: 'Total'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: item.weightCtrl,
                    keyboardType: TextInputType.number,
                    keyboardAppearance: Theme.of(context).brightness,
                    decoration: const InputDecoration(labelText: 'Weight %'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
