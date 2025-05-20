import 'package:flutter/material.dart';

/// Abstract base class for all types of questions
abstract class Question {
  final String id;
  final String title;
  final String? description;
  final int points;
  final int timeLimit; // in seconds, 0 means no limit
  final Map<String, dynamic> metadata;
  
  // Media attachments
  final String? imageUrl;
  final String? audioUrl;
  final String? videoUrl;

  // Partial credit properties
  final double partialCreditThreshold; // e.g., 0.5 for 50% credit

  Question({
    required this.id,
    required this.title,
    this.description,
    this.points = 10,
    this.timeLimit = 0,
    this.metadata = const {},
    this.imageUrl,
    this.audioUrl,
    this.videoUrl,
    this.partialCreditThreshold = 0.0,
  });

  /// Validate the answer provided by the user
  bool validateAnswer(dynamic answer);
  
  /// Calculate partial credit (0.0 to 1.0) for an answer
  double calculatePartialCredit(dynamic answer) => 0.0; // Default implementation

  /// Track time spent on this question
  Duration trackTimeSpent(DateTime startTime) => DateTime.now().difference(startTime);
  
  /// Render the question widget
  Widget buildQuestionWidget();
  
  /// Render media attachments
  Widget buildMediaWidget();

  /// Render the feedback widget
  Widget buildFeedbackWidget(dynamic userAnswer, bool isCorrect);

  /// Transform the question into a JSON object for storage
  Map<String, dynamic> toJson();
  
  /// Create Question from JSON (to be implemented by subclasses)
  /// factory Question.fromJson(Map<String, dynamic> json);

  /// Get the type of question as a string
  String get questionType;
}
