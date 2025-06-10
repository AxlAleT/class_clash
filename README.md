# class_clash

A kahoot like application

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Quiz Creation Feature Notes

The quiz creation feature (located in `lib/features/quiz_creation/`) is currently implemented as a conceptual model primarily designed for simulating the logic of quiz creation flows in a pure Dart environment.

Key aspects:
- **Conceptual Simulation:** The screens (`QuizPreviewScreen`, `AddQuestionScreen`) and widgets use `print` statements to simulate UI rendering and navigation rather than actual Flutter UI widgets.
- **MCQ Support:** The feature fully supports the creation and preview of Multiple Choice Questions (MCQs).
- **Incomplete Question Types:** While the `QuestionTypeSelector` shows options for 'True/False' and 'Short Answer' questions, the corresponding `QuestionBuilder` implementations for these types are not yet available. Therefore, the quiz creation is only functionally complete for MCQs.
- **Execution via `main()`:** The primary way to explore this conceptual feature is by running the `main()` functions within the screen files (e.g., `lib/features/quiz_creation/screens/add_question_screen.dart`). These `main` functions demonstrate the creation and flow of quiz data.
