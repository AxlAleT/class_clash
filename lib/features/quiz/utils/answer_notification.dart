import 'package:flutter/material.dart';

/// Custom notification used to communicate answers between question widgets and the quiz controller
class AnswerNotification extends Notification {
  final dynamic answer;

  const AnswerNotification(this.answer);
}
