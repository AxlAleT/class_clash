import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/screens/home_screen.dart';
import '../features/quiz/screens/quiz_list_screen.dart';
import '../features/quiz/screens/quiz_play_screen.dart';
import '../features/quiz_creation/screens/quiz_setup_screen.dart';
import '../features/quiz_creation/screens/add_question_screen.dart';
import '../features/quiz_creation/screens/quiz_preview_screen.dart';
import '../features/quiz_creation/controllers/quiz_creation_controller.dart';

// Define the route configuration
final GoRouter router = GoRouter(
  routes: [
    // Home route
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),

    // Quiz list route
    GoRoute(
      path: '/quizzes',
      builder: (context, state) => const QuizListScreen(),
    ),

    // Quiz play route with quiz ID parameter
    GoRoute(
      path: '/quiz/play/:quizId',
      builder: (context, state) {
        final quizId = state.pathParameters['quizId'] ?? '';
        return QuizPlayScreen(quizId: quizId);
      },
    ),

    // Quiz Creation Flow
    // Entry point for creating a quiz, instantiates the controller
    GoRoute(
      path: '/create',
      builder: (context, state) {
        final controller = QuizCreationController();
        return QuizSetupScreen(controller: controller);
      },
    ),
    GoRoute(
      path: '/quiz/create/add-question',
      builder: (context, state) {
        final controller = state.extra as QuizCreationController?;
        if (controller == null) {
          // Handle error or redirect if controller is not passed
          // For simplicity, returning an error screen or redirecting to /create
          return Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error: QuizCreationController not found.'),
                  ElevatedButton(
                    onPressed: () => context.go('/create'),
                    child: const Text('Start Over'),
                  )
                ],
              ),
            ),
          );
        }
        return AddQuestionScreen(controller: controller);
      },
    ),
    GoRoute(
      path: '/quiz/create/preview',
      builder: (context, state) {
        final controller = state.extra as QuizCreationController?;
        if (controller == null) {
          // Handle error or redirect
          return Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error: QuizCreationController not found for preview.'),
                  ElevatedButton(
                    onPressed: () => context.go('/create'),
                    child: const Text('Start Over'),
                  )
                ],
              ),
            ),
          );
        }
        return QuizPreviewScreen(controller: controller);
      },
    ),
    // Route to allow editing quiz setup details using the existing controller
    GoRoute(
      path: '/quiz/create/setup',
      builder: (context, state) {
        if (state.extra is QuizCreationController) {
          final controller = state.extra as QuizCreationController;
          // Potentially reset parts of controller state if needed before re-setup,
          // or assume QuizSetupScreen handles existing state appropriately.
          return QuizSetupScreen(controller: controller);
        } else {
          // Handle error: Controller not provided for editing setup
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error: Quiz controller not found for setup edit.'),
                  ElevatedButton(
                    onPressed: () => context.go('/create'),
                    child: const Text('Create New Quiz'),
                  ),
                ],
              ),
            ),
          );
        }
      },
    ),
  ],

  // Error page to show when a route doesn't exist
  errorBuilder:
      (context, state) => Scaffold(
        body: Center(child: Text('Route not found: ${state.uri.path}')),
      ),
);
