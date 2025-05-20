import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/quiz.dart';
import '../../../core/models/user.dart';
import '../../../core/models/question.dart';
import '../../../core/models/gamification_strategy.dart';
import '../../../providers/quiz_providers.dart';

/// Status of the quiz session
enum QuizStatus {
  initial,
  loading,
  inProgress,
  paused,
  completed,
  timedOut,
  error,
}

/// State class for the quiz
class QuizState {
  final QuizStatus status;
  final int remainingTime;
  final bool isAnswerSubmitted;
  final String? errorMessage;
  final int currentQuestionIndex;
  final int totalPoints;

  QuizState({
    this.status = QuizStatus.initial,
    this.remainingTime = 0,
    this.isAnswerSubmitted = false,
    this.errorMessage,
    this.currentQuestionIndex = 0,
    this.totalPoints = 0,
  });

  QuizState copyWith({
    QuizStatus? status,
    int? remainingTime,
    bool? isAnswerSubmitted,
    String? errorMessage,
    int? currentQuestionIndex,
    int? totalPoints,
  }) {
    return QuizState(
      status: status ?? this.status,
      remainingTime: remainingTime ?? this.remainingTime,
      isAnswerSubmitted: isAnswerSubmitted ?? this.isAnswerSubmitted,
      errorMessage: errorMessage,  // Passing null will clear the error
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }
}

/// Controller for managing quiz state, navigation, and user interactions
class QuizController extends StateNotifier<QuizState> {
  /// ID of the quiz being managed
  final String quizId;

  /// The quiz provider to fetch data
  final QuizProvider _quizProvider;

  /// The loaded quiz instance
  Quiz? quiz;

  /// The user taking the quiz
  final User? user;

  /// Timer for the current question
  Timer? _questionTimer;

  QuizController({
    required this.quizId,
    required QuizProvider quizProvider,
    this.user,
  }) : _quizProvider = quizProvider,
       super(QuizState(status: QuizStatus.loading)) {
    // Load the quiz when controller is created
    _loadQuiz();
  }

  // Async method to load the quiz
  Future<void> _loadQuiz() async {
    try {
      state = state.copyWith(status: QuizStatus.loading);
      
      quiz = await _quizProvider.loadQuiz(quizId);
      
      if (quiz == null) {
        state = state.copyWith(
          status: QuizStatus.error,
          errorMessage: 'Quiz not found: $quizId',
        );
        return;
      }
      
      state = state.copyWith(
        status: QuizStatus.initial,
        currentQuestionIndex: quiz!.currentQuestionIndex,
        totalPoints: quiz!.totalPoints,
      );
    } catch (e) {
      state = state.copyWith(
        status: QuizStatus.error,
        errorMessage: 'Failed to load quiz: $e',
      );
    }
  }

  // Computed properties
  Question? get currentQuestion => quiz?.currentQuestion;
  bool get isLastQuestion => quiz != null ? quiz!.currentQuestionIndex == quiz!.questions.length - 1 : false;
  bool get isFirstQuestion => quiz != null ? quiz!.currentQuestionIndex == 0 : true;
  double get progressPercentage {
    if (quiz == null || quiz!.questions.isEmpty) return 0;
    return (quiz!.currentQuestionIndex + 1) / quiz!.questions.length;
  }

  /// Start the quiz
  void startQuiz() {
    if (quiz == null) {
      _setError('Cannot start quiz: Quiz not loaded');
      return;
    }
    
    try {
      quiz!.start();
      state = state.copyWith(
        status: QuizStatus.inProgress,
      );
      _startQuestionTimer();
    } catch (e) {
      _setError('Failed to start quiz: $e');
    }
  }

  /// Pause the quiz
  void pauseQuiz() {
    state = state.copyWith(
      status: QuizStatus.paused,
    );
    _stopQuestionTimer();
  }

  /// Resume a paused quiz
  void resumeQuiz() {
    state = state.copyWith(
      status: QuizStatus.inProgress,
    );
    _startQuestionTimer();
  }

  /// End the quiz and calculate final results
  void endQuiz() {
    if (quiz == null) return;
    
    _stopQuestionTimer();
    
    // Submit any remaining answer if not submitted yet
    if (!state.isAnswerSubmitted && currentQuestion != null) {
      quiz!.submitAnswer(null);
    }
    
    quiz!.end();
    state = state.copyWith(
      status: QuizStatus.completed,
      totalPoints: quiz!.totalPoints,
    );

    // Update user data if available
    if (user != null) {
      final results = quiz!.getResults();
      user!.completeQuiz(quiz!.id, finalScore: results['totalPoints'] as int);
    }
  }
  
