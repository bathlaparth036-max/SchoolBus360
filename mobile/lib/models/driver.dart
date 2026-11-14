import 'package:cloud_firestore/cloud_firestore.dart';

/// Driver entity.
/// Firestore collection: `drivers/{uid}` (document ID matches Auth UID for phone switching resilience).
class Driver {
  final String uid;
  final String schoolId;
  final String name;
  final String phone;
  final String? assignedBusId;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Driver({
    required this.uid,
    required this.schoolId,
    required this.name,
    required this.phone,
    this.assignedBusId,
    this.active = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Driver.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Driver.fromMap(doc.id, data);
  }

  factory Driver.fromMap(String uid, Map<String, dynamic> data) {
    return Driver(
      uid: uid,
      schoolId: data['schoolId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      assignedBusId: data['assignedBusId'] as String?,
      active: data['active'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'name': name,
      'phone': phone,
      'assignedBusId': assignedBusId,
      'active': active,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Driver copyWith({
    String? uid,
    String? schoolId,
    String? name,
    String? phone,
    String? assignedBusId,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Driver(
      uid: uid ?? this.uid,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      assignedBusId: assignedBusId ?? this.assignedBusId,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
