import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:class_clash/features/quiz_creation/providers/quiz_questions_provider.dart';
import 'package:class_clash/features/quiz_creation/models/quiz/standard_quiz.dart';
import 'package:class_clash/features/quiz_creation/widgets/question_form.dart';
import 'package:class_clash/features/quiz_creation/controllers/quiz_questions_screen_controller.dart';

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
  // State for sidebar visibility (UI-only state)
  bool _isSidebarVisible = true;

  // Controller instance
  late QuizQuestionsScreenController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuizQuestionsScreenController(
      ref: ref,
      initialQuizData: widget.initialQuizData,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the provider state through the controller
    final quizQuestionsState = _controller.state;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Questions: ${quizQuestionsState.quizModel.title}'),
        actions: [
          // Toggle sidebar button
          IconButton(
            icon: Icon(_isSidebarVisible ? Icons.menu_open : Icons.menu),
            tooltip: _isSidebarVisible ? 'Hide Questions Panel' : 'Show Questions Panel',
            onPressed: () {
              _controller.toggleSidebar(_isSidebarVisible, (isVisible) {
                setState(() {
                  _isSidebarVisible = isVisible;
                });
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Quiz',
            onPressed: quizQuestionsState.hasQuestions ? () {
              _controller.saveQuiz(context);
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
                  items: _controller.notifier.supportedQuestionTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_controller.formatQuestionType(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _controller.notifier.setActiveQuestionType(value);
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
                      _controller.handleQuestionSaved(question);
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
                            'Questions (${quizQuestionsState.questions.length}/${QuizQuestionsNotifier.maxQuestions})',
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
                              onReorder: _controller.notifier.reorderQuestions,
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
                                            _controller.notifier.selectQuestion(index);
                                            setState(() { _isSidebarVisible = false; });
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            _controller.notifier.removeQuestion(index);
                                          },
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      _controller.notifier.selectQuestion(index);
                                      // Hide sidebar on mobile after selecting a question
                                      if (MediaQuery.of(context).size.width < 600) {
                                        setState(() {
                                          _isSidebarVisible = false;
                                        });
                                      }
                                    },
                                  )
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
        onPressed: _controller.notifier.isMaxQuestionsReached && _isSidebarVisible
            ? null // Disable the button if max questions reached and sidebar is visible
            : () {
                if (!_isSidebarVisible) {
                  // If sidebar is hidden, show it
                  setState(() {
                    _isSidebarVisible = true;
                  });
                } else {
                  // If sidebar is visible, save current question and reset for a new one
                  _controller.notifier.selectQuestion(-1);
                  _isSidebarVisible = false;
                  setState(() {}); // Ensure UI updates after state change
                }
              },
        tooltip: !_isSidebarVisible
            ? 'Show Questions'
            : (_controller.notifier.isMaxQuestionsReached
                ? 'Maximum Questions Reached (${QuizQuestionsNotifier.maxQuestions})'
                : 'Add New Question'),
        backgroundColor: _controller.notifier.isMaxQuestionsReached && _isSidebarVisible
            ? Theme.of(context).disabledColor
            : null,
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
}
