import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youth_safety_app/models/journey_model.dart';

/// Handles Firestore read/write operations for journey-timer sessions,
/// stored under `users/{uid}/journeys/{journeyId}`.
class JourneyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _journeysCollection(String uid) =>
      _firestore.collection('users').doc(uid).collection('journeys');

  /// Starts a new journey and returns its generated id.
  Future<String> startJourney({
    required String uid,
    required int durationMinutes,
  }) async {
    final docRef = await _journeysCollection(uid).add({
      'durationMinutes': durationMinutes,
      'status': 'active',
      'startedAt': FieldValue.serverTimestamp(),
      'endedAt': null,
    });
    return docRef.id;
  }

  /// Marks a journey as completed (user checked in safely).
  Future<void> completeJourney({
    required String uid,
    required String journeyId,
  }) async {
    await _journeysCollection(uid).doc(journeyId).update({
      'status': 'completed',
      'endedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Marks a journey as expired (timer ran out without check-in).
  Future<void> expireJourney({
    required String uid,
    required String journeyId,
  }) async {
    await _journeysCollection(uid).doc(journeyId).update({
      'status': 'expired',
      'endedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fetches journey history for a user, most recent first.
  Future<List<JourneyModel>> getJourneyHistory(String uid) async {
    final snapshot = await _journeysCollection(uid)
        .orderBy('startedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => JourneyModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}