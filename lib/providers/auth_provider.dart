import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

/// Exposes authentication state and actions to the UI layer.
/// Screens should call these methods instead of touching
/// FirebaseAuth or AuthService directly.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  AuthProvider() {
    // Keep _currentUser in sync with Firebase's own auth state,
    // so app restarts / token expiry are reflected automatically.
    _authService.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Registers a new user. Returns `true` on success, `false` on failure
  /// (with [errorMessage] populated for the UI to display).
  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    _setError(null);
    _setLoading(true);
    try {
      final user = await _authService.registerUser(
        name: name,
        email: email,
        password: password,
      );
      _currentUser = user;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Something went wrong. Please try again.');
      return false;
    }
  }

  /// Logs in an existing user. Returns `true` on success.
  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    _setError(null);
    _setLoading(true);
    try {
      final user = await _authService.loginUser(
        email: email,
        password: password,
      );
      _currentUser = user;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Something went wrong. Please try again.');
      return false;
    }
  }

  /// Logs the current user out.
  Future<void> logoutUser() async {
    await _authService.logoutUser();
    _currentUser = null;
    notifyListeners();
  }

  /// Sends a password reset email. Returns `true` on success.
  Future<bool> resetPassword({required String email}) async {
    _setError(null);
    _setLoading(true);
    try {
      await _authService.resetPassword(email: email);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Something went wrong. Please try again.');
      return false;
    }
  }

  /// Converts Firebase error codes into human-readable messages.
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try logging in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}