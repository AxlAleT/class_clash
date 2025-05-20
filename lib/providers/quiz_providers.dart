import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/gamification_strategy.dart';
import '../core/models/question.dart';
import '../features/quiz/factories/gamification_factory.dart';
import '../features/quiz/factories/question_factory.dart';
import '../core/models/quiz.dart';

/// Service class to handle quiz data retrieval 
class QuizService {
  // Method to get quiz data by ID
  Map<String, dynamic> getQuizData(String quizId) {
    // In a real app, this would fetch from an API or local storage
    // For now, returning mock data
    return {
      'id': quizId,
      'title': 'Sample Quiz',
      'questions': [
        {
          'type': 'multiple_choice',
          'data': {
            'id': '1',
            'title': 'What is the capital of France?',
            'description': 'Select the correct capital city.',
            'options': ['Paris', 'London', 'Berlin', 'Rome'],
            'correctOptionIndices': [0],
            'points': 10,
          },
        },
        {
          'type': 'true_false',
          'data': {
            'id': '2',
            'title': 'Flutter is developed by Google.',
            'description': 'Indicate whether this statement is true or false.',
            'correctAnswer': true,
            'points': 5,
          },
        },
        {
          'type': 'multiple_choice',
          'data': {
            'id': '3',
            'title': 'Which programming language is used for Flutter development?',
            'description': 'Choose the language used to build Flutter applications.',
            'options': ['JavaScript', 'Swift', 'Dart', 'Kotlin'],
            'correctOptionIndices': [2],
            'points': 15,
          },
        },
      ],
      'gamification': [
        {
          'type': 'points',
          'data': {
            'id': 'points_1',
            'name': 'Points System',
            'basePoints': 10
          },
        },
        {
          'type': 'streak',
          'data': {
            'id': 'streak_1',
            'name': 'Streak Bonus',
            'bonusPoints': 5
          },
        },
      ],
    };
  }
  
  /// Load a quiz with all its components instantiated
  Quiz loadQuiz(String quizId) {
    final quizData = getQuizData(quizId);
    
    // Process questions
    final List<Question> questions = [];
    for (var questionData in quizData['questions']) {
      try {
        final question = QuestionFactory.createQuestion(
          questionData['type'],
          questionData['data'],
        );
        questions.add(question);
      } catch (e) {
        print('Error creating question: $e');
        // Handle error as needed
      }
    }
    
    // Process gamification strategies
    final List<GamificationStrategy> strategies = [];
    for (var strategyData in quizData['gamification']) {
      try {
        final strategy = GamificationFactory.createStrategy(
          strategyData['type'],
          strategyData['data'],
        );
        strategies.add(strategy);
      } catch (e) {
        print('Error creating gamification strategy: $e');
        // Handle error as needed
      }
    }
    
    // Create and return Quiz instance
    return Quiz(
      id: quizData['id'],
      title: quizData['title'],
      questions: questions,
      gamificationStrategies: strategies,
    );
  }
}

// Provider for quiz service
final quizServiceProvider = Provider<QuizService>((ref) {
  return QuizService();
});

// Provider for available question types
final availableQuestionTypesProvider = Provider<List<String>>((ref) {
  return QuestionFactory.getAvailableQuestionTypes();
});

// Provider for available gamification strategies
final availableGamificationStrategiesProvider = Provider<List<String>>((ref) {
  return GamificationFactory.getAvailableStrategies();
});
