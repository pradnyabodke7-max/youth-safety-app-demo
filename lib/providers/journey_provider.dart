import 'package:flutter/material.dart';
import 'package:youth_safety_app/models/journey_model.dart';
import 'package:youth_safety_app/repositories/journey_repository.dart';

/// Exposes journey persistence to the UI. The actual countdown timer
/// stays in the screen (it already works well) — this provider just
/// handles saving/updating journey state in Firestore.
class JourneyProvider extends ChangeNotifier {
  final JourneyRepository _journeyRepository = JourneyRepository();

  String? _activeJourneyId;
  List<JourneyModel> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  String? get activeJourneyId => _activeJourneyId;
  List<JourneyModel> get history => _history;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Starts a new journey and stores its id locally for later
  /// complete/expire calls.
  Future<bool> startJourney({
    required String uid,
    required int durationMinutes,
  }) async {
    _errorMessage = null;
    try {
      _activeJourneyId = await _journeyRepository.startJourney(
        uid: uid,
        durationMinutes: durationMinutes,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to start journey: $e';
      notifyListeners();
      return false;
    }
  }

  /// Marks the active journey as completed (user checked in safely).
  Future<bool> completeJourney(String uid) async {
    if (_activeJourneyId == null) return false;
    _errorMessage = null;
    try {
      await _journeyRepository.completeJourney(
        uid: uid,
        journeyId: _activeJourneyId!,
      );
      _activeJourneyId = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to complete journey: $e';
      notifyListeners();
      return false;
    }
  }

  /// Marks the active journey as expired (timer ran out, no check-in).
  Future<bool> expireJourney(String uid) async {
    if (_activeJourneyId == null) return false;
    _errorMessage = null;
    try {
      await _journeyRepository.expireJourney(
        uid: uid,
        journeyId: _activeJourneyId!,
      );
      _activeJourneyId = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to expire journey: $e';
      notifyListeners();
      return false;
    }
  }

  /// Loads journey history for the given uid.
  Future<void> loadHistory(String uid) async {
    _isLoading = true;
    notifyListeners();
    try {
      _history = await _journeyRepository.getJourneyHistory(uid);
    } catch (e) {
      _errorMessage = 'Failed to load journey history: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _activeJourneyId = null;
    _history = [];
    _errorMessage = null;
    notifyListeners();
  }
}