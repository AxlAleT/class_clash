import 'package:flutter/material.dart';
import '../../utils/quiz_notifications.dart';

import '../../../../core/models/question.dart';

class MultipleChoiceQuestion extends Question {
  @override
  final String id;
  
  @override
  final String title;
  
  @override
  final String? description;
  
  @override
  final int points;
  
  @override
  final int timeLimit;
  
  @override
  final String? imageUrl;
  
  @override
  final String? audioUrl;
  
  @override
  final String? videoUrl;
  
  @override
  final double partialCreditThreshold;
  
  // Multiple choice specific properties
  final List<String> options;
  final List<int> correctOptionIndices; // Support for multiple correct answers
  final bool allowMultipleSelections;
  final bool randomizeOptions;
  
  @override
  String get questionType => 'multiple_choice';
  
  @override
  Map<String, dynamic> get metadata => {
    'options': options,
    'correctOptionIndices': correctOptionIndices,
    'allowMultipleSelections': allowMultipleSelections,
    'randomizeOptions': randomizeOptions,
  };

  MultipleChoiceQuestion({
    required this.id,
    required this.title,
    this.description,
    required this.options,
    required this.correctOptionIndices,
    this.points = 100,
    this.timeLimit = 30,
    this.imageUrl,
    this.audioUrl,
    this.videoUrl,
    this.allowMultipleSelections = false,
    this.randomizeOptions = true,
    this.partialCreditThreshold = 0.0,
  }) : assert(correctOptionIndices.every((index) => index >= 0 && index < options.length),
            'Correct option indices must be valid indices within the options list');

  factory MultipleChoiceQuestion.fromJson(Map<String, dynamic> json) {
    return MultipleChoiceQuestion(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      options: List<String>.from(json['metadata']['options']),
      correctOptionIndices: List<int>.from(json['metadata']['correctOptionIndices']),
      points: json['points'] ?? 100,
      timeLimit: json['timeLimit'] ?? 30,
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
      videoUrl: json['videoUrl'],
      allowMultipleSelections: json['metadata']['allowMultipleSelections'] ?? false,
      randomizeOptions: json['metadata']['randomizeOptions'] ?? true,
      partialCreditThreshold: (json['partialCreditThreshold'] ?? 0.0).toDouble(),
    );
  }

  @override
  bool validateAnswer(dynamic answer) {
    if (answer is! List<int>) return false;
    
    if (!allowMultipleSelections && answer.length > 1) return false;
    
    if (allowMultipleSelections) {
      // For multiple selection questions, check if all selected answers are correct
      // and all correct answers are selected
      return answer.length == correctOptionIndices.length && 
             answer.every((index) => correctOptionIndices.contains(index));
    } else {
      // For single selection questions, check if the selected answer is correct
      return answer.length == 1 && correctOptionIndices.contains(answer[0]);
    }
  }

  @override
  double calculatePartialCredit(dynamic answer) {
    if (answer is! List<int>) return 0.0;
    
    if (!allowMultipleSelections) {
      // For single selection, it's all or nothing
      return validateAnswer(answer) ? 1.0 : 0.0;
    }
    
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (description != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              description!,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        const SizedBox(height: 16),
        ...List.generate(
          options.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Builder(
              builder: (context) {
                return Material(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                  elevation: 1,
                  child: ListTile(
                    title: Text(options[index]),
                    leading: CircleAvatar(
                      child: Text(String.fromCharCode(65 + index)), // A, B, C, etc.
                    ),
                    onTap: () {
                      // dispatch the selected index as an AnswerNotification
                      AnswerNotification(<int>[index]).dispatch(context);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildMediaWidget() {
    if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => 
          const Icon(Icons.broken_image, size: 100),
      );
    } else if (videoUrl != null) {
      // Video player implementation would go here
      return const Center(child: Text("Video Player Placeholder"));
    } else if (audioUrl != null) {
      // Audio player implementation would go here
      return const Center(child: Text("Audio Player Placeholder"));
    }
    
    return const SizedBox.shrink(); // No media to show
  }

  @override
  Widget buildFeedbackWidget(dynamic userAnswer, bool isCorrect) {
    if (userAnswer is! List<int>) {
      return const Text("Invalid answer format");
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? Colors.green : Colors.red,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              isCorrect ? "Correct!" : "Incorrect",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isCorrect ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          "Correct answer(s):",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        ...correctOptionIndices.map((index) => Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            "• ${options[index]}",
            style: const TextStyle(fontSize: 16),
          ),
        )),
      ],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'points': points,
      'timeLimit': timeLimit,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'partialCreditThreshold': partialCreditThreshold,
      'questionType': questionType,
      'metadata': metadata,
    };
  }
}
