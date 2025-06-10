import 'dart:convert'; // For printing the map nicely, if desired
import 'package:flutter/foundation.dart'; // For ChangeNotifier

import '../models/quiz_creation_state.dart';
import '../models/question_model.dart';
import '../models/mcq_question_model.dart';
import '../models/true_false_question_model.dart';

// For a Flutter app, this would typically extend ChangeNotifier or be managed by a framework like Riverpod or BLoC.
class QuizCreationController with ChangeNotifier {
  QuizCreationState _quizState;

  QuizCreationController() : _quizState = QuizCreationState();

  QuizCreationState get quizState => _quizState;

  // Method to update quiz title
  void updateQuizTitle(String title) {
    _quizState = _quizState.copyWith(title: title);
    notifyListeners();
  }

  // Method to update quiz description
  void updateQuizDescription(String description) {
    _quizState = _quizState.copyWith(description: description);
    notifyListeners();
  }

  // Method to add a question
  void addQuestion(Question question) {
    final updatedQuestions = List<Question>.from(_quizState.questions)..add(question);
    _quizState = _quizState.copyWith(questions: updatedQuestions);
    notifyListeners();
  }

  // Method to remove a question by its ID
  void removeQuestionById(String id) {
    final updatedQuestions = List<Question>.from(_quizState.questions)
      ..removeWhere((q) => q.id == id);
    _quizState = _quizState.copyWith(questions: updatedQuestions);
    notifyListeners();
  }

  // Method to update a question
  // Note: Finding by ID is generally safer if questions can be reordered.
  // If order is fixed, index is fine. For now, we'll assume index is acceptable.
  void updateQuestion(int index, Question newQuestion) {
    if (index >= 0 && index < _quizState.questions.length) {
      // Ensure the new question maintains the same ID if it's an update
      // This might require more sophisticated logic if newQuestion can have a different ID.
      // For now, assuming newQuestion is a clone with modifications but same ID, or a new question for replacement.
      final updatedQuestions = List<Question>.from(_quizState.questions);
      updatedQuestions[index] = newQuestion;
      _quizState = _quizState.copyWith(questions: updatedQuestions);
      notifyListeners();
    }
  }

  // Method to save the quiz
  void saveQuiz() {
    final quizId = DateTime.now().millisecondsSinceEpoch.toString();
    final List<Map<String, dynamic>> questionsData = [];

    for (int i = 0; i < _quizState.questions.length; i++) {
      final question = _quizState.questions[i];
      final questionId = '${quizId}_q$i';
      final Map<String, dynamic> questionData = {
        'id': questionId,
        'title': question.questionText,
        // 'description': '', // Not available on Question model directly
        // 'points': 0, // Not available on Question model
        // 'timeLimit': 30, // Not available on Question model
      };

      if (question is MCQQuestion) {
        questionData['questionType'] = 'single_choice'; // Based on MCQQuestion structure
        questionData['metadata'] = {
          'options': question.options,
          'correctOptionIndices': [question.correctAnswerIndex],
          'allowMultipleSelections': false, // MCQQuestion has a single correctAnswerIndex
          // 'randomizeOptions': true, // Defaulting, not in model
        };
      } else if (question is TrueFalseQuestionModel) {
        questionData['questionType'] = 'true_false';
        questionData['metadata'] = {
          'correctAnswer': question.correctAnswer,
        };
      } else {
        // Handle other question types or provide a default
        questionData['questionType'] = 'unknown';
        questionData['metadata'] = {};
      }
      questionsData.add(questionData);
    }

    final quizMap = {
      'id': quizId,
      'title': _quizState.title,
      'description': _quizState.description,
      'questions': questionsData,
      'type': 'standard',
      // Fields like 'gamificationStrategies', 'currentQuestionIndex', 'totalPoints', 'currentStreak'
      // are not part of creation state and would typically be managed elsewhere or have defaults.
    };

    // Simulate submitting data (e.g., print to console)
    // Using jsonEncode for a slightly cleaner print, but simple print(quizMap) works too.
    print('Simulating Quiz Submission:');
    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String prettyPrinted = encoder.convert(quizMap);
    print(prettyPrinted);

    // Reset state after saving
    _quizState = QuizCreationState();
    notifyListeners(); // Notify that the state has been reset
    print('Quiz state has been reset.');
  }
}
