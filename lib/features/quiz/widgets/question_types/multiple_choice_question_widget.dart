import 'package:flutter/material.dart';
import '../../models/questions/multiple_choice_question.dart';
import '../../utils/quiz_notifications.dart';

class MultipleChoiceQuestionWidget extends StatefulWidget {
  final MultipleChoiceQuestion question;

  const MultipleChoiceQuestionWidget({super.key, required this.question});

  @override
  State<MultipleChoiceQuestionWidget> createState() =>
      _MultipleChoiceQuestionWidgetState();
}

class _MultipleChoiceQuestionWidgetState
    extends State<MultipleChoiceQuestionWidget> {
  List<int> selectedIndices = [];

  @override
  void initState() {
    super.initState();
    selectedIndices = List.from(widget.question.selectedIndices);
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
                  child: CheckboxListTile(
                    title: Text(widget.question.options[index]),
                    value: selectedIndices.contains(index),
                    activeColor: Colors.blue,
                    checkColor: Colors.white,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          if (!selectedIndices.contains(index)) {
                            selectedIndices.add(index);
                          }
                        } else {
                          selectedIndices.remove(index);
                        }
                        // Update the question's selectedIndices
                        widget.question.selectedIndices = List.from(selectedIndices);
                      });
                    },
                    secondary: CircleAvatar(
                      backgroundColor: selectedIndices.contains(index)
                          ? Colors.blue
                          : Colors.grey.shade200,
                      child: selectedIndices.contains(index)
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
            onPressed: selectedIndices.isEmpty
                ? null // Disable if nothing selected
                : () {
                    // Only dispatch notification when user confirms
                    AnswerNotification(List.from(selectedIndices))
                        .dispatch(context);
                  },
            child: const Text(
              'Submit Answer',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Center(
            child: Text(
              'Selected ${selectedIndices.length} of ${widget.question.options.length} options',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
