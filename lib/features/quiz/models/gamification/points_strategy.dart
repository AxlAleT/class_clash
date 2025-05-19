// Archivo: lib/features/quiz/models/gamification/points_strategy.dart
import 'package:flutter/material.dart';
import '../../../../core/models/gamification_strategy.dart';

class PointsStrategy extends GamificationStrategy {
  final int basePoints;
  final int bonusTimeThreshold; // en segundos
  final int timeBonus;
  final int streakBonus;
  final int streakThreshold;

  PointsStrategy({
    required super.id,
    required super.name,
    super.configuration,
    this.basePoints = 10,
    this.bonusTimeThreshold = 5,
    this.timeBonus = 5,
    this.streakBonus = 2,
    this.streakThreshold = 3,
  });

  @override
  void applyStrategy({
    required dynamic quizState,
    required dynamic userAction,
    required Function(dynamic) updateState,
  }) {
    // Implementación para calcular puntos con bonificación por tiempo
    if (userAction['type'] == 'answer' && userAction['isCorrect']) {
      int pointsEarned = basePoints;

      // Bonificación por tiempo rápido
      if (userAction['timeSpent'] < bonusTimeThreshold) {
        pointsEarned += timeBonus;
      }

      // Bonificación por racha de respuestas correctas
      if (quizState['currentStreak'] >= streakThreshold) {
        pointsEarned += streakBonus;
      }

      // Actualizar el estado del quiz
      var newState = {...quizState};
      newState['totalPoints'] = (quizState['totalPoints'] ?? 0) + pointsEarned;
      newState['currentStreak'] = (quizState['currentStreak'] ?? 0) + 1;
      newState['lastPointsEarned'] = pointsEarned;

      updateState(newState);
    } else if (userAction['type'] == 'answer' && !userAction['isCorrect']) {
      // Reiniciar la racha si la respuesta es incorrecta
      var newState = {...quizState};
      newState['currentStreak'] = 0;
      newState['lastPointsEarned'] = 0;

      updateState(newState);
    }
  }

  @override
  Widget buildStrategyWidget(dynamic quizState) {
    return _PointsWidget(
      points: quizState['totalPoints'] ?? 0,
      lastPointsEarned: quizState['lastPointsEarned'],
      streak: quizState['currentStreak'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'configuration': configuration,
      'basePoints': basePoints,
      'bonusTimeThreshold': bonusTimeThreshold,
      'timeBonus': timeBonus,
      'streakBonus': streakBonus,
      'streakThreshold': streakThreshold,
      'type': strategyType,
    };
  }

  @override
  String get strategyType => 'points';

  factory PointsStrategy.fromJson(Map<String, dynamic> json) {
    return PointsStrategy(
      id: json['id'],
      name: json['name'],
      configuration: json['configuration'] ?? {},
      basePoints: json['basePoints'] ?? 10,
      bonusTimeThreshold: json['bonusTimeThreshold'] ?? 5,
      timeBonus: json['timeBonus'] ?? 5,
      streakBonus: json['streakBonus'] ?? 2,
      streakThreshold: json['streakThreshold'] ?? 3,
    );
  }
}

// Widget placeholder para mostrar puntos
class _PointsWidget extends StatelessWidget {
  final int points;
  final int? lastPointsEarned;
  final int streak;

  const _PointsWidget({
    required this.points,
    this.lastPointsEarned,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Puntos: $points',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (streak > 0)
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orange),
              Text('Racha: $streak', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        if (lastPointsEarned != null && lastPointsEarned! > 0)
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            child: Text(
              '+$lastPointsEarned',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
      ],
    );
  }
}