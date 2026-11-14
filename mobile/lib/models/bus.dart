import 'package:cloud_firestore/cloud_firestore.dart';

/// Bus entity.
/// Firestore collection: `buses/{busId}`
class Bus {
  final String id;
  final String schoolId;
  final String busNumber;
  final String? driverId;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Bus({
    required this.id,
    required this.schoolId,
    required this.busNumber,
    this.driverId,
    this.active = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Bus.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Bus.fromMap(doc.id, data);
  }

  factory Bus.fromMap(String id, Map<String, dynamic> data) {
    return Bus(
      id: id,
      schoolId: data['schoolId'] as String? ?? '',
      busNumber: data['busNumber'] as String? ?? '',
      driverId: data['driverId'] as String?,
      active: data['active'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'busNumber': busNumber,
      'driverId': driverId,
      'active': active,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Bus copyWith({
    String? id,
    String? schoolId,
    String? busNumber,
    String? driverId,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bus(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      busNumber: busNumber ?? this.busNumber,
      driverId: driverId ?? this.driverId,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
