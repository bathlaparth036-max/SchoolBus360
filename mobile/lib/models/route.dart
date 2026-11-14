import 'package:cloud_firestore/cloud_firestore.dart';

/// Route stop entity.
/// Firestore subcollection: `routes/{routeId}/stops/{stopId}`
class StopModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int sequence;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StopModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.sequence,
    this.active = true,
    this.createdAt,
    this.updatedAt,
  });

  factory StopModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return StopModel.fromMap(doc.id, data);
  }

  factory StopModel.fromMap(String id, Map<String, dynamic> data) {
    return StopModel(
      id: id,
      name: data['name'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      sequence: (data['sequence'] as num?)?.toInt() ?? 0,
      active: data['active'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'sequence': sequence,
      'active': active,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

/// Transport route entity.
/// Firestore collection: `routes/{routeId}`
class RouteModel {
  final String id;
  final String schoolId;
  final String name;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RouteModel({
    required this.id,
    required this.schoolId,
    required this.name,
    this.active = true,
    this.createdAt,
    this.updatedAt,
  });

  factory RouteModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return RouteModel.fromMap(doc.id, data);
  }

  factory RouteModel.fromMap(String id, Map<String, dynamic> data) {
    return RouteModel(
      id: id,
      schoolId: data['schoolId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      active: data['active'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'name': name,
      'active': active,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  RouteModel copyWith({
    String? id,
    String? schoolId,
    String? name,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RouteModel(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
