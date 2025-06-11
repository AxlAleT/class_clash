import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:class_clash/features/quiz_creation/models/quiz/standard_quiz.dart';
import 'package:class_clash/features/quiz_creation/models/questions/question_model.dart';
import 'package:class_clash/features/quiz_creation/factory/question_factory.dart';
import 'package:class_clash/providers/quiz_providers.dart';

// Quiz questions provider to manage adding/editing questions
final quizQuestionsProvider = StateNotifierProvider.family<QuizQuestionsNotifier, QuizQuestionsState, StandardQuizModel>(
  (ref, initialQuizData) => QuizQuestionsNotifier(initialQuizData, ref),
);

// State class for quiz questions
class QuizQuestionsState {
  final StandardQuizModel quizModel;
  final int selectedQuestionIndex;
  final String activeQuestionType;

  QuizQuestionsState({
    required this.quizModel,
    this.selectedQuestionIndex = -1,
    this.activeQuestionType = 'single_choice',
  });

  // Getters
  List<QuestionModel> get questions => quizModel.questions;
  bool get hasQuestions => questions.isNotEmpty;

  // Create a new state with updated fields
  QuizQuestionsState copyWith({
    StandardQuizModel? quizModel,
    int? selectedQuestionIndex,
    String? activeQuestionType,
  }) {
    return QuizQuestionsState(
      quizModel: quizModel ?? this.quizModel,
      selectedQuestionIndex: selectedQuestionIndex ?? this.selectedQuestionIndex,
      activeQuestionType: activeQuestionType ?? this.activeQuestionType,
    );
  }
}

// StateNotifier for quiz questions management
class QuizQuestionsNotifier extends StateNotifier<QuizQuestionsState> {
  final Ref _ref;

  // Constants
  static const int maxQuestions = 60;

  QuizQuestionsNotifier(StandardQuizModel initialQuizData, this._ref)
      : super(QuizQuestionsState(quizModel: initialQuizData));

  // Get supported question types from the factory
  List<String> get supportedQuestionTypes => QuestionFactory.supportedQuestionTypes;

  // Check if max questions limit is reached
  bool get isMaxQuestionsReached => state.questions.length >= maxQuestions;

  // Set the active question type
  void setActiveQuestionType(String type) {
    if (QuestionFactory.supportedQuestionTypes.contains(type)) {
      state = state.copyWith(activeQuestionType: type);
    }
  }

  // Add a new question
  void addQuestion(QuestionModel question) {
    // Check if we've reached the maximum number of questions
    if (isMaxQuestionsReached) {
      return; // Don't add more questions if limit is reached
    }

    final updatedQuestions = List<QuestionModel>.from(state.questions)..add(question);

    final updatedQuizModel = StandardQuizModel(
      id: state.quizModel.id,
      title: state.quizModel.title,
      description: state.quizModel.description,
      questions: updatedQuestions,
      ownerId: state.quizModel.ownerId,
      createdAt: state.quizModel.createdAt,
      category: state.quizModel.category,
      isPublic: state.quizModel.isPublic,
      timeLimit: state.quizModel.timeLimit,
      settings: state.quizModel.settings,
    );

    // Select the newly added question
    state = state.copyWith(
      quizModel: updatedQuizModel,
      selectedQuestionIndex: updatedQuestions.length - 1,
    );
  }

  // Save the quiz to the server (mock)
  Future<String?> saveQuizToServer() async {
    if (!state.hasQuestions) {
      return null; // Don't save quizzes with no questions
    }

    try {
      // Use the QuizProvider from the provider to ensure we're using the shared instance
      final quizProvider = _ref.read(quizProviderProvider);
      final quizData = state.quizModel.toJson();

      // Generate a unique ID if one doesn't exist
      String quizId = state.quizModel.id ?? '';

      if (quizId.isEmpty) {
        // Create a new quiz
        quizId = await quizProvider.createQuiz(quizData);
      } else {
        // Update an existing quiz
        await quizProvider.updateQuiz(quizId, quizData);
      }

      return quizId;
    } catch (e) {
      print('Error saving quiz: $e');
      return null;
    }
  }

