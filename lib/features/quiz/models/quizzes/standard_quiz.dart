import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../../core/models/quiz.dart';
import '../../../../core/models/question.dart';
import '../../../../core/models/gamification_strategy.dart';

/// Standard implementation of the Quiz abstract class
class StandardQuiz extends Quiz {
  StandardQuiz({
    required String id,
    required String title,
    String? description,
    required List<Question> questions,
    List<GamificationStrategy> gamificationStrategies = const [],
    int currentQuestionIndex = 0,
    int totalPoints = 0,
    int currentStreak = 0,
    Map<String, dynamic>? metadata,
    List<dynamic>? userAnswers,
    DateTime? startTime,
    DateTime? endTime,
    Map<String, List<Duration>>? questionTimeTracking,
    Map<String, dynamic>? userFeedback,
  }) : super(
          id: id,
          title: title,
          description: description,
          questions: questions,
          gamificationStrategies: gamificationStrategies,
          currentQuestionIndex: currentQuestionIndex,
          totalPoints: totalPoints,
          currentStreak: currentStreak,
          metadata: metadata,
          userAnswers: userAnswers ?? [],
          startTime: startTime,
          endTime: endTime,
          questionTimeTracking: questionTimeTracking ?? {},
          userFeedback: userFeedback ?? {},
        );

  @override
  void start(){
    setStartTime(DateTime.now());
    reset();
  }

  @override
  void resumeSession(Map<String, dynamic> savedState) {
    if (savedState.containsKey('currentQuestionIndex')) {
      currentQuestionIndexValue = savedState['currentQuestionIndex'];
    }
    
    if (savedState.containsKey('totalPoints')) {
      totalPointsValue = savedState['totalPoints'];
    }
    
    if (savedState.containsKey('userAnswers') && savedState['userAnswers'] is List) {
      // Clear and refill user answers
      clearUserAnswers();
      for (dynamic answer in savedState['userAnswers']) {
        addUserAnswer(answer);
      }
    }
    
    if (savedState.containsKey('startTime') && savedState['startTime'] != null) {
      startTimeValue = DateTime.parse(savedState['startTime']);
    }
    
    if (savedState.containsKey('endTime') && savedState['endTime'] != null) {
      endTimeValue = DateTime.parse(savedState['endTime']);
    }
  }

  @override
  Map<String, dynamic> saveSession() {
    return {
      'id': id,
      'currentQuestionIndex': currentQuestionIndex,
      'totalPoints': totalPoints,
      'userAnswers': userAnswers,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      // Add other state data as needed
    };
  }

  @override
  void submitAnswer(dynamic answer) {
    final currentQuestion = questions[currentQuestionIndex];
    final bool isCorrect = currentQuestion.validateAnswer(answer);
    
    // Track the answer
    // Use the protected method to modify user answers
    setUserAnswer(currentQuestionIndex, answer);
    
    // If answer is correct, update streak and points
    if (isCorrect) {
      currentStreakValue = currentStreak + 1;
      totalPointsValue = totalPoints + currentQuestion.points;
    } else {
      currentStreakValue = 0;
    }
    
    // Apply gamification strategies
    for (final strategy in gamificationStrategies) {
      if (strategy.isApplicable(currentState)) {
        strategy.applyStrategy(
          quizState: currentState,
          userAction: {
            'answer': answer,
            'isCorrect': isCorrect,
            'timeTaken': currentQuestion.trackTimeSpent().inSeconds,
          },
          updateState: (newState) {
            // Update quiz state based on strategy results
            if (newState.containsKey('totalPoints')) {
              totalPointsValue = newState['totalPoints'];
            }
            if (newState.containsKey('currentStreak')) {
              currentStreakValue = newState['currentStreak'];
            }
            // Update other state properties as needed
          },
        );
      }
    }
  }

