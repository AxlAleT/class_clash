import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/gamification_strategy.dart';
import '../core/models/question.dart';
import '../features/quiz/factories/gamification_factory.dart';
import '../features/quiz/factories/question_factory.dart';

// Quiz Service class to handle quiz data
class QuizService {
  // Method to get quiz data by ID
  Map<String, dynamic> getQuizData(String quizId) {
    // In a real app, this would fetch from an API or local storage
    // For now, returning mock data
    return {
      'title': 'Sample Quiz',
      'questions': [
        {
          'type': 'multiple_choice',
          'data': {
            'id': '1', // Added id field
            'title': 'What is the capital of France?',
            'description': 'Select the correct capital city.',
            'options': ['Paris', 'London', 'Berlin', 'Rome'],
            'correctOptionIndices': [0], // Changed to use indices instead
            'points': 10,
          },
        },
        // More questions would be here
      ],
      'gamification': [
        {
          'type': 'points',
          'data': {'basePoints': 10},
        },
        {
          'type': 'streak',
          'data': {'bonusPoints': 5},
        },
      ],
    };
  }
}

// Provider for quiz service
final quizProvider = Provider<QuizService>((ref) {
  return QuizService();
});

// Proveedor para los tipos de preguntas disponibles
final availableQuestionTypesProvider = Provider<List<String>>((ref) {
  return QuestionFactory.getAvailableQuestionTypes();
});

// Proveedor para las estrategias de gamificación disponibles
final availableGamificationStrategiesProvider = Provider<List<String>>((ref) {
  return GamificationFactory.getAvailableStrategies();
});

// Estado para el quiz actual
class QuizState {
  final List<Question> questions;
  final List<GamificationStrategy> gamificationStrategies;
  final int currentQuestionIndex;
  final int totalPoints;
  final int currentStreak;
  final Map<String, dynamic> metadata;

  QuizState({
    this.questions = const [],
    this.gamificationStrategies = const [],
    this.currentQuestionIndex = 0,
    this.totalPoints = 0,
    this.currentStreak = 0,
    this.metadata = const {},
  });

  QuizState copyWith({
    List<Question>? questions,
    List<GamificationStrategy>? gamificationStrategies,
    int? currentQuestionIndex,
    int? totalPoints,
    int? currentStreak,
    Map<String, dynamic>? metadata,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      gamificationStrategies:
          gamificationStrategies ?? this.gamificationStrategies,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      metadata: metadata ?? this.metadata,
    );
  }
}

// Proveedor para el estado del quiz
final quizStateProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier();
});

class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier() : super(QuizState());

  // Añadir una pregunta al quiz
  void addQuestion(Question question) {
    state = state.copyWith(questions: [...state.questions, question]);
  }

  // Añadir una estrategia de gamificación
  void addGamificationStrategy(GamificationStrategy strategy) {
    state = state.copyWith(
      gamificationStrategies: [...state.gamificationStrategies, strategy],
    );
  }

  // Avanzar a la siguiente pregunta
  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    }
  }

  // Procesar una respuesta
  void processAnswer(dynamic answer) {
    Question currentQuestion = state.questions[state.currentQuestionIndex];
    bool isCorrect = currentQuestion.validateAnswer(answer);

    // Crear un mapa con la acción del usuario para las estrategias de gamificación
    Map<String, dynamic> userAction = {
      'type': 'answer',
      'isCorrect': isCorrect,
      'questionIndex': state.currentQuestionIndex,
      'answer': answer,
      'timeSpent': 0, // Esto se calcularía con el tiempo real
    };

    // Estado temporal para aplicar las estrategias
    Map<String, dynamic> tempState = {
      'totalPoints': state.totalPoints,
      'currentStreak': state.currentStreak,
      'metadata': state.metadata,
    };

    // Aplicar cada estrategia de gamificación
    for (var strategy in state.gamificationStrategies) {
      strategy.applyStrategy(
        quizState: tempState,
        userAction: userAction,
        updateState: (newState) {
          tempState = newState;
        },
      );
    }

    // Actualizar el estado con los valores calculados
    state = state.copyWith(
      totalPoints: tempState['totalPoints'],
      currentStreak: tempState['currentStreak'],
      metadata: tempState['metadata'],
    );
  }

  // Reiniciar el quiz
  void resetQuiz() {
    state = QuizState(
      questions: state.questions,
      gamificationStrategies: state.gamificationStrategies,
    );
  }

  // Update quiz metadata
  void updateQuizMetadata(Map<String, dynamic> newMetadata) {
    state = state.copyWith(metadata: {...state.metadata, ...newMetadata});
  }
}
