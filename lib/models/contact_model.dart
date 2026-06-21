/// Represents a single emergency contact stored under
/// `users/{uid}/contacts/{contactId}` in Firestore.
class ContactModel {
  final String id;
  final String name;
  final String phone;

  ContactModel({
    required this.id,
    required this.name,
    required this.phone,
  });

  /// Builds a [ContactModel] from a Firestore document map.
  factory ContactModel.fromMap(Map<String, dynamic> map, String id) {
    return ContactModel(
      id: id,
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
    );
  }

  /// Converts this model into a map suitable for `Firestore.set()`.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
    };
  }

  ContactModel copyWith({
    String? name,
    String? phone,
  }) {
    return ContactModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }
}