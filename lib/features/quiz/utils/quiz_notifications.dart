import 'package:flutter/material.dart';

/// Custom notification for handling answers in quizzes
class AnswerNotification extends Notification {
  final dynamic answer;

  AnswerNotification(this.answer);
}
