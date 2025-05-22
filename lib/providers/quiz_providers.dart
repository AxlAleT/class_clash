import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

import '../features/quiz/factories/quiz_factory.dart';
import '../features/quiz/factories/user_factory.dart';
import '../core/models/quiz.dart';
import '../core/models/user.dart';

/// Provider class that simulates REST API operations for quizzes
class QuizProvider {
  // Singleton pattern
  static final QuizProvider _instance = QuizProvider._internal();
  factory QuizProvider() => _instance;

  // Private constructor
  QuizProvider._internal() {
    // Initialize with mock data
    _addMockQuizzes();
  }

  // Dependencies
  final QuizFactory _quizFactory = QuizFactory();
  final UserFactory _userFactory = UserFactory();

  // Mock data storage
  final Map<String, Map<String, dynamic>> _quizData = {};
  final Map<String, List<User>> _quizUsers = {};

  // Mock server delay to simulate network requests
  final Duration _mockDelay = const Duration(milliseconds: 300);

  // Generate mock quiz data
  void _addMockQuizzes() {
    // Multiple choice question for a quiz
    final multipleChoiceQuestion1 = {
      'id': 'q1',
      'title': 'What is the capital of France?',
      'description': 'Choose the correct answer.',
      'points': 100,
      'timeLimit': 30,
      'questionType': 'multiple_choice',
      'metadata': {
        'options': ['London', 'Paris', 'Berlin', 'Rome'],
        'correctOptionIndices': [1], // Paris
        'allowMultipleSelections': false,
        'randomizeOptions': true,
      },
    };

    // Another multiple choice question
    final multipleChoiceQuestion2 = {
      'id': 'q2',
      'title': 'Which programming languages are statically typed?',
      'description': 'Select all that apply.',
      'points': 200,
      'timeLimit': 45,
      'questionType': 'multiple_choice',
      'metadata': {
        'options': ['JavaScript', 'TypeScript', 'Python', 'Java', 'C++'],
        'correctOptionIndices': [1, 3, 4], // TypeScript, Java, C++
        'allowMultipleSelections': true,
        'randomizeOptions': true,
      },
    };

    // A points-based gamification strategy
    final pointsStrategy = {
      'id': 'gs1',
      'name': 'Basic Points',
      'basePoints': 10,
      'speedBonusThreshold': 5,
      'speedBonusPoints': 5,
      'strategyType': 'PointsStrategy',
    };

    // Create a complete quiz
    final quiz1 = {
      'id': 'quiz_001',
      'title': 'General Knowledge Quiz',
      'description': 'Test your knowledge on various topics.',
      'questions': [multipleChoiceQuestion1, multipleChoiceQuestion2],
      'gamificationStrategies': [pointsStrategy],
      'currentQuestionIndex': 0,
      'totalPoints': 0,
      'currentStreak': 0,
      'type': 'standard', // Important to match with registered quiz types
    };

    // Programming quiz example
    final quiz2 = {
      'id': 'quiz_002',
      'title': 'Dart Programming Basics',
      'description': 'Test your knowledge of Dart programming fundamentals.',
      'questions': [
        {
          'id': 'q3',
          'title': 'What keyword is used to declare a variable that can be assigned only once?',
          'description': 'Choose the correct Dart keyword.',
          'points': 100,
          'timeLimit': 30,
          'questionType': 'multiple_choice',
          'metadata': {
            'options': ['var', 'const', 'final', 'static'],
            'correctOptionIndices': [2], // final
            'allowMultipleSelections': false,
            'randomizeOptions': true,
          },
        }
      ],
      'gamificationStrategies': [pointsStrategy],
      'type': 'standard',
    };

    // Add the quizzes to our mock data store
    _quizData['quiz_001'] = quiz1;
    _quizData['quiz_002'] = quiz2;

    // Add some mock users for this quiz
    final user1 = {
      'id': 'user_001',
      'displayName': 'John Doe',
      'joinedAt': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      'userType': 'StandardUser',
      'quizScores': {'quiz_001': 300},
      'quizCompletion': {'quiz_001': true},
    };

    final user2 = {
      'id': 'user_002',
      'displayName': 'Jane Smith',
      'joinedAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      'userType': 'StandardUser',
      'quizScores': {'quiz_001': 250},
      'quizCompletion': {'quiz_001': true},
    };

    _quizUsers['quiz_001'] = [
      _userFactory.createFromJson(user1),
      _userFactory.createFromJson(user2)
    ];
  }

  /// Load a quiz by its ID
  Future<Quiz?> loadQuiz(String quizId, {String? userId}) async {
    // Simulate network delay
    await Future.delayed(_mockDelay);

    if (!_quizData.containsKey(quizId)) {
      return null;
    }

    // Get the quiz data
    final quizData = Map<String, dynamic>.from(_quizData[quizId]!);

    // Add user data to the quiz data if a userId is provided
    if (userId != null) {
      // Find the user in the quiz participants
      User? user;
      if (_quizUsers.containsKey(quizId)) {
        user = _quizUsers[quizId]!.firstWhere(
          (u) => u.id == userId,
          orElse: () => _userFactory.createGuestUser(displayName: "Guest")
        );
      } else {
        // If no participants are registered, create a guest user
        user = _userFactory.createGuestUser(displayName: "Guest");
      }

      // Add user data to the quiz JSON
      quizData['user'] = user.toJson();
    } else if (_quizUsers.containsKey(quizId) && _quizUsers[quizId]!.isNotEmpty) {
      // If no specific userId is provided but there are participants, use the first one
      quizData['user'] = _quizUsers[quizId]!.first.toJson();
    } else {
      // Default to a guest user if no users are available
      quizData['user'] = _userFactory.createGuestUser(displayName: "Guest").toJson();
    }

    // Create and return the quiz with user data
    return _quizFactory.createFromJson(quizData);
  }

