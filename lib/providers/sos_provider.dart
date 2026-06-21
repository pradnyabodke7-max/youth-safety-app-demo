import 'package:flutter/material.dart';

import 'package:youth_safety_app/models/sos_model.dart';
import 'package:youth_safety_app/repositories/sos_repository.dart';
import 'package:youth_safety_app/repositories/contact_repository.dart';
import 'package:youth_safety_app/services/sms_service.dart';
import 'package:youth_safety_app/services/location_service.dart';

/// Orchestrates the full SOS flow: fetch contacts + location, send SMS,
/// log the event to Firestore, and expose SOS history to the UI.
class SosProvider extends ChangeNotifier {
  final SosRepository _sosRepository = SosRepository();
  final ContactRepository _contactRepository = ContactRepository();

  List<SosModel> _sosHistory = [];
  bool _isLoading = false;
  bool _isTriggering = false;
  String? _errorMessage;

  List<SosModel> get sosHistory => _sosHistory;
  bool get isLoading => _isLoading;
  bool get isTriggering => _isTriggering;
  String? get errorMessage => _errorMessage;

  /// Loads SOS history for the given uid, most recent first.
  Future<void> loadHistory(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _sosHistory = await _sosRepository.getSOSHistory(uid);
    } catch (e) {
      _errorMessage = 'Failed to load SOS history: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Triggers a full SOS event:
  /// 1. Fetches the user's emergency contacts from Firestore.
  /// 2. Gets the current location.
  /// 3. Sends an SMS to each contact.
  /// 4. Logs the event to Firestore.
  ///
  /// Returns true if the flow completed (even if no contacts were found),
  /// false only on an unexpected error.
  Future<bool> triggerSOS(String uid) async {
    _isTriggering = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final contacts = await _contactRepository.getContacts(uid);
      final locationLink = await LocationService.getCurrentLocation();

      await SmsService.sendSOSSms(
        contacts: contacts,
        locationLink: locationLink,
      );

      await _sosRepository.createSOSLog(
        uid: uid,
        location: locationLink,
        contactsNotified: contacts.map((c) => c.phone).toList(),
      );

      // Refresh history so the UI reflects the new log immediately.
      _sosHistory = await _sosRepository.getSOSHistory(uid);

      _isTriggering = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to trigger SOS: $e';
      _isTriggering = false;
      notifyListeners();
      return false;
    }
  }

  /// Clears state (e.g. call this on logout).
  void clear() {
    _sosHistory = [];
    _errorMessage = null;
    notifyListeners();
  }
}