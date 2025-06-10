import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../controllers/quiz_creation_controller.dart';

class QuizSetupScreen extends StatelessWidget {
  final QuizCreationController controller;
  const QuizSetupScreen({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example UI, replace with your actual UI
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Setup')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Quiz title: ${controller.quizState.title}'),
            Text('Quiz description: ${controller.quizState.description}'),
            ElevatedButton(
              onPressed: () {
                context.go('/quiz/create/add-question', extra: controller);
              },
              child: const Text('Add Questions'),
            ),
          ],
        ),
      ),
    );
  }
}