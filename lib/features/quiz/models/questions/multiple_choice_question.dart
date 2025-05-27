import 'package:flutter/material.dart';
import '../../widgets/question_types/multiple_choice_question_widget.dart';
import '../../utils/quiz_notifications.dart';
import 'abstract/choice_question.dart';

class MultipleChoiceQuestion extends ChoiceQuestion {
  @override
  String get questionType => 'multiple_choice';

  @override
  Map<String, dynamic> get metadata => {
    'options': options,
    'correctOptionIndices': correctOptionIndices,
    'randomizeOptions': randomizeOptions,
  };

  MultipleChoiceQuestion({
    required super.id,
    required super.title,
    super.description,
    required super.options,
    required super.correctOptionIndices,
    super.points,
    super.timeLimit,
    super.imageUrl,
    super.audioUrl,
    super.videoUrl,
    super.randomizeOptions,
    super.partialCreditThreshold,
  });

  factory MultipleChoiceQuestion.fromJson(Map<String, dynamic> json) {
    return MultipleChoiceQuestion(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      options: List<String>.from(json['metadata']['options']),
      correctOptionIndices: List<int>.from(
        json['metadata']['correctOptionIndices'],
      ),
      points: json['points'] ?? 100,
      timeLimit: json['timeLimit'] ?? 30,
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
      videoUrl: json['videoUrl'],
      randomizeOptions: json['metadata']['randomizeOptions'] ?? true,
      partialCreditThreshold:
          (json['partialCreditThreshold'] ?? 0.0).toDouble(),
    );
  }

  @override
  bool validateAnswer(dynamic answer) {
    if (answer is! List<int>) return false;

    // For multiple selection questions, check if all selected answers are correct
    // and all correct answers are selected
    return answer.length == correctOptionIndices.length &&
        answer.every((index) => correctOptionIndices.contains(index));
  }

  @override
  double calculatePartialCredit(dynamic answer) {
    if (answer is! List<int>) return 0.0;

    // For multiple selection questions, calculate partial credit
    int totalCorrectOptions = correctOptionIndices.length;
    if (totalCorrectOptions == 0) return 0.0;

    int correctSelections = 0;

    // Count correctly selected options
    for (int selectedIndex in answer) {
      if (correctOptionIndices.contains(selectedIndex)) {
        correctSelections++;
      } else {
        // Penalty for incorrect selections
        correctSelections--;
      }
    }

    // Ensure we don't give negative credit
    correctSelections = correctSelections < 0 ? 0 : correctSelections;

    // Calculate percentage of correct selections
    double percentage = correctSelections / totalCorrectOptions;

    // If percentage is above threshold, award partial credit
    return percentage >= partialCreditThreshold ? percentage : 0.0;
  }

}
