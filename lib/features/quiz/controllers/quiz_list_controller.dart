import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/quiz.dart';
import '../../../providers/quiz_providers.dart';

/// Controller to handle quiz listing operations
class QuizListController extends StateNotifier<AsyncValue<List<Quiz>>> {
  final QuizProvider _quizProvider;

  QuizListController({
    required QuizProvider quizProvider,
  }) : _quizProvider = quizProvider,
       super(const AsyncValue.loading()) {
    // Load quizzes when controller is created
    loadQuizzes();
  }

  /// Load or reload the list of quizzes
  Future<void> loadQuizzes() async {
    try {
      state = const AsyncValue.loading();
      final quizzes = await _quizProvider.listQuizzes();
      state = AsyncValue.data(quizzes);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Get the type of a quiz based on metadata or default to "standard"
  String getQuizType(Quiz quiz) {
    // Since we can't modify Quiz class, we'll extract type from metadata if available
    if (quiz.metadata.containsKey('type')) {
      return quiz.metadata['type'] as String;
    }

    // Check if it has time limits on questions
    bool hasTimeLimits = quiz.questions.any((q) => q.timeLimit > 0);

    // Determine type based on available information
    if (hasTimeLimits) {
      return 'timed';
    }

    return 'standard';
  }
}

/// Provider for the quiz list controller
final quizListControllerProvider = StateNotifierProvider<QuizListController, AsyncValue<List<Quiz>>>(
  (ref) => QuizListController(
    quizProvider: ref.watch(quizProviderInstance),
  ),
);
