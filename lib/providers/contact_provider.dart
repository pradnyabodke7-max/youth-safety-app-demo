import 'package:flutter/material.dart';
import 'package:youth_safety_app/models/contact_model.dart';
import 'package:youth_safety_app/repositories/contact_repository.dart';

/// Exposes the current user's emergency contacts to the UI and
/// handles loading/adding/updating/deleting them in Firestore.
class ContactProvider extends ChangeNotifier {
  final ContactRepository _contactRepository = ContactRepository();

  List<ContactModel> _contacts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ContactModel> get contacts => _contacts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Loads all contacts for the given uid from Firestore.
  Future<void> loadContacts(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _contacts = await _contactRepository.getContacts(uid);
    } catch (e) {
      _errorMessage = 'Failed to load contacts: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Adds a new contact and refreshes local state.
  /// Returns true on success, false on failure (check [errorMessage]).
  Future<bool> addContact({
    required String uid,
    required String name,
    required String phone,
  }) async {
    _errorMessage = null;
    try {
      final newContact = await _contactRepository.addContact(
        uid: uid,
        name: name,
        phone: phone,
      );
      _contacts.add(newContact);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add contact: $e';
      notifyListeners();
      return false;
    }
  }

  /// Updates an existing contact and refreshes local state.
  Future<bool> updateContact({
    required String uid,
    required String contactId,
    String? name,
    String? phone,
  }) async {
    _errorMessage = null;
    try {
      await _contactRepository.updateContact(
        uid: uid,
        contactId: contactId,
        name: name,
        phone: phone,
      );

      final index = _contacts.indexWhere((c) => c.id == contactId);
      if (index != -1) {
        _contacts[index] = _contacts[index].copyWith(name: name, phone: phone);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update contact: $e';
      notifyListeners();
      return false;
    }
  }

  /// Deletes a contact and refreshes local state.
  Future<bool> deleteContact({
    required String uid,
    required String contactId,
  }) async {
    _errorMessage = null;
    try {
      await _contactRepository.deleteContact(uid: uid, contactId: contactId);
      _contacts.removeWhere((c) => c.id == contactId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete contact: $e';
      notifyListeners();
      return false;
    }
  }

  /// Clears state (e.g. call this on logout).
  void clear() {
    _contacts = [];
    _errorMessage = null;
    notifyListeners();
  }
}