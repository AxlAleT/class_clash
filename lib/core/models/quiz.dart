import 'package:flutter/material.dart';

import 'gamification_strategy.dart';
import 'question.dart';

/// Model class to represent a quiz with its state and behaviors
abstract class Quiz {
  final String id;
  final String title;
  final String? description;
  final List<Question> questions;
  final List<GamificationStrategy> gamificationStrategies;

  // State properties
  int _currentQuestionIndex;
  int _totalPoints;
  int _currentStreak;
  Map<String, dynamic> _metadata;
  List<dynamic> _userAnswers;
  DateTime? _startTime;
  DateTime? _endTime;
  Map<String, List<Duration>> _questionTimeTracking; // Question ID -> List of durations spent
  Map<String, dynamic> _userFeedback;
  
  Quiz({
    required this.id,
    required this.title,
    this.description,
    required this.questions,
    this.gamificationStrategies = const [],
    int currentQuestionIndex = 0,
    int totalPoints = 0,
    int currentStreak = 0,
    Map<String, dynamic>? metadata,
    List<dynamic>? userAnswers,
    DateTime? startTime,
    DateTime? endTime,
    Map<String, List<Duration>>? questionTimeTracking,
    Map<String, dynamic>? userFeedback,
  }) : 
    _currentQuestionIndex = currentQuestionIndex,
    _totalPoints = totalPoints,
    _currentStreak = currentStreak,
    _metadata = metadata ?? {},
    _userAnswers = userAnswers ?? List.filled(questions.length, null),
    _startTime = startTime,
    _endTime = endTime,
    _questionTimeTracking = questionTimeTracking ?? {},
    _userFeedback = userFeedback ?? {};
  
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
  DateTime? get startTime => _startTime;
  DateTime? get endTime => _endTime;
  Duration? get totalTime => (_startTime != null && _endTime != null) 
      ? _endTime!.difference(_startTime!) 
      : null;
  
  /// Get current quiz state as a map for use with strategies
  Map<String, dynamic> get currentState => {
    'totalPoints': _totalPoints,
    'currentStreak': _currentStreak,
    'metadata': Map<String, dynamic>.from(_metadata),
  };
  
  /// Start quiz and record start time
  void start() {
    _startTime = DateTime.now();
    reset();
  }
  
  /// Resume a previously saved quiz session
  void resumeSession(Map<String, dynamic> savedState);
  
  /// Save current quiz session state
  Map<String, dynamic> saveSession();
  
  /// Submit an answer and process it with gamification strategies
  void submitAnswer(dynamic answer);
  
  /// Move to next question if possible
  bool nextQuestion();
  
  /// Move to previous question if possible
  bool previousQuestion();
  
  /// Jump to a specific question index
  bool goToQuestion(int index);
  
  /// Reset the quiz to its initial state
  void reset();
  
  /// End quiz and record end time
  void end() {
    _endTime = DateTime.now();
  }
  
  /// Track time spent on current question
  void trackQuestionTime(String questionId, Duration time) {
    if (!_questionTimeTracking.containsKey(questionId)) {
      _questionTimeTracking[questionId] = [];
    }
    _questionTimeTracking[questionId]!.add(time);
  }
  
  /// Submit user feedback for this quiz
  void submitFeedback(Map<String, dynamic> feedback) {
    _userFeedback = feedback;
  }
  
  /// Get user feedback
  Map<String, dynamic> get userFeedback => Map.unmodifiable(_userFeedback);
  
  /// Get quiz results for final display
  Map<String, dynamic> getResults();
  
  /// Get completion statistics (correct answers, completion percentage, etc.)
  Map<String, dynamic> getStatistics();
  
  /// Export results to shareable format (JSON, PDF, etc.)
  Future<String> exportResults(String format);
  
  /// Build UI for the current question
  Widget buildCurrentQuestionWidget();
  
  /// Build UI for all active gamification elements
  List<Widget> buildGamificationWidgets();
  
  /// Build UI for quiz summary/results
  Widget buildSummaryWidget();
  
  /// Convert to JSON for persistence
  Map<String, dynamic> toJson();
  
  /// Create Quiz from JSON (to be implemented by subclasses)
  /// factory Quiz.fromJson(Map<String, dynamic> json);
}
