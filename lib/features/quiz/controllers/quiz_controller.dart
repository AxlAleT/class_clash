import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/question.dart';
import '../../../core/models/gamification_strategy.dart';
import '../factories/question_factory.dart';
import '../factories/gamification_factory.dart';
import '../../../providers/quiz_providers.dart';

/// Controller to handle quiz flow and dynamic screen creation
class QuizController extends StateNotifier<QuizState> {
  final Reader read;

  QuizController(this.read) : super(QuizState());

  /// Load a quiz by ID from storage or API
  Future<void> loadQuiz(String quizId) async {
    // Simulate loading quiz data
    // In a real app, this would fetch from an API or local storage
    final Map<String, dynamic> quizData = {
      'id': quizId,
      'title': 'Sample Quiz',
      'questions': [
        {
          'type': 'multiple_choice',
          'data': {
            'id': 'q1',
            'title': 'What is the capital of France?',
            'options': ['Berlin', 'Madrid', 'Paris', 'Rome'],
            'correctAnswer': 2,
            'points': 10,
          }
        },
        {
          'type': 'true_false',
          'data': {
            'id': 'q2',
            'title': 'The sky is blue.',
            'correctAnswer': true,
            'points': 5,
          }
        }
      ],
      'gamification': [
        {
          'type': 'points',
          'data': {
            'speedBonus': true,
            'streakMultiplier': 1.5,
          }
        },
        {
          'type': 'leaderboard',
          'data': {
            'enabled': true,
            'showTop': 5,
          }
        }
      ]
    };

    // Process and load questions using the factory
    final List<Question> questions = [];
    for (var questionData in quizData['questions']) {
      try {
        final question = QuestionFactory.createQuestion(
          questionData['type'],
          questionData['data'],
        );
        questions.add(question);
      } catch (e) {
        debugPrint('Error creating question: $e');
        // Handle error - perhaps log or show fallback question
      }
    }

    // Process and load gamification strategies using the factory
    final List<GamificationStrategy> strategies = [];
    for (var strategyData in quizData['gamification']) {
      try {
        final strategy = GamificationFactory.createStrategy(
          strategyData['type'],
          strategyData['data'],
        );
        strategies.add(strategy);
      } catch (e) {
        debugPrint('Error creating gamification strategy: $e');
        // Handle error
      }
    }

    // Update state with loaded quiz
    state = state.copyWith(
      questions: questions,
      gamificationStrategies: strategies,
      metadata: {
        'quizId': quizId,
        'quizTitle': quizData['title'],
      },
    );
  }

  /// Create quiz question widgets dynamically
  Widget buildCurrentQuestionWidget() {
    if (state.questions.isEmpty) {
      return const Center(child: Text('No questions available'));
    }

    if (state.currentQuestionIndex >= state.questions.length) {
      return const Center(child: Text('Quiz completed'));
    }

    // Get current question and build its widget
    final currentQuestion = state.questions[state.currentQuestionIndex];
    return currentQuestion.buildQuestionWidget();
  }

  /// Create gamification UI widgets
  List<Widget> buildGamificationWidgets() {
    List<Widget> widgets = [];

    for (var strategy in state.gamificationStrategies) {
      // Extract current state for the strategy
      final strategyState = {
        'totalPoints': state.totalPoints,
        'currentStreak': state.currentStreak,
        'metadata': state.metadata,
      };

      // Get UI widget from the strategy
      Widget? strategyWidget = strategy.buildUI(strategyState);
      if (strategyWidget != null) {
        widgets.add(strategyWidget);
      }
    }

    return widgets;
  }

  /// Process an answer and apply gamification strategies
  void submitAnswer(dynamic answer) {
    if (state.questions.isEmpty ||
        state.currentQuestionIndex >= state.questions.length) {
      return;
    }

    Question currentQuestion = state.questions[state.currentQuestionIndex];
    bool isCorrect = currentQuestion.validateAnswer(answer);

    // Create action data for strategies
    Map<String, dynamic> userAction = {
      'type': 'answer',
      'isCorrect': isCorrect,
      'questionIndex': state.currentQuestionIndex,
      'answer': answer,
      'timeSpent': 0, // This would be calculated from actual time tracking
    };

    // Temporary state to apply strategies
    Map<String, dynamic> tempState = {
      'totalPoints': state.totalPoints,
      'currentStreak': isCorrect ? state.currentStreak + 1 : 0,
      'metadata': Map<String, dynamic>.from(state.metadata),
    };

    // Add base points
    if (isCorrect) {
      tempState['totalPoints'] += currentQuestion.points;
    }

    // Apply each gamification strategy
    for (var strategy in state.gamificationStrategies) {
      strategy.applyStrategy(
        quizState: tempState,
        userAction: userAction,
        updateState: (newState) {
          tempState = newState;
        },
      );
    }

    // Update state with calculated values
    state = state.copyWith(
      totalPoints: tempState['totalPoints'],
      currentStreak: tempState['currentStreak'],
      metadata: tempState['metadata'],
    );

    // Show feedback (this would be handled by the UI)

    // After delay, move to next question
    Future.delayed(const Duration(seconds: 2), () {
      if (state.currentQuestionIndex < state.questions.length - 1) {
        state = state.copyWith(
          currentQuestionIndex: state.currentQuestionIndex + 1,
        );
      } else {
        // Quiz completed - handle in UI
      }
    });
  }

  /// Check if quiz is completed
  bool get isQuizCompleted =>
      state.currentQuestionIndex >= state.questions.length - 1;

  /// Get quiz completion data
  Map<String, dynamic> getQuizResults() {
    return {
      'totalPoints': state.totalPoints,
      'totalQuestions': state.questions.length,
      'streak': state.currentStreak,
      'metadata': state.metadata,
    };
  }
}