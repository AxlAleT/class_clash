import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../providers/quiz_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/quiz/models/users/standard_user.dart';
import '../../../core/utils/dialog_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _quizIdController = TextEditingController();
  final _studentNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  bool _isJoinDialogOpen = false; // Track if join dialog is open

  @override
  void dispose() {
    _quizIdController.dispose();
    _studentNameController.dispose();
    super.dispose();
  }

  // Handle back button press
  Future<bool> _onWillPop() async {
    if (_isJoinDialogOpen) {
      // If dialog is open, close it and don't exit the app
      Navigator.of(context).pop();
      return false;
    } else {
      // If no dialog is open, show confirmation dialog
      return await DialogUtils.showConfirmationDialog(
        context: context,
        title: 'Exit App',
        content: 'Are you sure you want to exit the app?',
        confirmText: 'Exit',
        cancelText: 'Stay',
      );
    }
  }

  void _showStudentJoinDialog() {
    // Reset error message
    setState(() {
      _errorMessage = null;
      _isJoinDialogOpen = true; // Set dialog state to open
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join a Quiz'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _quizIdController,
                decoration: const InputDecoration(
                  labelText: 'Enter Quiz Code',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quiz code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _studentNameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _joinQuiz();
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    ).then((_) {
      // When dialog is closed, update the state
      setState(() {
        _isJoinDialogOpen = false;
      });
    });
  }

  void _joinQuiz() {
    final quizId = _quizIdController.text.trim();
    final studentName = _studentNameController.text.trim();

    // Check if quiz exists using the QuizProvider
    final quizData = ref.watch(quizzesProvider);

    quizData.when(
      data: (quizzes) {
        final quizExists = quizzes.any((quiz) => quiz['id'] == quizId);

        if (!quizExists) {
          setState(() {
            _errorMessage = 'Quiz not found. Please check the code and try again.';
          });
          // Force dialog to rebuild with the error message
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Join a Quiz'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _quizIdController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Quiz Code',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quiz code';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _studentNameController,
                      decoration: const InputDecoration(
                        labelText: 'Your Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _joinQuiz();
                    }
                  },
                  child: const Text('Join'),
                ),
              ],
            ),
          );
          return;
        }

        // Generate a unique ID for the student
        final uuid = const Uuid();
        final studentId = uuid.v4();

        // Create a standard user for the student
        final student = StandardUser.guest(
          displayName: studentName,
        );

        // Close dialog
        Navigator.pop(context);

        // Navigate to the quiz play screen with the quiz ID
        context.go('/quiz/play/$quizId', extra: student);
      },
      loading: () {
        setState(() {
          _errorMessage = 'Loading quiz data, please wait...';
        });
      },
      error: (error, stackTrace) {
        setState(() {
          _errorMessage = 'Error loading quiz data: $error';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Add WillPopScope to handle back button
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Image.asset(
                    'lib/assets/app_icon.png',
                    width: 64,
                    height: 64,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 32),

                // App Title
                Text(
                  'Class Clash',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 16),

                // App Description
                Text(
                  'Make learning fun with interactive quizzes and games!',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 64),

                // Teacher Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to login screen instead of directly to quizzes
                      context.go('/login');
                    },
                    icon: const Icon(Icons.person),
                    label: const Text(
                      'Enter as Teacher',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Student Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _showStudentJoinDialog,
                    icon: const Icon(Icons.people),
                    label: const Text(
                      'Enter as Student',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const Spacer(),

                // Version info
                Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
