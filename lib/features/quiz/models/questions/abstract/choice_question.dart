import 'package:flutter/material.dart';

import '../../../../../core/models/question.dart';

/// Base class for questions with choices (single or multiple)
abstract class ChoiceQuestion extends Question {
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

  // Common properties for choice questions
  final List<String> options;
  final List<int> correctOptionIndices;
  final bool randomizeOptions;

  // Track selected options
  final List<int> selectedIndices = <int>[];

  ChoiceQuestion({
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
    this.randomizeOptions = true,
    this.partialCreditThreshold = 0.0,
  }) : assert(
         correctOptionIndices.every(
           (index) => index >= 0 && index < options.length,
         ),
         'Correct option indices must be valid indices within the options list',
       );

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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ...correctOptionIndices.map(
          (index) => Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "• ${options[index]}",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
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
