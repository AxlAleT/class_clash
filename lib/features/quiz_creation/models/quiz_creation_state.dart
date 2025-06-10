import 'question_model.dart'; // Corrected import

class QuizCreationState {
  String title;
  String description;
  List<Question> questions; // Abstract Question type
  // Potentially add other fields like timeLimit, difficulty, etc. later

  QuizCreationState({
    this.title = '',
    this.description = '',
    List<Question>? questions,
  }) : this.questions = questions ?? [];

  // Method to add a question
  void addQuestion(Question question) {
    questions.add(question);
  }

  // Method to remove a question
  void removeQuestion(Question question) {
    questions.remove(question);
  }

  // Method to update a question
  void updateQuestion(int index, Question question) {
    if (index >= 0 && index < questions.length) {
      questions[index] = question;
    }
  }

  // CopyWith method for immutability if using a state management solution like Riverpod/Provider
  QuizCreationState copyWith({
    String? title,
    String? description,
    List<Question>? questions,
  }) {
    return QuizCreationState(
      title: title ?? this.title,
      description: description ?? this.description,
      questions: questions ?? this.questions,
    );
  }
}
