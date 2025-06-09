// This is a conceptual Flutter widget.
// In a real Flutter app, this would import 'package:flutter/material.dart';

import '../controllers/quiz_creation_controller.dart';
import '../models/question_model.dart';
import '../models/mcq_question_model.dart'; // Added import
import '../widgets/question_type_selector.dart';
import '../widgets/question_builders/question_builder.dart'; // Abstract
import '../widgets/question_builders/mcq_builder.dart'; // Now using the concrete implementation

class AddQuestionScreen {
  // In a real Flutter app, this would be a StatefulWidget or StatelessWidget
  final QuizCreationController controller;
  // In a real app, selectedQuestionBuilder would change based on QuestionTypeSelector
  QuestionBuilder? selectedQuestionBuilder;
  String selectedQuestionType = 'MCQ'; // Default or from selector

  AddQuestionScreen({required this.controller}) {
    // Initialize with a default builder, e.g., MCQBuilder
    // This is conceptual; in Flutter, this would be part of the build method or state management
    _updateQuestionBuilder(selectedQuestionType);
  }

  void _updateQuestionBuilder(String questionType) {
    selectedQuestionType = questionType;
    // In a real app, this would use a factory or switch statement
    // to instantiate the correct QuestionBuilder based on questionType.
    if (questionType == 'MCQ') {
      // Assuming MCQBuilder is available and QuestionTypeSelector sets this type
      // The actual MCQBuilder will be created in a later step.
      // For now, this might error if MCQBuilder is not defined, or be a placeholder.
      // We'll create a placeholder MCQBuilder in this subtask to avoid errors.
      selectedQuestionBuilder = MCQBuilder(
        onQuestionCreated: (Question question) {
          controller.addQuestion(question);
          print("MCQ Question added to controller: ${question.questionText}");
          // In Flutter, might navigate back or clear form
        }
      );
    }
    // else if (questionType == 'TrueFalse') {
    //   selectedQuestionBuilder = TrueFalseBuilder(...);
    // }
    // ... and so on for other types
    print("Selected question builder for type: $questionType");
  }

  // Conceptual representation of building the UI
  void build() {
    print("Building AddQuestionScreen UI...");

    // 1. Display QuestionTypeSelector (conceptually)
    //    In a real app, this widget would call _updateQuestionBuilder on selection change.
    QuestionTypeSelector typeSelector = QuestionTypeSelector(
        availableTypes: ['MCQ', 'True/False', 'Short Answer'], // Example types
        onTypeSelected: (type) {
          print("Question type selected: $type");
          _updateQuestionBuilder(type);
          // In Flutter, this would trigger a rebuild to show the new builder
          this.build(); // Simulate rebuild for the new builder
        }
    );
    typeSelector.build(); // Simulate selector UI build

    // 2. Display the selectedQuestionBuilder
    if (selectedQuestionBuilder != null) {
      selectedQuestionBuilder!.build(); // Simulate builder UI build
    } else {
      print("No question builder selected.");
    }

    // 3. Button to save the question (would call selectedQuestionBuilder.getQuestion())
    //    and then onQuestionCreated callback.
    //    This is simplified here; the builder itself would handle its internal save.
    print("AddQuestionScreen built. Current builder: ${selectedQuestionBuilder.runtimeType}");
  }

  // Simulating saving the question from the current builder
  void saveQuestion() {
    if (selectedQuestionBuilder != null) {
      Question question = selectedQuestionBuilder!.getQuestion();
      // The onQuestionCreated callback in the builder would handle adding to controller
      // controller.addQuestion(question);
      print("Question obtained from builder: ${question.questionText}");
    } else {
      print("Cannot save: No question builder selected or question not complete.");
    }
  }
}

// Example of how this screen might be used (conceptual)
void main() {
  final controller = QuizCreationController();
  final addQuestionScreen = AddQuestionScreen(controller: controller);

  // Simulate user selecting 'MCQ' (default or via selector)
  // The initial _updateQuestionBuilder in the constructor already sets up an MCQBuilder
  // and its onQuestionCreated callback is wired to controller.addQuestion.
  addQuestionScreen.build();

  // Simulate user filling out the MCQ form using the currently selected builder
  // and then the builder internally calling its onQuestionCreated callback.
  if (addQuestionScreen.selectedQuestionBuilder is MCQBuilder) {
    MCQBuilder currentMCQBuilder = addQuestionScreen.selectedQuestionBuilder as MCQBuilder;
    print("\nSimulating user interaction with the current MCQBuilder:");
    currentMCQBuilder.setQuestionText("What is Flutter?");
    currentMCQBuilder.updateOptionText(0, "A bird");
    currentMCQBuilder.updateOptionText(1, "A UI toolkit");
    currentMCQBuilder.addOption();
    currentMCQBuilder.updateOptionText(2, "A programming language");
    currentMCQBuilder.setCorrectAnswer(1); // "A UI toolkit"
    currentMCQBuilder.finalizeQuestion(); // This will trigger onQuestionCreated
  }

  // To test adding another question, we'd typically simulate changing type or just adding another of the same.
  // Let's simulate creating and saving another MCQ directly through a new builder instance for clarity.
  print("\nSimulating adding another MCQ question (distinct builder instance):");
  MCQBuilder anotherMcqBuilder = MCQBuilder(
    onQuestionCreated: (Question q) {
      controller.addQuestion(q);
      print("Another MCQ Question added to controller: ${q.questionText}");
      if (q is MCQQuestion) { // Displaying the MCQ details
        q.display();
      }
    }
  );
  // Simulate user filling data in anotherMcqBuilder UI...
  anotherMcqBuilder.build(); // Simulate UI build
  anotherMcqBuilder.setQuestionText("What is Dart?");
  anotherMcqBuilder.updateOptionText(0, "A programming language");
  anotherMcqBuilder.updateOptionText(1, "A type of missile");
  anotherMcqBuilder.setCorrectAnswer(0);
  // Then user clicks "Save" in its UI, which calls finalizeQuestion()
  anotherMcqBuilder.finalizeQuestion(); // This will call onQuestionCreated

  print("\nTotal questions in controller: ${controller.quizState.questions.length}");
  if (controller.quizState.questions.isNotEmpty) {
    print("\nDisplaying all questions in controller:");
    for (var q_idx = 0; q_idx < controller.quizState.questions.length; q_idx++) {
        print("--- Question ${q_idx+1} ---");
        controller.quizState.questions[q_idx].display();
    }
  }
}
