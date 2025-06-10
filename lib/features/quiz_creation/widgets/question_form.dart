import 'package:flutter/material.dart';
import 'package:class_clash/features/quiz_creation/models/questions/question_model.dart';
import 'package:class_clash/features/quiz_creation/models/questions/single_choice_question.dart';
import 'package:class_clash/features/quiz_creation/models/questions/multiple_choice_question.dart';
import 'package:class_clash/features/quiz_creation/models/questions/true_false_question.dart';
import 'package:uuid/uuid.dart';

class QuestionForm extends StatefulWidget {
  final String questionType;
  final QuestionModel? questionToEdit;
  final Function(QuestionModel) onSave;

  const QuestionForm({
    super.key,
    required this.questionType,
    this.questionToEdit,
    required this.onSave,
  });

  @override
  State<QuestionForm> createState() => _QuestionFormState();
}

class _QuestionFormState extends State<QuestionForm> {
  final _formKey = GlobalKey<FormState>();

  // Common fields for all question types
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late int _points;
  late int _timeLimit;

  // Fields for choice-based questions
  List<TextEditingController> _optionControllers = [];
  List<int> _correctOptionIndices = [];
  bool _allowMultipleSelections = false;
  bool _randomizeOptions = false;

  @override
  void initState() {
    super.initState();
    _initializeFormFields();
  }

