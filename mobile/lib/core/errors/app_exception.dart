/// Base application exception for domain error handling in SchoolBus360.
abstract class AppException implements Exception {
  final String message;
  final String? technicalCode;

  const AppException(this.message, [this.technicalCode]);

  @override
  String toString() => message;
}

/// Network connectivity issues (offline, timeout, DNS resolution failure).
class NetworkException extends AppException {
  const NetworkException([
    String message = 'No internet connection. Please check your network and try again.',
    String? technicalCode,
  ]) : super(message, technicalCode);
}

/// Authentication and verification failures.
class AuthException extends AppException {
  const AuthException(
    String message, [
    String? technicalCode,
  ]) : super(message, technicalCode);
}

/// User profile not found in Firestore after successful phone OTP verification.
class UserNotFoundException extends AppException {
  const UserNotFoundException([
    String message = 'Your phone number is authenticated, but no active school profile was found.',
    String? technicalCode,
  ]) : super(message, technicalCode);
}

/// Authorization / permission failures.
class PermissionException extends AppException {
  const PermissionException([
    String message = 'You do not have permission to perform this action.',
    String? technicalCode,
  ]) : super(message, technicalCode);
}

/// Generic unexpected server errors.
class ServerException extends AppException {
  const ServerException([
    String message = 'Unable to connect to school server. Please try again later.',
    String? technicalCode,
  ]) : super(message, technicalCode);
}
