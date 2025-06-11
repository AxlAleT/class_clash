import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:class_clash/features/quiz_creation/models/quiz/standard_quiz.dart';
import 'package:class_clash/providers/quiz_providers.dart';
import 'package:logging/logging.dart';

/// State for saving quiz
enum QuizSaveState {
  initial,
  saving,
  success,
  error,
}

/// Provider state class for quiz saving
class QuizSaveStatus {
  final QuizSaveState state;
  final String? quizId;
  final String? errorMessage;

  QuizSaveStatus({
    this.state = QuizSaveState.initial,
    this.quizId,
    this.errorMessage,
  });

  QuizSaveStatus copyWith({
    QuizSaveState? state,
    String? quizId,
    String? errorMessage,
  }) {
    return QuizSaveStatus(
      state: state ?? this.state,
      quizId: quizId ?? this.quizId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// StateNotifier for handling quiz saving operations
class QuizSaveNotifier extends StateNotifier<QuizSaveStatus> {
  final QuizProvider _quizProvider;
  final Logger _log = Logger('QuizSaveNotifier');

  QuizSaveNotifier(this._quizProvider) : super(QuizSaveStatus());

  /// Save the quiz to the "server" (mock)
  Future<void> saveQuiz(StandardQuizModel quiz) async {
    try {
      // Set state to saving
      state = state.copyWith(state: QuizSaveState.saving);
      _log.info('Saving quiz: ${quiz.title}');

      // Convert the quiz to a JSON representation
      Map<String, dynamic> quizData = quiz.toJson();

      // If the quiz doesn't have an ID yet, it's a new quiz
      if (quiz.id == null || quiz.id!.isEmpty) {
        // Create a new quiz on the "server"
        String quizId = await _quizProvider.createQuiz(quizData);
        _log.info('Created new quiz with ID: $quizId');

        // Update state with success and the quiz ID
        state = state.copyWith(
          state: QuizSaveState.success,
          quizId: quizId,
        );
      } else {
        // Update an existing quiz
        bool success = await _quizProvider.updateQuiz(quiz.id!, quizData);

        if (success) {
          _log.info('Updated existing quiz: ${quiz.id}');
          // Update state with success
          state = state.copyWith(
            state: QuizSaveState.success,
            quizId: quiz.id,
          );
        } else {
          throw Exception('Failed to update quiz');
        }
      }
    } catch (e) {
      _log.severe('Error saving quiz: $e');
      // Update state with error
      state = state.copyWith(
        state: QuizSaveState.error,
        errorMessage: 'Failed to save quiz: $e',
      );
    }
  }

  /// Reset the save state to initial
  void reset() {
    state = QuizSaveStatus();
  }
}

/// Provider for quiz saving functionality
final quizSaveProvider = StateNotifierProvider<QuizSaveNotifier, QuizSaveStatus>((ref) {
  return QuizSaveNotifier(QuizProvider());
});
