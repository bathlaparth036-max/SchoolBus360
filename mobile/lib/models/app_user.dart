import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/user_role.dart';

/// Core user entity in SchoolBus360.
/// Firestore collection: `users/{uid}`
class AppUser {
  final String uid;
  final String phone;
  final String name;
  final UserRole role;
  final String schoolId;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppUser({
    required this.uid,
    required this.phone,
    required this.name,
    required this.role,
    required this.schoolId,
    this.active = true,
    this.createdAt,
    this.updatedAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppUser.fromMap(doc.id, data);
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      phone: data['phone'] as String? ?? '',
      name: data['name'] as String? ?? '',
      role: UserRole.fromString(data['role'] as String?),
      schoolId: data['schoolId'] as String? ?? '',
      active: data['active'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'name': name,
      'role': role.toJson(),
      'schoolId': schoolId,
      'active': active,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  AppUser copyWith({
    String? uid,
    String? phone,
    String? name,
    UserRole? role,
    String? schoolId,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      role: role ?? this.role,
      schoolId: schoolId ?? this.schoolId,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
