import 'package:flutter/material.dart';

class QuestionTypeSelector extends StatefulWidget {
  final List<String> availableTypes;
  final Function(String) onTypeSelected;
  final String? initialType;

  const QuestionTypeSelector({
    Key? key,
    required this.availableTypes,
    required this.onTypeSelected,
    this.initialType,
  }) : super(key: key);

  @override
  State<QuestionTypeSelector> createState() => _QuestionTypeSelectorState();
}

class _QuestionTypeSelectorState extends State<QuestionTypeSelector> {
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _initializeSelectedType();
  }

  void _initializeSelectedType() {
    if (widget.initialType != null && widget.availableTypes.contains(widget.initialType!)) {
      _selectedType = widget.initialType!;
    } else if (widget.availableTypes.isNotEmpty) {
      _selectedType = widget.availableTypes.first;
    } else {
      // Handle case where availableTypes is empty or initialType is invalid
      // This ideally shouldn't happen if parent provides valid data.
      // For robustness, we could set it to a placeholder or throw an error.
      // For now, if types are available, use first, otherwise this widget will be problematic.
      _selectedType = ''; // Or handle error appropriately
      if (widget.availableTypes.isEmpty) {
          print("Error: QuestionTypeSelector has no available types to select.");
      }
    }
  }

  @override
  void didUpdateWidget(QuestionTypeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the initialType provided by the parent changes and it's different from the current one
    if (widget.initialType != null &&
        widget.availableTypes.contains(widget.initialType!) &&
        widget.initialType != _selectedType) {
      setState(() {
        _selectedType = widget.initialType!;
      });
      // No need to call widget.onTypeSelected here as this is an external change,
      // the parent already knows and triggered this. Parent should handle consequences.
    } else if (widget.initialType == null && _selectedType != widget.availableTypes.first && widget.availableTypes.isNotEmpty) {
      // If initialType becomes null, and current type is not the default, reset to default
      // This might be an edge case depending on desired behavior.
      // Generally, parent controls initialType. If it's removed, behavior might need clarification.
      // For now, let's assume parent manages this by providing a valid initialType or none.
      // If available types change and _selectedType is no longer valid, reset.
      if (!widget.availableTypes.contains(_selectedType)) {
        setState(() {
          _selectedType = widget.availableTypes.first;
        });
        widget.onTypeSelected(_selectedType);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.availableTypes.isEmpty) {
      return const Text("No question types available.");
    }
    // Ensure _selectedType is valid, especially after potential list changes
    // This check is crucial if availableTypes can change dynamically and _selectedType becomes invalid
    if (!widget.availableTypes.contains(_selectedType) && widget.availableTypes.isNotEmpty) {
        _selectedType = widget.availableTypes.first; // Fallback to the first available type
    }


    return DropdownButtonFormField<String>(
      value: _selectedType,
      decoration: const InputDecoration(
        labelText: 'Select Question Type',
        border: OutlineInputBorder(),
      ),
      items: widget.availableTypes.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedType = newValue;
          });
          widget.onTypeSelected(newValue);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a question type.';
        }
        return null;
      },
    );
  }
}
