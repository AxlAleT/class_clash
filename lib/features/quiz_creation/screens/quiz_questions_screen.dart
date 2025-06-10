import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:class_clash/features/quiz_creation/providers/quiz_questions_provider.dart';
import 'package:class_clash/features/quiz_creation/models/quiz/standard_quiz.dart';
import 'package:class_clash/features/quiz_creation/widgets/question_form.dart';

class QuizQuestionsScreen extends ConsumerStatefulWidget {
  final StandardQuizModel initialQuizData;

  const QuizQuestionsScreen({
    super.key,
    required this.initialQuizData,
  });

  @override
  ConsumerState<QuizQuestionsScreen> createState() => _QuizQuestionsScreenState();
}

class _QuizQuestionsScreenState extends ConsumerState<QuizQuestionsScreen> {
  // State for sidebar visibility
  bool _isSidebarVisible = true;

  @override
  Widget build(BuildContext context) {
    // Initialize the provider with the initial quiz data
    final quizQuestionsState = ref.watch(quizQuestionsProvider(widget.initialQuizData));
    final quizQuestionsNotifier = ref.read(quizQuestionsProvider(widget.initialQuizData).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Questions: ${quizQuestionsState.quizModel.title}'),
        actions: [
          // Toggle sidebar button
          IconButton(
            icon: Icon(_isSidebarVisible ? Icons.menu_open : Icons.menu),
            tooltip: _isSidebarVisible ? 'Hide Questions Panel' : 'Show Questions Panel',
            onPressed: () {
              setState(() {
                _isSidebarVisible = !_isSidebarVisible;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Quiz',
            onPressed: quizQuestionsState.hasQuestions ? () {
              _saveQuiz(context, quizQuestionsNotifier);
            } : null,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Right panel: Question form (always full width)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quizQuestionsState.selectedQuestionIndex == -1
                      ? 'Create New Question'
                      : 'Edit Question ${quizQuestionsState.selectedQuestionIndex + 1}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Question Type Selector
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Question Type',
                    border: OutlineInputBorder(),
                  ),
                  value: quizQuestionsState.activeQuestionType,
                  items: quizQuestionsNotifier.supportedQuestionTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_formatQuestionType(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      quizQuestionsNotifier.setActiveQuestionType(value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Question Form
                Expanded(
                  child: QuestionForm(
                    questionType: quizQuestionsState.activeQuestionType,
                    questionToEdit: quizQuestionsState.selectedQuestionIndex != -1
                        ? quizQuestionsState.questions[quizQuestionsState.selectedQuestionIndex]
                        : null,
                    onSave: (question) {
                      if (quizQuestionsState.selectedQuestionIndex != -1) {
                        quizQuestionsNotifier.updateQuestion(
                          quizQuestionsState.selectedQuestionIndex,
                          question,
                        );
                      } else {
                        quizQuestionsNotifier.addQuestion(question);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Left panel: Question list (collapsible sidebar that overlays)
          if (_isSidebarVisible)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 320, // Fixed width for the sidebar
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Questions (${quizQuestionsState.questions.length})',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _isSidebarVisible = false;
                              });
                            },
                            tooltip: 'Hide Questions Panel',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: quizQuestionsState.hasQuestions
                          ? ReorderableListView.builder(
                              itemCount: quizQuestionsState.questions.length,
                              onReorder: quizQuestionsNotifier.reorderQuestions,
                              itemBuilder: (context, index) {
                                final question = quizQuestionsState.questions[index];
                                return Card(
                                  key: ValueKey(index),
                                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  color: quizQuestionsState.selectedQuestionIndex == index
                                      ? Theme.of(context).colorScheme.primaryContainer
                                      : null,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: Text('${index + 1}'),
                                    ),
                                    title: Text(question.title),
                                    subtitle: Text(
                                      'Type: ${question.questionType} · ${question.points} pts',
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {
                                            quizQuestionsNotifier.selectQuestion(index);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            quizQuestionsNotifier.removeQuestion(index);
                                          },
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      quizQuestionsNotifier.selectQuestion(index);
                                      // Hide sidebar on mobile after selecting a question
                                      if (MediaQuery.of(context).size.width < 600) {
                                        setState(() {
                                          _isSidebarVisible = false;
                                        });
                                      }
                                    },
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Text('No questions added yet'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      // FAB to show the sidebar and add a new question
      floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (!_isSidebarVisible) {
                  // If sidebar is hidden, show it
                  setState(() {
                    _isSidebarVisible = true;
                  });
                } else {
                  // If sidebar is visible, save current question and reset for a new one
                  // This is equivalent to pressing "Add" button on the form
                  // The form should handle the actual saving via its onSave callback

                  // First select no question (which puts the form in "create new" mode)
                  quizQuestionsNotifier.selectQuestion(-1);

                  // Optional: scroll to the form field to make it clear we're adding a new question
                  // This could be implemented with a ScrollController if needed
                }
              },
              tooltip: !_isSidebarVisible ? 'Show Questions' : 'Add New Question',
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(!_isSidebarVisible ? Icons.menu : Icons.add),
                  if (quizQuestionsState.hasQuestions && !_isSidebarVisible)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${quizQuestionsState.questions.length}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  String _formatQuestionType(String type) {
    return type.split('_').map((word) =>
      '${word[0].toUpperCase()}${word.substring(1)}'
    ).join(' ');
  }

  void _saveQuiz(BuildContext context, QuizQuestionsNotifier notifier) {
    // Generate the quiz JSON
    final quizJson = notifier.getQuizJson();

    // Here you would typically send this JSON to your backend
    // For demonstration, we'll just show a success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Saved'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quiz "${notifier.state.quizModel.title}" has been created with ${notifier.state.questions.length} questions.'),
            const SizedBox(height: 16),
            const Text('JSON data (for demonstration):'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              height: 200,
              child: SingleChildScrollView(
                child: Text(quizJson.toString()),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Navigate back to home or quiz list
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
