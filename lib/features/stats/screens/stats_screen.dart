import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../questions/providers/question_provider.dart';
import '../providers/stats_provider.dart';
import '../widgets/progress_summary_card_widget.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StatsProvider stats = StatsProvider(
      questionProvider: context.watch<QuestionProvider>(),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ProgressSummaryCard(
          total: stats.totalQuestions,
          mastered: stats.masteredQuestions,
          percent: stats.masteryPercent,
        ),
      ),
    );
  }
}
