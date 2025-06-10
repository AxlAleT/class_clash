import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../controllers/quiz_creation_controller.dart';
import '../models/question_model.dart';
import '../models/mcq_question_model.dart';
import '../widgets/question_type_selector.dart';
import '../widgets/question_builders/question_builder.dart';
import '../widgets/question_builders/mcq_builder.dart';

class AddQuestionScreen extends StatelessWidget {
  final QuizCreationController controller;
  const AddQuestionScreen({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example UI, replace with your actual UI
    return Scaffold(
      appBar: AppBar(title: const Text('Add Question')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Add a question to: ${controller.quizState.title}'),
            ElevatedButton(
              onPressed: () {
                context.go('/quiz/create/preview', extra: controller);
              },
              child: const Text('Preview Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
