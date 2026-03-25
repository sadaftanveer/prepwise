import 'package:flutter/foundation.dart';

import '../../questions/providers/question_provider.dart';

class StatsProvider extends ChangeNotifier {
  StatsProvider({required QuestionProvider questionProvider})
      : _questionProvider = questionProvider;

  final QuestionProvider _questionProvider;

  int get totalQuestions => _questionProvider.totalCount;
  int get masteredQuestions => _questionProvider.masteredCount;

  double get masteryPercent {
    if (totalQuestions == 0) {
      return 0;
    }
    return (masteredQuestions / totalQuestions) * 100;
  }
}
