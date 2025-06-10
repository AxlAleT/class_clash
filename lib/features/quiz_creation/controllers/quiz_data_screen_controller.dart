import 'package:flutter/material.dart';
import 'package:class_clash/features/quiz_creation/models/quiz/standard_quiz.dart';

class QuizDataScreenController extends ChangeNotifier {
  String _title = '';
  String _description = '';
  String _category = '';
  int _timeLimit = 0;
  bool _isPublic = false;

  // Getters
  String get title => _title;
  String get description => _description;
  String get category => _category;
  int get timeLimit => _timeLimit;
  bool get isPublic => _isPublic;

  // Form validation
  bool get isFormValid => _title.isNotEmpty && _category.isNotEmpty;

  // Setters with notification
  void setTitle(String value) {
    _title = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setCategory(String value) {
    _category = value;
    notifyListeners();
  }

  void setTimeLimit(int value) {
    _timeLimit = value;
    notifyListeners();
  }

  void setIsPublic(bool value) {
    _isPublic = value;
    notifyListeners();
  }

  // Create initial quiz data object
  StandardQuizModel createInitialQuizData(String ownerId) {
    return StandardQuizModel(
      title: _title,
      description: _description,
      questions: [],
      ownerId: ownerId,
      category: _category,
      isPublic: _isPublic,
      timeLimit: _timeLimit,
      createdAt: DateTime.now(),
    );
  }

  // Reset the form
  void reset() {
    _title = '';
    _description = '';
    _category = '';
    _timeLimit = 0;
    _isPublic = false;
    notifyListeners();
  }
}
