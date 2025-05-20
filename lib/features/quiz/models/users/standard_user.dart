import 'package:flutter/material.dart';

import '../../../../core/models/user.dart';

/// A standard implementation of the User abstract class
class StandardUser extends User {
  /// Optional avatar color for user representation
  final Color avatarColor;
  
  /// Optional avatar URL if the user has a custom avatar
  final String? avatarUrl;

  // Local copy of the maps to manage mutations
  final Map<String, int> _localQuizScores;
  final Map<String, int> _localQuizRankings;
  final Map<String, bool> _localQuizCompletion;

  StandardUser({
    required String id,
    required String displayName,
    required DateTime joinedAt,
    Map<String, dynamic> metadata = const {},
    Map<String, int>? quizScores,
    Map<String, int>? quizRankings,
    Map<String, bool>? quizCompletion,
    this.avatarColor = Colors.blue,
    this.avatarUrl,
  }) : 
    _localQuizScores = quizScores ?? {},
    _localQuizRankings = quizRankings ?? {},
    _localQuizCompletion = quizCompletion ?? {},
    super(
      id: id,
      displayName: displayName,
      joinedAt: joinedAt,
      metadata: metadata,
      quizScores: quizScores,
      quizRankings: quizRankings,
      quizCompletion: quizCompletion,
    );

  @override
  void updateQuizScore(String quizId, int score) {
    // We should create a new map to ensure immutability
    final updatedScores = Map<String, int>.from(_localQuizScores);
    // If there's an existing score, only update if the new score is higher
    if (!updatedScores.containsKey(quizId) || score > updatedScores[quizId]!) {
      updatedScores[quizId] = score;
    }
    // Update the local copy
    _localQuizScores.clear();
    _localQuizScores.addAll(updatedScores);
  }

  @override
  void updateQuizRanking(String quizId, int ranking) {
    final updatedRankings = Map<String, int>.from(_localQuizRankings);
    updatedRankings[quizId] = ranking;
    
    _localQuizRankings.clear();
    _localQuizRankings.addAll(updatedRankings);
  }

  @override
  void completeQuiz(String quizId, {required int finalScore}) {
    // Mark the quiz as completed
    final updatedCompletion = Map<String, bool>.from(_localQuizCompletion);
    updatedCompletion[quizId] = true;
    
    _localQuizCompletion.clear();
    _localQuizCompletion.addAll(updatedCompletion);
    
    // Update the final score
    updateQuizScore(quizId, finalScore);
  }

  // Override the getters to use our local copies
  @override
  Map<String, int> get quizScores => Map.unmodifiable(_localQuizScores);
  
  @override
  Map<String, int> get quizRankings => Map.unmodifiable(_localQuizRankings);
  
  @override
  Map<String, bool> get quizCompletion => Map.unmodifiable(_localQuizCompletion);
  
  @override
  int getQuizScore(String quizId) => _localQuizScores[quizId] ?? 0;
  
  @override
  int? getQuizRanking(String quizId) => _localQuizRankings[quizId];
  
  @override
  bool hasCompletedQuiz(String quizId) => _localQuizCompletion[quizId] ?? false;

  @override
  Widget buildAvatarWidget({double size = 40}) {
    // If avatar URL is provided, use a network image
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(avatarUrl!),
        backgroundColor: avatarColor,
      );
    }
    
    // Otherwise use the first letter of display name with avatar color
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: avatarColor,
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.5,
        ),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'joinedAt': joinedAt.toIso8601String(),
      'metadata': metadata,
      'quizScores': _localQuizScores,
      'quizRankings': _localQuizRankings,
      'quizCompletion': _localQuizCompletion,
      'avatarColor': avatarColor.value,
      'avatarUrl': avatarUrl,
    };
  }

  /// Create a StandardUser from JSON data
  factory StandardUser.fromJson(Map<String, dynamic> json) {
    return StandardUser(
      id: json['id'],
      displayName: json['displayName'],
      joinedAt: DateTime.parse(json['joinedAt']),
      metadata: json['metadata'] ?? {},
      quizScores: (json['quizScores'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value as int),
      ),
      quizRankings: (json['quizRankings'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value as int),
      ),
      quizCompletion: (json['quizCompletion'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value as bool),
      ),
      avatarColor: json['avatarColor'] != null 
          ? Color(json['avatarColor']) 
          : Colors.blue,
      avatarUrl: json['avatarUrl'],
    );
  }

  /// Create a guest user with a temporary ID
  factory StandardUser.guest({
    required String displayName,
    Color avatarColor = Colors.grey,
  }) {
    final now = DateTime.now();
    final tempId = 'guest_${now.millisecondsSinceEpoch}';
    
    return StandardUser(
      id: tempId,
      displayName: displayName,
      joinedAt: now,
      avatarColor: avatarColor,
    );
  }
}
