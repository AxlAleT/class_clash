# Quiz Application Architecture with Flutter

## General Structure

The application will follow a modular architecture based on the Factory Method pattern, using
Riverpod for state management and go_router for navigation. The proposed structure allows easy
addition of new question types and gamification strategies without modifying existing code.

lib/
├── main.dart
├── app.dart
├── config/
│ ├── routes.dart
│ ├── theme.dart
│ └── constants.dart
├── core/
│ ├── models/
│ │ ├── question.dart
│ │ ├── gamification_strategy.dart
│ │ ├── quiz.dart
│ │ └── user.dart
│ ├── services/
│ │ ├── auth_service.dart
│ │ ├── storage_service.dart
│ │ └── analytics_service.dart
│ └── utils/
│ ├── extensions.dart
│ └── validators.dart
├── features/
│ ├── auth/
│ │ ├── controllers/
│ │ ├── repositories/
│ │ ├── screens/
│ │ └── widgets/
│ ├── quiz/
│ │ ├── controllers/
│ │ │ ├── quiz_controller.dart
│ │ │ └── question_controller.dart
│ │ ├── factories/
│ │ │ ├── question_factory.dart
│ │ │ └── gamification_factory.dart
│ │ ├── models/
│ │ │ ├── questions/
│ │ │ │ ├── multiple_choice_question.dart
│ │ │ │ ├── true_false_question.dart
│ │ │ │ ├── short_answer_question.dart
│ │ │ │ └── ...
│ │ │ └── gamification/
│ │ │ ├── points_strategy.dart
│ │ │ ├── leaderboard_strategy.dart
│ │ │ └── ...
│ │ ├── repositories/
│ │ │ └── quiz_repository.dart
│ │ ├── screens/
│ │ │ ├── quiz_list_screen.dart
│ │ │ ├── quiz_creation_screen.dart
│ │ │ └── quiz_play_screen.dart
│ │ └── widgets/
│ │ ├── question_types/
│ │ │ ├── multiple_choice_widget.dart
│ │ │ ├── true_false_widget.dart
│ │ │ └── ...
│ │ └── gamification/
│ │ ├── leaderboard_widget.dart
│ │ ├── points_display_widget.dart
│ │ └── ...
│ └── profile/
│ ├── controllers/
│ ├── repositories/
│ ├── screens/
│ └── widgets/
└── providers/
├── app_providers.dart
├── auth_providers.dart
└── quiz_providers.dart

## Architecture Diagram

┌─────────────────────────────┐ ┌─────────────────────────────┐
│ QuestionFactory │ │ GamificationFactory │
├─────────────────────────────┤ ├─────────────────────────────┤
│ + createQuestion(type, data)│ │ + createStrategy(type, data)│
└───────────┬─────────────────┘ └───────────┬─────────────────┘
│ │
▼ ▼
┌─────────────────────────────┐ ┌─────────────────────────────┐
│ AbstractQuestion │ │ AbstractGamification │
├─────────────────────────────┤ ├─────────────────────────────┤
│ + render() │ │ + apply(quizState) │
│ + validate(answer) │ │ + getUI() │
└───────────┬─────────────────┘ └───────────┬─────────────────┘
│ │
┌───────┴───────┬───────┐ ┌───────┴───────┬───────┐
▼ ▼ ▼ ▼ ▼ ▼
┌─────────┐ ┌─────────┐ ┌─────┐ ┌─────────┐ ┌─────────┐ ┌─────┐
│ MCQ │ │ TrueFalse│ │ ... │ │ Points │ │Leaderboard│ │... │
└─────────┘ └─────────┘ └─────┘ └─────────┘ └─────────┘ └─────┘

## Design Patterns Used

1. **Factory Method**: For creating different question types and gamification strategies
2. **Repository Pattern**: For data access independent of the data source
3. **Provider Pattern**: Using Riverpod for state management
4. **Strategy Pattern**: For implementing different gamification mechanics