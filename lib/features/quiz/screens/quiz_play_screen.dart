import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/quiz_play_controller.dart';
import '../../../providers/quiz_controller_provider.dart';
import '../utils/quiz_notifications.dart';
import '../utils/answer_notification.dart'; // Add import for AnswerNotification
import '../../../core/models/user.dart';

class QuizPlayScreen extends ConsumerStatefulWidget {
  final String quizId;
  final User? user;

  const QuizPlayScreen({
    super.key,
    required this.quizId,
    this.user,
  });

  @override
  ConsumerState<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends ConsumerState<QuizPlayScreen> {
  dynamic _selectedAnswer;

  @override
  void initState() {
    super.initState();
    // Start the quiz when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Pass the user to the controller if available
      final controller = ref.read(quizControllerProvider(widget.quizId).notifier);
      controller.startQuiz(user: widget.user);

      // Show welcome message if we have a user
      if (widget.user != null) {
        QuizNotifications.showToast(
          context,
          'Welcome, ${widget.user!.displayName}!',
          duration: const Duration(seconds: 2),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the quiz state through the controller
    final quizState = ref.watch(quizControllerProvider(widget.quizId));
    final controller = ref.read(quizControllerProvider(widget.quizId).notifier);
    final currentQuestion = controller.currentQuestion;

    // Handle different quiz states
    if (quizState.status == QuizStatus.loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading Quiz...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (quizState.status == QuizStatus.error) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(quizState.errorMessage ?? 'An unknown error occurred'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Return Home'),
              ),
            ],
          ),
        ),
      );
    }

    if (quizState.status == QuizStatus.completed) {
      return _buildCompletionScreen(controller);
    }

    // Check if we have a valid current question
    if (currentQuestion == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Issue')),
        body: const Center(child: Text('No question available')),
      );
    }

    // Calculate progress
    final progressValue = controller.progressPercentage;

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz ${controller.quiz?.title ?? ""}'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Score: ${quizState.totalPoints}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: progressValue,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),

          // Question counter and timer
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${quizState.currentQuestionIndex + 1}/${controller.quiz?.questions.length ?? 0}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (currentQuestion.timeLimit > 0)
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 20),
                      const SizedBox(width: 4),
                      Text('${quizState.remainingTime}s'),
                    ],
                  ),
              ],
            ),
          ),

          // Dynamic question widget
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Question title
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      currentQuestion.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Question description if available
                  if (currentQuestion.description != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        currentQuestion.description!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Dynamic question widget - we wrap it in a builder to preserve state
                  Builder(
                    builder: (context) {
                      // This wrapping is important for animations and state preservation
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: quizState.isAnswerSubmitted
                            ? KeyedSubtree(
                                key: ValueKey('feedback_${quizState.currentQuestionIndex}'),
                                child: Column(
                                  children: [
                                    currentQuestion.buildFeedbackWidget(
                                      _selectedAnswer,
                                      currentQuestion.validateAnswer(
                                        _selectedAnswer,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(200, 48),
                                      ),
                                      onPressed: () => _proceedToNextQuestion(controller),
                                      child: Text(
                                        controller.isLastQuestion
                                            ? 'Finish Quiz'
                                            : 'Next Question',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : KeyedSubtree(
                                key: ValueKey('question_${quizState.currentQuestionIndex}'),
                                child: _wrapWithAnswerHandler(
                                  currentQuestion.buildQuestionWidget(),
                                  controller,
                                ),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Dynamic gamification UI elements
          ..._buildGamificationWidgets(controller),
        ],
      ),
    );
  }

  // Handle answer submission and feedback display
  Widget _wrapWithAnswerHandler(
    Widget questionWidget,
    QuizController controller,
  ) {
    // This method will intercept the answer before passing it to the controller
    // It allows us to show feedback before moving to the next question
    return NotificationListener<AnswerNotification>(
      onNotification: (notification) {
        _selectedAnswer = notification.answer;

        // Process the answer in the controller
        controller.submitAnswer(notification.answer);
        return true;
      },
      child: questionWidget,
    );
  }

  // Method to proceed to the next question or end the quiz
  void _proceedToNextQuestion(QuizController controller) {
    if (controller.isLastQuestion) {
      controller.endQuiz();
    } else {
      controller.goToNextQuestion();
      setState(() {
        _selectedAnswer = null;
      });
    }
  }

  // Build completion screen
  Widget _buildCompletionScreen(QuizController controller) {
    final results = controller.getResults();

    return Scaffold(
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
              'Your score: ${results['totalPoints'] ?? 0} points',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 48),
              ),
              onPressed: () async {
                // Submit quiz results to the server
                await controller.submitQuizResultsToServer();

                // Clean up the quiz safely
                _disposeQuizController(controller);

                if (mounted) {
                  context.go('/');
                }
              },
              child: const Text('Return Home'),
            ),
          ],
        ),
      ),
    );
  }

  // Safely clean up quiz resources without disposing the container
  void _disposeQuizController(QuizController controller) {
    // Release resources but don't dispose the container
    controller.disposeQuiz();
  }

  // Build gamification widgets from the controller
  List<Widget> _buildGamificationWidgets(
    QuizController controller,
  ) {
    final quiz = controller.quiz;
    if (quiz == null) return [];

    // Check if we have a leaderboard strategy
    final hasLeaderboard = quiz.gamificationStrategies.any(
      (s) => s.strategyType == 'leaderboard',
    );

    if (hasLeaderboard) {
      // Display a dummy leaderboard for this example
      return [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Leaderboard',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final participants = [
                      'You',
                      'Alex',
                      'Jamie',
                      'Taylor',
                      'Morgan',
                    ];
                    final scores = {
                      'You': controller.state.totalPoints,
                      'Alex': 120,
                      'Jamie': 90,
                      'Taylor': 150,
                      'Morgan': 85,
                    };

                    final participant = participants[index];
                    final score = scores[participant] ?? 0;

                    return Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: participant == 'You'
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.2)
                            : Theme.of(context).colorScheme.surface,
                        border: participant == 'You'
                            ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            participant,
                            style: TextStyle(
                              fontWeight: participant == 'You'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$score pts',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return [];
  }
}
