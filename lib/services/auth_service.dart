// auth_service.dart
// Handles signup/login logic. This is the file to link for the
// "signup implementation" and "login implementation" checklist items.
//
// A hardcoded demo account (testuser / password123) always works, matching
// the original lab. Any account created via the Signup screen is persisted
// through StorageService, so it can also be used to log back in later —
// this doubles as a real demonstration of local storage persistence.

import 'storage_service.dart';

class AuthService {
  static const String demoUsername = 'testuser';
  static const String demoPassword = 'password123';

  /// Validates and registers a new user.
  /// Returns null on success, or an error message string on failure.
  static Future<String?> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    // ---------- Required-field validation ----------
    if (name.trim().isEmpty || username.trim().isEmpty) {
      return 'Name and username are required.';
    }
    if (email.trim().isEmpty) {
      return 'Email is required.';
    }
    if (password.trim().isEmpty) {
      return 'Password is required.';
    }

    final users = await StorageService.getUsers();
    if (users.containsKey(username) || username == demoUsername) {
      return 'That username is already taken.';
    }

    users[username] = password;
    await StorageService.saveUsers(users);

    // Save basic account info so Settings/Profile show it immediately.
    // Age, height, weight, goal, and experience are collected right after
    // this during onboarding and saved separately via UserProfile.
    await StorageService.saveProfile(
      name: name,
      username: username,
      country: 'Australia',
    );

    return null; // success
  }

  /// Validates login credentials.
  /// Returns null on success, or an error message string on failure.
  static Future<String?> login({
    required String username,
    required String password,
  }) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      return 'Username and password are required.';
    }

    // Hardcoded demo account
    if (username == demoUsername && password == demoPassword) {
      return null;
    }

    // Check accounts created via Signup
    final users = await StorageService.getUsers();
    if (users.containsKey(username) && users[username] == password) {
      return null;
    }

    return 'Invalid username or password.';
  }
}
