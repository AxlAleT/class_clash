import 'package:go_router/go_router.dart';
import 'package:class_clash/features/splash/screens/splash_screen.dart';
import 'package:class_clash/features/auth/screens/login_screen.dart';
import 'package:class_clash/features/quiz/models/users/standard_user.dart';

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

    // Auth routes
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Quiz list route
    GoRoute(
      path: '/quizzes',
      builder: (context, state) => const QuizListScreen(),
    ),

    // Quiz play route with quiz ID parameter and user data
    GoRoute(
      path: '/quiz/play/:quizId',
      builder: (context, state) {
        final quizId = state.pathParameters['quizId'] ?? '';
        // Get the user from the extra parameter as StandardUser
        final user = state.extra as StandardUser?;
        return QuizPlayScreen(quizId: quizId, user: user);
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
        final quizId = state.pathParameters['quizId']!;
        return QuizDataScreen(quizId: quizId);
      },
    ),
  ],
);
