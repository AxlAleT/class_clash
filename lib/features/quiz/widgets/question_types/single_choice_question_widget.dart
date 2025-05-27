import 'package:flutter/material.dart';
import '../../models/questions/single_choice_question.dart';
import '../../utils/quiz_notifications.dart';

class SingleChoiceQuestionWidget extends StatefulWidget {
  final SingleChoiceQuestion question;

  const SingleChoiceQuestionWidget({super.key, required this.question});

  @override
  State<SingleChoiceQuestionWidget> createState() =>
      _SingleChoiceQuestionWidgetState();
}

class _SingleChoiceQuestionWidgetState
    extends State<SingleChoiceQuestionWidget> {
  int? selectedOptionIndex;

  @override
  void initState() {
    super.initState();
    // Initialize selectedOptionIndex from the question's current state if needed
    // Assuming SingleChoiceQuestion might store its last selected index or it's always null initially for the widget
    if (widget.question.selectedIndices.isNotEmpty) {
      selectedOptionIndex = widget.question.selectedIndices.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (widget.question.description != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(widget.question.description!,
                style: const TextStyle(fontSize: 16)),
          ),
        const SizedBox(height: 16),

        // Scrollable container for options
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(
                widget.question.options.length,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: RadioListTile<int>(
                    title: Text(widget.question.options[index]),
                    value: index,
                    groupValue: selectedOptionIndex,
                    activeColor: Colors.blue,
                    onChanged: (value) {
                      setState(() {
                        selectedOptionIndex = value;
                        // Update the question's selectedIndices
                        widget.question.selectedIndices.clear();
                        if (value != null) {
                          widget.question.selectedIndices.add(value);
                        }
                      });
                    },
                    secondary: CircleAvatar(
                      backgroundColor: selectedOptionIndex == index
                          ? Colors.blue
                          : Colors.grey.shade200,
                      child: selectedOptionIndex == index
                          ? const Icon(Icons.check, color: Colors.white)
                          : Text(String.fromCharCode(
                              65 + index)), // A, B, C, etc.
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Confirmation button
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 48),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: selectedOptionIndex == null
                ? null // Disable if nothing selected
                : () {
                    // Only dispatch notification when user confirms
                    if (selectedOptionIndex != null) {
                      AnswerNotification([selectedOptionIndex!])
                          .dispatch(context);
                    }
                  },
            child: const Text(
              'Submit Answer',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
