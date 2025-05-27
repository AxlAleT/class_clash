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
│ │ ├── quiz_completion_widget.dart
│ │ ├── question_types/
│ │ │ ├── multiple_choice_question_widget.dart
│ │ │ ├── single_choice_question_widget.dart
│ │ │ └── ...
│ │ └── gamification/
│ │ │ ├── leaderboard_widget.dart
│ │ │ └── ...
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

**Overview:** The diagram illustrates how questions and gamification strategies are created and utilized.
The `QuizPlayScreen` (not explicitly shown in this part of the diagram but is the consumer)
orchestrates the display of questions and gamification elements.

**Question Handling:**
`QuestionFactory` is responsible for two main tasks:
1. Creating `AbstractQuestion` instances (data models like `MCQ`, `SingleChoiceQuestion`).
2. Creating specific `QuestionWidget` instances (like `MultipleChoiceQuestionWidget`) based on the question type.
The `QuizPlayScreen` uses the factory to get the appropriate widget for the current question model.

**Gamification Handling:**
`GamificationFactory` creates `AbstractGamification` strategy instances (like `PointsStrategy`, `LeaderboardStrategy`).
Each strategy, via its `buildWidget(context)` method, can provide a UI component (e.g., `LeaderboardWidget`).
The `QuizPlayScreen` calls this method on active strategies to render their UI.

**Diagram:**

┌─────────────────────────────┐ ┌─────────────────────────────┐
│       QuestionFactory       │ │    GamificationFactory      │
├─────────────────────────────┤ ├─────────────────────────────┤
│+ createQuestion(type, data) │ │+ createStrategy(type, data) │
│+ createQuestionWidget(q)    │ │                             │
└───────────┬────┬────────────┘ └───────────┬─────────────────┘
            │    │ creates                  │
creates     │    │                          │ creates
▼           │    └─────► ┌────────────────┐ ▼
┌───────────┴───┐        │ QuestionWidget │ ┌───────────────────────────┐
│AbstractQuestion │◄──data─┤ (e.g., MCQW) │ │ AbstractGamification    │
├─────────────────┤        └────────────────┘ ├───────────────────────────┤
│+ validate(answer)│                         │+ applyStrategy(...)     │
│+ questionType   │                         │+ buildWidget(context)   │
└──────┬──────────┘                         └───────────┬───────────────┘
       │ implements                                     │ implements
┌──────┴───────┬───────┐                         ┌──────┴───────┬──────────┐
▼              ▼       ▼                         ▼              ▼          ▼
┌─────┐   ┌──────────┐┌─────┐             ┌───────────┐ ┌───────────────────┐┌─────┐
│ MCQ │   │SingleChoice││ ... │             │ PointsStrat││LeaderboardStrategy││ ... │
└─────┘   └──────────┘└─────┘             └───────────┘└───────────────────┘└─────┘
                                                                 │ builds
                                                                 ▼
                                                      ┌───────────────────┐
                                                      │LeaderboardWidget  │
                                                      └───────────────────┘

**Note:** `MCQW` is `MultipleChoiceQuestionWidget`. `AbstractQuestion` models (like `MCQ`) are primarily data containers with validation logic. Their UI is handled by separate `QuestionWidget`s. `QuizPlayScreen` uses `QuestionFactory` to get the `QuestionWidget` for a given `AbstractQuestion` and uses `AbstractGamification.buildWidget()` to get gamification UI.

## Design Patterns Used

1.  **Factory Method**:
    *   Used by `QuestionFactory` to create different types of `AbstractQuestion` data models.
    *   Extended in `QuestionFactory` to also create corresponding `QuestionWidget` UI components.
    *   Used by `GamificationFactory` to create different `AbstractGamification` strategies.
2.  **Repository Pattern**: For data access independent of the data source (e.g., `QuizRepository`).
3.  **Provider Pattern**: Using Riverpod for state management throughout the application.
4.  **Strategy Pattern**: For implementing different gamification mechanics (`AbstractGamification` and its concrete implementations like `PointsStrategy`, `LeaderboardStrategy`).
5.  **Single Responsibility Principle (SRP)**:
    *   More strongly enforced by separating data models and core logic (e.g., `AbstractQuestion`, `MultipleChoiceQuestion`) from their UI representations (e.g., `MultipleChoiceQuestionWidget`).
    *   The `QuizCompletionWidget` also encapsulates the UI and logic for the quiz completion screen, separating it from the `QuizPlayScreen`.
    *   Gamification strategies (`AbstractGamification`) are responsible for their logic, and now also for providing their specific UI components via `buildWidget(context)`.