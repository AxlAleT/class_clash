import 'package:flutter/material.dart';
import '../../widgets/question_types/single_choice_question_widget.dart';
import '../../utils/quiz_notifications.dart';
import 'abstract/choice_question.dart';

class SingleChoiceQuestion extends ChoiceQuestion {
  @override
  String get questionType => 'single_choice';

  @override
  Map<String, dynamic> get metadata => {
    'options': options,
    'correctOptionIndices': correctOptionIndices,
    'randomizeOptions': randomizeOptions,
  };

  SingleChoiceQuestion({
    required super.id,
    required super.title,
    super.description,
    required super.options,
    required int correctOptionIndex,
    super.points,
    super.timeLimit,
    super.imageUrl,
    super.audioUrl,
    super.videoUrl,
    super.randomizeOptions,
    super.partialCreditThreshold,
  }) : super(
          correctOptionIndices: [correctOptionIndex],
        );

  factory SingleChoiceQuestion.fromJson(Map<String, dynamic> json) {
    return SingleChoiceQuestion(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      options: List<String>.from(json['metadata']['options']),
      correctOptionIndex: List<int>.from(
        json['metadata']['correctOptionIndices'],
      )[0], // Take first index as the correct one
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
    if (answer is! List<int> || answer.length != 1) return false;
    return correctOptionIndices.contains(answer[0]);
  }

  @override
  double calculatePartialCredit(dynamic answer) {
    return validateAnswer(answer) ? 1.0 : 0.0;
  }

  @override
  Widget buildQuestionWidget() {
    return SingleChoiceQuestionWidget(question: this);
  }

}
