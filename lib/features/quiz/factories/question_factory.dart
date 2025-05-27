import 'package:flutter/widgets.dart';
import '../widgets/question_types/multiple_choice_question_widget.dart';
import '../widgets/question_types/single_choice_question_widget.dart';
import '../../../core/models/question.dart';
import '../models/questions/multiple_choice_question.dart';
import '../models/questions/single_choice_question.dart';

/// Factory class responsible for creating Question objects
class QuestionFactory {
  static final QuestionFactory _instance = QuestionFactory._internal();

  // Registry of question creation functions by type
  final Map<String, Question Function(Map<String, dynamic>)> _questionCreators = {};

  // Registry of question widget builder functions by type
  final Map<String, Widget Function(Question)> _questionWidgetBuilders = {};

  // Private constructor
  QuestionFactory._internal() {
    // Register built-in question types
    registerQuestionType('multiple_choice', MultipleChoiceQuestion.fromJson);
    registerQuestionType('single_choice', SingleChoiceQuestion.fromJson);

    // Register built-in question widget builders
    registerQuestionWidgetBuilder('multiple_choice', (question) {
      if (question is MultipleChoiceQuestion) {
        return MultipleChoiceQuestionWidget(question: question);
      }
      throw Exception('Invalid question type for MultipleChoiceQuestionWidget');
    });
    registerQuestionWidgetBuilder('single_choice', (question) {
      if (question is SingleChoiceQuestion) {
        return SingleChoiceQuestionWidget(question: question);
      }
      throw Exception('Invalid question type for SingleChoiceQuestionWidget');
    });
  }

  // Singleton instance
  factory QuestionFactory() => _instance;

  /// Register a question type with its creator function
  void registerQuestionType(String type, Question Function(Map<String, dynamic>) creator) {
    _questionCreators[type] = creator;
  }

  /// Register a question widget builder
  void registerQuestionWidgetBuilder(String type, Widget Function(Question) builder) {
    _questionWidgetBuilders[type] = builder;
  }

  /// Create a question from its JSON representation
  Question createFromJson(Map<String, dynamic> json) {
    final String questionType = json['type'] as String? ??
                                json['questionType'] as String? ??
                                'default';

    if (!_questionCreators.containsKey(questionType)) {
      throw Exception('Unknown question type: $questionType');
    }

    return _questionCreators[questionType]!(json);
  }

  /// Create a widget for the given question
  Widget createQuestionWidget(Question question) {
    final builder = _questionWidgetBuilders[question.questionType];
    if (builder == null) {
      throw Exception('No widget builder registered for question type: ${question.questionType}');
    }
    return builder(question);
  }

  /// Create multiple questions from a list of JSON objects
  List<Question> createManyFromJson(List<dynamic> jsonList) {
    return jsonList
        .cast<Map<String, dynamic>>()
        .map((json) => createFromJson(json))
        .toList();
  }

  /// Get available question types
  List<String> getAvailableTypes() => _questionCreators.keys.toList();

  /// Check if a question type is registered
  bool hasType(String type) => _questionCreators.containsKey(type);
}
