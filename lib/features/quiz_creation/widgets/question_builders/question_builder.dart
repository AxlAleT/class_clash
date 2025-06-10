import 'package:flutter/material.dart';
import '../../models/question_model.dart';

// Abstract class for widgets that build or edit a specific type of Question
abstract class QuestionBuilder extends StatefulWidget {
  final Function(Question) onQuestionCreated; // Callback when a question is finalized

  const QuestionBuilder({Key? key, required this.onQuestionCreated}) : super(key: key);

  // Concrete subclasses will provide their own State implementation
  // and that State's build method will return the widget's UI.

  // Method to get the created/edited question.
  // This will be called by the concrete implementation, typically when a "Save" button is pressed.
  Question getQuestion();
}

// Abstract base class for the State of any QuestionBuilder.
// This allows AddQuestionScreen to use a GlobalKey<QuestionBuilderState>
// to potentially interact with any type of question builder if needed,
// for example, to call a reset method or the getQuestion method.
abstract class QuestionBuilderState<T extends StatefulWidget> extends State<T> {
  Question getQuestion();
  // Potentially add other common methods here, e.g.:
  // void reset(); // To clear the builder's fields
}