  /// Clean up all resources associated with this quiz instance
  void disposeQuiz() {
    _stopQuestionTimer();
    quiz = null;
  }

  /// Reset the quiz for a new attempt
  void resetQuiz() {
    if (quiz == null) return;
    
    _stopQuestionTimer();
    quiz!.reset();
    
    state = state.copyWith(
      status: QuizStatus.initial,
      currentQuestionIndex: quiz!.currentQuestionIndex,
      totalPoints: quiz!.totalPoints,
      isAnswerSubmitted: false,
      remainingTime: 0,
    );
  }

  /// Submit an answer for the current question
  void submitAnswer(dynamic answer) {
    if (quiz == null || state.isAnswerSubmitted) return;

    try {
      _stopQuestionTimer();
      quiz!.submitAnswer(answer);
      state = state.copyWith(
        isAnswerSubmitted: true,
        totalPoints: quiz!.totalPoints,
      );

      // Track time spent if we have a current question
      if (currentQuestion != null) {
        final time = currentQuestion!.trackTimeSpent();
        quiz!.trackQuestionTime(currentQuestion!.id, time);
      }
    } catch (e) {
      _setError('Failed to submit answer: $e');
    }
  }

  /// Move to the next question
  bool goToNextQuestion() {
    if (quiz == null) return false;
    
    if (isLastQuestion) {
      endQuiz();
      return false;
    }

    final moved = quiz!.nextQuestion();
    if (moved) {
      _resetQuestionState();
    }
    return moved;
  }

  /// Move to the previous question
  bool goToPreviousQuestion() {
    if (quiz == null) return false;
    
    final moved = quiz!.previousQuestion();
    if (moved) {
      _resetQuestionState();
    }
    return moved;
  }

  /// Jump to a specific question by index
  bool goToQuestion(int index) {
    if (quiz == null) return false;
    
    final moved = quiz!.goToQuestion(index);
    if (moved) {
      _resetQuestionState();
    }
    return moved;
  }

  /// Save the current quiz session state
  Map<String, dynamic> saveSession() {
    if (quiz == null) return {};
    return quiz!.saveSession();
  }

  /// Resume a saved quiz session
  void resumeSession(Map<String, dynamic> sessionData) {
    if (quiz == null) return;
    
    quiz!.resumeSession(sessionData);
    _resetQuestionState();
    state = state.copyWith(
      status: QuizStatus.inProgress,
      currentQuestionIndex: quiz!.currentQuestionIndex,
      totalPoints: quiz!.totalPoints,
    );
  }

  /// Submit feedback for the quiz
  void submitFeedback(Map<String, dynamic> feedback) {
    if (quiz == null) return;
    quiz!.submitFeedback(feedback);
  }

  /// Get quiz results
  Map<String, dynamic> getResults() {
    if (quiz == null) return {};
    return quiz!.getResults();
  }

  /// Get detailed quiz statistics
  Map<String, dynamic> getStatistics() {
    if (quiz == null) return {};
    return quiz!.getStatistics();
  }

  /// Export quiz results in the specified format
  Future<String> exportResults(String format) {
    if (quiz == null) return Future.value('');
    return quiz!.exportResults(format);
  }

  /// Start the timer for the current question
  void _startQuestionTimer() {
    _stopQuestionTimer();

    if (currentQuestion == null || currentQuestion!.timeLimit <= 0) {
      return; // No time limit for this question
    }

    state = state.copyWith(
      remainingTime: currentQuestion!.timeLimit,
    );

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingTime > 0) {
        state = state.copyWith(
          remainingTime: state.remainingTime - 1,
        );
      } else {
        // Time's up for this question
        _questionTimer?.cancel();
        _questionTimer = null;

        // Auto-submit null answer if none has been submitted
        if (!state.isAnswerSubmitted) {
          submitAnswer(null);
        }
      }
    });
  }

  /// Stop the question timer
  void _stopQuestionTimer() {
    _questionTimer?.cancel();
    _questionTimer = null;
  }

  /// Reset the state for a new question
  void _resetQuestionState() {
    if (quiz == null) return;
    
    state = state.copyWith(
      isAnswerSubmitted: false,
      currentQuestionIndex: quiz!.currentQuestionIndex,
      totalPoints: quiz!.totalPoints,
    );
    _startQuestionTimer();
  }

  /// Set an error message
  void _setError(String message) {
    state = state.copyWith(
      errorMessage: message,
    );
  }

  /// Clear any error message
  void clearError() {
    state = state.copyWith(
      errorMessage: null,
    );
  }

  @override
  void dispose() {
    _stopQuestionTimer();
    super.dispose();
  }
}
