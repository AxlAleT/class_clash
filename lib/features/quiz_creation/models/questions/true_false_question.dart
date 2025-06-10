import 'package:class_clash/features/quiz_creation/models/questions/question_model.dart';

class TrueFalseQuestionModel extends QuestionModel {
  final List<int> correctOptionIndices; // 0 for True, 1 for False

  TrueFalseQuestionModel({
    super.id,
    required super.title,
    super.description,
    required super.points,
    required super.timeLimit,
    required this.correctOptionIndices,
  }) : super(
          questionType: 'true_false',
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'points': points,
      'timeLimit': timeLimit,
      'questionType': questionType,
      'metadata': {
        'correctOptionIndices': correctOptionIndices,
      },
    };
  }

  // Factory constructor to create a TrueFalseQuestionModel from JSON
  factory TrueFalseQuestionModel.fromJson(Map<String, dynamic> json) {
    return TrueFalseQuestionModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      points: json['points'],
      timeLimit: json['timeLimit'],
      correctOptionIndices: List<int>.from(json['metadata']['correctOptionIndices']),
    );
  }
}
