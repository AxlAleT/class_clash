// Represents an abstract question in a quiz
abstract class Question {
  final String id; // Unique ID for each question
  String questionText;
  // Common properties for all questions can be added here (e.g., points, difficulty)

  Question({required this.id, required this.questionText});

  // Abstract method to display the question (could be used in a preview or quiz-taking UI)
  void display();

  // Abstract method to check if an answer is correct (implementation varies by question type)
  bool isCorrect(dynamic answer);

  // Abstract method to clone the question (useful for editing)
  Question clone();

  // Abstract getter for the question type
  String get type;
}
