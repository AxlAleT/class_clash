// This is a conceptual Flutter widget.
// In a real Flutter app, this would import 'package:flutter/material.dart';
import '../../models/question_model.dart';

// Abstract class for widgets that build or edit a specific type of Question
abstract class QuestionBuilder {
  // In a real Flutter app, this would be a StatefulWidget or StatelessWidget
  // And would likely take a Question object as a parameter for editing

  final Function(Question) onQuestionCreated; // Callback when a question is finalized

  QuestionBuilder({required this.onQuestionCreated});

  // Conceptual method to build the UI for creating/editing this question type
  void build();
  // In Flutter, this would be the build(BuildContext context) method returning a Widget.

  // Method to get the created/edited question
  // This might be called by a "Save Question" button in the UI
  Question getQuestion();
}
