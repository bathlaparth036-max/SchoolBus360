import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/errors/app_exception.dart';
import '../core/errors/error_handler.dart';

/// Callback signatures for phone verification workflow.
typedef OnCodeSentCallback = void Function(String verificationId, int? resendToken);
typedef OnVerificationFailedCallback = void Function(AppException exception);
typedef OnAutoVerifiedCallback = void Function(UserCredential credential);

/// Repository handling phone OTP authentication with Firebase.
class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Exposes stream of user authentication state changes.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Gets the currently authenticated Firebase user, if any.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Initiates Phone Number verification and sends 6-digit OTP SMS.
  Future<void> sendOtp({
    required String phoneNumber,
    required OnCodeSentCallback onCodeSent,
    required OnVerificationFailedCallback onVerificationFailed,
    required OnAutoVerifiedCallback onAutoVerified,
    int? forceResendingToken,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: forceResendingToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final userCredential = await _firebaseAuth.signInWithCredential(credential);
            onAutoVerified(userCredential);
          } catch (e) {
            onVerificationFailed(ErrorHandler.handle(e));
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          onVerificationFailed(ErrorHandler.handle(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto retrieval timed out, user manually enters OTP code.
        },
      );
    } catch (e) {
      onVerificationFailed(ErrorHandler.handle(e));
    }
  }

  /// Verifies the entered SMS code with the verification ID.
  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Signs out the current user session.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
