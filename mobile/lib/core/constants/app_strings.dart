/// Centralized user-facing strings for SchoolBus360.
/// Avoids hardcoded strings throughout presentation screens.
class AppStrings {
  AppStrings._();

  static const String appName = 'SchoolBus360';
  static const String appTagline = 'Safe & Reliable School Transport';

  // Auth & Login
  static const String loginTitle = 'SchoolBus360';
  static const String loginSubtitle = 'Enter your 10-digit mobile number to proceed';
  static const String phoneLabel = 'Phone Number';
  static const String phonePlaceholder = '98765 43210';
  static const String sendOtp = 'Send OTP';
  static const String sendingOtp = 'Sending OTP...';

  // OTP
  static const String otpTitle = 'Enter OTP';
  static const String otpSubtitle = 'We sent a 6-digit verification code to';
  static const String verifyOtp = 'Verify';
  static const String verifyingOtp = 'Verifying...';
  static const String resendOtp = 'Resend OTP';
  static const String resendWait = 'Resend in';
  static const String changePhoneNumber = 'Change phone number';

  // Roles & Home
  static const String welcome = 'Welcome,';
  static const String roleLabel = 'Role:';
  static const String schoolLabel = 'School:';
  static const String assignedBusLabel = 'Assigned Bus:';
  static const String notAssigned = 'Not Assigned';
  static const String logout = 'Logout';
  static const String logoutConfirmTitle = 'Confirm Logout';
  static const String logoutConfirmMessage = 'Are you sure you want to log out of SchoolBus360?';
  static const String cancel = 'Cancel';

  // Errors & Offline
  static const String offlineMessage = 'No internet connection. Operating offline.';
  static const String networkRestored = 'Internet connection restored.';
  static const String unexpectedError = 'An unexpected error occurred. Please try again.';
  static const String invalidPhoneError = 'Please enter a valid 10-digit mobile number.';
  static const String invalidOtpError = 'Please enter a valid 6-digit OTP code.';
  static const String sessionExpired = 'Your session has expired. Please log in again.';
  static const String accountPendingTitle = 'Account Not Registered';
  static const String accountPendingMessage =
      'This phone number is not linked to any school account. Please contact your school administrator to register.';
}
