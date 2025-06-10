import 'package:class_clash/features/quiz_creation/models/questions/question_model.dart';
import 'package:class_clash/features/quiz_creation/models/questions/single_choice_question.dart';
import 'package:class_clash/features/quiz_creation/models/questions/multiple_choice_question.dart';
import 'package:class_clash/features/quiz_creation/models/questions/true_false_question.dart';

class QuestionFactory {
  // Map to hold registered question type factories
  static final Map<String, Function(Map<String, dynamic>)> _factories = {
    'single_choice': (json) => SingleChoiceQuestionModel.fromJson(json),
    'multiple_choice': (json) => MultipleChoiceQuestionModel.fromJson(json),
    'true_false': (json) => TrueFalseQuestionModel.fromJson(json),
  };

  // Create a question based on its type
  static QuestionModel createQuestionFromJson(Map<String, dynamic> json) {
    final questionType = json['questionType'];
    final factory = _factories[questionType];

    if (factory == null) {
      throw ArgumentError('Unknown question type: $questionType');
    }

    return factory(json);
  }

  // Register a new question type factory
  static void registerQuestionType(
      String type, Function(Map<String, dynamic>) factory) {
    _factories[type] = factory;
  }

  // Get list of supported question types
  static List<String> get supportedQuestionTypes => _factories.keys.toList();
}
