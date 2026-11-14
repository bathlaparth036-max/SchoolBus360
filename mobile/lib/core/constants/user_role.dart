/// Strongly typed user role representation for SchoolBus360.
/// Centralizes all role definitions and prevents magic string scattering.
enum UserRole {
  parent('parent', 'Parent'),
  driver('driver', 'Driver'),
  admin('admin', 'Administrator'),
  unknown('unknown', 'Unknown');

  final String value;
  final String displayName;

  const UserRole(this.value, this.displayName);

  /// Converts a Firestore role string into a strongly-typed [UserRole].
  static UserRole fromString(String? roleStr) {
    if (roleStr == null) return UserRole.unknown;
    final normalized = roleStr.trim().toLowerCase();
    for (final role in UserRole.values) {
      if (role.value == normalized) {
        return role;
      }
    }
    return UserRole.unknown;
  }

  /// Serializes role into string value for Firestore persistence.
  String toJson() => value;

  bool get isParent => this == UserRole.parent;
  bool get isDriver => this == UserRole.driver;
  bool get isAdmin => this == UserRole.admin;
  bool get isKnown => this != UserRole.unknown;
}
