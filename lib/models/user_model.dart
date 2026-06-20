import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a Youth Safety user profile stored in Firestore
/// under the `users/{uid}` document.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? bloodGroup;
  final int? age;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.bloodGroup,
    this.age,
    required this.createdAt,
  });

  /// Builds a [UserModel] from a Firestore document map.
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
      bloodGroup: map['bloodGroup'] as String?,
      age: map['age'] as int?,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Converts this model into a map suitable for `Firestore.set()`.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'bloodGroup': bloodGroup,
      'age': age,
      'createdAt': createdAt,
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? bloodGroup,
    int? age,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      age: age ?? this.age,
      createdAt: createdAt,
    );
  }
}