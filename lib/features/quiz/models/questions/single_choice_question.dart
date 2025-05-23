import 'package:flutter/material.dart';

import '../../utils/quiz_notifications.dart';
import 'abstract/choice_question.dart';

class SingleChoiceQuestion extends ChoiceQuestion {
  @override
  String get questionType => 'single_choice';

  @override
  Map<String, dynamic> get metadata => {
    'options': options,
    'correctOptionIndices': correctOptionIndices,
    'randomizeOptions': randomizeOptions,
  };

  SingleChoiceQuestion({
    required super.id,
    required super.title,
    super.description,
    required super.options,
    required int correctOptionIndex,
    super.points,
    super.timeLimit,
    super.imageUrl,
    super.audioUrl,
    super.videoUrl,
    super.randomizeOptions,
    super.partialCreditThreshold,
  }) : super(
          correctOptionIndices: [correctOptionIndex],
        );

  factory SingleChoiceQuestion.fromJson(Map<String, dynamic> json) {
    return SingleChoiceQuestion(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      options: List<String>.from(json['metadata']['options']),
      correctOptionIndex: List<int>.from(
        json['metadata']['correctOptionIndices'],
      )[0], // Take first index as the correct one
      points: json['points'] ?? 100,
      timeLimit: json['timeLimit'] ?? 30,
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
      videoUrl: json['videoUrl'],
      randomizeOptions: json['metadata']['randomizeOptions'] ?? true,
      partialCreditThreshold:
          (json['partialCreditThreshold'] ?? 0.0).toDouble(),
    );
  }

  @override
  bool validateAnswer(dynamic answer) {
    if (answer is! List<int> || answer.length != 1) return false;
    return correctOptionIndices.contains(answer[0]);
  }

  @override
  double calculatePartialCredit(dynamic answer) {
    return validateAnswer(answer) ? 1.0 : 0.0;
  }

  @override
  Widget buildQuestionWidget() {
    // Use a StatefulBuilder to manage local UI state
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

            // Scrollable container for options
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Column(
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
                              : Text(String.fromCharCode(65 + index)), // A, B, C, etc.
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Confirmation button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 48),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed:
                    selectedIndices.isEmpty
                        ? null // Disable if nothing selected
                        : () {
                          // Only dispatch notification when user confirms
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
