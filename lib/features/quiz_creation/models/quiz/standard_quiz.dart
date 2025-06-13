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
    final id = json['id'] as String?;
    final title = json['title'] as String? ?? '';
    final description = json['description'] as String?;
    final questionsJson = json['questions'] as List? ?? [];
    final ownerId = json['ownerId'] as String? ?? '';
    final createdAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String)
        : null;
    final category = json['category'] as String? ?? '';
    final isPublic = json['isPublic'] as bool? ?? false;
    final timeLimit = json['timeLimit'] as int? ?? 0;
    final settings = (json['settings'] as Map<String, dynamic>?) ?? {};
    return StandardQuizModel(
      id: id,
      title: title,
      description: description,
      questions: questionsJson
          .map((q) => _createQuestionFromJson(q as Map<String, dynamic>))
          .toList(),
      ownerId: ownerId,
      createdAt: createdAt,
      category: category,
      isPublic: isPublic,
      timeLimit: timeLimit,
      settings: settings,
    );
  }

  // Helper method to create appropriate question type from JSON
  static QuestionModel _createQuestionFromJson(Map<String, dynamic> json) {
    return QuestionFactory.createQuestionFromJson(json);
  }
}
