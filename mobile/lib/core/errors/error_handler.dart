import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_exception.dart';

/// Centralized utility to map technical exceptions and Firebase Auth errors
/// into user-friendly, localized domain exceptions.
class ErrorHandler {
  ErrorHandler._();

  /// Converts any thrown error or exception into a user-safe [AppException].
  static AppException handle(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is SocketException) {
      return const NetworkException(
        'Cannot reach school servers. Please verify your mobile data or Wi-Fi connection.',
      );
    }

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-phone-number':
          return const AuthException(
            'The mobile number entered is invalid. Please check and try again.',
            'invalid-phone-number',
          );
        case 'invalid-verification-code':
          return const AuthException(
            'The OTP code you entered is incorrect. Please recheck the SMS code.',
            'invalid-verification-code',
          );
        case 'session-expired':
          return const AuthException(
            'The OTP verification session has expired. Please request a new OTP.',
            'session-expired',
          );
        case 'too-many-requests':
          return const AuthException(
            'Too many OTP attempts from this device. Please wait a few minutes before trying again.',
            'too-many-requests',
          );
        case 'quota-exceeded':
          return const AuthException(
            'SMS quota exceeded. Please contact your school administrator or try again later.',
            'quota-exceeded',
          );
        case 'user-disabled':
          return const AuthException(
            'This user account has been disabled by the school administrator.',
            'user-disabled',
          );
        case 'network-request-failed':
          return const NetworkException(
            'Network request failed. Please check your internet connectivity.',
            'network-request-failed',
          );
        case 'operation-not-allowed':
          return const AuthException(
            'Phone OTP authentication is currently disabled for this school project.',
            'operation-not-allowed',
          );
        case 'credential-already-in-use':
          return const AuthException(
            'This phone number is already associated with another active session.',
            'credential-already-in-use',
          );
        default:
          return AuthException(
            'Authentication failed. Please verify your number and try again.',
            error.code,
          );
      }
    }

    if (error is FirebaseException) {
      if (error.code == 'permission-denied') {
        return const PermissionException(
          'Access denied. You do not have permission to view or modify this record.',
          'permission-denied',
        );
      }
      if (error.code == 'unavailable') {
        return const NetworkException(
          'Firebase service is currently unavailable. Cached offline data will be shown.',
          'unavailable',
        );
      }
    }

    return const ServerException(
      'An unexpected error occurred. Please try again.',
    );
  }
}