  /// Get quiz data without creating a Quiz instance
  Future<Map<String, dynamic>?> getQuizData(String quizId) async {
    // Simulate network delay
    await Future.delayed(_mockDelay);

    if (!_quizData.containsKey(quizId)) {
      return null;
    }

    return Map<String, dynamic>.from(_quizData[quizId]!);
  }

  /// Create a new quiz
  Future<String> createQuiz(Map<String, dynamic> quizData) async {
    // Simulate network delay
    await Future.delayed(_mockDelay);

    final String quizId = quizData['id'] ?? 'quiz_${DateTime.now().millisecondsSinceEpoch}';
    quizData['id'] = quizId;

    _quizData[quizId] = quizData;

    return quizId;
  }

  /// Update an existing quiz
  Future<bool> updateQuiz(String quizId, Map<String, dynamic> quizData) async {
    // Simulate network delay
    await Future.delayed(_mockDelay);

    if (!_quizData.containsKey(quizId)) {
      return false;
    }

    quizData['id'] = quizId; // Ensure ID is preserved
    _quizData[quizId] = quizData;

    return true;
  }

  /// Delete a quiz
  Future<bool> deleteQuiz(String quizId) async {
    // Simulate network delay
    await Future.delayed(_mockDelay);

    if (!_quizData.containsKey(quizId)) {
      return false;
    }

    _quizData.remove(quizId);
    _quizUsers.remove(quizId);

    return true;
  }

  /// List all quizzes
  Future<List<Quiz>> listQuizzes({String? userId}) async {
    // Simulate network delay
    await Future.delayed(_mockDelay);

    final List<Quiz> quizzes = [];

    for (final entry in _quizData.entries) {
      final quizId = entry.key;
      final quizData = Map<String, dynamic>.from(entry.value);

      // Add user data to each quiz JSON
      if (userId != null) {
        // Try to find the specific user in the quiz participants
        User? user;
        if (_quizUsers.containsKey(quizId)) {
          user = _quizUsers[quizId]!.firstWhere(
            (u) => u.id == userId,
            orElse: () => _userFactory.createGuestUser(displayName: "Guest")
          );
        } else {
          user = _userFactory.createGuestUser(displayName: "Guest");
        }
        quizData['user'] = user.toJson();
      } else if (_quizUsers.containsKey(quizId) && _quizUsers[quizId]!.isNotEmpty) {
        // If no specific user ID, use the first participant
        quizData['user'] = _quizUsers[quizId]!.first.toJson();
      } else {
        // Default to guest user
        quizData['user'] = _userFactory.createGuestUser(displayName: "Guest").toJson();
      }

      quizzes.add(_quizFactory.createFromJson(quizData));
    }

    return quizzes;
  }

  /// Get quiz participants
  Future<List<User>> getQuizParticipants(String quizId) async {
    // Simulate network delay
    await Future.delayed(_mockDelay);

    if (!_quizUsers.containsKey(quizId)) {
      return [];
    }

    return List<User>.from(_quizUsers[quizId]!);
  }

  /// Add participant to a quiz
  Future<bool> addParticipant(String quizId, User user) async {
    // Simulate network delay
    await Future.delayed(_mockDelay);

    if (!_quizData.containsKey(quizId)) {
      return false;
    }

    if (!_quizUsers.containsKey(quizId)) {
      _quizUsers[quizId] = [];
    }

    _quizUsers[quizId]!.add(user);

    return true;
  }

  /// Simulate submitting quiz results to a server endpoint
  Future<bool> submitQuizResults(String quizId, Map<String, dynamic> results) async {
    // Simulate network delay
    await Future.delayed(_mockDelay);

    // Check if quiz exists
    if (!_quizData.containsKey(quizId)) {
      _logError('Quiz not found: $quizId');
      return false;
    }

    // In a real implementation, this would send results to a server
    // For simulation, we'll store it in our mock data

    // Create or get the results array for this quiz
    if (!_quizData[quizId]!.containsKey('submissions')) {
      _quizData[quizId]!['submissions'] = [];
    }

    // Add timestamp to results
    final submissionData = {
      ...results,
      'submittedAt': DateTime.now().toIso8601String(),
    };

    // Add the submission to our mock database
    (_quizData[quizId]!['submissions'] as List).add(submissionData);

    // Log the submission data in a more visible way
    _logInfo('Quiz results submitted', {
      'quizId': quizId,
      'userId': results['userId'] ?? 'unknown',
      'totalPoints': results['totalPoints'] ?? 0,
      'submissionData': submissionData,
    });

    return true;
  }

  /// Log information with detailed data
  void _logInfo(String message, [Map<String, dynamic>? data]) {
    // Use developer.log for better logging in debug console
    developer.log(
      message,
      name: 'QuizProvider',
      time: DateTime.now(),
    );

    // Also print a formatted version for console visibility
    if (kDebugMode) {
      print('ℹ️ QuizProvider: $message');
      if (data != null) {
        final prettyJson = const JsonEncoder.withIndent('  ').convert(data);
        print('📊 Data: $prettyJson');
      }
    }
  }

  /// Log errors
  void _logError(String message, [dynamic error]) {
    developer.log(
      message,
      name: 'QuizProvider',
      error: error,
    );

    if (kDebugMode) {
      print('❌ QuizProvider ERROR: $message');
      if (error != null) {
        print('🔍 Error details: $error');
      }
    }
  }
}

/// Riverpod provider for QuizProvider singleton
final quizProviderProvider = Provider<QuizProvider>((ref) => QuizProvider());
