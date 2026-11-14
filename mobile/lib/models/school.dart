import 'package:cloud_firestore/cloud_firestore.dart';

/// School institution entity.
/// Firestore collection: `schools/{schoolId}`
class School {
  final String id;
  final String name;
  final String address;
  final String phone;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const School({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.active = true,
    this.createdAt,
    this.updatedAt,
  });

  factory School.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return School.fromMap(doc.id, data);
  }

  factory School.fromMap(String id, Map<String, dynamic> data) {
    return School(
      id: id,
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      active: data['active'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'active': active,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  School copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return School(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
