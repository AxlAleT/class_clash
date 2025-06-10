import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../controllers/quiz_creation_controller.dart';

class QuizSetupScreen extends StatefulWidget {
  final QuizCreationController controller;
  const QuizSetupScreen({Key? key, required this.controller}) : super(key: key);

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.controller.quizState.title);
    _descriptionController =
        TextEditingController(text: widget.controller.quizState.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Quiz Title'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Quiz Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  widget.controller.updateQuizTitle(_titleController.text);
                  widget.controller
                      .updateQuizDescription(_descriptionController.text);
                  context.go('/quiz/create/add-question',
                      extra: widget.controller);
                },
                child: const Text('Add Questions'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}