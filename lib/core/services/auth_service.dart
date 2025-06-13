import 'package:flutter/material.dart';
import '../models/user.dart';
import '../../features/quiz/models/users/standard_user.dart';

class AuthService {
  // Mock users for testing authentication
  final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': 'teacher_001',
      'email': 'teacher@example.com',
      'password': 'password123',
      'displayName': 'Professor Smith',
      'userType': 'Teacher',
    },
    {
      'id': 'teacher_002',
      'email': 'admin@classdash.com',
      'password': 'admin123',
      'displayName': 'Admin Johnson',
      'userType': 'Teacher',
    },
  ];

  // Login method that returns a User if credentials are correct
  Future<User?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Find user with matching email and password
    final userMap = _mockUsers.firstWhere(
      (user) => user['email'] == email && user['password'] == password,
      orElse: () => {},
    );

    if (userMap.isEmpty) {
      return null; // Authentication failed
    }

    // Create a StandardUser from the map data
    return StandardUser(
      id: userMap['id'],
      displayName: userMap['displayName'],
      joinedAt: DateTime.now(),
      metadata: {'email': userMap['email'], 'userType': userMap['userType']},
      avatarColor: Colors.orange,
    );
  }

  // Check if user is currently authenticated
  Future<bool> isAuthenticated() async {
    // In a real app, this would check token validity, etc.
    // For now, we'll just use a simulated check
    return false;
  }

  // Log out the current user
  Future<void> logout() async {
    // In a real app, this would clear tokens, etc.
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
