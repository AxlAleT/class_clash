import 'package:flutter/material.dart';

import '../../../../core/models/gamification_strategy.dart';

class StreakStrategy extends GamificationStrategy {
  final int bonusPoints;
  final int streakThreshold;
  final int maxMultiplier;

  StreakStrategy({
    required super.id,
    required super.name,
    super.configuration,
    this.bonusPoints = 5,
    this.streakThreshold = 3,
    this.maxMultiplier = 3,
  });

  @override
  void applyStrategy({
    required dynamic quizState,
    required dynamic userAction,
    required Function(dynamic) updateState,
  }) {
    if (userAction['type'] == 'answer' && userAction['isCorrect']) {
      final int streak = quizState['currentStreak'] ?? 0;
      
      // Apply streak bonus if threshold reached
      if (streak >= streakThreshold) {
        // Calculate multiplier based on streak length, capped at maxMultiplier
        final int multiplier = ((streak / streakThreshold).floor()).clamp(1, maxMultiplier);
        final int bonusAwarded = bonusPoints * multiplier;
        
        var newState = <String, dynamic>{...quizState};
        newState['totalPoints'] = (quizState['totalPoints'] ?? 0) + bonusAwarded;
        
        // Store streak info in metadata
        if (newState['metadata'] == null) {
          newState['metadata'] = {};
        }
        newState['metadata']['streakBonus'] = bonusAwarded;
        newState['metadata']['currentMultiplier'] = multiplier;
        
        updateState(newState);
      }
    }
  }

  @override
  Widget buildStrategyWidget(dynamic quizState) {
    final int streak = quizState['currentStreak'] ?? 0;
    final int? multiplier = streak >= streakThreshold 
        ? ((streak / streakThreshold).floor()).clamp(1, maxMultiplier) 
        : null;
    final int? streakBonus = quizState['metadata']?['streakBonus'];
    
    if (streak < streakThreshold) {
      return const SizedBox.shrink(); // Don't show anything if no streak
    }
    
    return _StreakWidget(
      streak: streak,
      multiplier: multiplier,
      streakBonus: streakBonus,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'configuration': configuration,
      'bonusPoints': bonusPoints,
      'streakThreshold': streakThreshold,
      'maxMultiplier': maxMultiplier,
      'type': strategyType,
    };
  }

  @override
  String get strategyType => 'streak';

  factory StreakStrategy.fromJson(Map<String, dynamic> json) {
    return StreakStrategy(
      id: json['id'] ?? 'streak_default',
      name: json['name'] ?? 'Streak Bonus',
      configuration: json['configuration'] ?? <String, dynamic>{},
      bonusPoints: json['bonusPoints'] ?? 5,
      streakThreshold: json['streakThreshold'] ?? 3,
      maxMultiplier: json['maxMultiplier'] ?? 3,
    );
  }
}

// Widget to display streak information
class _StreakWidget extends StatelessWidget {
  final int streak;
  final int? multiplier;
  final int? streakBonus;

  const _StreakWidget({
    required this.streak,
    this.multiplier,
    this.streakBonus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: Colors.orange),
          const SizedBox(width: 8),
          Text(
            'Streak: $streak',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
          if (multiplier != null) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '×$multiplier',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          if (streakBonus != null && streakBonus != 0) ...[
            const SizedBox(width: 8),
            Text(
              '+$streakBonus',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
