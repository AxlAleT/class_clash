import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:flutter/material.dart';

import '../../../../core/models/question.dart';

part 'multiple_choice_question.g.dart';

abstract class MultipleChoiceQuestion implements Built<MultipleChoiceQuestion, MultipleChoiceQuestionBuilder>, Question {
  // Question required properties
  @override
  String get id;
  
  @override
  String get title;
  
  @override
  @nullable
  String? get description;
  
  @override
  @BuiltValueField(wireName: 'points')
  int get points;
  
  @override
  @BuiltValueField(wireName: 'timeLimit')
  int get timeLimit;
  
  @override
  @nullable
  String? get imageUrl;
  
  @override
  @nullable
  String? get audioUrl;
  
  @override
  @nullable
  String? get videoUrl;
  
  @override
  double get partialCreditThreshold;
  
  // Multiple choice specific properties
  BuiltList<String> get options;
  
  BuiltList<int> get correctOptionIndices;
  
  bool get allowMultipleAnswers;
  
  @override
  @memoized
  Map<String, dynamic> get metadata => {
    'allowMultipleAnswers': allowMultipleAnswers,
    'optionsCount': options.length
  };

  static void _initializeBuilder(MultipleChoiceQuestionBuilder b) {
    b
      ..points = 10
      ..timeLimit = 0
      ..allowMultipleAnswers = false
      ..partialCreditThreshold = 0.0;
  }

  MultipleChoiceQuestion._();
  
  factory MultipleChoiceQuestion([void Function(MultipleChoiceQuestionBuilder) updates]) = _$MultipleChoiceQuestion;

  static Serializer<MultipleChoiceQuestion> get serializer => _$multipleChoiceQuestionSerializer;

  @override
  bool validateAnswer(dynamic answer) {
    if (allowMultipleAnswers) {
      // For multiple answers
      final List<int> selectedIndices = List<int>.from(answer);
      return selectedIndices.length == correctOptionIndices.length &&
          correctOptionIndices.every((index) => selectedIndices.contains(index));
    } else {
      // For single answer
      final int selectedIndex = answer as int;
      return correctOptionIndices.contains(selectedIndex);
    }
  }

  @override
  double calculatePartialCredit(dynamic answer) {
    if (!allowMultipleAnswers || correctOptionIndices.length <= 1) {
      return 0.0; // No partial credit for single-answer questions
    }

    final List<int> selectedIndices = List<int>.from(answer);
    int correctSelections = 0;
    
    // Count correct selections
    for (int index in selectedIndices) {
      if (correctOptionIndices.contains(index)) {
        correctSelections++;
      } else {
        // Penalty for incorrect selections
        correctSelections--;
      }
    }
    
    // Calculate proportion of correct answers
    double proportion = correctSelections / correctOptionIndices.length;
    proportion = proportion < 0 ? 0 : proportion; // Ensure non-negative
    
    // Apply threshold
    if (proportion >= partialCreditThreshold && proportion < 1.0) {
      return proportion;
    }
    
    return 0.0;
  }

  @override
  Widget buildQuestionWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        
        if (description != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(description!, style: const TextStyle(fontSize: 16)),
          ),
        
        if (imageUrl != null || audioUrl != null || videoUrl != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: buildMediaWidget(),
          ),
          
        const SizedBox(height: 16),
        Text(
          allowMultipleAnswers 
              ? "Select all correct answers:" 
              : "Select the correct answer:",
          style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
        ),
        const SizedBox(height: 8),
        
        // Option widgets would be built here
        ...List.generate(
          options.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(options[index]),
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
        errorBuilder: (context, error, stackTrace) => 
            const Text('Failed to load image'),
      );
    } else if (videoUrl != null) {
      return const Center(child: Text('Video player would be here'));
    } else if (audioUrl != null) {
      return const Center(child: Text('Audio player would be here'));
    }
    return const SizedBox.shrink();
  }

  @override
  Widget buildFeedbackWidget(dynamic userAnswer, bool isCorrect) {
    return Column(
      children: [
        Icon(
          isCorrect ? Icons.check_circle : Icons.cancel,
          color: isCorrect ? Colors.green : Colors.red,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          isCorrect ? 'Correct!' : 'Incorrect',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isCorrect ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'The correct answer${correctOptionIndices.length > 1 ? 's are' : ' is'}: ' +
              correctOptionIndices
                  .map((index) => options[index])
                  .join(', '),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': questionType,
      'title': title,
      'description': description,
      'options': options.toList(),
      'correctOptionIndices': correctOptionIndices.toList(),
      'allowMultipleAnswers': allowMultipleAnswers,
      'points': points,
      'timeLimit': timeLimit,
      'metadata': metadata,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'partialCreditThreshold': partialCreditThreshold,
    };
  }

  static MultipleChoiceQuestion fromJson(Map<String, dynamic> json) {
    return MultipleChoiceQuestion((b) => b
      ..id = json['id']
      ..title = json['title']
      ..description = json['description']
      ..options = ListBuilder<String>(List<String>.from(json['options']))
      ..correctOptionIndices = ListBuilder<int>(List<int>.from(json['correctOptionIndices']))
      ..allowMultipleAnswers = json['allowMultipleAnswers'] ?? false
      ..points = json['points'] ?? 10
      ..timeLimit = json['timeLimit'] ?? 0
      ..imageUrl = json['imageUrl']
      ..audioUrl = json['audioUrl']
      ..videoUrl = json['videoUrl']
      ..partialCreditThreshold = json['partialCreditThreshold'] ?? 0.0
    );
  }

  @override
  String get questionType => 'multipleChoice';
}
