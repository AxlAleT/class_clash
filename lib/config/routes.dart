import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/quiz/screens/quiz_list_screen.dart';
import '../features/quiz/screens/quiz_creation_screen.dart';
import '../features/quiz/screens/quiz_play_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const QuizListScreen(),
    ),
    GoRoute(
      path: '/create',
      builder: (context, state) => const QuizCreationScreen(),
    ),
    GoRoute(
      path: '/play/:quizId',
      builder: (context, state) {
        final quizId = state.pathParameters['quizId']!;
        return QuizPlayScreen(quizId: quizId);
      },
    ),
  ],
);