  @override
  void didUpdateWidget(QuestionForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questionType != widget.questionType ||
        oldWidget.questionToEdit != widget.questionToEdit) {
      _initializeFormFields();
    }
  }

  void _initializeFormFields() {
    // Initialize with default values or from existing question
    if (widget.questionToEdit != null) {
      _titleController = TextEditingController(text: widget.questionToEdit!.title);
      _descriptionController = TextEditingController(text: widget.questionToEdit!.description ?? '');
      _points = widget.questionToEdit!.points;
      _timeLimit = widget.questionToEdit!.timeLimit;

      // Handle specific question type data
      if (widget.questionToEdit is SingleChoiceQuestionModel) {
        final question = widget.questionToEdit as SingleChoiceQuestionModel;
        _initializeChoiceOptions(
          question.options,
          question.correctOptionIndices,
          question.allowMultipleSelections,
          question.randomizeOptions,
        );
      } else if (widget.questionToEdit is MultipleChoiceQuestionModel) {
        final question = widget.questionToEdit as MultipleChoiceQuestionModel;
        _initializeChoiceOptions(
          question.options,
          question.correctOptionIndices,
          question.allowMultipleSelections,
          question.randomizeOptions,
        );
      } else if (widget.questionToEdit is TrueFalseQuestionModel) {
        final question = widget.questionToEdit as TrueFalseQuestionModel;
        _correctOptionIndices = question.correctOptionIndices;
      }
    } else {
      // Default values for new question
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _points = 10;
      _timeLimit = 30;

      // Initialize based on question type
      if (widget.questionType == 'single_choice' || widget.questionType == 'multiple_choice') {
        _initializeChoiceOptions(
          ['', '', '', ''],
          [],
          widget.questionType == 'multiple_choice',
          false,
        );
      } else if (widget.questionType == 'true_false') {
        _correctOptionIndices = [0]; // Default to "True"
      }
    }
  }

  void _initializeChoiceOptions(
    List<String> options,
    List<int> correctIndices,
    bool allowMultiple,
    bool randomize,
  ) {
    // Clear existing controllers
    for (var controller in _optionControllers) {
      controller.dispose();
    }

    // Create new controllers
    _optionControllers = options.map((option) =>
      TextEditingController(text: option)
    ).toList();

    _correctOptionIndices = List<int>.from(correctIndices);
    _allowMultipleSelections = allowMultiple;
    _randomizeOptions = randomize;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Common fields for all question types
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Question Text',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a question';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description/Hint (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Points and time limit
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _points.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Points',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Enter a number';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _points = int.tryParse(value) ?? _points;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _timeLimit.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Time Limit (seconds)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Enter a number';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _timeLimit = int.tryParse(value) ?? _timeLimit;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Type-specific form fields
            _buildQuestionTypeSpecificFields(),

            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveQuestion,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    widget.questionToEdit != null ? 'Update Question' : 'Add Question',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionTypeSpecificFields() {
    switch (widget.questionType) {
      case 'single_choice':
      case 'multiple_choice':
        return _buildChoiceQuestionFields();
      case 'true_false':
        return _buildTrueFalseQuestionFields();
      default:
        return const Center(
          child: Text('Unsupported question type'),
        );
    }
  }

  Widget _buildChoiceQuestionFields() {
    final isMultipleChoice = widget.questionType == 'multiple_choice';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Options',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        // Option list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _optionControllers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  // Checkbox/Radio for correct answer
                  if (isMultipleChoice)
                    Checkbox(
                      value: _correctOptionIndices.contains(index),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            if (!_correctOptionIndices.contains(index)) {
                              _correctOptionIndices.add(index);
                            }
                          } else {
                            _correctOptionIndices.remove(index);
                          }
                        });
                      },
                    )
                  else
                    Radio<int>(
                      value: index,
                      groupValue: _correctOptionIndices.isNotEmpty ? _correctOptionIndices[0] : null,
                      onChanged: (value) {
                        setState(() {
                          _correctOptionIndices = [value!];
                        });
                      },
                    ),

                  // Option text field
                  Expanded(
                    child: TextFormField(
                      controller: _optionControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Option ${index + 1}',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Remove option button
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _optionControllers.length > 2
                        ? () {
                            setState(() {
                              _optionControllers[index].dispose();
                              _optionControllers.removeAt(index);

                              // Update correct indices
                              _correctOptionIndices = _correctOptionIndices
                                  .where((i) => i != index)
                                  .map((i) => i > index ? i - 1 : i)
                                  .toList();
                            });
                          }
                        : null,
                  ),
                ],
              ),
            );
          },
        ),

        // Add option button
        TextButton.icon(
          onPressed: () {
            setState(() {
              _optionControllers.add(TextEditingController());
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Option'),
        ),

        const SizedBox(height: 16),

        // Additional settings for choice questions
        if (isMultipleChoice)
          SwitchListTile(
            title: const Text('Allow Multiple Selections'),
            value: _allowMultipleSelections,
            onChanged: (value) {
              setState(() {
                _allowMultipleSelections = value;
              });
            },
          ),

        SwitchListTile(
          title: const Text('Randomize Options'),
          value: _randomizeOptions,
          onChanged: (value) {
            setState(() {
              _randomizeOptions = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTrueFalseQuestionFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Correct Answer',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        // True/False radio buttons
        RadioListTile<int>(
          title: const Text('True'),
          value: 0,
          groupValue: _correctOptionIndices.isNotEmpty ? _correctOptionIndices[0] : null,
          onChanged: (value) {
            setState(() {
              _correctOptionIndices = [value!];
            });
          },
        ),
        RadioListTile<int>(
          title: const Text('False'),
          value: 1,
          groupValue: _correctOptionIndices.isNotEmpty ? _correctOptionIndices[0] : null,
          onChanged: (value) {
            setState(() {
              _correctOptionIndices = [value!];
            });
          },
        ),
      ],
    );
  }

  void _saveQuestion() {
    if (_formKey.currentState!.validate()) {
      // Create question based on type
      late QuestionModel question;

      // Generate a unique ID for new questions
      final id = widget.questionToEdit?.id ?? const Uuid().v4();

      switch (widget.questionType) {
        case 'single_choice':
          question = SingleChoiceQuestionModel(
            id: id,
            title: _titleController.text,
            description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
            points: _points,
            timeLimit: _timeLimit,
            options: _optionControllers.map((c) => c.text).toList(),
            correctOptionIndices: _correctOptionIndices,
            allowMultipleSelections: false,
            randomizeOptions: _randomizeOptions,
          );
          break;

        case 'multiple_choice':
          question = MultipleChoiceQuestionModel(
            id: id,
            title: _titleController.text,
            description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
            points: _points,
            timeLimit: _timeLimit,
            options: _optionControllers.map((c) => c.text).toList(),
            correctOptionIndices: _correctOptionIndices,
            allowMultipleSelections: _allowMultipleSelections,
            randomizeOptions: _randomizeOptions,
          );
          break;

        case 'true_false':
          question = TrueFalseQuestionModel(
            id: id,
            title: _titleController.text,
            description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
            points: _points,
            timeLimit: _timeLimit,
            correctOptionIndices: _correctOptionIndices,
          );
          break;

        default:
          throw UnimplementedError('Unsupported question type: ${widget.questionType}');
      }

      // Call the onSave callback
      widget.onSave(question);
    }
  }
}
