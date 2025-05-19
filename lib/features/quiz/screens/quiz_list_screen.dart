import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuizListScreen extends StatelessWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for quizzes
    final quizzes = [
      {'id': '1', 'title': 'Math Quiz', 'questions': 10, 'time': '15 min'},
      {'id': '2', 'title': 'Science Trivia', 'questions': 15, 'time': '20 min'},
      {'id': '3', 'title': 'History Facts', 'questions': 12, 'time': '18 min'},
      {'id': '4', 'title': 'Grammar Challenge', 'questions': 8, 'time': '10 min'},
    ];

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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: quizzes.length,
              itemBuilder: (context, index) {
                final quiz = quizzes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                          Icon(Icons.question_answer, size: 16, color: Colors.grey[600]),
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
                        context.go('/play/${quiz['id']}');
                      },
                      child: const Text('Play'),
                    ),
                    onTap: () {
                      // Show quiz details
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
