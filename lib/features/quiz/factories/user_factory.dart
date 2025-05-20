import '../../../core/models/user.dart';
import '../models/users/standard_user.dart';

/// Factory class responsible for creating User objects
class UserFactory {
  static final UserFactory _instance = UserFactory._internal();
  
  // Registry of user creation functions by type
  final Map<String, User Function(Map<String, dynamic>)> _userCreators = {};
  
  // Private constructor
  UserFactory._internal() {
    // Register built-in user types
    registerUserType('standard', StandardUser.fromJson);
    registerUserType('default', StandardUser.fromJson); // Alias for standard
  }
  
  // Singleton instance
  factory UserFactory() => _instance;
  
  /// Register a user type with its creator function
  void registerUserType(String type, User Function(Map<String, dynamic>) creator) {
    _userCreators[type] = creator;
  }
  
  /// Create a user from its JSON representation
  User createFromJson(Map<String, dynamic> json) {
    final String userType = json['type'] as String? ?? 
                            json['userType'] as String? ?? 
                            'default';
    
    if (!_userCreators.containsKey(userType)) {
      throw Exception('Unknown user type: $userType');
    }
    
    return _userCreators[userType]!(json);
  }
  
  /// Create multiple users from a list of JSON objects
  List<User> createManyFromJson(List<dynamic> jsonList) {
    return jsonList
        .cast<Map<String, dynamic>>()
        .map((json) => createFromJson(json))
        .toList();
  }
  
  /// Get available user types
  List<String> getAvailableTypes() => _userCreators.keys.toList();
  
  /// Check if a user type is registered
  bool hasType(String type) => _userCreators.containsKey(type);
}