  @override
  bool nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      return goToQuestion(currentQuestionIndex + 1);
    }
    return false;
  }

  @override
  bool previousQuestion() {
    if (currentQuestionIndex > 0) {
      return goToQuestion(currentQuestionIndex - 1);
    }
    return false;
  }

  @override
  bool goToQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      currentQuestionIndexValue = index;
      return true;
    }
    return false;
  }

  @override
  void reset() {
    currentQuestionIndexValue = 0;
    totalPointsValue = 0;
    currentStreakValue = 0;
    
    // Clear and reset user answers
    clearUserAnswers();
    for (int i = 0; i < questions.length; i++) {
      addUserAnswer(null);
    }
    
    // Reset question-specific timers
    for (final question in questions) {
      question.resetTimer();
    }
  }

  @override
  Map<String, dynamic> getResults() {
    int correctAnswers = 0;
    int totalQuestions = questions.length;
    
    for (int i = 0; i < totalQuestions; i++) {
      if (i < userAnswers.length && 
          userAnswers[i] != null && 
          questions[i].validateAnswer(userAnswers[i])) {
        correctAnswers++;
      }
    }
    
    return {
      'quizId': id,
      'quizTitle': title,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'totalPoints': totalPoints,
      'completionRate': totalQuestions > 0 ? correctAnswers / totalQuestions : 0,
      'timeSpent': totalTime?.inSeconds ?? 0,
    };
  }

  @override
  Map<String, dynamic> getStatistics() {
    final results = getResults();
    // Add more detailed statistics
    return {
      ...results,
      'averageTimePerQuestion': questions.isNotEmpty && totalTime != null 
          ? totalTime!.inSeconds / questions.length 
          : 0,
    };
  }

  @override
  Future<String> exportResults(String format) async {
    // Export results to the requested format
    final results = getResults();
    
    switch (format.toLowerCase()) {
      case 'json':
        return jsonEncode(results);
      // Add other formats as needed
      default:
        throw UnimplementedError('Format not supported: $format');
    }
  }

  @override
  Widget buildCurrentQuestionWidget() {
    final question = currentQuestion;
    if (question == null) {
      return const Center(child: Text('No question available'));
    }
    
    return question.buildQuestionWidget();
  }

  @override
  List<Widget> buildGamificationWidgets() {
    return gamificationStrategies
        .where((strategy) => strategy.isApplicable(currentState))
        .map((strategy) => strategy.buildStrategyWidget(currentState))
        .toList();
  }

  @override
  Widget buildSummaryWidget() {
    final results = getResults();
    
    return Column(
      children: [
        Text(
          'Quiz Results: ${title}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          'Score: ${results['totalPoints']} points',
          style: const TextStyle(fontSize: 20),
        ),
        Text(
          'Correct Answers: ${results['correctAnswers']}/${results['totalQuestions']}',
          style: const TextStyle(fontSize: 18),
        ),
        Text(
          'Completion Rate: ${(results['completionRate'] * 100).toStringAsFixed(1)}%',
          style: const TextStyle(fontSize: 18),
        ),
        if (totalTime != null)
          Text(
            'Time Spent: ${totalTime!.inMinutes}m ${totalTime!.inSeconds % 60}s',
            style: const TextStyle(fontSize: 18),
          ),
      ],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
      'gamificationStrategies': gamificationStrategies.map((s) => s.toJson()).toList(),
      'currentQuestionIndex': currentQuestionIndex,
      'totalPoints': totalPoints,
      'currentStreak': currentStreak,
      'metadata': metadata,
      'userAnswers': userAnswers,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'questionTimeTracking': questionTimeTracking,
      'userFeedback': userFeedback,
    };
  }
  
  /// Create a StandardQuiz from JSON data
  factory StandardQuiz.fromJson(Map<String, dynamic> json, {
    required List<Question> parsedQuestions,
    List<GamificationStrategy> parsedStrategies = const [],
  }) {
    return StandardQuiz(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      questions: parsedQuestions,
      gamificationStrategies: parsedStrategies,
      currentQuestionIndex: json['currentQuestionIndex'] ?? 0,
      totalPoints: json['totalPoints'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      metadata: json['metadata'],
      userAnswers: json['userAnswers'],
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      questionTimeTracking: (json['questionTimeTracking'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          key, 
          (value as List).map((e) => Duration(seconds: e)).toList(),
        ),
      ),
      userFeedback: json['userFeedback'],
    );
  }
  
  // Helper function for export
  String jsonEncode(Map<String, dynamic> data) {
    return json.encode(data);
  }
  
  /// Get total time spent on this quiz
  Duration? get totalTime {
    if (startTime == null) return null;
    final end = endTime ?? DateTime.now();
    return end.difference(startTime!);
  }
}
