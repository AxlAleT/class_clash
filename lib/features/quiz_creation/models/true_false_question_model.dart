import 'question_model.dart';

class TrueFalseQuestionModel extends Question {
  bool correctAnswer;
  // id is inherited from Question and is final String.

  TrueFalseQuestionModel({
    required String id, // Add id to constructor, make it required
    required String questionText,
    required this.correctAnswer,
  }) : super(id: id, questionText: questionText); // Pass id to super

  @override
  String get type => 'True/False';

  @override
  void display() {
    print('Question (True/False): $questionText');
    print('Answer: ${correctAnswer ? "True" : "False"}');
  }

  @override
  bool isCorrect(dynamic answer) {
    if (answer is bool) {
      return answer == correctAnswer;
    }
    return false;
  }

  @override
  TrueFalseQuestionModel clone() {
    return TrueFalseQuestionModel(
      id: id, // Include id in cloning
      questionText: questionText,
      correctAnswer: correctAnswer,
    );
  }
}
