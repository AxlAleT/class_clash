import 'package:flutter/material.dart';
import '../../models/question_model.dart';
import '../../models/mcq_question_model.dart';
import 'question_builder.dart'; // QuestionBuilderState is now in this file

class MCQBuilder extends QuestionBuilder {
  final MCQQuestion? existingQuestion;

  const MCQBuilder({
    Key? key,
    required super.onQuestionCreated,
    this.existingQuestion,
  }) : super(key: key);

  @override
  State<MCQBuilder> createState() => _MCQBuilderState();

  @override
  MCQQuestion getQuestion() {
    // This method is now more of a conceptual placeholder from the abstract class.
    // The actual question creation and callback invocation will happen within the State.
    // It might be good to have the State object accessible if we need to call this from outside,
    // or this method could be removed from the abstract class if onQuestionCreated is sufficient.
    // For now, let's throw an UnimplementedError as it shouldn't be called directly like this anymore.
    throw UnimplementedError(
        "getQuestion() should be called from within the State's save method.");
  }
}

class _MCQBuilderState extends QuestionBuilderState<MCQBuilder> { // Extend QuestionBuilderState
  late TextEditingController _questionController;
  final List<TextEditingController> _optionControllers = [];
  int? _correctAnswerIndex;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _questionController =
        TextEditingController(text: widget.existingQuestion?.questionText ?? '');

    if (widget.existingQuestion != null) {
      _correctAnswerIndex = widget.existingQuestion!.correctAnswerIndex;
      for (var option in widget.existingQuestion!.options) {
        _addOptionController(optionText: option);
      }
    } else {
      // Start with two empty options for a new question
      _addOptionController();
      _addOptionController();
    }
  }

  void _addOptionController({String optionText = ''}) {
    final controller = TextEditingController(text: optionText);
    _optionControllers.add(controller);
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _addOptionController();
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length <= 2) {
      // Show a snackbar or some feedback: Cannot have less than 2 options
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Cannot have less than two options.")));
      return;
    }
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
      if (_correctAnswerIndex == index) {
        _correctAnswerIndex = null; // Or 0, depending on desired behavior
      } else if (_correctAnswerIndex != null && _correctAnswerIndex! > index) {
        _correctAnswerIndex = _correctAnswerIndex! - 1;
      }
    });
  }

  void _setCorrectAnswer(int? index) {
    setState(() {
      _correctAnswerIndex = index;
    });
  }

  void _saveQuestion() {
    if (_formKey.currentState!.validate()) {
      if (_correctAnswerIndex == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a correct answer.')),
        );
        return;
      }

      final options = _optionControllers
          .map((controller) => controller.text.trim())
          .toList();

      if (options.any((option) => option.isEmpty)) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Option text cannot be empty.')),
        );
        return;
      }

      final question = MCQQuestion(
        id: widget.existingQuestion?.id ?? UniqueKey().toString(), // Generate ID if new
        questionText: _questionController.text.trim(),
        options: options,
        correctAnswerIndex: _correctAnswerIndex!,
      );
      widget.onQuestionCreated(question);
    }
  }

  // Implementation for the abstract method in QuestionBuilderState
  @override
  Question getQuestion() {
    if (_correctAnswerIndex == null || _optionControllers.any((c) => c.text.trim().isEmpty) || _questionController.text.trim().isEmpty) {
      throw Exception("Cannot get question when form is invalid or not complete.");
    }
    return MCQQuestion(
      id: widget.existingQuestion?.id ?? UniqueKey().toString(), // Generate ID if new
      questionText: _questionController.text.trim(),
      options: _optionControllers.map((controller) => controller.text.trim()).toList(),
      correctAnswerIndex: _correctAnswerIndex!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Question Text',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the question text.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text('Options:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_optionControllers.isEmpty)
              const Text('Please add some options.'),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _optionControllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _optionControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Option ${index + 1}',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Option text cannot be empty.';
                            }
                            return null;
                          },
                        ),
                      ),
                      RadioListTile<int?>(
                        value: index,
                        groupValue: _correctAnswerIndex,
                        onChanged: _setCorrectAnswer,
                        title: const Text('Correct'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeOption(index),
                        tooltip: 'Remove Option',
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add),
              label: const Text('Add Option'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveQuestion,
              child: const Text('Save Question'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Make button wider
              ),
            ),
          ],
        ),
      ),
    );
  }
}
