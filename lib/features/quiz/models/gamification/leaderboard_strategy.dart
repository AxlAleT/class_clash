import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../core/models/gamification_strategy.dart';
import '../../widgets/gamification/leaderboard_widget.dart'; // Import for LeaderboardWidget

// Dummy data for now, this should ideally come from a shared state or service
final List<Map<String, dynamic>> _dummyParticipants = [
  {'name': 'Alex', 'score': 120},
  {'name': 'Jamie', 'score': 90},
  {'name': 'Taylor', 'score': 150},
  {'name': 'Morgan', 'score': 85},
];

class LeaderboardStrategy extends GamificationStrategy {
  LeaderboardStrategy({
    required super.id,
    required super.name,
    super.configuration,
    super.priority,
    super.conditions,
    super.analyticsData,
  });

  /// Factory method to create a LeaderboardStrategy from JSON
  static LeaderboardStrategy fromJson(Map<String, dynamic> json) {
    return LeaderboardStrategy(
      id: json['id'] as String,
      name: json['name'] as String,
      configuration:
          json['configuration'] as Map<String, dynamic>? ?? <String, dynamic>{},
      priority: json['priority'] as int? ?? 1, // Default priority
      conditions:
          json['conditions'] as Map<String, dynamic>? ?? <String, dynamic>{},
      analyticsData: json['analyticsData'] as Map<String, dynamic>?,
    );
  }

  @override
  String get strategyType => 'leaderboard'; // Consistent with QuizPlayScreen check

  @override
  void applyStrategy({
    required dynamic quizState,
    required dynamic userAction,
    required Function(dynamic) updateState,
  }) {
    // Leaderboard strategy might not directly modify quizState upon user action
    // It primarily serves to display data.
    // However, it could update leaderboard rankings if they are stored within quizState.
    // For now, this can be a no-op.
  }

  @override
  Widget buildStrategyWidget(dynamic quizState) {
    // This method might be used if the strategy needs to build a widget
    // that's deeply integrated with quizState internal details.
    // For a leaderboard, buildWidget is more appropriate.
    // Returning a simple Text widget as a placeholder or for debugging.
    final int currentUserScore = quizState is Map && quizState.containsKey('totalPoints')
        ? quizState['totalPoints'] as int
        : 0;
    return LeaderboardWidget(
        currentUserScore: currentUserScore,
        participantsData: _dummyParticipants,
    );
  }
  
  @override
  Widget buildWidget(BuildContext context) {
    // This is the primary method for rendering the leaderboard.
    // For now, it uses dummy data. In a real app, this data would come from
    // the quiz state, a service, or be passed through the context.
    // Let's assume a way to get the current user's score, e.g., from a QuizState or similar.
    // For simplicity, defaulting to 0 if not available.
    // final quizState = Provider.of<QuizState>(context, listen: false); // Example of accessing state
    // final currentUserScore = quizState.currentUserScore; 
    const int currentUserScore = 0; // Placeholder for current user's score

    return const LeaderboardWidget(
      currentUserScore: currentUserScore, // This should be dynamic
      participantsData: _dummyParticipants, // Using dummy data
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'configuration': configuration,
      'priority': priority,
      'conditions': conditions,
      'analyticsData': analyticsData,
      'strategyType': strategyType,
    };
  }

  @override
  void trackEffectiveness(dynamic beforeState, dynamic afterState) {
    // Implementation for tracking effectiveness, if any.
  }
}
