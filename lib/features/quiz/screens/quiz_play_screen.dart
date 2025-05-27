import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/quiz_play_controller.dart';
import '../../../providers/quiz_controller_provider.dart';
import '../utils/quiz_notifications.dart';
import '../factories/question_factory.dart';
import '../widgets/quiz_completion_widget.dart'; // Import QuizCompletionWidget

class QuizPlayScreen extends ConsumerStatefulWidget {
  final String quizId;

  const QuizPlayScreen({super.key, required this.quizId});

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
      ref.read(quizControllerProvider(widget.quizId).notifier).startQuiz();
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
      return QuizCompletionWidget(
        results: controller.getResults(), // Or quizState.results if available and appropriate
        controller: controller,
        onReturnHome: () {
          // The navigation logic previously in _buildCompletionScreen's ElevatedButton
          // _disposeQuizController(controller); // This logic is now handled inside QuizCompletionWidget's button
          if (mounted) { // Check if the widget is still in the tree
            context.go('/');
          }
        },
      );
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
                                  QuestionFactory().createQuestionWidget(currentQuestion),
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

  // Build gamification widgets from the controller
  List<Widget> _buildGamificationWidgets(
    QuizController controller,
  ) {
    final quiz = controller.quiz;
    if (quiz == null) return [];

    List<Widget> gamificationWidgets = [];

    for (var strategy in quiz.gamificationStrategies) {
      // Use the buildWidget method from the strategy
      // Pass the current BuildContext
      // The LeaderboardStrategy.buildWidget will internally handle fetching the current user's score
      // For now, LeaderboardStrategy's buildWidget uses dummy participant data and a placeholder for current user score
      // This part needs to be updated if LeaderboardWidget requires live score from QuizPlayScreen's state.
      // However, the current LeaderboardStrategy.buildWidget is designed to use dummy data
      // and LeaderboardStrategy.buildStrategyWidget is what uses quizState for score.
      // To use the new buildWidget method:
      if (strategy.strategyType == 'leaderboard') {
         // The new buildWidget method in LeaderboardStrategy now directly returns LeaderboardWidget
         // with dummy data. If live score needs to be passed, LeaderboardStrategy.buildWidget
         // or LeaderboardWidget itself needs modification/access to live state.
         // For this refactor, we assume LeaderboardStrategy.buildWidget handles its data needs.
         gamificationWidgets.add(strategy.buildWidget(context));
      }
      // Add other strategies' widgets if needed. For example:
      // if (strategy.strategyType == 'PointsStrategy') {
      //   gamificationWidgets.add(strategy.buildStrategyWidget({'points': controller.state.totalPoints}));
      // }
    }
    return gamificationWidgets;
  }
}
