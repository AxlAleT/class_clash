import '../models/quiz_creation_state.dart';
import '../models/question_model.dart'; // This will be created in a later step

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

  // Method to save the quiz (implementation would depend on backend/storage)
  void saveQuiz() {
    // Logic to save _quizState
    // For example, convert to JSON and send to an API or save locally
    print('Quiz saved: ${_quizState.title}');
    print('Description: ${_quizState.description}');
    print('Questions: ${_quizState.questions.length}');
    // Reset state after saving, or navigate away
    _quizState = QuizCreationState();
    // In a real app, notify listeners here
  }
}
