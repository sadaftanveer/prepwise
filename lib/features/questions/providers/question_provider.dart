import 'package:flutter/foundation.dart';

import '../../../data/models/question_model.dart';
import '../../../data/repositories/question_repository.dart';

class QuestionProvider extends ChangeNotifier {
  QuestionProvider({QuestionRepository? questionRepository})
      : _questionRepository = questionRepository ?? QuestionRepository();

  final QuestionRepository _questionRepository;

  List<QuestionModel> _questions = <QuestionModel>[];
  bool _isLoading = false;
  String? _error;
  QuestionCategory? _selectedCategory;

  List<QuestionModel> get questions {
    if (_selectedCategory == null) {
      return _questions;
    }
    return _questions
        .where((QuestionModel q) => q.category == _selectedCategory)
        .toList();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  QuestionCategory? get selectedCategory => _selectedCategory;

  int get totalCount => _questions.length;
  int get masteredCount => _questions.where((QuestionModel q) => q.isMastered).length;

  Future<void> loadQuestions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _questions = await _questionRepository.fetchQuestions();
    } catch (_) {
      _error = 'Failed to load questions';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addQuestion(QuestionModel question) async {
    _error = null;
    notifyListeners();
    try {
      await _questionRepository.addQuestion(question);
      await loadQuestions();
    } catch (_) {
      _error = 'Failed to add question';
      notifyListeners();
    }
  }

  Future<void> updateQuestion(QuestionModel question) async {
    _error = null;
    notifyListeners();
    try {
      await _questionRepository.updateQuestion(question);
      await loadQuestions();
    } catch (_) {
      _error = 'Failed to update question';
      notifyListeners();
    }
  }

  Future<void> deleteQuestion(String questionId) async {
    _error = null;
    notifyListeners();
    try {
      await _questionRepository.deleteQuestion(questionId);
      await loadQuestions();
    } catch (_) {
      _error = 'Failed to delete question';
      notifyListeners();
    }
  }

  Future<void> toggleMastered(QuestionModel question, bool isMastered) async {
    final QuestionModel updated = question.copyWith(
      isMastered: isMastered,
      updatedAt: DateTime.now(),
    );
    await updateQuestion(updated);
  }

  void setCategoryFilter(QuestionCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
