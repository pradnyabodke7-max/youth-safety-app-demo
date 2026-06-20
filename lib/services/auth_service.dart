import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Thin wrapper around FirebaseAuth + the initial Firestore user
/// document creation. Contains NO UI logic — only Firebase calls.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of auth state changes (null when logged out).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently signed-in Firebase user, if any.
  User? get currentUser => _auth.currentUser;

  /// Registers a new user with email/password, then creates their
  /// profile document in Firestore under `users/{uid}`.
  ///
  /// Throws a [FirebaseAuthException] on failure (handled by the
  /// provider layer, not here).
  Future<User> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-creation-failed',
        message: 'User could not be created. Please try again.',
      );
    }

    // Create the initial Firestore profile document.
    await _firestore.collection('users').doc(user.uid).set({
      'name': name.trim(),
      'email': email.trim(),
      'phone': null,
      'bloodGroup': null,
      'age': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return user;
  }

  /// Logs in an existing user with email/password.
  Future<User> loginUser({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'login-failed',
        message: 'Login failed. Please try again.',
      );
    }
    return user;
  }

  /// Signs the current user out.
  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  /// Sends a password reset email to the given address.
  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}