import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../features/quiz/factories/quiz_factory.dart';
import '../features/quiz/factories/user_factory.dart';
import '../core/models/quiz.dart';
import '../core/models/user.dart';
import 'quiz_mocks.dart';

// Create a provider for the QuizProvider class
final quizProviderInstance = Provider<QuizProvider>((ref) => QuizProvider());

// Create a provider for the list of available quizzes
final quizzesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final provider = ref.read(quizProviderInstance);
  final quizzes = await provider.getAllQuizzes();
  return quizzes;
});

/// Provider class that simulates REST API operations for quizzes
class QuizProvider {
  // Singleton pattern
  static final QuizProvider _instance = QuizProvider._internal();
  factory QuizProvider() => _instance;
  
  // Logger instance
  final _log = Logger('QuizProvider');

  // Private constructor
  QuizProvider._internal() {
    // Setup logging
    _setupLogging();
    
    // Initialize with mock data
    _addMockQuizzes();
    _log.info('QuizProvider initialized with mock data');
  }
  
  /// Setup logging configuration
  void _setupLogging() {
    // Only configure the root logger if it hasn't been configured yet
    if (Logger.root.level == Level.INFO) {
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((record) {
        if (kDebugMode) {
          print('${record.level.name}: ${record.time}: ${record.message}');
          if (record.error != null) {
            print('Error details: ${record.error}');
          }
          if (record.stackTrace != null) {
            print('Stack trace: ${record.stackTrace}');
          }
        }
      });
    }
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
    _log.fine('Adding mock quiz data');
    
    // Add the quizzes to our mock data store
    _quizData['quiz_001'] = generalKnowledgeQuiz;
    _quizData['quiz_002'] = dartBasicsQuiz;
    _quizData['quiz_003'] = trueFalseChallengeQuiz;

    // Add some mock users for this quiz
    _quizUsers['quiz_001'] = [
      _userFactory.createFromJson(mockUserJohnDoe),
      _userFactory.createFromJson(mockUserJaneSmith)
    ];
    
    _log.fine('Added ${_quizData.length} mock quizzes and users for ${_quizUsers.length} quizzes');
  }

  /// Load a quiz by its ID
  Future<Quiz?> loadQuiz(String quizId, {String? userId}) async {
    _log.info('Loading quiz: $quizId (userId: $userId)');
    
    // Simulate network delay
    await Future.delayed(_mockDelay);

    if (!_quizData.containsKey(quizId)) {
      _log.warning('Quiz not found: $quizId');
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
    final quiz = _quizFactory.createFromJson(quizData);
    _log.fine('Quiz loaded successfully: $quizId (title: ${quiz.title})');
    
    return quiz;
  }

  /// Get quiz data without creating a Quiz instance
  Future<Map<String, dynamic>?> getQuizData(String quizId) async {
    _log.info('Getting raw quiz data: $quizId');
    
    // Simulate network delay
    await Future.delayed(_mockDelay);

    if (!_quizData.containsKey(quizId)) {
      _log.warning('Quiz data not found: $quizId');
      return null;
    }

    _log.fine('Quiz data retrieved successfully: $quizId');
    return Map<String, dynamic>.from(_quizData[quizId]!);
  }

  /// Create a new quiz
  Future<String> createQuiz(Map<String, dynamic> quizData) async {
    _log.info('Creating new quiz');
    
    // Simulate network delay
    await Future.delayed(_mockDelay);

    final String quizId = quizData['id'] ?? 'quiz_${DateTime.now().millisecondsSinceEpoch}';
    quizData['id'] = quizId;

    _quizData[quizId] = quizData;
    
    _log.info('Quiz created with ID: $quizId');
    _log.fine('Quiz details: ${jsonEncode({
      'title': quizData['title'],
      'questions': (quizData['questions'] as List?)?.length ?? 0,
    })}');

