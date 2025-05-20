import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/quiz_providers.dart';
import '../controllers/quiz_controller.dart';
import '../../../core/models/quiz.dart';

// Provider for the quiz controller
final quizControllerProvider =
    StateNotifierProvider.family<QuizController, Quiz?, String>(
      (ref, quizId) => QuizController(ref)..loadQuiz(quizId),
    );

class QuizPlayScreen extends ConsumerStatefulWidget {
  final String quizId;

  const QuizPlayScreen({super.key, required this.quizId});

  @override
  ConsumerState<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends ConsumerState<QuizPlayScreen> {
  bool _answered = false;
  dynamic _selectedAnswer;

  @override
  void initState() {
    super.initState();
    // Quiz is loaded automatically by the provider
  }

  @override
  Widget build(BuildContext context) {
    // Watch the quiz state through the controller
    final quiz = ref.watch(quizControllerProvider(widget.quizId));
    final controller = ref.read(quizControllerProvider(widget.quizId).notifier);

    // Check if quiz is still loading
    if (quiz == null || quiz.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading Quiz...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Get current question information
    final currentQuestionIndex = quiz.currentQuestionIndex;
    final totalQuestions = quiz.questions.length;
    final currentQuestion = quiz.currentQuestion;
    if (currentQuestion == null) {
      // Handle the case where there's no current question
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Complete')),
        body: const Center(child: Text('No more questions available')),
      );
    }
    final progressValue = (currentQuestionIndex + 1) / totalQuestions;

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz ${quiz.title}'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Score: ${quiz.totalPoints}',
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

          // Question counter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${currentQuestionIndex + 1}/$totalQuestions',
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
                      Text('${currentQuestion.timeLimit}s'),
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
                        child: _answered
                            ? Column(
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
                                    onPressed: () =>
                                        _proceedToNextQuestion(controller),
                                    child: Text(
                                      controller.isQuizCompleted
                                          ? 'Finish Quiz'
                                          : 'Next Question',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              )
                            : _wrapWithAnswerHandler(
                                currentQuestion.buildQuestionWidget(),
                                controller,
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Dynamic gamification UI elements
          ..._buildGamificationWidgets(controller, quiz),
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
        setState(() {
          _answered = true;
          _selectedAnswer = notification.answer;
        });

        // Process the answer in the controller
        controller.submitAnswer(notification.answer);
        return true;
      },
      child: questionWidget,
    );
  }

  // Method to proceed to the next question or end the quiz
  void _proceedToNextQuestion(QuizController controller) {
    if (controller.isQuizCompleted) {
      _showQuizCompletionDialog(controller.getQuizResults());
    } else {
      controller.proceedToNextQuestion();
      setState(() {
        _answered = false;
        _selectedAnswer = null;
      });
    }
  }

  // Build gamification widgets from the controller
  List<Widget> _buildGamificationWidgets(
    QuizController controller,
    Quiz quiz,
  ) {
    // This is a simplified version - in a real app, you'd get these from the controller
    // which would use the gamification factories

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
            color: Theme.of(context).colorScheme.surfaceVariant,
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
                      'You': quiz.totalPoints,
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

  // Show quiz completion dialog
  void _showQuizCompletionDialog(Map<String, dynamic> results) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your score: ${results['totalPoints']} points'),
            const SizedBox(height: 16),
            const Text('Congratulations on completing the quiz!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.go('/');
            },
            child: const Text('Return Home'),
          ),
        ],
      ),
    );
  }
}

// Custom notification for handling answers
class AnswerNotification extends Notification {
  final dynamic answer;

  AnswerNotification(this.answer);
}
