import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youth_safety_app/models/contact_model.dart';

/// Handles all Firestore read/write operations for a user's
/// emergency contacts, stored under `users/{uid}/contacts/{contactId}`.
class ContactRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _contactsCollection(String uid) =>
      _firestore.collection('users').doc(uid).collection('contacts');

  /// Fetches all contacts for the given user, once.
  Future<List<ContactModel>> getContacts(String uid) async {
    final snapshot = await _contactsCollection(uid).get();
    return snapshot.docs
        .map((doc) => ContactModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Streams all contacts for the given user, for live UI updates.
  Stream<List<ContactModel>> streamContacts(String uid) {
    return _contactsCollection(uid).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ContactModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Adds a new contact and returns the created [ContactModel] (with its
  /// Firestore-generated id).
  Future<ContactModel> addContact({
    required String uid,
    required String name,
    required String phone,
  }) async {
    final docRef = await _contactsCollection(uid).add({
      'name': name,
      'phone': phone,
    });
    return ContactModel(id: docRef.id, name: name, phone: phone);
  }

  /// Updates an existing contact's fields.
  Future<void> updateContact({
    required String uid,
    required String contactId,
    String? name,
    String? phone,
  }) async {
    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (updates.isEmpty) return;

    await _contactsCollection(uid).doc(contactId).update(updates);
  }

  /// Deletes a contact by id.
  Future<void> deleteContact({
    required String uid,
    required String contactId,
  }) async {
    await _contactsCollection(uid).doc(contactId).delete();
  }
}