import 'package:flutter/widgets.dart';

/// Abstract base interface for all types of questions
abstract class Question {
  String get id;

  String get title;

  String? get description;

  int get points; // in points
  int get timeLimit; // in seconds, 0 means no limit
  Map<String, dynamic> get metadata;

  String? get imageUrl;

  String? get audioUrl;

  String? get videoUrl;

  double get partialCreditThreshold; // e.g., 0.5 for 50% credit

  // Making startTime protected so it can be reset
  @protected
  DateTime startTime = DateTime.now();

  bool validateAnswer(dynamic answer);

  double calculatePartialCredit(dynamic answer) => 0.0;

  Duration trackTimeSpent() => DateTime.now().difference(startTime);

  /// Reset the timer for this question
  void resetTimer() {
    startTime = DateTime.now();
  }

  Widget buildMediaWidget();

  Widget buildFeedbackWidget(dynamic userAnswer, bool isCorrect);

  Map<String, dynamic> toJson();

  Widget buildQuestionWidget();

  String get questionType;
}
