import 'package:class_clash/features/quiz_creation/models/questions/question_model.dart';
import 'package:class_clash/features/quiz_creation/factory/question_factory.dart';

class StandardQuizModel {
  final String? id;
  final String title;
  final String? description;
  final List<QuestionModel> questions;
  final String ownerId;
  final DateTime? createdAt;
  final String category;
  final bool isPublic;
  final int timeLimit; // Total quiz time in seconds (0 for no limit)
  final Map<String, dynamic> settings;

  StandardQuizModel({
    this.id,
    required this.title,
    this.description,
    required this.questions,
    required this.ownerId,
    this.createdAt,
    required this.category,
    this.isPublic = false,
    this.timeLimit = 0,
    this.settings = const {},
  });

  // Convert the quiz to JSON format for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((question) => question.toJson()).toList(),
      'ownerId': ownerId,
      'createdAt': createdAt?.toIso8601String(),
      'category': category,
      'isPublic': isPublic,
      'timeLimit': timeLimit,
      'settings': settings,
    };
  }

  // Create a quiz from JSON data
  factory StandardQuizModel.fromJson(Map<String, dynamic> json) {
    return StandardQuizModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      questions: (json['questions'] as List)
          .map((q) => _createQuestionFromJson(q))
          .cast<QuestionModel>()
          .toList(),
      ownerId: json['ownerId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      category: json['category'],
      isPublic: json['isPublic'] ?? false,
      timeLimit: json['timeLimit'] ?? 0,
      settings: json['settings'] ?? {},
    );
  }

  // Helper method to create appropriate question type from JSON
  static QuestionModel _createQuestionFromJson(Map<String, dynamic> json) {
    return QuestionFactory.createQuestionFromJson(json);
  }
}
