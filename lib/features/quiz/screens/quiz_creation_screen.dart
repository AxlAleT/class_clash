import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/quiz_providers.dart';

class QuizCreationScreen extends ConsumerStatefulWidget {
  const QuizCreationScreen({super.key});

  @override
  ConsumerState<QuizCreationScreen> createState() => _QuizCreationScreenState();
}

class _QuizCreationScreenState extends ConsumerState<QuizCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<Map<String, dynamic>> _questions = [];
  final List<String> _selectedGamificationStrategies = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get available question types and gamification strategies from providers
    final availableQuestionTypes = ref.watch(availableQuestionTypesProvider);
    final availableStrategies = ref.watch(
      availableGamificationStrategiesProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Create Quiz')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quiz basic information
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Quiz Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quiz title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // Questions section
              const Text(
                'Questions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Question list
              ..._buildQuestionsList(),

              // Add question button
              ElevatedButton.icon(
                onPressed: () => _showAddQuestionDialog(availableQuestionTypes),
                icon: const Icon(Icons.add),
                label: const Text('Add Question'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),

              const SizedBox(height: 24),

              // Gamification section
              const Text(
                'Gamification Features',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Gamification options
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    availableStrategies.map((strategy) {
                      final isSelected = _selectedGamificationStrategies
                          .contains(strategy);

                      return FilterChip(
                        label: Text(_formatStrategyName(strategy)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedGamificationStrategies.add(strategy);
                            } else {
                              _selectedGamificationStrategies.remove(strategy);
                            }
                          });
                        },
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceVariant,
                        selectedColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).colorScheme.primary,
                      );
                    }).toList(),
              ),

              const SizedBox(height: 32),

              // Save quiz button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveQuiz,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Quiz'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the list of questions with edit/delete options
  List<Widget> _buildQuestionsList() {
    if (_questions.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Center(child: Text('No questions added yet.')),
        ),
      ];
    }

    return _questions.asMap().entries.map((entry) {
      final index = entry.key;
      final question = entry.value;

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          title: Text(question['data']['title'] ?? 'Question ${index + 1}'),
          subtitle: Text('Type: ${_formatQuestionType(question['type'])}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editQuestion(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _removeQuestion(index),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  // Dialog to add a new question
  void _showAddQuestionDialog(List<String> questionTypes) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Question Type'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    questionTypes.map((type) {
                      return ListTile(
                        title: Text(_formatQuestionType(type)),
                        onTap: () {
                          Navigator.pop(context);
                          _configureQuestion(type);
                        },
                      );
                    }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  // Configure a specific question based on its type
  void _configureQuestion(String type) {
    // This would open a specific configuration screen based on question type
    // For simplicity, I'm using a dummy question creator
    final questionData = _createDummyQuestionData(type);

    setState(() {
      _questions.add({'type': type, 'data': questionData});
    });
  }

  // Edit an existing question
  void _editQuestion(int index) {
    // This would open the question editor screen
    // For simplicity, we're just showing a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Question editing would open here')),
    );
  }

  // Remove a question
  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  // Create dummy question data for the demo
  Map<String, dynamic> _createDummyQuestionData(String type) {
    // In a real app, this would be replaced with proper question editors
    switch (type) {
      case 'multiple_choice':
        return {
          'id': 'q${_questions.length + 1}',
          'title': 'New Multiple Choice Question',
          'options': ['Option 1', 'Option 2', 'Option 3', 'Option 4'],
          'correctAnswer': 0,
          'points': 10,
        };
      case 'true_false':
        return {
          'id': 'q${_questions.length + 1}',
          'title': 'New True/False Question',
          'correctAnswer': true,
          'points': 5,
        };
      case 'short_answer':
        return {
          'id': 'q${_questions.length + 1}',
          'title': 'New Short Answer Question',
          'correctAnswer': 'answer',
          'points': 15,
        };
      default:
        return {
          'id': 'q${_questions.length + 1}',
          'title': 'New Question',
          'points': 10,
        };
    }
  }

  // Format question type for display
  String _formatQuestionType(String type) {
    return type
        .split('_')
        .map((word) {
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  // Format strategy name for display
  String _formatStrategyName(String strategy) {
    return strategy
        .split('_')
        .map((word) {
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  // Save the quiz
  void _saveQuiz() {
    if (_formKey.currentState!.validate()) {
      if (_questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one question')),
        );
        return;
      }

      // Create quiz data for saving
      final quizData = {
        'id': 'quiz_${DateTime.now().millisecondsSinceEpoch}',
        'title': _titleController.text,
        'description': _descriptionController.text,
        'questions': _questions,
        'gamification':
            _selectedGamificationStrategies.map((strategy) {
              return {
                'type': strategy,
                'data': {'enabled': true},
              };
            }).toList(),
      };

      // In a real app, this would save to a repository
      debugPrint('Saving quiz: $quizData');

      // Show success message and navigate back
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Quiz saved successfully!')));

      context.go('/');
    }
  }
}
