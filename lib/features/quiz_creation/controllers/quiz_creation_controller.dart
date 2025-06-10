import 'dart:convert'; // For printing the map nicely, if desired

import '../models/quiz_creation_state.dart';
import '../models/question_model.dart';
import '../models/mcq_question_model.dart'; // Import MCQQuestion

// For a Flutter app, this would typically extend ChangeNotifier or be managed by a framework like Riverpod or BLoC.
// For this example, we'll keep it as a plain Dart class.
class QuizCreationController {
  QuizCreationState _quizState;

  QuizCreationController() : _quizState = QuizCreationState();

  QuizCreationState get quizState => _quizState;

  // Method to update quiz title
  void updateQuizTitle(String title) {
    _quizState = _quizState.copyWith(title: title);
    // In a real app, notify listeners here
  }

  // Method to update quiz description
  void updateQuizDescription(String description) {
    _quizState = _quizState.copyWith(description: description);
    // In a real app, notify listeners here
  }

  // Method to add a question
  void addQuestion(Question question) {
    final updatedQuestions = List<Question>.from(_quizState.questions)..add(question);
    _quizState = _quizState.copyWith(questions: updatedQuestions);
    // In a real app, notify listeners here
  }

  // Method to remove a question
  void removeQuestion(Question question) {
    final updatedQuestions = List<Question>.from(_quizState.questions)..remove(question);
    _quizState = _quizState.copyWith(questions: updatedQuestions);
    // In a real app, notify listeners here
  }

  // Method to update a question
  void updateQuestion(int index, Question newQuestion) {
    if (index >= 0 && index < _quizState.questions.length) {
      final updatedQuestions = List<Question>.from(_quizState.questions);
      updatedQuestions[index] = newQuestion;
      _quizState = _quizState.copyWith(questions: updatedQuestions);
      // In a real app, notify listeners here
    }
  }

  // Method to save the quiz
  void saveQuiz() {
    final quizId = DateTime.now().millisecondsSinceEpoch.toString();
    final List<Map<String, dynamic>> questionsData = [];

    for (int i = 0; i < _quizState.questions.length; i++) {
      final question = _quizState.questions[i];
      final questionId = '${quizId}_q$i';
      final Map<String, dynamic> questionData = {
        'id': questionId,
        'title': question.questionText,
        // 'description': '', // Not available on Question model directly
        // 'points': 0, // Not available on Question model
        // 'timeLimit': 30, // Not available on Question model
      };

      if (question is MCQQuestion) {
        questionData['questionType'] = 'single_choice'; // Based on MCQQuestion structure
        questionData['metadata'] = {
          'options': question.options,
          'correctOptionIndices': [question.correctAnswerIndex],
          'allowMultipleSelections': false, // MCQQuestion has a single correctAnswerIndex
          // 'randomizeOptions': true, // Defaulting, not in model
        };
      } else {
        // Handle other question types or provide a default
        questionData['questionType'] = 'unknown';
        questionData['metadata'] = {};
      }
      questionsData.add(questionData);
    }

    final quizMap = {
      'id': quizId,
      'title': _quizState.title,
      'description': _quizState.description,
      'questions': questionsData,
      'type': 'standard',
      // Fields like 'gamificationStrategies', 'currentQuestionIndex', 'totalPoints', 'currentStreak'
      // are not part of creation state and would typically be managed elsewhere or have defaults.
    };

    // Simulate submitting data (e.g., print to console)
    // Using jsonEncode for a slightly cleaner print, but simple print(quizMap) works too.
    print('Simulating Quiz Submission:');
    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String prettyPrinted = encoder.convert(quizMap);
    print(prettyPrinted);

    // Reset state after saving
    _quizState = QuizCreationState();
    // In a real app, notify listeners here
    print('Quiz state has been reset.');
  }
}
