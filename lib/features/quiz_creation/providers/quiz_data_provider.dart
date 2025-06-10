import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:class_clash/features/quiz_creation/models/quiz/standard_quiz.dart';

// Quiz data provider to manage the basic quiz information
final quizDataProvider = StateNotifierProvider<QuizDataNotifier, QuizDataState>((ref) {
  return QuizDataNotifier();
});

// State class for quiz data
class QuizDataState {
  final String title;
  final String description;
  final String category;
  final int timeLimit;
  final bool isPublic;

  QuizDataState({
    this.title = '',
    this.description = '',
    this.category = '',
    this.timeLimit = 0,
    this.isPublic = false,
  });

  // Helper to check if the form is valid
  bool get isFormValid => title.isNotEmpty && category.isNotEmpty;

  // Create a new state with updated fields
  QuizDataState copyWith({
    String? title,
    String? description,
    String? category,
    int? timeLimit,
    bool? isPublic,
  }) {
    return QuizDataState(
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      timeLimit: timeLimit ?? this.timeLimit,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  // Create initial quiz data object
  StandardQuizModel createInitialQuizData(String ownerId) {
    return StandardQuizModel(
      title: title,
      description: description.isEmpty ? null : description,
      questions: [],
      ownerId: ownerId,
      category: category,
      isPublic: isPublic,
      timeLimit: timeLimit,
      createdAt: DateTime.now(),
    );
  }
}

// StateNotifier for quiz data management
class QuizDataNotifier extends StateNotifier<QuizDataState> {
  QuizDataNotifier() : super(QuizDataState());

  void setTitle(String value) {
    state = state.copyWith(title: value);
  }

  void setDescription(String value) {
    state = state.copyWith(description: value);
  }

  void setCategory(String value) {
    state = state.copyWith(category: value);
  }

  void setTimeLimit(int value) {
    state = state.copyWith(timeLimit: value);
  }

  void setIsPublic(bool value) {
    state = state.copyWith(isPublic: value);
  }

  void reset() {
    state = QuizDataState();
  }
}
