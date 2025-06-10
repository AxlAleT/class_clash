// Base abstract class for all question types in quiz creation
abstract class QuestionModel {
  final String? id;
  final String title;
  final String? description;
  final int points;
  final int timeLimit;
  final String questionType;

  QuestionModel({
    this.id,
    required this.title,
    this.description,
    required this.points,
    required this.timeLimit,
    required this.questionType,
  });

  // Abstract method that all question types must implement
  // This generates the JSON representation matching the mock format
  Map<String, dynamic> toJson();
}
