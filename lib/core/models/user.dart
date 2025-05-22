import 'package:flutter/material.dart';

/// A minimal user model for quiz participation (similar to Kahoot)
abstract class User {
  final String id; // Session/participant ID
  final String displayName; // Name chosen by participant
  final DateTime joinedAt; // When the user joined
  final Map<String, dynamic> metadata; // Additional attributes

  // Quiz participation state
  final Map<String, int> _quizScores; // Quiz ID -> Score
  final Map<String, int> _quizRankings; // Quiz ID -> Ranking
  final Map<String, bool> _quizCompletion; // Quiz ID -> Completed status

  User({
    required this.id,
    required this.displayName,
    required this.joinedAt,
    this.metadata = const {},
    Map<String, int>? quizScores,
    Map<String, int>? quizRankings,
    Map<String, bool>? quizCompletion,
  }) : _quizScores = quizScores ?? {},
       _quizRankings = quizRankings ?? {},
       _quizCompletion = quizCompletion ?? {};

  // Getters
  Map<String, int> get quizScores => Map.unmodifiable(_quizScores);

  Map<String, int> get quizRankings => Map.unmodifiable(_quizRankings);

  Map<String, bool> get quizCompletion => Map.unmodifiable(_quizCompletion);

  /// Get user's score for a specific quiz
  int getQuizScore(String quizId) => _quizScores[quizId] ?? 0;

  /// Get user's ranking for a specific quiz
  int? getQuizRanking(String quizId) => _quizRankings[quizId];

  /// Check if user has completed a specific quiz
  bool hasCompletedQuiz(String quizId) => _quizCompletion[quizId] ?? false;

  /// Update user's score for a quiz
  void updateQuizScore(String quizId, int score);

  /// Update user's ranking for a quiz
  void updateQuizRanking(String quizId, int ranking);

  /// Mark a quiz as completed
  void completeQuiz(String quizId, {required int finalScore});

  /// Build avatar/profile widget for display in UI
  Widget buildAvatarWidget({double size = 40});

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson();

  /// Get the type of user as a string
  String get userType;
}
