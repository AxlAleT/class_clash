import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../controllers/quiz_creation_controller.dart';
import '../models/question_model.dart';
import '../models/mcq_question_model.dart';
import '../models/true_false_question_model.dart'; // Import TrueFalseQuestionModel

class QuizPreviewScreen extends StatelessWidget {
  final QuizCreationController controller;
  const QuizPreviewScreen({Key? key, required this.controller}) : super(key: key);

  Widget _buildQuestionPreviewCard(Question question, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.questionText,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Type: ${question.type}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            if (question is MCQQuestion)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Options:', style: Theme.of(context).textTheme.labelLarge),
                  for (int i = 0; i < question.options.length; i++)
                    Text(
                      '  ${i + 1}. ${question.options[i]}${i == question.correctAnswerIndex ? " (Correct)" : ""}',
                      style: TextStyle(
                        fontWeight: i == question.correctAnswerIndex
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: i == question.correctAnswerIndex
                            ? Colors.green
                            : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                ],
              )
            else if (question is TrueFalseQuestionModel)
              Text(
                'Correct Answer: ${question.correctAnswer ? "True" : "False"}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[700],
                ),
              ),
            // Add more conditions for other question types here
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizState = controller.quizState;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Preview')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            quizState.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            quizState.description.isEmpty
                ? 'No description provided.'
                : quizState.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Divider(),
          const SizedBox(height: 16),
          Text(
            'Questions (${quizState.questions.length}):',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (quizState.questions.isEmpty)
            const Text('No questions added to this quiz yet.')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: quizState.questions.length,
              itemBuilder: (context, index) {
                return _buildQuestionPreviewCard(quizState.questions[index], context);
              },
            ),
          const SizedBox(height: 24),
          Divider(),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit_note),
            label: const Text('Edit Setup (Title/Description)'),
            onPressed: () {
              context.go('/quiz/create/setup', extra: controller);
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.list_alt_add),
            label: const Text('Add/Edit Questions'),
            onPressed: () {
              context.go('/quiz/create/add-question', extra: controller);
            },
             style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save Quiz'),
            onPressed: () {
              controller.saveQuiz();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Quiz saved successfully!')),
              );
              // Optionally, navigate away or clear creation flow further
              // For now, assume saveQuiz() in controller handles state reset.
              // To navigate to home, for example:
              // context.go('/');
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}