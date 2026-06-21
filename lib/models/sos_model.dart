import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single SOS event stored under
/// `users/{uid}/sos_logs/{logId}` in Firestore.
class SosModel {
  final String id;
  final String location;
  final List<String> contactsNotified;
  final DateTime createdAt;

  SosModel({
    required this.id,
    required this.location,
    required this.contactsNotified,
    required this.createdAt,
  });

  /// Builds a [SosModel] from a Firestore document map.
  factory SosModel.fromMap(Map<String, dynamic> map, String id) {
    return SosModel(
      id: id,
      location: map['location'] as String? ?? 'Unknown',
      contactsNotified: (map['contactsNotified'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Converts this model into a map suitable for `Firestore.set()`.
  Map<String, dynamic> toMap() {
    return {
      'location': location,
      'contactsNotified': contactsNotified,
      'createdAt': createdAt,
    };
  }
}