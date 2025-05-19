import 'package:flutter/material.dart';
import '../../../../core/models/question.dart';

class ShortAnswerQuestion extends Question {
  final List<String> acceptableAnswers;
  final bool caseSensitive;

  ShortAnswerQuestion({
    required super.id,
    required super.title,
    super.description,
    super.points,
    super.timeLimit,
    super.metadata,
    required this.acceptableAnswers,
    this.caseSensitive = false,
  });

  @override
  bool validateAnswer(dynamic answer) {
    if (answer is! String) return false;
    
    String userAnswer = caseSensitive ? answer : answer.toLowerCase();
    for (var acceptableAnswer in acceptableAnswers) {
      String correctAnswer = caseSensitive ? acceptableAnswer : acceptableAnswer.toLowerCase();
      if (userAnswer == correctAnswer) return true;
    }
    return false;
  }

  @override
  Widget buildQuestionWidget() {
    return _ShortAnswerQuestionWidget(question: this);
  }

  @override
  Widget buildFeedbackWidget(dynamic userAnswer, bool isCorrect) {
    return _ShortAnswerFeedbackWidget(
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
      'acceptableAnswers': acceptableAnswers,
      'caseSensitive': caseSensitive,
      'type': questionType,
    };
  }

  @override
  String get questionType => 'short_answer';

  factory ShortAnswerQuestion.fromJson(Map<String, dynamic> json) {
    return ShortAnswerQuestion(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      points: json['points'] ?? 10,
      timeLimit: json['timeLimit'] ?? 0,
      metadata: json['metadata'] ?? {},
      acceptableAnswers: List<String>.from(json['acceptableAnswers']),
      caseSensitive: json['caseSensitive'] ?? false,
    );
  }
}

class _ShortAnswerQuestionWidget extends StatefulWidget {
  final ShortAnswerQuestion question;

  const _ShortAnswerQuestionWidget({required this.question});

  @override
  State<_ShortAnswerQuestionWidget> createState() => _ShortAnswerQuestionWidgetState();
}

class _ShortAnswerQuestionWidgetState extends State<_ShortAnswerQuestionWidget> {
  final TextEditingController _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

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
        TextField(
          controller: _answerController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Your Answer',
            hintText: 'Type your answer here',
          ),
          maxLines: 1,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}

class _ShortAnswerFeedbackWidget extends StatelessWidget {
  final ShortAnswerQuestion question;
  final dynamic userAnswer;
  final bool isCorrect;

  const _ShortAnswerFeedbackWidget({
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
        Text('Tu respuesta: "$userAnswer"'),
        const SizedBox(height: 8),
        Text('Respuestas aceptables:'),
        ...question.acceptableAnswers.map((answer) =>
          Text('• $answer', style: const TextStyle(fontWeight: FontWeight.bold))
        ).toList(),
      ],
    );
  }
}
