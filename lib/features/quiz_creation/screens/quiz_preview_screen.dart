// This is a conceptual Flutter widget.
// In a real Flutter app, this would import 'package:flutter/material.dart';
// For GoRouter navigation
import 'package:go_router/go_router.dart';
import '../controllers/quiz_creation_controller.dart';
import '../models/question_model.dart';
// We might need specific question types if display logic differs greatly
// import '../models/mcq_question_model.dart';
import '../widgets/question_builders/mcq_builder.dart'; // For main method setup
import 'add_question_screen.dart'; // For main method setup


class QuizPreviewScreen {
  // In a real Flutter app, this would be a StatefulWidget or StatelessWidget
  final QuizCreationController controller;

  QuizPreviewScreen({required this.controller});

  // Conceptual representation of building the UI
  void build() {
    print("\nBuilding QuizPreviewScreen UI...");
    print("===================================");
    print("      QUIZ PREVIEW               ");
    print("===================================");
    print("Title: ${controller.quizState.title}");
    print("Description: ${controller.quizState.description}");
    print("-----------------------------------");
    print("Questions (${controller.quizState.questions.length}):");

    if (controller.quizState.questions.isEmpty) {
      print("  No questions added yet.");
    } else {
      for (int i = 0; i < controller.quizState.questions.length; i++) {
        Question question = controller.quizState.questions[i];
        print("\n  Question ${i + 1}:");
        // The 'display' method on the Question model handles specific formatting
        question.display();
        // Example: if you wanted to show edit/delete buttons conceptually:
        // print("    [Edit Question Button] [Delete Question Button]");
      }
    }
    print("-----------------------------------");
    print("[Save Quiz Button] [Edit Quiz Setup Button] [Add More Questions Button]");
    print("===================================");
  }

  // Conceptual actions
  // Added dynamic context for navigation and renamed to avoid conflict
  void saveAndExit(dynamic context) {
    print("\nQuizPreviewScreen: Save Quiz action triggered.");
    controller.saveQuiz(); // This will print save messages and reset the state
    print("QuizPreviewScreen: Navigating to /quizzes (quiz list)...");
    if (context is BuildContext) {
      context.go('/quizzes');
    } else {
      print("QuizPreviewScreen: Conceptual navigation to /quizzes (context not BuildContext).");
    }
  }

  // Added dynamic context for navigation
  void editQuizSetup(dynamic context) {
    print("\nQuizPreviewScreen: Edit Quiz Setup action triggered.");
    if (context is BuildContext) {
      context.go('/quiz/create/setup', extra: controller);
      print("QuizPreviewScreen: Navigating to /quiz/create/setup");
    } else {
      print("QuizPreviewScreen: Conceptual navigation to QuizSetupScreen (context not BuildContext).");
    }
  }

  // Added dynamic context for navigation
  void goToAddQuestions(dynamic context) {
    print("\nQuizPreviewScreen: Add More Questions action triggered.");
    if (context is BuildContext) {
      context.go('/quiz/create/add-question', extra: controller);
      print("QuizPreviewScreen: Navigating to /quiz/create/add-question");
    } else {
      print("QuizPreviewScreen: Conceptual navigation to AddQuestionScreen (context not BuildContext).");
    }
  }
}

// Example of how this screen might be used (conceptual)
void main() {
  // Setup a controller with some data
  final controller = QuizCreationController();
  controller.updateQuizTitle("Sample Preview Quiz");
  controller.updateQuizDescription("This is a quiz to demonstrate the preview screen.");

  // Add questions using AddQuestionScreen's logic (which adds to controller)
  final addQuestionScreen = AddQuestionScreen(controller: controller);
  addQuestionScreen.build(null); // This will conceptually add questions and might try to navigate

  // Simulate adding an MCQ question via the AddQuestionScreen's builder flow
  // Note: addQuestionScreen.build(null) in its current form will attempt navigation.
  // For this main, we might need to suppress that or ensure questions are added before it navigates.
  // The main in add_question_screen.dart already does a good job of adding questions.
  // Let's assume questions were added as per add_question_screen.dart's main().
  if (controller.quizState.questions.isEmpty) {
      // Manually add questions if the addQuestionScreen.build(null) didn't run its full course
      // due to conceptual navigation.
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


  // Now the controller has questions. Let's build the preview screen.
  final previewScreen = QuizPreviewScreen(controller: controller);
  previewScreen.build();

  // Simulate user actions (passing null for context)
  previewScreen.saveAndExit(null);
  // After saving, the controller's state is reset. Let's check:
  print("\n--- Previewing after save (should be empty) ---");
  final newPreviewScreen = QuizPreviewScreen(controller: controller);
  newPreviewScreen.build();

  // Simulate refilling and going to other screens
  controller.updateQuizTitle("Another Quiz");
  // (add questions again if needed)
  if (controller.quizState.questions.isEmpty) { // Add a question to make sense for navigation
      MCQBuilder mcqBuilder = MCQBuilder(onQuestionCreated: (q) => controller.addQuestion(q));
      mcqBuilder.setQuestionText("Capital of France?");
      mcqBuilder.updateOptionText(0, "Paris");
      mcqBuilder.setCorrectAnswer(0);
      mcqBuilder.finalizeQuestion();
  }
  print("\n--- Simulating navigation from preview (with 'Another Quiz') ---");
  final previewScreen2 = QuizPreviewScreen(controller: controller);
  previewScreen2.build();
  previewScreen2.editQuizSetup(null);
  previewScreen2.goToAddQuestions(null);
}
