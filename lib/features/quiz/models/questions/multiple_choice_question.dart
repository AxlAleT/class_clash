import 'package:flutter/material.dart';

import '../../../../core/models/question.dart';
import '../../screens/quiz_play_screen.dart';

class MultipleChoiceQuestion extends Question {
  final List<String> options;
  final List<int> correctOptionIndices;
  final bool allowMultipleSelections;

  MultipleChoiceQuestion({
    required super.id,
    required super.title,
    super.description,
    super.points,
    super.timeLimit,
    super.metadata,
    required this.options,
    required this.correctOptionIndices,
    this.allowMultipleSelections = false,
  });

  @override
  bool validateAnswer(dynamic answer) {
    if (answer is List<int>) {
      if (allowMultipleSelections) {
        // Para selección múltiple, verificar si todas las respuestas correctas están seleccionadas
        return answer.length == correctOptionIndices.length &&
            answer.every((i) => correctOptionIndices.contains(i));
      } else {
        // Para selección única, verificar si la única opción seleccionada es correcta
        return answer.length == 1 && correctOptionIndices.contains(answer[0]);
      }
    }
    return false;
  }

  @override
  Widget buildQuestionWidget() {
    // Implementación del widget de pregunta de opción múltiple
    return _MultipleChoiceQuestionWidget(question: this);
  }

  @override
  Widget buildFeedbackWidget(dynamic userAnswer, bool isCorrect) {
    // Implementación del widget de retroalimentación
    return _MultipleChoiceFeedbackWidget(
      question: this,
      userAnswer: userAnswer,
      isCorrect: isCorrect,
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
      'metadata': metadata,
      'options': options,
      'correctOptionIndices': correctOptionIndices,
      'allowMultipleSelections': allowMultipleSelections,
      'type': questionType,
    };
  }

  @override
  String get questionType => 'multiple_choice';

  factory MultipleChoiceQuestion.fromJson(Map<String, dynamic> json) {
    return MultipleChoiceQuestion(
      id: json['id'] ?? '',
      // Provide default empty string
      title: json['title'] ?? '',
      // Provide default empty string
      description: json['description'],
      // This can be null
      points: json['points'] ?? 10,
      timeLimit: json['timeLimit'] ?? 0,
      metadata: json['metadata'] ?? {},
      options: List<String>.from(json['options'] ?? []),
      // Handle null options
      correctOptionIndices: List<int>.from(json['correctOptionIndices'] ?? []),
      // Handle null correctOptionIndices
      allowMultipleSelections: json['allowMultipleSelections'] ?? false,
    );
  }
}

// Widget placeholder para la pregunta de opción múltiple
class _MultipleChoiceQuestionWidget extends StatefulWidget {
  final MultipleChoiceQuestion question;

  const _MultipleChoiceQuestionWidget({required this.question});

  @override
  _MultipleChoiceQuestionWidgetState createState() =>
      _MultipleChoiceQuestionWidgetState();
}

class _MultipleChoiceQuestionWidgetState
    extends State<_MultipleChoiceQuestionWidget> {
  List<int> selectedIndices = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question.title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (widget.question.description != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(widget.question.description!),
          ),
        const SizedBox(height: 16),
        ...widget.question.options.asMap().entries.map((entry) {
          int index = entry.key;
          String option = entry.value;
          bool isSelected = selectedIndices.contains(index);

          return ListTile(
            title: Text(option),
            leading:
                widget.question.allowMultipleSelections
                    ? Checkbox(
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedIndices.add(index);
                          } else {
                            selectedIndices.remove(index);
                          }
                        });
                      },
                    )
                    : Radio<int>(
                      value: index,
                      groupValue:
                          selectedIndices.isNotEmpty
                              ? selectedIndices.first
                              : null,
                      onChanged: (int? value) {
                        setState(() {
                          selectedIndices = [value!];
                        });
                      },
                    ),
          );
        }).toList(),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 48),
            ),
            onPressed: selectedIndices.isNotEmpty
                ? () {
                    // Send notification with selected answer
                    AnswerNotification(selectedIndices).dispatch(context);
                  }
                : null,
            child: const Text('Submit Answer', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}

// Widget placeholder para la retroalimentación
class _MultipleChoiceFeedbackWidget extends StatelessWidget {
  final MultipleChoiceQuestion question;
  final dynamic userAnswer;
  final bool isCorrect;

  const _MultipleChoiceFeedbackWidget({
    required this.question,
    required this.userAnswer,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          isCorrect ? Icons.check_circle : Icons.cancel,
          color: isCorrect ? Colors.green : Colors.red,
          size: 48,
        ),
        Text(
          isCorrect ? '¡Respuesta correcta!' : 'Respuesta incorrecta',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Text('Las opciones correctas eran:'),
        ...question.correctOptionIndices.map((index) {
          return Text(
            '- ${question.options[index]}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        }).toList(),
      ],
    );
  }
}
