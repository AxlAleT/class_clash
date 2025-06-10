import 'package:flutter/material.dart';
import '../../models/question_model.dart';
import '../../models/true_false_question_model.dart';
import 'question_builder.dart';
// Assuming QuestionBuilderState is in add_question_screen.dart for now
// Ideally, it should be in its own file or in question_builder.dart
import '../../screens/add_question_screen.dart' show QuestionBuilderState;


class TrueFalseBuilder extends QuestionBuilder {
  final TrueFalseQuestionModel? existingQuestion;

  const TrueFalseBuilder({
    Key? key,
    required super.onQuestionCreated,
    this.existingQuestion,
  }) : super(key: key);

  @override
  State<TrueFalseBuilder> createState() => _TrueFalseBuilderState();

  @override
  Question getQuestion() {
    // This method is now more of a conceptual placeholder from the abstract class.
    // The actual question creation and callback invocation will happen within the State's save method.
    throw UnimplementedError(
        "getQuestion() should be called from within the State's save method of TrueFalseBuilder.");
  }
}

class _TrueFalseBuilderState extends QuestionBuilderState<TrueFalseBuilder> {
  late TextEditingController _questionController;
  bool? _correctAnswer;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(
        text: widget.existingQuestion?.questionText ?? '');
    _correctAnswer = widget.existingQuestion?.correctAnswer;
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _saveQuestion() {
    if (_formKey.currentState!.validate()) {
      if (_correctAnswer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select either True or False.')),
        );
        return;
      }

      final question = TrueFalseQuestionModel(
        id: widget.existingQuestion?.id ?? UniqueKey().toString(), // Generate ID if new
        questionText: _questionController.text.trim(),
        correctAnswer: _correctAnswer!,
      );
      widget.onQuestionCreated(question);
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('True/False question saved successfully!')),
      );
    }
  }

  @override
  Question getQuestion() {
     if (_correctAnswer == null) {
        throw Exception("Cannot get question when correct answer is not selected.");
     }
     return TrueFalseQuestionModel(
        id: widget.existingQuestion?.id ?? UniqueKey().toString(), // Generate ID if new
        questionText: _questionController.text.trim(),
        correctAnswer: _correctAnswer!,
      );
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                hintText: 'Enter the true/false statement',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the question text.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text('Correct Answer:', style: Theme.of(context).textTheme.titleMedium),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('True'),
                    value: true,
                    groupValue: _correctAnswer,
                    onChanged: (bool? value) {
                      setState(() {
                        _correctAnswer = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('False'),
                    value: false,
                    groupValue: _correctAnswer,
                    onChanged: (bool? value) {
                      setState(() {
                        _correctAnswer = value;
                      });
                    },
                  ),
                ),
              ],
            ),
             if (_correctAnswer == null) // Show validation error message for RadioListTile if needed
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 0), // Adjust padding as needed
                child: Text(
                  'Please select an answer.', // This message is shown if _formKey.currentState.validate() is called and this field is not handled by a FormField
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveQuestion,
              child: const Text('Save Question'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
