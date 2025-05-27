import 'package:flutter/material.dart';
import '../controllers/quiz_play_controller.dart'; // Import QuizController

class QuizCompletionWidget extends StatelessWidget {
  final Map<String, dynamic> results;
  final QuizController controller;
  final Function onReturnHome; // Callback for navigation

  const QuizCompletionWidget({
    super.key,
    required this.results,
    required this.controller,
    required this.onReturnHome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Added Scaffold to match original structure
      appBar: AppBar(title: const Text('Quiz Complete')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'Quiz Complete!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your score: ${results['totalPoints'] ?? 0} points', // Use widget.results
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 48),
              ),
              onPressed: () async {
                // Submit quiz results to the server
                await controller.submitQuizResultsToServer(); // Use widget.controller

                // Clean up the quiz safely
                controller.disposeQuiz(); // Use widget.controller

                // Call the callback for navigation
                onReturnHome(); // Use widget.onReturnHome
              },
              child: const Text('Return Home'),
            ),
          ],
        ),
      ),
    );
  }
}
