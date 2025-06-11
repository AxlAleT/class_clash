import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:class_clash/features/quiz_creation/models/quiz/standard_quiz.dart';
import 'package:class_clash/features/quiz_creation/models/questions/question_model.dart';
import 'package:class_clash/features/quiz_creation/providers/quiz_questions_provider.dart';
import 'package:class_clash/features/quiz/controllers/quiz_list_controller.dart';
import 'package:go_router/go_router.dart';

// A controller that handles UI-specific logic and delegates to the provider
class QuizQuestionsScreenController {
  final WidgetRef ref;
  final StandardQuizModel initialQuizData;

  QuizQuestionsScreenController({
    required this.ref,
    required this.initialQuizData,
  });

  // Get provider state
  QuizQuestionsState get state => ref.watch(quizQuestionsProvider(initialQuizData));

  // Get provider notifier
  QuizQuestionsNotifier get notifier => ref.read(quizQuestionsProvider(initialQuizData).notifier);

  // UI-specific methods that handle user interactions and delegate to the provider

  // Handle form submission
  void handleQuestionSaved(QuestionModel question) {
    if (state.selectedQuestionIndex != -1) {
      notifier.updateQuestion(state.selectedQuestionIndex, question);
    } else {
      notifier.addQuestion(question);
    }
  }

  // Handle sidebar toggle
  void toggleSidebar(bool isVisible, Function(bool) updateVisibility) {
    updateVisibility(!isVisible);
  }

  // Save quiz and handle navigation/dialog
  Future<void> saveQuiz(BuildContext context) async {
    // Delegate to provider for saving to server
    final quizId = await notifier.saveQuizToServer();

    if (quizId != null) {
      // Show success dialog (UI-specific logic)
      _showSuccessDialog(context, quizId);
    } else {
      // Show error dialog
      _showErrorDialog(context);
    }
  }

  // Show success dialog - UI specific logic
  void _showSuccessDialog(BuildContext context, String quizId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Saved'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quiz "${state.quizModel.title}" has been created with ${state.questions.length} questions.'),
            const SizedBox(height: 16),
            Text('Quiz ID: $quizId'),
            const SizedBox(height: 16),
            const Text('Your quiz is now available in the quiz list!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close the dialog first
              Navigator.of(context).pop();

              // Refresh the quiz list before navigating
              ref.read(quizListControllerProvider.notifier).loadQuizzes();

              // Navigate to the quiz list route
              GoRouter.of(context).go('/quizzes');
            },
            child: const Text('Go to Quiz List'),
          ),
          TextButton(
            onPressed: () {
              // Close the dialog first
              Navigator.of(context).pop();

              // Use GoRouter to navigate to home route
              GoRouter.of(context).go('/');
            },
            child: const Text('Go to Home'),
          ),
          TextButton(
            onPressed: () {
              // Close dialog but stay on this screen
              Navigator.of(context).pop();
            },
            child: const Text('Continue Editing'),
          ),
        ],
      ),
    );
  }

  // Show error dialog - UI specific logic
  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error Saving Quiz'),
        content: const Text('There was an error saving your quiz. Please make sure you have at least one question.'),
        actions: [
          TextButton(
            onPressed: () {
              // Close the dialog
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Format question type for display - UI specific helper
  String formatQuestionType(String type) {
    return type.split('_').map((word) =>
      '${word[0].toUpperCase()}${word.substring(1)}'
    ).join(' ');
  }
}
