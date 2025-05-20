import 'package:flutter/material.dart';

import 'gamification_strategy.dart';
import 'question.dart';

/// Model class to represent a quiz with its state and behaviors
class Quiz {
  final String id;
  final String title;
  final List<Question> questions;
  final List<GamificationStrategy> gamificationStrategies;
  
  // State properties
  int _currentQuestionIndex;
  int _totalPoints;
  int _currentStreak;
  Map<String, dynamic> _metadata;
  List<dynamic> _userAnswers;
  
  Quiz({
    required this.id,
    required this.title,
    required this.questions,
    required this.gamificationStrategies,
    int currentQuestionIndex = 0,
    int totalPoints = 0,
    int currentStreak = 0,
    Map<String, dynamic>? metadata,
    List<dynamic>? userAnswers,
  }) : 
    _currentQuestionIndex = currentQuestionIndex,
    _totalPoints = totalPoints,
    _currentStreak = currentStreak,
    _metadata = metadata ?? {},
    _userAnswers = userAnswers ?? List.filled(questions.length, null);
  
  // Getters
  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalPoints => _totalPoints;
  int get currentStreak => _currentStreak;
  Map<String, dynamic> get metadata => _metadata;
  bool get isCompleted => _currentQuestionIndex >= questions.length;
  Question? get currentQuestion => 
      questions.isNotEmpty && _currentQuestionIndex < questions.length 
      ? questions[_currentQuestionIndex] 
      : null;
  
  /// Get current quiz state as a map for use with strategies
  Map<String, dynamic> get currentState => {
    'totalPoints': _totalPoints,
    'currentStreak': _currentStreak,
    'metadata': Map<String, dynamic>.from(_metadata),
  };
  
  /// Submit an answer and process it with gamification strategies
  void submitAnswer(dynamic answer) {
    if (questions.isEmpty || _currentQuestionIndex >= questions.length) {
      return;
    }
    
    // Store the user's answer
    _userAnswers[_currentQuestionIndex] = answer;
    
    Question question = questions[_currentQuestionIndex];
    bool isCorrect = question.validateAnswer(answer);
    
    // Create action data for strategies
    Map<String, dynamic> userAction = {
      'type': 'answer',
      'isCorrect': isCorrect,
      'questionIndex': _currentQuestionIndex,
      'answer': answer,
      'timeSpent': 0, // This would be calculated from actual time tracking
    };
    
    // Temporary state to apply strategies
    Map<String, dynamic> tempState = {
      'totalPoints': _totalPoints,
      'currentStreak': isCorrect ? _currentStreak + 1 : 0,
      'metadata': Map<String, dynamic>.from(_metadata),
    };
    
    // Add base points
    if (isCorrect) {
      tempState['totalPoints'] += question.points;
    }
    
    // Apply each gamification strategy
    for (var strategy in gamificationStrategies) {
      strategy.applyStrategy(
        quizState: tempState,
        userAction: userAction,
        updateState: (newState) {
          tempState = newState;
        },
      );
    }
    
    // Update state with calculated values
    _totalPoints = tempState['totalPoints'];
    _currentStreak = tempState['currentStreak'];
    _metadata = tempState['metadata'];
  }
  
  /// Move to next question if possible
  bool nextQuestion() {
    if (_currentQuestionIndex < questions.length - 1) {
      _currentQuestionIndex++;
      return true;
    }
    return false;
  }
  
  /// Move to previous question if possible
  bool previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      return true;
    }
    return false;
  }
  
  /// Jump to a specific question index
  bool goToQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      _currentQuestionIndex = index;
      return true;
    }
    return false;
  }
  
  /// Reset the quiz to its initial state
  void reset() {
    _currentQuestionIndex = 0;
    _totalPoints = 0;
    _currentStreak = 0;
    _userAnswers = List.filled(questions.length, null);
    // Keep metadata that needs to persist or reset as needed
  }
  
  /// Get quiz results for final display
  Map<String, dynamic> getResults() {
    return {
      'quizId': id,
      'quizTitle': title,
      'totalPoints': _totalPoints,
      'totalQuestions': questions.length,
      'attemptedQuestions': _userAnswers.where((a) => a != null).length,
      'streak': _currentStreak,
      'metadata': _metadata,
      'userAnswers': _userAnswers,
    };
  }
  
  /// Build UI for the current question
  Widget buildCurrentQuestionWidget() {
    if (questions.isEmpty) {
      return const Center(child: Text('No questions available'));
    }
    
    if (_currentQuestionIndex >= questions.length) {
      return const Center(child: Text('Quiz completed'));
    }
    
    return questions[_currentQuestionIndex].buildQuestionWidget();
  }
  
  /// Build UI for all active gamification elements
  List<Widget> buildGamificationWidgets() {
    List<Widget> widgets = [];
    
    for (var strategy in gamificationStrategies) {
      Widget? strategyWidget = strategy.buildStrategyWidget(currentState);
      if (strategyWidget != null) {
        widgets.add(strategyWidget);
      }
    }
    
    return widgets;
  }
}
