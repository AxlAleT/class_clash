// This is a conceptual Flutter widget.
// In a real Flutter app, this would import 'package:flutter/material.dart';

class QuestionTypeSelector {
  // In a real Flutter app, this would be a StatefulWidget or StatelessWidget

  final List<String> availableTypes;
  final Function(String) onTypeSelected; // Callback when a type is selected
  String currentSelectedType;

  QuestionTypeSelector({
    required this.availableTypes,
    required this.onTypeSelected,
    String? initialType,
  }) : currentSelectedType = initialType ?? (availableTypes.isNotEmpty ? availableTypes.first : '') {
    if (availableTypes.isEmpty) {
      print("Warning: QuestionTypeSelector created with no available types.");
    }
  }

  // Conceptual representation of building the UI
  void build() {
    print("Building QuestionTypeSelector UI...");
    print("Available question types: $availableTypes");
    // In a real UI, this would be a dropdown, a list of buttons, or similar.
    // For simulation, we can just print the types and allow programmatic selection.
    if (currentSelectedType.isNotEmpty) {
      print("Current selected type: $currentSelectedType");
    } else if (availableTypes.isNotEmpty) {
      // If no initial type, select the first one by default for simulation
      selectType(availableTypes.first);
    }
  }

  // Method to simulate selecting a question type (e.g., user taps a button)
  void selectType(String type) {
    if (availableTypes.contains(type)) {
      currentSelectedType = type;
      print("QuestionTypeSelector: Type '$type' selected.");
      onTypeSelected(type); // Call the callback
    } else {
      print("QuestionTypeSelector: Attempted to select invalid type '$type'.");
    }
  }
}

// Example of how this widget might be used (conceptual)
void main() {
  final selector = QuestionTypeSelector(
    availableTypes: ['Multiple Choice', 'True/False', 'Short Answer'],
    onTypeSelected: (String selectedType) {
      print("Callback: User selected $selectedType");
      // In a real app, this callback would trigger updating the QuestionBuilder
      // in the AddQuestionScreen.
    },
    initialType: 'Multiple Choice',
  );

  selector.build(); // Simulate building the UI

  // Simulate user interactions
  print("\nSimulating user selecting 'True/False':");
  selector.selectType('True/False');

  print("\nSimulating user selecting 'Short Answer':");
  selector.selectType('Short Answer');

  print("\nSimulating user selecting an invalid type:");
  selector.selectType('Essay'); // This type is not in availableTypes
}
