import 'question_model.dart';

class MCQQuestion extends Question {
  List<String> options;
  int correctAnswerIndex; // Index of the correct option in the options list
  // The 'id' field is inherited from the Question class.

  MCQQuestion({
    required String id, // Add id to constructor
    required String questionText,
    required this.options,
    required this.correctAnswerIndex,
  }) : super(id: id, questionText: questionText) { // Pass id to super
    if (options.isEmpty) {
      throw ArgumentError("MCQQuestion must have at least one option.");
    }
    if (correctAnswerIndex < 0 || correctAnswerIndex >= options.length) {
      throw ArgumentError("Correct answer index is out of bounds.");
    }
  }

  @override
  void display() {
    print("MCQ Question: $questionText");
    for (int i = 0; i < options.length; i++) {
      print("${i + 1}. ${options[i]} ${i == correctAnswerIndex ? '(Correct)' : ''}");
    }
  }

  @override
  bool isCorrect(dynamic answer) {
    // Assuming 'answer' is the index of the selected option
    if (answer is int) {
      return answer == correctAnswerIndex;
    }
    return false;
  }

  @override
  MCQQuestion clone() {
    return MCQQuestion(
      id: id, // Include id in cloning
      questionText: questionText,
      options: List.from(options), // Create a new list for options
      correctAnswerIndex: correctAnswerIndex,
    );
  }

  // Helper to update an option - useful for editing
  void updateOption(int index, String newOptionText) {
    if (index >= 0 && index < options.length) {
      options[index] = newOptionText;
    }
  }

  // Helper to add an option
  void addOption(String optionText) {
    options.add(optionText);
  }

  // Helper to remove an option (ensure correctAnswerIndex is still valid)
  bool removeOption(int index) {
    if (options.length > 1 && index >= 0 && index < options.length) { // Ensure at least one option remains
      options.removeAt(index);
      // Adjust correctAnswerIndex if necessary
      if (correctAnswerIndex == index) {
        correctAnswerIndex = 0; // Default to first option if correct one is removed
      } else if (correctAnswerIndex > index) {
        correctAnswerIndex--;
      }
      return true;
    }
    return false;
  }

  @override
  String get type => 'Multiple Choice';
}
