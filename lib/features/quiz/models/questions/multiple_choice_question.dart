import 'package:flutter/material.dart';

import '../../utils/quiz_notifications.dart';
import 'abstract/choice_question.dart';

class MultipleChoiceQuestion extends ChoiceQuestion {
  @override
  String get questionType => 'multiple_choice';

  @override
  Map<String, dynamic> get metadata => {
    'options': options,
    'correctOptionIndices': correctOptionIndices,
    'randomizeOptions': randomizeOptions,
  };

  MultipleChoiceQuestion({
    required super.id,
    required super.title,
    super.description,
    required super.options,
    required super.correctOptionIndices,
    super.points,
    super.timeLimit,
    super.imageUrl,
    super.audioUrl,
    super.videoUrl,
    super.randomizeOptions,
    super.partialCreditThreshold,
  });

  factory MultipleChoiceQuestion.fromJson(Map<String, dynamic> json) {
    return MultipleChoiceQuestion(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      options: List<String>.from(json['metadata']['options']),
      correctOptionIndices: List<int>.from(
        json['metadata']['correctOptionIndices'],
      ),
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
    if (answer is! List<int>) return false;

    // For multiple selection questions, check if all selected answers are correct
    // and all correct answers are selected
    return answer.length == correctOptionIndices.length &&
        answer.every((index) => correctOptionIndices.contains(index));
  }

  @override
  double calculatePartialCredit(dynamic answer) {
    if (answer is! List<int>) return 0.0;

    // For multiple selection questions, calculate partial credit
    int totalCorrectOptions = correctOptionIndices.length;
    if (totalCorrectOptions == 0) return 0.0;

    int correctSelections = 0;

    // Count correctly selected options
    for (int selectedIndex in answer) {
      if (correctOptionIndices.contains(selectedIndex)) {
        correctSelections++;
      } else {
        // Penalty for incorrect selections
        correctSelections--;
      }
    }

    // Ensure we don't give negative credit
    correctSelections = correctSelections < 0 ? 0 : correctSelections;

    // Calculate percentage of correct selections
    double percentage = correctSelections / totalCorrectOptions;

    // If percentage is above threshold, award partial credit
    return percentage >= partialCreditThreshold ? percentage : 0.0;
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

            // Scrollable container for options
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(
                    options.length,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: CheckboxListTile(
                        title: Text(options[index]),
                        value: selectedIndices.contains(index),
                        activeColor: Colors.blue,
                        checkColor: Colors.white,
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              if (!selectedIndices.contains(index)) {
                                selectedIndices.add(index);
                              }
                            } else {
                              selectedIndices.remove(index);
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

            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Center(
                child: Text(
                  'Selected ${selectedIndices.length} of ${options.length} options',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
