import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../controllers/quiz_creation_controller.dart';
import '../models/question_model.dart';
import '../models/mcq_question_model.dart';
// import '../widgets/question_type_selector.dart'; // Assuming this will be a widget later
import '../widgets/question_builders/question_builder.dart'; // Contains QuestionBuilderState now
import '../widgets/question_builders/mcq_builder.dart';
import '../widgets/question_builders/true_false_builder.dart';
import '../models/true_false_question_model.dart';
import '../widgets/question_type_selector.dart'; // Import the new widget

class AddQuestionScreen extends StatefulWidget {
  final QuizCreationController controller;
  const AddQuestionScreen({Key? key, required this.controller}) : super(key: key);

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  String _selectedQuestionType = 'Multiple Choice';
  GlobalKey<QuestionBuilderState> _questionBuilderKey = GlobalKey<QuestionBuilderState>();
  List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
    _questions = List.from(widget.controller.quizState.questions);
  }

  void _handleQuestionCreated(Question question) {
    widget.controller.addQuestion(question);
    setState(() {
      _questions = List.from(widget.controller.quizState.questions);
      // Reset the builder by changing its key, so it's fresh for the next question
      _questionBuilderKey = GlobalKey<QuestionBuilderState>();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${question.type}: Question added successfully!')),
    );
  }

  void _deleteQuestion(String questionId) { // Changed parameter to String questionId
    widget.controller.removeQuestionById(questionId); // Call new method
    // The QuizCreationController will call notifyListeners(),
    // so if this screen is listening (e.g. via Provider), it will rebuild.
    // For now, to ensure UI updates without Provider, we manually refresh _questions.
    // In a Provider setup, this manual setState and _questions refresh might not be needed
    // if the widget tree rebuilds based on controller's notification.
    final deletedQuestion = _questions.firstWhere(
      (q) => q.id == questionId,
      orElse: () => MCQQuestion(id: '', questionText: 'Unknown', options: [''], correctAnswerIndex: 0)
    ); // Use MCQQuestion instead of abstract Question
    setState(() {
      _questions = List.from(widget.controller.quizState.questions);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${deletedQuestion.type} question deleted.')),
    );
  }

  // Placeholder for edit functionality
  void _editQuestion(Question question, int index) {
    // This would involve navigating to a specific editing UI or
    // re-populating the current builder with the question's data.
    // For now, just a print statement and maybe a snackbar.
    print("Editing question at index $index: ${question.questionText}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit functionality for "${question.questionText}" is not yet implemented.')),
    );
    // TODO: Implement actual edit functionality.
    // This might involve:
    // 1. Setting _selectedQuestionType to question.type.
    // 2. Creating a new _questionBuilderKey.
    // 3. Passing the `question` object to the builder (e.g., `MCQBuilder(existingQuestion: question, ...)`).
    // This would require `MCQBuilder` (and other builders) to handle `existingQuestion`.
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Questions to "${widget.controller.quizState.title}"')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Question Type Selector ---
          QuestionTypeSelector(
            availableTypes: const ['Multiple Choice', 'True/False'],
            initialType: _selectedQuestionType,
            onTypeSelected: (String newType) {
              if (newType != _selectedQuestionType) {
                setState(() {
                  _selectedQuestionType = newType;
                  _questionBuilderKey = GlobalKey<QuestionBuilderState>(); // Reset builder
                });
              }
            },
          ),
          const SizedBox(height: 20),

          // --- Question Builder ---
          if (_selectedQuestionType == 'Multiple Choice')
            MCQBuilder(
              key: _questionBuilderKey,
              onQuestionCreated: _handleQuestionCreated,
              // existingQuestion: null, // Pass existing MCQQuestion when editing
            )
          else if (_selectedQuestionType == 'True/False')
            TrueFalseBuilder(
              key: _questionBuilderKey,
              onQuestionCreated: _handleQuestionCreated,
              // existingQuestion: null, // Pass existing TrueFalseQuestionModel when editing
            ),
          // Add other builders here based on _selectedQuestionType

          const SizedBox(height: 30),
          Divider(thickness: 1),
          const SizedBox(height: 10),
          Text('Added Questions (${_questions.length})', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          if (_questions.isEmpty)
            const Text('No questions added yet. Add one using the builder above.'),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              final question = _questions[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  title: Text(question.questionText),
                  subtitle: Text('Type: ${question.type}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editQuestion(question, index),
                        tooltip: 'Edit Question',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteQuestion(question.id), // Pass question.id
                        tooltip: 'Delete Question',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              if (_questions.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please add at least one question before previewing.'))
                );
                return;
              }
              context.go('/quiz/create/preview', extra: widget.controller);
            },
            child: const Text('Preview Quiz'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
        ],
      ),
    );
  }
}
