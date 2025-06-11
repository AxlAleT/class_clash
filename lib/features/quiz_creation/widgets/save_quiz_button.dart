import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:class_clash/features/quiz_creation/models/quiz/standard_quiz.dart';
import 'package:class_clash/features/quiz_creation/providers/quiz_save_provider.dart';
import 'package:go_router/go_router.dart';

class SaveQuizButton extends ConsumerWidget {
  final StandardQuizModel quiz;
  final VoidCallback? onBeforeSave;
  final VoidCallback? onSuccess;
  final Function(String)? onError;
  final bool navigateToListOnSuccess;

  const SaveQuizButton({
    super.key,
    required this.quiz,
    this.onBeforeSave,
    this.onSuccess,
    this.onError,
    this.navigateToListOnSuccess = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saveStatus = ref.watch(quizSaveProvider);

    return ElevatedButton(
      onPressed: saveStatus.state == QuizSaveState.saving
          ? null
          : () => _saveQuiz(context, ref),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: saveStatus.state == QuizSaveState.saving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.save),
                SizedBox(width: 8),
                Text('Save Quiz'),
              ],
            ),
    );
  }

  Future<void> _saveQuiz(BuildContext context, WidgetRef ref) async {
    if (onBeforeSave != null) {
      onBeforeSave!();
    }

    // First, reset the save state
    ref.read(quizSaveProvider.notifier).reset();

    // Then, save the quiz
    await ref.read(quizSaveProvider.notifier).saveQuiz(quiz);

    // Check the result
    final saveStatus = ref.read(quizSaveProvider);

    if (saveStatus.state == QuizSaveState.success) {
      if (onSuccess != null) {
        onSuccess!();
      }

      if (navigateToListOnSuccess) {
        if (context.mounted) {
          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quiz saved successfully! It will now appear in the quiz list.'),
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Navigate to the quiz list screen
          context.go('/quizzes');
        }
      }
    } else if (saveStatus.state == QuizSaveState.error && onError != null) {
      onError!(saveStatus.errorMessage ?? 'Unknown error');
    }
  }
}
