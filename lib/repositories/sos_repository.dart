import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youth_safety_app/models/sos_model.dart';

/// Handles Firestore read/write operations for SOS event logs,
/// stored under `users/{uid}/sos_logs/{logId}`.
class SosRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _sosLogsCollection(String uid) =>
      _firestore.collection('users').doc(uid).collection('sos_logs');

  /// Creates a new SOS log entry. Server-side timestamp is used for
  /// `createdAt` so ordering is reliable even with clock drift.
  Future<void> createSOSLog({
    required String uid,
    required String location,
    required List<String> contactsNotified,
  }) async {
    await _sosLogsCollection(uid).add({
      'location': location,
      'contactsNotified': contactsNotified,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fetches the SOS history for a user, most recent first.
  Future<List<SosModel>> getSOSHistory(String uid) async {
    final snapshot = await _sosLogsCollection(uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => SosModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Streams the SOS history for live updates, most recent first.
  Stream<List<SosModel>> streamSOSHistory(String uid) {
    return _sosLogsCollection(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SosModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}