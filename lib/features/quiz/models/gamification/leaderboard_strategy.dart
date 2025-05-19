import 'package:flutter/material.dart';

import '../../../../core/models/gamification_strategy.dart';

/// Implementation of a leaderboard gamification strategy
class LeaderboardStrategy extends GamificationStrategy {
  final bool enabled;
  final int showTop;

  LeaderboardStrategy({
    required this.enabled,
    required this.showTop,
    required super.id,
    required super.name,
  });

  @override
  void applyStrategy({
    required dynamic quizState,
    required dynamic userAction,
    required Function(dynamic) updateState,
  }) {
    // Leaderboard itself doesn't modify points
    // In a real app, this would send the score to a leaderboard service
    if (!enabled) return;

    final Map<String, dynamic> quizStateMap = quizState as Map<String, dynamic>;

    // You might want to add data to the metadata for leaderboard tracking
    final updatedMetadata = Map<String, dynamic>.from(
      quizStateMap['metadata'] ?? {},
    );
    updatedMetadata['leaderboardSubmitted'] = true;

    updateState({...quizStateMap, 'metadata': updatedMetadata});
  }

  @override
  Widget buildStrategyWidget(dynamic quizState) {
    if (!enabled) return Container(); // Return empty container instead of null

    final Map<String, dynamic> quizStateMap = quizState as Map<String, dynamic>;

    // Simple leaderboard widget
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text(
              'Leaderboard',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // In a real app, this would display actual leaderboard data
            Text('Top $showTop players will be displayed here'),
          ],
        ),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': strategyType,
      'enabled': enabled,
      'showTop': showTop,
      'configuration': configuration,
    };
  }

  @override
  String get strategyType => 'leaderboard';
}
