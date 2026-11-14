import 'package:cloud_firestore/cloud_firestore.dart';

/// Student entity.
/// Firestore collection: `students/{studentId}`
/// Parents can only access records where their UID is present in `parentIds`.
class Student {
  final String id;
  final String schoolId;
  final String name;
  final List<String> parentIds;
  final String? busId;
  final String? routeId;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Student({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.parentIds,
    this.busId,
    this.routeId,
    this.active = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Student.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Student.fromMap(doc.id, data);
  }

  factory Student.fromMap(String id, Map<String, dynamic> data) {
    final rawParents = data['parentIds'];
    final List<String> parents = rawParents is List
        ? rawParents.map((e) => e.toString()).toList()
        : <String>[];

    return Student(
      id: id,
      schoolId: data['schoolId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      parentIds: parents,
      busId: data['busId'] as String?,
      routeId: data['routeId'] as String?,
      active: data['active'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'name': name,
      'parentIds': parentIds,
      'busId': busId,
      'routeId': routeId,
      'active': active,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Student copyWith({
    String? id,
    String? schoolId,
    String? name,
    List<String>? parentIds,
    String? busId,
    String? routeId,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      parentIds: parentIds ?? this.parentIds,
      busId: busId ?? this.busId,
      routeId: routeId ?? this.routeId,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
