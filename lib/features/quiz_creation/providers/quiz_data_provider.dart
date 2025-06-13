import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:class_clash/features/quiz_creation/models/quiz/standard_quiz.dart';
import 'package:class_clash/providers/quiz_providers.dart';

// Provider with optional quizId for editing existing quizzes
final quizDataProvider = StateNotifierProvider.family<QuizDataNotifier, QuizDataState, String?>(
  (ref, quizId) => QuizDataNotifier(ref, quizId),
);

// State class for quiz data
class QuizDataState {
  final String? id;
  final String title;
  final String description;
  final String category;
  final int timeLimit;
  final bool isPublic;

  QuizDataState({
    this.id,
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
    String? id,
    String? title,
    String? description,
    String? category,
    int? timeLimit,
    bool? isPublic,
  }) {
    return QuizDataState(
      id: id ?? this.id,
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
      id: id,
      title: title,
      description: description.isEmpty ? null : description,
      questions: [],
      ownerId: ownerId,
      createdAt: DateTime.now(),
      category: category,
      isPublic: isPublic,
      timeLimit: timeLimit,
    );
  }
}

// StateNotifier for quiz data management
class QuizDataNotifier extends StateNotifier<QuizDataState> {
  final Ref ref;
  final String? quizId;

  QuizDataNotifier(this.ref, this.quizId) : super(QuizDataState()) {
    if (quizId != null) {
      loadQuizData();
    }
  }

  Future<void> loadQuizData() async {
    final quizDataMap = await ref.read(quizProviderProvider).getQuizData(quizId!);
    if (quizDataMap != null) {
      state = state.copyWith(
        id: quizDataMap['id'] as String?,
        title: quizDataMap['title'] as String? ?? '',
        description: quizDataMap['description'] as String? ?? '',
        category: quizDataMap['category'] as String? ?? '',
        timeLimit: quizDataMap['timeLimit'] as int? ?? 0,
        isPublic: quizDataMap['isPublic'] as bool? ?? false,
      );
    }
  }

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
