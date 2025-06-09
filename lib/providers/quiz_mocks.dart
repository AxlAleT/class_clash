// Mock quiz and user data for QuizProvider

final multipleChoiceQuestion1 = {
  'id': 'q1',
  'title': 'What is the capital of France?',
  'description': 'Choose the correct answer.',
  'points': 100,
  'timeLimit': 30,
  'questionType': 'single_choice',
  'metadata': {
    'options': ['London', 'Paris', 'Berlin', 'Rome'],
    'correctOptionIndices': [1], // Paris
    'allowMultipleSelections': false,
    'randomizeOptions': true,
  },
};

final multipleChoiceQuestion2 = {
  'id': 'q2',
  'title': 'Which programming languages are statically typed?',
  'description': 'Select all that apply.',
  'points': 200,
  'timeLimit': 45,
  'questionType': 'multiple_choice',
  'metadata': {
    'options': ['JavaScript', 'TypeScript', 'Python', 'Java', 'C++'],
    'correctOptionIndices': [1, 3, 4], // TypeScript, Java, C++
    'allowMultipleSelections': true,
    'randomizeOptions': true,
  },
};

final pointsStrategy = {
  'id': 'gs1',
  'name': 'Basic Points',
  'basePoints': 10,
  'speedBonusThreshold': 5,
  'speedBonusPoints': 5,
  'strategyType': 'PointsStrategy',
};

final quiz1 = {
  'id': 'quiz_001',
  'title': 'General Knowledge Quiz',
  'description': 'Test your knowledge on various topics.',
  'questions': [multipleChoiceQuestion1, multipleChoiceQuestion2],
  'gamificationStrategies': [pointsStrategy],
  'currentQuestionIndex': 0,
  'totalPoints': 0,
  'currentStreak': 0,
  'type': 'standard',
};

final quiz2 = {
  'id': 'quiz_002',
  'title': 'Dart Programming Basics',
  'description': 'Test your knowledge of Dart programming fundamentals.',
  'questions': [
    {
      'id': 'q3',
      'title': 'What keyword is used to declare a variable that can be assigned only once?',
      'description': 'Choose the correct Dart keyword.',
      'points': 100,
      'timeLimit': 30,
      'questionType': 'single_choice',
      'metadata': {
        'options': ['var', 'const', 'final', 'static'],
        'correctOptionIndices': [2], // final
        'allowMultipleSelections': false,
        'randomizeOptions': true,
      },
    }
  ],
  'gamificationStrategies': [pointsStrategy],
  'type': 'standard',
};

final user1 = {
  'id': 'user_001',
  'displayName': 'John Doe',
  'joinedAt': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
  'userType': 'StandardUser',
  'quizScores': {'quiz_001': 300},
  'quizCompletion': {'quiz_001': true},
};

final trueFalseQuestion1 = {
  "id": "tf001",
  "type": "true_false", // Corrected: "type" instead of "questionType" to match factory registration
  "title": "The sky is blue.",
  "description": "Is this statement true or false?",
  "points": 50,
  "timeLimit": 15,
  "metadata": {
    "correctOptionIndices": [0] // 0 for True, 1 for False
  }
};

final trueFalseQuestion2 = {
  "id": "tf002",
  "type": "true_false", // Corrected: "type" instead of "questionType"
  "title": "Flutter is a programming language.",
  "description": "Is this statement true or false?",
  "points": 50,
  "timeLimit": 15,
  "metadata": {
    "correctOptionIndices": [1] // 0 for True, 1 for False (Flutter is a UI toolkit)
  }
};

final trueFalseQuizSample = {
  'id': 'quiz_003',
  'title': 'True/False Challenge',
  'description': 'Test your knowledge with these true or false questions.',
  'questions': [trueFalseQuestion1, trueFalseQuestion2],
  // Assuming the same pointsStrategy can be reused or is optional
  // 'gamificationStrategies': [pointsStrategy],
  'currentQuestionIndex': 0,
  'totalPoints': 0,
  'currentStreak': 0,
  'type': 'standard',
};

final user2 = {
  'id': 'user_002',
  'displayName': 'Jane Smith',
  'joinedAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
  'userType': 'StandardUser',
  'quizScores': {'quiz_001': 250},
  'quizCompletion': {'quiz_001': true},
};