  // Update an existing question
  void updateQuestion(int index, QuestionModel updatedQuestion) {
    if (index >= 0 && index < state.questions.length) {
      final updatedQuestions = List<QuestionModel>.from(state.questions);
      updatedQuestions[index] = updatedQuestion;

      final updatedQuizModel = StandardQuizModel(
        id: state.quizModel.id,
        title: state.quizModel.title,
        description: state.quizModel.description,
        questions: updatedQuestions,
        ownerId: state.quizModel.ownerId,
        createdAt: state.quizModel.createdAt,
        category: state.quizModel.category,
        isPublic: state.quizModel.isPublic,
        timeLimit: state.quizModel.timeLimit,
        settings: state.quizModel.settings,
      );

      state = state.copyWith(quizModel: updatedQuizModel);
    }
  }

  // Remove a question
  void removeQuestion(int index) {
    if (index >= 0 && index < state.questions.length) {
      final updatedQuestions = List<QuestionModel>.from(state.questions);
      updatedQuestions.removeAt(index);

      final updatedQuizModel = StandardQuizModel(
        id: state.quizModel.id,
        title: state.quizModel.title,
        description: state.quizModel.description,
        questions: updatedQuestions,
        ownerId: state.quizModel.ownerId,
        createdAt: state.quizModel.createdAt,
        category: state.quizModel.category,
        isPublic: state.quizModel.isPublic,
        timeLimit: state.quizModel.timeLimit,
        settings: state.quizModel.settings,
      );

      // Adjust selected question index if necessary
      int newSelectedIndex = state.selectedQuestionIndex;
      if (state.selectedQuestionIndex == index) {
        newSelectedIndex = -1;
      } else if (state.selectedQuestionIndex > index) {
        newSelectedIndex = state.selectedQuestionIndex - 1;
      }

      state = state.copyWith(
        quizModel: updatedQuizModel,
        selectedQuestionIndex: newSelectedIndex,
      );
    }
  }

  // Reorder questions
  void reorderQuestions(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final updatedQuestions = List<QuestionModel>.from(state.questions);
    final item = updatedQuestions.removeAt(oldIndex);
    updatedQuestions.insert(newIndex, item);

    final updatedQuizModel = StandardQuizModel(
      id: state.quizModel.id,
      title: state.quizModel.title,
      description: state.quizModel.description,
      questions: updatedQuestions,
      ownerId: state.quizModel.ownerId,
      createdAt: state.quizModel.createdAt,
      category: state.quizModel.category,
      isPublic: state.quizModel.isPublic,
      timeLimit: state.quizModel.timeLimit,
      settings: state.quizModel.settings,
    );

    // Update selected question index if necessary
    int newSelectedIndex = state.selectedQuestionIndex;
    if (state.selectedQuestionIndex == oldIndex) {
      newSelectedIndex = newIndex;
    } else if (state.selectedQuestionIndex < oldIndex && state.selectedQuestionIndex >= newIndex) {
      newSelectedIndex = state.selectedQuestionIndex + 1;
    } else if (state.selectedQuestionIndex > oldIndex && state.selectedQuestionIndex <= newIndex) {
      newSelectedIndex = state.selectedQuestionIndex - 1;
    }

    state = state.copyWith(
      quizModel: updatedQuizModel,
      selectedQuestionIndex: newSelectedIndex,
    );
  }

  // Select a question for editing
  void selectQuestion(int index) {
    if (index >= -1 && index < state.questions.length) {
      state = state.copyWith(selectedQuestionIndex: index);
    }
  }

  // Get the final quiz data as JSON
  Map<String, dynamic> getQuizJson() {
    return state.quizModel.toJson();
  }

  // Save the quiz to the provider
  Future<String> saveQuiz() async {
    final quizJson = getQuizJson();
    final quizProvider = _ref.read(quizProviderProvider);

    // Create a new quiz in the provider
    final quizId = await quizProvider.createQuiz(quizJson);

    return quizId;
  }
}
