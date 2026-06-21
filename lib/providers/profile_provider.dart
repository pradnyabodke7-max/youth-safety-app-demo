import 'package:flutter/material.dart';
import 'package:youth_safety_app/models/user_model.dart';
import 'package:youth_safety_app/repositories/user_repository.dart';

/// Exposes the current user's Firestore profile to the UI and
/// handles loading/updating it.
class ProfileProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  UserModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Loads the profile for the given uid from Firestore.
  Future<void> loadProfile(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userProfile = await _userRepository.getUserProfile(uid);
    } catch (e) {
      _errorMessage = 'Failed to load profile: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Updates the given fields on Firestore, then refreshes local state.
  /// Returns true on success, false on failure (check [errorMessage]).
  Future<bool> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? bloodGroup,
    int? age,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userRepository.updateUserProfile(
        uid: uid,
        name: name,
        phone: phone,
        bloodGroup: bloodGroup,
        age: age,
      );

      // Reflect changes locally without re-fetching from Firestore.
      if (_userProfile != null) {
        _userProfile = _userProfile!.copyWith(
          name: name,
          phone: phone,
          bloodGroup: bloodGroup,
          age: age,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clears state (e.g. call this on logout).
  void clear() {
    _userProfile = null;
    _errorMessage = null;
    notifyListeners();
  }
}