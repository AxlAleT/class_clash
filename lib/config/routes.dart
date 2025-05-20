import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/screens/home_screen.dart';
import '../features/quiz/screens/quiz_list_screen.dart';
import '../features/quiz/screens/quiz_play_screen.dart';

// Define the route configuration
final GoRouter router = GoRouter(
  routes: [
    // Home route shows the quiz list
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
        // Extract the quiz ID from the route parameters
        final quizId = state.pathParameters['quizId'] ?? '';
        return QuizPlayScreen(quizId: quizId);
      },
    ),

    // Create quiz route
    GoRoute(
      path: '/create',
      redirect: (context, state) {
        // Implement later
        return '/';
      },
    ),
  ],

  // Error page to show when route doesn't exist
  errorBuilder:
      (context, state) => Scaffold(
        body: Center(child: Text('Route not found: ${state.uri.path}')),
      ),
);
