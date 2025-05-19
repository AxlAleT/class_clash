// Archivo: lib/features/quiz/factories/gamification_factory.dart

import 'package:flutter/material.dart';
import '../../../core/models/gamification_strategy.dart';
import '../models/gamification/points_strategy.dart';
import '../models/gamification/leaderboard_strategy.dart';
// Importar otras estrategias

/// Factory para crear diferentes estrategias de gamificación
class GamificationFactory {
  static GamificationStrategy createStrategy(String type, Map<String, dynamic> data) {
    switch (type.toLowerCase()) {
      case 'points':
        return PointsStrategy.fromJson(data);
      case 'leaderboard':
        return LeaderboardStrategy.fromJson(data);
    // Añadir más estrategias de gamificación aquí
      default:
        throw Exception('Estrategia de gamificación no soportada: $type');
    }
  }

  /// Obtener lista de estrategias de gamificación disponibles
  static List<String> getAvailableStrategies() {
    return [
      'points',
      'leaderboard',
      'avatars',
      'streaks',
      'power_ups',
      'badges',
      'visual_effects',
      'team_mode',
      'progress_indicators',
      // Añadir más estrategias conforme se implementen
    ];
  }
}