import '../../../core/models/gamification_strategy.dart';
import '../models/gamification/points_strategy.dart';
import '../models/gamification/leaderboard_strategy.dart'; // Import LeaderboardStrategy

/// Factory class responsible for creating GamificationStrategy objects
class GamificationFactory {
  static final GamificationFactory _instance = GamificationFactory._internal();

  // Registry of strategy creation functions by type
  final Map<String, GamificationStrategy Function(Map<String, dynamic>)> _strategyCreators = {};

  // Private constructor
  GamificationFactory._internal() {
    // Register built-in strategy types
    registerStrategyType('PointsStrategy', _createPointsStrategy);
    registerStrategyType('leaderboard', _createLeaderboardStrategy); // Register LeaderboardStrategy
  }

  // Singleton instance
  factory GamificationFactory() => _instance;

  /// Register a strategy type with its creator function
  void registerStrategyType(String type, GamificationStrategy Function(Map<String, dynamic>) creator) {
    _strategyCreators[type] = creator;
  }

  /// Create a strategy from its JSON representation
  GamificationStrategy createFromJson(Map<String, dynamic> json) {
    final String strategyType = json['type'] as String? ??
                               json['strategyType'] as String? ??
                               'default';

    if (!_strategyCreators.containsKey(strategyType)) {
      throw Exception('Unknown gamification strategy type: $strategyType');
    }

    return _strategyCreators[strategyType]!(json);
  }

  /// Create multiple strategies from a list of JSON objects
  List<GamificationStrategy> createManyFromJson(List<dynamic> jsonList) {
    return jsonList
        .cast<Map<String, dynamic>>()
        .map((json) => createFromJson(json))
        .toList();
  }

  /// Get available strategy types
  List<String> getAvailableTypes() => _strategyCreators.keys.toList();

  /// Check if a strategy type is registered
  bool hasType(String type) => _strategyCreators.containsKey(type);

  // Factory method for creating PointsStrategy
  GamificationStrategy _createPointsStrategy(Map<String, dynamic> json) {
    return PointsStrategy.fromJson(json); // Use existing fromJson
  }

  // Factory method for creating LeaderboardStrategy
  GamificationStrategy _createLeaderboardStrategy(Map<String, dynamic> json) {
    return LeaderboardStrategy.fromJson(json); // Use fromJson from LeaderboardStrategy
  }
}
