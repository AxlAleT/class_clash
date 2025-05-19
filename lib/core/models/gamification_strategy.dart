// Archivo: lib/core/models/gamification_strategy.dart

import 'package:flutter/material.dart';

/// Clase abstracta base para todas las estrategias de gamificación
abstract class GamificationStrategy {
  final String id;
  final String name;
  final Map<String, dynamic> configuration;

  GamificationStrategy({
    required this.id,
    required this.name,
    this.configuration = const {},
  });

  /// Aplicar la estrategia al estado actual del quiz
  void applyStrategy({
    required dynamic quizState,
    required dynamic userAction,
    required Function(dynamic) updateState,
  });

  /// Construir el widget de UI para esta estrategia
  Widget buildStrategyWidget(dynamic quizState);

  /// Convertir a JSON para persistencia
  Map<String, dynamic> toJson();

  /// Obtener el tipo de estrategia como string
  String get strategyType;
}