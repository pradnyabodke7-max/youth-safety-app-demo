import 'package:cloud_firestore/cloud_firestore.dart';

enum JourneyStatus { active, completed, expired }

/// Represents a single journey-timer session stored under
/// `users/{uid}/journeys/{journeyId}` in Firestore.
class JourneyModel {
  final String id;
  final int durationMinutes;
  final JourneyStatus status;
  final DateTime startedAt;
  final DateTime? endedAt;

  JourneyModel({
    required this.id,
    required this.durationMinutes,
    required this.status,
    required this.startedAt,
    this.endedAt,
  });

  factory JourneyModel.fromMap(Map<String, dynamic> map, String id) {
    return JourneyModel(
      id: id,
      durationMinutes: map['durationMinutes'] as int? ?? 0,
      status: _statusFromString(map['status'] as String?),
      startedAt: map['startedAt'] is Timestamp
          ? (map['startedAt'] as Timestamp).toDate()
          : DateTime.now(),
      endedAt: map['endedAt'] is Timestamp
          ? (map['endedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'durationMinutes': durationMinutes,
      'status': status.name,
      'startedAt': startedAt,
      'endedAt': endedAt,
    };
  }

  static JourneyStatus _statusFromString(String? value) {
    switch (value) {
      case 'completed':
        return JourneyStatus.completed;
      case 'expired':
        return JourneyStatus.expired;
      default:
        return JourneyStatus.active;
    }
  }
}