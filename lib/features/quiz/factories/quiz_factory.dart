
import '../../../core/models/quiz.dart';
import '../../../core/models/question.dart';
import '../../../core/models/gamification_strategy.dart';
import 'question_factory.dart';
import 'gamification_factory.dart';
import 'user_factory.dart';
import '../models/quizzes/standard_quiz.dart';

/// Factory class responsible for creating Quiz objects
class QuizFactory {
  static final QuizFactory _instance = QuizFactory._internal();

  // Registry of quiz creation functions by type
  final Map<String, Quiz Function(Map<String, dynamic>)> _quizCreators = {};

  // Private constructor
  QuizFactory._internal() {
    // Register built-in quiz types
    registerQuizType('standard', _createStandardQuiz);
    registerQuizType('default', _createStandardQuiz); // Alias for standard
  }

  // Singleton instance
  factory QuizFactory() => _instance;

  // Dependencies on other factories
  final QuestionFactory _questionFactory = QuestionFactory();
  final GamificationFactory _gamificationFactory = GamificationFactory();
  final UserFactory _userFactory = UserFactory();

  /// Register a quiz type with its creator function
  void registerQuizType(String type, Quiz Function(Map<String, dynamic>) creator) {
    _quizCreators[type] = creator;
  }

  /// Create a quiz from its JSON representation
  Quiz createFromJson(Map<String, dynamic> json) {
    final String quizType = json['type'] as String? ?? 'default';

    if (!_quizCreators.containsKey(quizType)) {
      throw Exception('Unknown quiz type: $quizType');
    }

    // Create questions
    final List<Question> questions = [];
    if (json.containsKey('questions') && json['questions'] is List) {
      for (final questionJson in json['questions']) {
        questions.add(_questionFactory.createFromJson(questionJson));
      }
    }

    // Create gamification strategies
    final List<GamificationStrategy> strategies = [];
    if (json.containsKey('gamificationStrategies') && json['gamificationStrategies'] is List) {
      for (final strategyJson in json['gamificationStrategies']) {
        strategies.add(_gamificationFactory.createFromJson(strategyJson));
      }
    }

    // Update json with processed objects
    final Map<String, dynamic> processedJson = Map<String, dynamic>.from(json);
    processedJson['questions'] = questions;
    processedJson['gamificationStrategies'] = strategies;

    // Create the quiz using registered creator
    return _quizCreators[quizType]!(processedJson);
  }

  /// Create a StandardQuiz from JSON data
  Quiz _createStandardQuiz(Map<String, dynamic> json) {
    // Extract questions and strategies that were pre-processed
    final List<Question> questions = json['questions'] as List<Question>;
    final List<GamificationStrategy> strategies =
        json['gamificationStrategies'] as List<GamificationStrategy>;

    // Create user from user data in JSON
    final user = json.containsKey('user') && json['user'] != null
        ? _userFactory.createFromJson(json['user'])
        : _userFactory.createGuestUser(displayName: "Guest");

    return StandardQuiz.fromJson(json,
      parsedQuestions: questions,
      parsedStrategies: strategies,
      user: user,
    );
  }

  /// Get available quiz types
  List<String> getAvailableTypes() => _quizCreators.keys.toList();

  /// Check if a quiz type is registered
  bool hasType(String type) => _quizCreators.containsKey(type);
}
