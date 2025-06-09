// This is a conceptual Flutter widget.
// In a real Flutter app, this would import 'package:flutter/material.dart';
import '../../models/question_model.dart';
import '../../models/mcq_question_model.dart';
import 'question_builder.dart';

class MCQBuilder extends QuestionBuilder {
  // In a real Flutter app, these would be TextEditingControllers or similar
  String _questionText = '';
  List<String> _options = ['Option 1', 'Option 2']; // Start with two default options
  int _correctAnswerIndex = 0;

  // If editing an existing question, it could be passed in a constructor
  MCQQuestion? _editingQuestion;

  MCQBuilder({
    required super.onQuestionCreated,
    MCQQuestion? existingQuestion, // For editing
  }) {
    if (existingQuestion != null) {
      _editingQuestion = existingQuestion;
      _questionText = existingQuestion.questionText;
      _options = List.from(existingQuestion.options); // Important to copy
      _correctAnswerIndex = existingQuestion.correctAnswerIndex;
    }
  }

  // Methods to simulate UI input for question text
  void setQuestionText(String text) {
    _questionText = text;
    print("MCQBuilder: Question text set to '$_questionText'");
  }

  // Methods to simulate UI input for options
  void addOption() {
    _options.add('New Option ${_options.length + 1}');
    print("MCQBuilder: Option added. Options: $_options");
    // If the new option makes the current correct answer index invalid, adjust it.
    // (Though typically you'd select the correct one after adding all options)
  }

  void updateOptionText(int index, String text) {
    if (index >= 0 && index < _options.length) {
      _options[index] = text;
      print("MCQBuilder: Option $index updated to '$text'. Options: $_options");
    }
  }

  void removeOption(int index) {
    if (_options.length > 1 && index >= 0 && index < _options.length) { // Keep at least one option
      _options.removeAt(index);
      if (_correctAnswerIndex == index) {
        _correctAnswerIndex = 0; // Default to first if correct was removed
      } else if (_correctAnswerIndex > index) {
        _correctAnswerIndex--;
      }
      print("MCQBuilder: Option $index removed. Options: $_options. Correct answer index: $_correctAnswerIndex");
    } else {
      print("MCQBuilder: Cannot remove option. Need at least one option.");
    }
  }

  // Method to simulate UI input for selecting the correct answer
  void setCorrectAnswer(int index) {
    if (index >= 0 && index < _options.length) {
      _correctAnswerIndex = index;
      print("MCQBuilder: Correct answer set to index $index (${_options[index]})");
    }
  }

  @override
  void build() {
    print("Building MCQBuilder UI...");
    print("  Question Text Input: [Current: '$_questionText']");
    for (int i = 0; i < _options.length; i++) {
      print("  Option ${i+1} Input: [Current: '${_options[i]}'] ${i == _correctAnswerIndex ? '(Correct)' : ''}");
    }
    print("  [Add Option Button]");
    print("  [Remove Option Button(s)]");
    print("  [Save/Finalize Question Button]");
    // In a real UI, this would render text fields, radio buttons, buttons etc.
  }

  @override
  MCQQuestion getQuestion() {
    if (_questionText.isEmpty || _options.isEmpty) {
      // In a real app, show validation error
      print("Error: Question text or options cannot be empty.");
      // Return a default or throw error, depending on desired handling
      // For now, creating a potentially invalid question if fields are empty
    }
    MCQQuestion question;
    if (_editingQuestion != null) {
        // If editing, update the existing instance or create new based on it
        _editingQuestion!.questionText = _questionText;
        _editingQuestion!.options = List.from(_options);
        _editingQuestion!.correctAnswerIndex = _correctAnswerIndex;
        question = _editingQuestion!;
    } else {
        question = MCQQuestion(
            questionText: _questionText,
            options: List.from(_options), // Use a copy
            correctAnswerIndex: _correctAnswerIndex,
        );
    }
    print("MCQBuilder: Generated MCQQuestion - Text: ${question.questionText}, Options: ${question.options}, Correct Index: ${question.correctAnswerIndex}");
    return question;
  }

  // Typically, a "Save" button within this builder's UI would call this
  void finalizeQuestion() {
    MCQQuestion q = getQuestion();
    // Perform validation before calling back
    if (q.questionText.trim().isEmpty) {
        print("MCQBuilder Error: Question text cannot be empty.");
        return;
    }
    if (q.options.any((opt) => opt.trim().isEmpty)) {
        print("MCQBuilder Error: Option text cannot be empty.");
        return;
    }
    onQuestionCreated(q); // Call the callback passed from AddQuestionScreen
    print("MCQBuilder: Question finalized and onQuestionCreated callback invoked.");
  }
}

// Example of how this builder might be used (conceptual)
void main() {
  print("--- Creating a new MCQ Question ---");
  final mcqBuilder = MCQBuilder(
    onQuestionCreated: (Question question) {
      print("Callback: MCQ Question created/updated: ${question.questionText}");
      question.display();
    }
  );

  mcqBuilder.build(); // Simulate initial UI build
  mcqBuilder.setQuestionText("What is the capital of France?");
  mcqBuilder.updateOptionText(0, "Paris");
  mcqBuilder.updateOptionText(1, "London");
  mcqBuilder.addOption(); // Adds 'New Option 3'
  mcqBuilder.updateOptionText(2, "Berlin");
  mcqBuilder.setCorrectAnswer(0); // Paris
  mcqBuilder.build(); // Simulate UI update

  // Simulate user clicking "Save" in the builder's UI
  mcqBuilder.finalizeQuestion();

  MCQQuestion createdQuestion = mcqBuilder.getQuestion(); // get the question for further use if needed

  print("\n--- Editing an existing MCQ Question ---");
  MCQQuestion existingQ = MCQQuestion(
      questionText: "Old question",
      options: ["Old Opt 1", "Old Opt 2"],
      correctAnswerIndex: 1
  );
  print("Existing question before edit:");
  existingQ.display();

  final mcqEditor = MCQBuilder(
    onQuestionCreated: (Question question) {
      print("Callback: MCQ Question updated: ${question.questionText}");
      question.display();
    },
    existingQuestion: existingQ.clone() // Pass a clone to edit
  );

  mcqEditor.build();
  mcqEditor.setQuestionText("What is 2 + 2?");
  mcqEditor.updateOptionText(0, "3");
  mcqEditor.updateOptionText(1, "4");
  mcqEditor.setCorrectAnswer(1);
  mcqEditor.build();
  mcqEditor.finalizeQuestion();

  print("\nOriginal existing question (should be unchanged if clone was passed):");
  existingQ.display(); // Verify original is unchanged if a clone was passed and edited.
}
