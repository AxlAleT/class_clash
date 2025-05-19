import 'package:flutter/material.dart';

/// Clase abstracta base para todos los tipos de preguntas
abstract class Question {
  final String id;
  final String title;
  final String? description;
  final int points;
  final int timeLimit; // en segundos, 0 significa sin límite
  final Map<String, dynamic> metadata;

  Question({
    required this.id,
    required this.title,
    this.description,
    this.points = 10,
    this.timeLimit = 0,
    this.metadata = const {},
  });

  /// Método para validar una respuesta dada
  bool validateAnswer(dynamic answer);

  /// Método para renderizar el widget de la pregunta
  Widget buildQuestionWidget();

  /// Método para renderizar el widget de retroalimentación después de responder
  Widget buildFeedbackWidget(dynamic userAnswer, bool isCorrect);

  /// Convertir a JSON para persistencia
  Map<String, dynamic> toJson();

  /// Obtener el tipo de pregunta como string
  String get questionType;
}