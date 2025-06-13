import 'package:flutter/material.dart';

import '../../utils/answer_notification.dart';
import 'abstract/choice_question.dart';

class TrueFalseQuestion extends ChoiceQuestion {
  @override
  String get questionType => 'true_false';

  @override
  Map<String, dynamic> get metadata => {
        'options': options,
        'correctOptionIndices': correctOptionIndices,
        'randomizeOptions': false, // Options should not be randomized for True/False
      };

  TrueFalseQuestion({
    required super.id,
    required super.title,
    super.description,
    required bool correctAnswer, // True if the correct answer is "True", False otherwise
    super.points,
    super.timeLimit,
    super.imageUrl,
    super.audioUrl,
    super.videoUrl,
    super.partialCreditThreshold,
  }) : super(
          options: ["True", "False"],
          correctOptionIndices: [correctAnswer ? 0 : 1],
          randomizeOptions: false,
        );

  factory TrueFalseQuestion.fromJson(Map<String, dynamic> json) {
    // Ensure that correctOptionIndices is present and not empty
    if (json['metadata'] == null ||
        json['metadata']['correctOptionIndices'] == null ||
        (json['metadata']['correctOptionIndices'] as List).isEmpty) {
      throw ArgumentError(
          'correctOptionIndices must be provided and non-empty for TrueFalseQuestion');
    }
    return TrueFalseQuestion(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      // Assuming correctOptionIndices will contain one value: 0 for True, 1 for False
      correctAnswer: List<int>.from(json['metadata']['correctOptionIndices'])[0] == 0,
      points: json['points'] ?? 100,
      timeLimit: json['timeLimit'] ?? 30,
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
      videoUrl: json['videoUrl'],
      partialCreditThreshold:
          (json['partialCreditThreshold'] ?? 0.0).toDouble(),
    );
  }

  @override
  bool validateAnswer(dynamic answer) {
    if (answer is! List<int> || answer.length != 1) return false;
    // Check if the selected index (0 for True, 1 for False) matches the correct one
    return correctOptionIndices.contains(answer[0]);
  }

  @override
  double calculatePartialCredit(dynamic answer) {
    // True/False questions typically don't have partial credit
    return validateAnswer(answer) ? 1.0 : 0.0;
  }

  @override
  Widget buildQuestionWidget() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (description != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(description!, style: const TextStyle(fontSize: 16)),
              ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300), // Adjust as needed
              child: Column( // Using Column directly as options are fixed
                children: List.generate(
                  options.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: RadioListTile<int>(
                      title: Text(options[index]),
                      value: index,
                      groupValue: selectedIndices.isNotEmpty ? selectedIndices[0] : null,
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        setState(() {
                          selectedIndices.clear();
                          if (value != null) {
                            selectedIndices.add(value);
                          }
                        });
                      },
                      secondary: CircleAvatar(
                        backgroundColor: selectedIndices.contains(index)
                            ? Colors.blue
                            : Colors.grey.shade200,
                        child: selectedIndices.contains(index)
                            ? const Icon(Icons.check, color: Colors.white)
                            : Text(options[index][0]), // T or F
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 48),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: selectedIndices.isEmpty
                    ? null
                    : () {
                        AnswerNotification(selectedIndices).dispatch(context);
                      },
                child: const Text(
                  'Submit Answer',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
