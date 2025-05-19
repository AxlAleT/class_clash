import 'package:flutter/material.dart';

import '../../../../core/models/question.dart';

class TrueFalseQuestion extends Question {
  final bool correctAnswer;

  TrueFalseQuestion({
    required super.id,
    required super.title,
    super.description,
    super.points,
    super.timeLimit,
    super.metadata,
    required this.correctAnswer,
  });

  @override
  bool validateAnswer(dynamic answer) {
    return answer is bool && answer == correctAnswer;
  }

  @override
  Widget buildQuestionWidget() {
    return _TrueFalseQuestionWidget(question: this);
  }

  @override
  Widget buildFeedbackWidget(dynamic userAnswer, bool isCorrect) {
    return _TrueFalseFeedbackWidget(
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
      'correctAnswer': correctAnswer,
      'type': questionType,
    };
  }

  @override
  String get questionType => 'true_false';

  factory TrueFalseQuestion.fromJson(Map<String, dynamic> json) {
    return TrueFalseQuestion(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      points: json['points'] ?? 10,
      timeLimit: json['timeLimit'] ?? 0,
      metadata: json['metadata'] ?? {},
      correctAnswer: json['correctAnswer'],
    );
  }
}

class _TrueFalseQuestionWidget extends StatefulWidget {
  final TrueFalseQuestion question;

  const _TrueFalseQuestionWidget({required this.question});

  @override
  _TrueFalseQuestionWidgetState createState() =>
      _TrueFalseQuestionWidgetState();
}

class _TrueFalseQuestionWidgetState extends State<_TrueFalseQuestionWidget> {
  bool? selectedAnswer;

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
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedAnswer = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    selectedAnswer == true ? Colors.blue.shade300 : null,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
              ),
              child: const Text('True', style: TextStyle(fontSize: 18)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedAnswer = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    selectedAnswer == false ? Colors.blue.shade300 : null,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
              ),
              child: const Text('False', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ],
    );
  }
}

class _TrueFalseFeedbackWidget extends StatelessWidget {
  final TrueFalseQuestion question;
  final dynamic userAnswer;
  final bool isCorrect;

  const _TrueFalseFeedbackWidget({
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
        Text('La respuesta correcta era:'),
        Text(
          question.correctAnswer ? 'True' : 'False',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }
}
