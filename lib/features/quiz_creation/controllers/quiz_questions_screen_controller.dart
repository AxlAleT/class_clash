import 'package:flutter/material.dart';
import 'package:class_clash/features/quiz_creation/models/quiz/standard_quiz.dart';
import 'package:class_clash/features/quiz_creation/models/questions/question_model.dart';
import 'package:class_clash/features/quiz_creation/factory/question_factory.dart';

class QuizQuestionsScreenController extends ChangeNotifier {
  // The quiz model being created/edited
  StandardQuizModel _quizModel;

  // Currently selected question for editing
  int _selectedQuestionIndex = -1;

  // Currently active question type for new questions
  String _activeQuestionType = 'single_choice';

  QuizQuestionsScreenController({required StandardQuizModel initialQuizData})
      : _quizModel = initialQuizData;

  // Getters
  StandardQuizModel get quizModel => _quizModel;
  List<QuestionModel> get questions => _quizModel.questions;
  int get selectedQuestionIndex => _selectedQuestionIndex;
  String get activeQuestionType => _activeQuestionType;
  bool get hasQuestions => questions.isNotEmpty;

  // Get supported question types from the factory
  List<String> get supportedQuestionTypes => QuestionFactory.supportedQuestionTypes;

  // Set the active question type
  void setActiveQuestionType(String type) {
    if (QuestionFactory.supportedQuestionTypes.contains(type)) {
      _activeQuestionType = type;
      notifyListeners();
    }
  }

  // Add a new question
  void addQuestion(QuestionModel question) {
    final updatedQuestions = List<QuestionModel>.from(_quizModel.questions)
      ..add(question);

    _quizModel = StandardQuizModel(
      id: _quizModel.id,
      title: _quizModel.title,
      description: _quizModel.description,
      questions: updatedQuestions,
      ownerId: _quizModel.ownerId,
      createdAt: _quizModel.createdAt,
      category: _quizModel.category,
      isPublic: _quizModel.isPublic,
      timeLimit: _quizModel.timeLimit,
      settings: _quizModel.settings,
    );

    // Select the newly added question
    _selectedQuestionIndex = _quizModel.questions.length - 1;
    notifyListeners();
  }

  // Update an existing question
  void updateQuestion(int index, QuestionModel updatedQuestion) {
    if (index >= 0 && index < _quizModel.questions.length) {
      final updatedQuestions = List<QuestionModel>.from(_quizModel.questions);
      updatedQuestions[index] = updatedQuestion;

      _quizModel = StandardQuizModel(
        id: _quizModel.id,
        title: _quizModel.title,
        description: _quizModel.description,
        questions: updatedQuestions,
        ownerId: _quizModel.ownerId,
        createdAt: _quizModel.createdAt,
        category: _quizModel.category,
        isPublic: _quizModel.isPublic,
        timeLimit: _quizModel.timeLimit,
        settings: _quizModel.settings,
      );

      notifyListeners();
    }
  }

  // Remove a question
  void removeQuestion(int index) {
    if (index >= 0 && index < _quizModel.questions.length) {
      final updatedQuestions = List<QuestionModel>.from(_quizModel.questions);
      updatedQuestions.removeAt(index);

      _quizModel = StandardQuizModel(
        id: _quizModel.id,
        title: _quizModel.title,
        description: _quizModel.description,
        questions: updatedQuestions,
        ownerId: _quizModel.ownerId,
        createdAt: _quizModel.createdAt,
        category: _quizModel.category,
        isPublic: _quizModel.isPublic,
        timeLimit: _quizModel.timeLimit,
        settings: _quizModel.settings,
      );

      // Adjust selected question index if necessary
      if (_selectedQuestionIndex == index) {
        _selectedQuestionIndex = -1;
      } else if (_selectedQuestionIndex > index) {
        _selectedQuestionIndex--;
      }

      notifyListeners();
    }
  }

  // Reorder questions
  void reorderQuestions(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final updatedQuestions = List<QuestionModel>.from(_quizModel.questions);
    final item = updatedQuestions.removeAt(oldIndex);
    updatedQuestions.insert(newIndex, item);

    _quizModel = StandardQuizModel(
      id: _quizModel.id,
      title: _quizModel.title,
      description: _quizModel.description,
      questions: updatedQuestions,
      ownerId: _quizModel.ownerId,
      createdAt: _quizModel.createdAt,
      category: _quizModel.category,
      isPublic: _quizModel.isPublic,
      timeLimit: _quizModel.timeLimit,
      settings: _quizModel.settings,
    );

    // Update selected question index if necessary
    if (_selectedQuestionIndex == oldIndex) {
      _selectedQuestionIndex = newIndex;
    } else if (_selectedQuestionIndex < oldIndex && _selectedQuestionIndex >= newIndex) {
      _selectedQuestionIndex++;
    } else if (_selectedQuestionIndex > oldIndex && _selectedQuestionIndex <= newIndex) {
      _selectedQuestionIndex--;
    }

    notifyListeners();
  }

  // Select a question for editing
  void selectQuestion(int index) {
    if (index >= -1 && index < _quizModel.questions.length) {
      _selectedQuestionIndex = index;
      notifyListeners();
    }
  }

  // Get the final quiz data as JSON
  Map<String, dynamic> getQuizJson() {
    return _quizModel.toJson();
  }
}
