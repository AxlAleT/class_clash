// This is a conceptual Flutter widget.
// In a real Flutter app, this would import 'package:flutter/material.dart';
// For GoRouter navigation
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../controllers/quiz_creation_controller.dart';
import '../models/question_model.dart';
// We might need specific question types if display logic differs greatly
// import '../models/mcq_question_model.dart';
import '../widgets/question_builders/mcq_builder.dart'; // For main method setup
import 'add_question_screen.dart'; // For main method setup

class QuizPreviewScreen extends StatelessWidget {
  final QuizCreationController controller;
  const QuizPreviewScreen({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Preview')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Preview: ${controller.quizState.title}'),
            Text('Description: ${controller.quizState.description}'),
            Text('Questions: ${controller.quizState.questions.length}'),
            ElevatedButton(
              onPressed: () {
                context.go('/quiz/create/setup', extra: controller);
              },
              child: const Text('Edit Setup'),
            ),
          ],
        ),
      ),
    );
  }
}

// Example of how this screen might be used (conceptual)
void main() {
  // Setup a controller with some data
  final controller = QuizCreationController();
  controller.updateQuizTitle("Sample Preview Quiz");
  controller.updateQuizDescription("This is a quiz to demonstrate the preview screen.");

  // Manually adding questions directly to the controller for preview:
  if (controller.quizState.questions.isEmpty) {
    MCQBuilder mcqBuilder = MCQBuilder(onQuestionCreated: (q) => controller.addQuestion(q));
    mcqBuilder.setQuestionText("What is 2+2?");
    mcqBuilder.updateOptionText(0, "3");
    mcqBuilder.updateOptionText(1, "4");
    mcqBuilder.setCorrectAnswer(1);
    mcqBuilder.finalizeQuestion();

    MCQBuilder mcqBuilder2 = MCQBuilder(onQuestionCreated: (q) => controller.addQuestion(q));
    mcqBuilder2.setQuestionText("Red Planet?");
    mcqBuilder2.updateOptionText(0, "Earth");
    mcqBuilder2.updateOptionText(1, "Mars");
    mcqBuilder2.setCorrectAnswer(1);
    mcqBuilder2.finalizeQuestion();
    print("Manually added questions for QuizPreviewScreen main. Total: ${controller.quizState.questions.length}");
  }

  // Now the controller has questions. Let's print the quiz state for demonstration.
  print('Preview: ${controller.quizState.title}');
  print('Description: ${controller.quizState.description}');
  print('Questions: ${controller.quizState.questions.length}');

  // Simulate user actions (no BuildContext used)
  // After saving, the controller's state is reset. Let's check:
  controller.quizState.questions.clear();
  print("\n--- Previewing after save (should be empty) ---");
  print('Questions: ${controller.quizState.questions.length}');

  // Simulate refilling and going to other screens
  controller.updateQuizTitle("Another Quiz");
  // (add questions again if needed)
  if (controller.quizState.questions.isEmpty) {
    MCQBuilder mcqBuilder = MCQBuilder(onQuestionCreated: (q) => controller.addQuestion(q));
    mcqBuilder.setQuestionText("Capital of France?");
    mcqBuilder.updateOptionText(0, "Paris");
    mcqBuilder.setCorrectAnswer(0);
    mcqBuilder.finalizeQuestion();
  }
  print("\n--- Simulating navigation from preview (with 'Another Quiz') ---");
  print('Preview: ${controller.quizState.title}');
  print('Questions: ${controller.quizState.questions.length}');
}
