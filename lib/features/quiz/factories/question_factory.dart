import 'package:flutter/material.dart';
import '../../../core/models/question.dart';
import '../models/questions/multiple_choice_question.dart';
import '../models/questions/true_false_question.dart';
import '../models/questions/short_answer_question.dart';
// Importar otros tipos de preguntas

/// Factory para crear diferentes tipos de preguntas
class QuestionFactory {
  static Question createQuestion(String type, Map<String, dynamic> data) {
    switch (type.toLowerCase()) {
      case 'multiple_choice':
        return MultipleChoiceQuestion.fromJson(data);
      case 'true_false':
        return TrueFalseQuestion.fromJson(data);
      case 'short_answer':
        return ShortAnswerQuestion.fromJson(data);
    // Añadir más tipos de preguntas aquí
      default:
        throw Exception('Tipo de pregunta no soportado: $type');
    }
  }

  /// Obtener lista de tipos de preguntas disponibles
  static List<String> getAvailableQuestionTypes() {
    return [
      'multiple_choice',
      'true_false',
      'short_answer',
      'open_ended',
      'poll',
      'puzzle',
      'matching',
      'image_hotspot',
      'media_prompt',
      'slider',
      'timed_challenge',
      // Añadir más tipos conforme se implementen
    ];
  }
}
