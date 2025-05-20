import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/quiz_providers.dart';
import '../controllers/quiz_controller.dart';

class QuizListScreen extends ConsumerWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use quiz providers to fetch quiz data
    final quizService = ref.watch(quizServiceProvider);

    // In a real app, you'd have a provider that returns a list of all quizzes
    // For now, we'll create sample quiz IDs and fetch their data
    final quizIds = ['1'];
    final quizzes =
        quizIds.map((id) {
          final quizData = quizService.getQuizData(id);
          return {
            'id': id,
            'title': quizData['title'],
            'questions': quizData['questions']?.length ?? 0,
            'time': '${(quizData['questions']?.length ?? 0) * 1.5} min',
          };
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Clash'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to profile page
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Available Quizzes',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: quizzes.length,
              itemBuilder: (context, index) {
                final quiz = quizzes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      quiz['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.question_answer,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text('${quiz['questions']} Questions'),
                          const SizedBox(width: 16),
                          Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(quiz['time'] as String),
                        ],
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // When button is pressed, navigate to quiz play screen
                        context.go('/quiz/play/${quiz['id']}');
                      },
                      child: const Text('Play'),
                    ),
                    onTap: () {
                      // When card is tapped, navigate to quiz play screen
                      context.go('/quiz/play/${quiz['id']}');
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/create');
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Quiz'),
      ),
    );
  }
}
