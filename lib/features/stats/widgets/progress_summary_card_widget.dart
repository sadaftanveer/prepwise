import 'package:flutter/material.dart';

class ProgressSummaryCard extends StatelessWidget {
  const ProgressSummaryCard({
    super.key,
    required this.total,
    required this.mastered,
    required this.percent,
  });

  final int total;
  final int mastered;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Total Questions: $total'),
            const SizedBox(height: 8),
            Text('Mastered: $mastered'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: percent / 100),
            const SizedBox(height: 6),
            Text('${percent.toStringAsFixed(1)}% Mastered'),
          ],
        ),
      ),
    );
  }
}
