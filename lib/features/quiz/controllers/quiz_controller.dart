import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/quiz_providers.dart';
import '../../../core/models/quiz.dart';

/// Controller to manage quiz state and UI interactions
class QuizController extends StateNotifier<Quiz?> {
  final Ref ref;

  QuizController(this.ref) : super(null);

  /// Load a quiz by ID
  Future<void> loadQuiz(String quizId) async {
    final quizService = ref.read(quizServiceProvider);
    final quiz = quizService.loadQuiz(quizId);
    state = quiz;
  }

  /// Check if a quiz is currently loaded
  bool get isQuizLoaded => state != null;

  /// Get the current quiz or throw an error if none is loaded
  Quiz get currentQuiz {
    if (state == null) {
      throw Exception('No quiz is currently loaded');
    }
    return state!;
  }

  /// Submit an answer to the current question
  void submitAnswer(dynamic answer) {
    if (!isQuizLoaded) return;
    
    currentQuiz.submitAnswer(answer);
    state = currentQuiz; // Trigger a state update
    
    // Optionally auto-advance to next question after a delay
    Future.delayed(const Duration(seconds: 2), () {
      proceedToNextQuestion();
    });
  }

  /// Move to the next question
  void proceedToNextQuestion() {
    if (!isQuizLoaded) return;
    
    if (currentQuiz.nextQuestion()) {
      state = currentQuiz; // Trigger a state update
    }
  }

  /// Move to the previous question
  void proceedToPreviousQuestion() {
    if (!isQuizLoaded) return;
    
    if (currentQuiz.previousQuestion()) {
      state = currentQuiz; // Trigger a state update
    }
  }

  /// Reset the current quiz
  void resetQuiz() {
    if (!isQuizLoaded) return;
    
    currentQuiz.reset();
    state = currentQuiz; // Trigger a state update
  }

  /// Create widget for the current question
  Widget buildCurrentQuestionWidget() {
    if (!isQuizLoaded) {
      return const Center(child: Text('No quiz loaded'));
    }
    
    return currentQuiz.buildCurrentQuestionWidget();
  }

  /// Create gamification UI widgets
  List<Widget> buildGamificationWidgets() {
    if (!isQuizLoaded) {
      return [];
    }
    
    return currentQuiz.buildGamificationWidgets();
  }

  /// Check if quiz is completed
  bool get isQuizCompleted => isQuizLoaded && currentQuiz.isCompleted;

  /// Get quiz results
  Map<String, dynamic> getQuizResults() {
    if (!isQuizLoaded) {
      return {'error': 'No quiz loaded'};
    }
    
    return currentQuiz.getResults();
  }
}

// Provider for the quiz controller
final quizControllerProvider = StateNotifierProvider<QuizController, Quiz?>((ref) {
  return QuizController(ref);
});
