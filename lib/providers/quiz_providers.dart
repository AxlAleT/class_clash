
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/quiz/factories/question_factory.dart';
import '../features/quiz/factories/gamification_factory.dart';
import '../core/models/question.dart';
import '../core/models/gamification_strategy.dart';

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
      gamificationStrategies: gamificationStrategies ?? this.gamificationStrategies,
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
    state = state.copyWith(
      questions: [...state.questions, question],
    );
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
}