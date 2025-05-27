import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../core/models/gamification_strategy.dart';

class PointsStrategy extends GamificationStrategy {
  final int basePoints;
  final int speedBonusThreshold; // Time in seconds for speed bonus
  final int speedBonusPoints;

  PointsStrategy({
    required super.id,
    required super.name,
    this.basePoints = 10,
    this.speedBonusThreshold = 5,
    this.speedBonusPoints = 5,
    super.configuration,
    super.priority,
    super.conditions,
    super.analyticsData,
  });

  /// Factory method to create a PointsStrategy from JSON
  static PointsStrategy fromJson(Map<String, dynamic> json) {
    return PointsStrategy(
      id: json['id'] as String,
      name: json['name'] as String,
      basePoints: json['basePoints'] as int? ?? 10,
      speedBonusThreshold: json['speedBonusThreshold'] as int? ?? 5,
      speedBonusPoints: json['speedBonusPoints'] as int? ?? 5,
      configuration:
          json['configuration'] as Map<String, dynamic>? ?? <String, dynamic>{},
      priority: json['priority'] as int? ?? 1,
      conditions:
          json['conditions'] as Map<String, dynamic>? ?? <String, dynamic>{},
      analyticsData: json['analyticsData'] as Map<String, dynamic>?,
    );
  }

  @override
  void applyStrategy({
    required dynamic quizState,
    required dynamic userAction,
    required Function(dynamic) updateState,
  }) {
    final int timeTaken = userAction['timeTaken'] ?? 0;
    final bool isCorrect = userAction['isCorrect'] ?? false;

    if (!isCorrect) return;

    int points = basePoints;
    if (timeTaken <= speedBonusThreshold) {
      points += speedBonusPoints;
    }

    final int currentPoints = quizState['points'] ?? 0;
    updateState({'points': currentPoints + points});
  }

  @override
  Widget buildStrategyWidget(dynamic quizState) {
    final int points = quizState['points'] ?? 0;
    return Text(
      'Points: $points',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'basePoints': basePoints,
      'speedBonusThreshold': speedBonusThreshold,
      'speedBonusPoints': speedBonusPoints,
      'configuration': configuration,
      'priority': priority,
      'conditions': conditions,
      'analyticsData': analyticsData,
      'strategyType': strategyType,
    };
  }

  @override
  String get strategyType => 'PointsStrategy';

  @override
  Widget buildWidget(BuildContext context) {
    // This strategy is not primarily UI-focused, so return an empty widget.
    // Its UI representation is typically handled by `buildStrategyWidget` if needed directly.
    return const SizedBox.shrink();
  }
}
