import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youth_safety_app/models/user_model.dart';

/// Handles all Firestore read/write operations for the `users/{uid}` collection.
class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Fetches a single user's profile document by uid.
  /// Returns null if the document doesn't exist.
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  /// Streams a single user's profile document for live UI updates.
  Stream<UserModel?> streamUserProfile(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    });
  }

  /// Updates only the provided fields on the user's profile document.
  /// Pass only the fields that changed — others are left untouched.
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? phone,
    String? bloodGroup,
    int? age,
  }) async {
    final Map<String, dynamic> updates = {};

    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (bloodGroup != null) updates['bloodGroup'] = bloodGroup;
    if (age != null) updates['age'] = age;

    if (updates.isEmpty) return;

    await _usersCollection.doc(uid).update(updates);
  }
}