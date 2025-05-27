import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Abstract base class for all gamification strategies
abstract class GamificationStrategy {
  final String id;
  final String name;
  final Map<String, dynamic> configuration;

  // Additional properties
  final int
  priority; // Higher number = higher priority when multiple strategies apply
  final Map<String, dynamic> conditions; // When this strategy should be applied
  final Map<String, dynamic> analyticsData; // Track effectiveness

  GamificationStrategy({
    required this.id,
    required this.name,
    this.configuration = const <String, dynamic>{},
    this.priority = 1,
    this.conditions = const <String, dynamic>{},
    Map<String, dynamic>? analyticsData,
  }) : analyticsData = analyticsData ?? {};

  /// Check if strategy is applicable in the current context
  bool isApplicable(Map<String, dynamic> quizState) {
    // Default implementation - can be overridden by subclasses
    if (conditions.isEmpty) return true;

    // Check each condition against quiz state
    for (final entry in conditions.entries) {
      final key = entry.key;
      final value = entry.value;

      if (!quizState.containsKey(key)) return false;
      if (quizState[key] != value) return false;
    }

    return true;
  }

  /// Apply the strategy to the current quiz state
  void applyStrategy({
    required dynamic quizState,
    required dynamic userAction,
    required Function(dynamic) updateState,
  });

  /// Track effectiveness of this strategy
  void trackEffectiveness(dynamic beforeState, dynamic afterState) {
    // Record metrics about how this strategy affected user performance/engagement
    // To be implemented by subclasses
  }

  /// Build the UI widget for this strategy
  Widget buildStrategyWidget(dynamic quizState);

  /// Builds the widget for this strategy
  Widget buildWidget(BuildContext context);

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson();

  /// Create GamificationStrategy from JSON (to be implemented by subclasses)
  /// factory GamificationStrategy.fromJson(Map<String, dynamic> json);

  /// Get the type of strategy as a string
  String get strategyType;
}
