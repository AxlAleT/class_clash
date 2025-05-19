import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuizPlayScreen extends StatefulWidget {
  final String quizId;
  
  const QuizPlayScreen({super.key, required this.quizId});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _answered = false;
  int? _selectedAnswer;
  final List<String> _participants = ['You', 'Alex', 'Jamie', 'Taylor', 'Morgan'];
  final Map<String, int> _leaderboard = {
    'You': 0,
    'Alex': 0,
    'Jamie': 0,
    'Taylor': 0,
    'Morgan': 0,
  };
  
  // Dummy data for questions
  late final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the capital of France?',
      'options': ['Berlin', 'Madrid', 'Paris', 'Rome'],
      'correctAnswer': 2,
    },
    {
      'question': 'What is 2 + 2?',
      'options': ['3', '4', '5', '22'],
      'correctAnswer': 1,
    },
    {
      'question': 'Which planet is closest to the sun?',
      'options': ['Venus', 'Earth', 'Mars', 'Mercury'],
      'correctAnswer': 3,
    },
    {
      'question': 'Who wrote "Romeo and Juliet"?',
      'options': ['Charles Dickens', 'William Shakespeare', 'Jane Austen', 'Mark Twain'],
      'correctAnswer': 1,
    },
  ];

  void _checkAnswer(int index) {
    if (_answered) return;
    
    setState(() {
      _answered = true;
      _selectedAnswer = index;
      
      final correctAnswer = _questions[_currentQuestionIndex]['correctAnswer'] as int;
      if (index == correctAnswer) {
        _score += 100;
        _leaderboard['You'] = _score;
        
        // Simulate other participants answering
        _simulateOtherParticipants();
      }
    });

    // Wait before moving to next question
    Future.delayed(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _answered = false;
          _selectedAnswer = null;
        });
      } else {
        _showResultDialog();
      }
    });
  }
  
  void _simulateOtherParticipants() {
    // Randomly update other participants' scores
    for (final participant in _participants) {
      if (participant != 'You') {
        _leaderboard[participant] = _leaderboard[participant]! + 
            (25 * (1 + _currentQuestionIndex) * (DateTime.now().millisecond % 4));
      }
    }
  }
  
  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your score: $_score points'),
            const SizedBox(height: 16),
            const Text('Leaderboard:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...List.generate(
              _leaderboard.entries.length,
              (index) {
                final entries = _leaderboard.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                final entry = entries[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Text('${index + 1}.', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text(entry.key),
                      const Spacer(),
                      Text('${entry.value} pts'),
                    ],
                  ),
                );
              },
            ),
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

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final options = currentQuestion['options'] as List<String>;
    final correctAnswer = currentQuestion['correctAnswer'] as int;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz ${widget.quizId}'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Score: $_score',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
          ),
          
          // Question counter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const Icon(Icons.timer, size: 20),
              ],
            ),
          ),
          
          // Question text
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              currentQuestion['question'] as String,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Answer options
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: options.length,
              itemBuilder: (context, index) {
                Color? backgroundColor;
                if (_answered) {
                  if (index == correctAnswer) {
                    backgroundColor = Colors.green[100];
                  } else if (index == _selectedAnswer) {
                    backgroundColor = Colors.red[100];
                  }
                }
                
                return Card(
                  color: backgroundColor,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _checkAnswer(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index), // A, B, C, D...
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              options[index],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          if (_answered && index == correctAnswer)
                            const Icon(Icons.check_circle, color: Colors.green),
                          if (_answered && index == _selectedAnswer && index != correctAnswer)
                            const Icon(Icons.cancel, color: Colors.red),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Leaderboard section
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
                    itemCount: _participants.length,
                    itemBuilder: (context, index) {
                      final participant = _participants[index];
                      final score = _leaderboard[participant] ?? 0;
                      
                      return Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: participant == 'You' 
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: participant == 'You'
                              ? Border.all(color: Theme.of(context).colorScheme.primary)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              participant,
                              style: TextStyle(
                                fontWeight: participant == 'You' ? FontWeight.bold : FontWeight.normal,
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
        ],
      ),
    );
  }
}
