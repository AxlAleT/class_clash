import 'package:go_router/go_router.dart';
import 'package:class_clash/features/splash/screens/splash_screen.dart';

import '../features/home/screens/home_screen.dart';
import '../features/quiz/screens/quiz_list_screen.dart';
import '../features/quiz/screens/quiz_play_screen.dart';
import '../features/quiz_creation/screens/quiz_data_screen.dart';

// Define the route configuration
final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),

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

    // Quiz creation route - first step
    GoRoute(
      path: '/create',
      builder: (context, state) => const QuizDataScreen(),
    ),

    // Quiz editing route - when editing an existing quiz
    GoRoute(
      path: '/quiz/edit/:quizId',
      builder: (context, state) {
        final quizId = state.pathParameters['quizId'] ?? '';
        // TODO: Implement loading quiz data for editing
        return const QuizDataScreen();
      },
    ),
  ],
);
