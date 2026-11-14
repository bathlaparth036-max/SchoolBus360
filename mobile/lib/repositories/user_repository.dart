import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/error_handler.dart';
import '../models/app_user.dart';
import '../models/school.dart';
import '../models/driver.dart';
import '../models/bus.dart';
import '../models/student.dart';

/// Repository responsible for user profiles, school information,
/// and associated transportation entities in Firestore.
class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches user profile document: `users/{uid}`
  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return AppUser.fromFirestore(doc);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Fetches school information document: `schools/{schoolId}`
  Future<School?> getSchool(String schoolId) async {
    try {
      if (schoolId.trim().isEmpty) return null;
      final doc = await _firestore.collection('schools').doc(schoolId).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return School.fromFirestore(doc);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Fetches driver profile document: `drivers/{uid}`
  Future<Driver?> getDriverProfile(String uid) async {
    try {
      final doc = await _firestore.collection('drivers').doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return Driver.fromFirestore(doc);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Fetches bus document: `buses/{busId}`
  Future<Bus?> getBus(String busId) async {
    try {
      if (busId.trim().isEmpty) return null;
      final doc = await _firestore.collection('buses').doc(busId).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return Bus.fromFirestore(doc);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Fetches all children associated with a parent in a specific school.
  Future<List<Student>> getStudentsForParent({
    required String schoolId,
    required String parentUid,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('students')
          .where('schoolId', isEqualTo: schoolId)
          .where('parentIds', arrayContains: parentUid)
          .get();

      return querySnapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
