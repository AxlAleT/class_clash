import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/quiz/controllers/quiz_play_controller.dart';
import 'quiz_providers.dart';

/// Provider for the quiz controller
/// Using autoDispose to ensure a fresh controller is created each time
final quizControllerProvider = StateNotifierProvider.autoDispose.family<QuizController, QuizState, String>(
  (ref, quizId) {
    // When this provider is auto-disposed, it will call the dispose method in the controller
    ref.onDispose(() {
      // Clean-up logic (if needed)
    });
    
    return QuizController(
      quizId: quizId,
      quizProvider: ref.watch(quizProviderProvider),
      user: null, // This could be retrieved from another provider
    );
  },
);

/// Provider to get the current quiz state
final quizStateProvider = Provider.family<QuizState, String>(
  (ref, quizId) => ref.watch(quizControllerProvider(quizId)),
);