    return quizId;
  }

  /// Update an existing quiz
  Future<bool> updateQuiz(String quizId, Map<String, dynamic> quizData) async {
    _log.info('Updating quiz: $quizId');
    
    // Simulate network delay
    await Future.delayed(_mockDelay);

    if (!_quizData.containsKey(quizId)) {
      _log.warning('Cannot update quiz - quiz not found: $quizId');
      return false;
    }

    quizData['id'] = quizId; // Ensure ID is preserved
    _quizData[quizId] = quizData;
    
    _log.fine('Quiz updated successfully: $quizId');

    return true;
  }

  /// Delete a quiz
  Future<bool> deleteQuiz(String quizId) async {
    _log.info('Deleting quiz: $quizId');
    
    // Simulate network delay
    await Future.delayed(_mockDelay);

    if (!_quizData.containsKey(quizId)) {
      _log.warning('Cannot delete quiz - quiz not found: $quizId');
      return false;
    }

    _quizData.remove(quizId);
    _quizUsers.remove(quizId);
    
    _log.info('Quiz deleted: $quizId');

    return true;
  }

  /// List all quizzes
  Future<List<Quiz>> listQuizzes({String? userId}) async {
    _log.info('Listing all quizzes${userId != null ? ' for user: $userId' : ''}');
    
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
    
    _log.fine('Retrieved ${quizzes.length} quizzes');

    return quizzes;
  }

  /// Get quiz participants
  Future<List<User>> getQuizParticipants(String quizId) async {
    _log.info('Getting participants for quiz: $quizId');
    
    // Simulate network delay
    await Future.delayed(_mockDelay);

    if (!_quizUsers.containsKey(quizId)) {
      _log.fine('No participants found for quiz: $quizId');
      return [];
    }
    
    _log.fine('Retrieved ${_quizUsers[quizId]!.length} participants for quiz: $quizId');
    return List<User>.from(_quizUsers[quizId]!);
  }

  /// Add participant to a quiz
  Future<bool> addParticipant(String quizId, User user) async {
    _log.info('Adding participant ${user.id} to quiz: $quizId');
    
    // Simulate network delay
    await Future.delayed(_mockDelay);

    if (!_quizData.containsKey(quizId)) {
      _log.warning('Cannot add participant - quiz not found: $quizId');
      return false;
    }

    if (!_quizUsers.containsKey(quizId)) {
      _quizUsers[quizId] = [];
    }

    _quizUsers[quizId]!.add(user);
    
    _log.fine('Participant ${user.id} (${user.displayName}) added to quiz: $quizId');
    _log.fine('Total participants for quiz $quizId: ${_quizUsers[quizId]!.length}');

    return true;
  }

  /// Simulate submitting quiz results to a server endpoint
  Future<bool> submitQuizResults(String quizId, Map<String, dynamic> results) async {
    _log.info('Submitting quiz results for quiz: $quizId');
    
    // Simulate network delay
    await Future.delayed(_mockDelay);

    // Check if quiz exists
    if (!_quizData.containsKey(quizId)) {
      _log.severe('Cannot submit results - quiz not found: $quizId', 'QuizNotFoundError');
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

    // Log the submission data
    final logData = {
      'quizId': quizId,
      'userId': results['userId'] ?? 'unknown',
      'totalPoints': results['totalPoints'] ?? 0,
    };
    
    _log.info('Quiz results submitted successfully: ${jsonEncode(logData)}');
    _log.fine('Full submission data: ${jsonEncode(submissionData)}');

    return true;
  }

  /// Get all available quizzes as raw data
  Future<List<Map<String, dynamic>>> getAllQuizzes() async {
    _log.info('Getting all available quizzes as raw data');

    // Simulate network delay
    await Future.delayed(_mockDelay);

    // Convert the quiz data to a list of maps
    final quizzes = _quizData.entries.map((entry) {
      final quiz = Map<String, dynamic>.from(entry.value);
      // Add the ID to ensure it's in the returned data
      quiz['id'] = entry.key;
      return quiz;
    }).toList();

    _log.fine('Retrieved ${quizzes.length} quizzes as raw data');
    return quizzes;
  }
}
