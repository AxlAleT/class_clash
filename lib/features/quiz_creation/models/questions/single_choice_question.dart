import 'package:class_clash/features/quiz_creation/models/questions/question_model.dart';

class SingleChoiceQuestionModel extends QuestionModel {
  final List<String> options;
  final List<int> correctOptionIndices;
  final bool allowMultipleSelections;
  final bool randomizeOptions;

  SingleChoiceQuestionModel({
    super.id,
    required super.title,
    super.description,
    required super.points,
    required super.timeLimit,
    required this.options,
    required this.correctOptionIndices,
    this.allowMultipleSelections = false,
    this.randomizeOptions = false,
  }) : super(
          questionType: 'single_choice',
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
        'options': options,
        'correctOptionIndices': correctOptionIndices,
        'allowMultipleSelections': allowMultipleSelections,
        'randomizeOptions': randomizeOptions,
      },
    };
  }

  // Factory constructor to create a SingleChoiceQuestionModel from JSON
  factory SingleChoiceQuestionModel.fromJson(Map<String, dynamic> json) {
    return SingleChoiceQuestionModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      points: json['points'],
      timeLimit: json['timeLimit'],
      options: List<String>.from(json['metadata']['options']),
      correctOptionIndices: List<int>.from(json['metadata']['correctOptionIndices']),
      allowMultipleSelections: json['metadata']['allowMultipleSelections'] ?? false,
      randomizeOptions: json['metadata']['randomizeOptions'] ?? false,
    );
  }
}
