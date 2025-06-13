import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:class_clash/features/quiz_creation/providers/quiz_data_provider.dart';
import 'package:class_clash/features/quiz_creation/screens/quiz_questions_screen.dart';
import 'package:class_clash/providers/quiz_providers.dart';
import 'package:class_clash/features/quiz_creation/models/quiz/standard_quiz.dart';

class QuizDataScreen extends ConsumerStatefulWidget {
  final String? quizId;

  const QuizDataScreen({super.key, this.quizId});

  @override
  ConsumerState<QuizDataScreen> createState() => _QuizDataScreenState();
}

class _QuizDataScreenState extends ConsumerState<QuizDataScreen> {
  late TextEditingController titleController;
  late TextEditingController descController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        // Sync controllers when provider state changes
        ref.listen<QuizDataState>(quizDataProvider(widget.quizId), (prev, next) {
          if (prev == null || prev.title != next.title) {
            titleController.text = next.title;
          }
          if (prev == null || prev.description != next.description) {
            descController.text = next.description;
          }
        });
        final quizData = ref.watch(quizDataProvider(widget.quizId));
        final quizDataNotifier = ref.read(quizDataProvider(widget.quizId).notifier);

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.quizId != null ? 'Edit Quiz' : 'Create New Quiz'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quiz Title
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Quiz Title',
                    hintText: 'Enter a title for your quiz',
                    border: OutlineInputBorder(),
                  ),
                  controller: titleController,
                  onChanged: quizDataNotifier.setTitle,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Quiz Description
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Enter a description for your quiz',
                    border: OutlineInputBorder(),
                  ),
                  controller: descController,
                  maxLines: 3,
                  onChanged: quizDataNotifier.setDescription,
                ),
                const SizedBox(height: 16),

                // Quiz Category
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Select a category'),
                  value: quizData.category.isNotEmpty ? quizData.category : null,
                  items: const [
                    DropdownMenuItem(value: 'math', child: Text('Mathematics')),
                    DropdownMenuItem(value: 'science', child: Text('Science')),
                    DropdownMenuItem(value: 'history', child: Text('History')),
                    DropdownMenuItem(value: 'language', child: Text('Language')),
                    DropdownMenuItem(value: 'computer_science', child: Text('Computer Science')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      quizDataNotifier.setCategory(value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Time Limit
                Row(
                  children: [
                    const Text('Time Limit (minutes):'),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Slider(
                        min: 0,
                        max: 60,
                        divisions: 12,
                        label: quizData.timeLimit == 0
                            ? 'No Limit'
                            : '${quizData.timeLimit} min',
                        value: quizData.timeLimit.toDouble(),
                        onChanged: (value) {
                          quizDataNotifier.setTimeLimit(value.round());
                        },
                      ),
                    ),
                    Text(
                      quizData.timeLimit == 0
                          ? 'No Limit'
                          : '${quizData.timeLimit} min',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Public Quiz Toggle
                SwitchListTile(
                  title: const Text('Public Quiz'),
                  subtitle: const Text('Make this quiz visible to other users'),
                  value: quizData.isPublic,
                  onChanged: quizDataNotifier.setIsPublic,
                ),
                const SizedBox(height: 32),

                // Next Button
                ElevatedButton(
                  onPressed: quizData.isFormValid
                      ? () async {
                          StandardQuizModel initialQuizData;
                          if (widget.quizId != null) {
                            // Load full quiz JSON including questions
                            final quizMap = await ref.read(quizProviderInstance).getQuizData(widget.quizId!);
                            initialQuizData = StandardQuizModel.fromJson(quizMap!);
                          } else {
                            initialQuizData = quizData.createInitialQuizData('teacher_1');
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => QuizQuestionsScreen(
                                initialQuizData: initialQuizData,
                              ),
                            ),
                          );
                        }
                      : null,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'Next: Add Questions',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
