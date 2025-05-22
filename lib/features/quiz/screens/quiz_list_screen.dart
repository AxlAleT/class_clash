import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/quiz.dart';
import '../controllers/quiz_list_controller.dart';

class QuizListScreen extends ConsumerWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesAsync = ref.watch(quizListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Quizzes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/create'),
            tooltip: 'Create New Quiz',
          ),
        ],
      ),
      body: quizzesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading quizzes: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(quizListControllerProvider.notifier).loadQuizzes(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (quizzes) {
          if (quizzes.isEmpty) {
            return const _EmptyQuizList();
          }
          return _QuizListView(quizzes: quizzes);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/create'),
        tooltip: 'Create New Quiz',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _QuizListView extends StatelessWidget {
  final List<Quiz> quizzes;

  const _QuizListView({required this.quizzes});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        return _QuizCard(quiz: quiz);
      },
    );
  }
}

class _QuizCard extends ConsumerWidget {
  final Quiz quiz;

  const _QuizCard({required this.quiz});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get quiz type from controller
    final quizType = ref.read(quizListControllerProvider.notifier).getQuizType(quiz);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        quiz.description ?? 'No description available',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                _buildQuizTypeChip(context, quizType),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '${quiz.questions.length} questions',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                _QuizActions(quiz: quiz),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build quiz type chip directly in the card
  Widget _buildQuizTypeChip(BuildContext context, String type) {
    return Chip(
      label: Text(type.toUpperCase()),
      backgroundColor: _getChipColor(type),
      labelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      padding: EdgeInsets.zero,
    );
  }

  Color _getChipColor(String type) {
    switch(type.toLowerCase()) {
      case 'standard':
        return Colors.blue;
      case 'timed':
        return Colors.orange;
      case 'competitive':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

class _QuizActions extends StatelessWidget {
  final Quiz quiz;

  const _QuizActions({required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () {
            // TODO: Implement edit functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Edit quiz: ${quiz.title}')),
            );
          },
          tooltip: 'Edit Quiz',
        ),
        IconButton(
          icon: const Icon(Icons.bar_chart, color: Colors.green),
          onPressed: () {
            // TODO: Implement statistics view
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('View statistics for: ${quiz.title}')),
            );
          },
          tooltip: 'View Statistics',
        ),
        IconButton(
          icon: const Icon(Icons.play_arrow, color: Colors.red),
          onPressed: () {
            context.go('/quiz/play/${quiz.id}');
          },
          tooltip: 'Play Quiz',
        ),
      ],
    );
  }
}

class _EmptyQuizList extends StatelessWidget {
  const _EmptyQuizList();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.quiz_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No quizzes available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.go('/create'),
            icon: const Icon(Icons.add),
            label: const Text('Create your first quiz'),
          ),
        ],
      ),
    );
  }
}
