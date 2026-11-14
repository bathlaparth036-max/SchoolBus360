/// Input validation rules tailored for Indian school transportation users.
class Validators {
  Validators._();

  /// Validates a 10-digit Indian mobile number.
  /// Standard Indian mobile numbers begin with digits 6, 7, 8, or 9.
  static String? validateIndianPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required.';
    }

    final cleanDigits = value.replaceAll(RegExp(r'\D'), '');

    // Allow raw 10 digits or 12 digits starting with 91
    if (cleanDigits.length == 10) {
      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleanDigits)) {
        return 'Please enter a valid 10-digit Indian mobile number starting with 6-9.';
      }
      return null;
    } else if (cleanDigits.length == 12 && cleanDigits.startsWith('91')) {
      final nationalNumber = cleanDigits.substring(2);
      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(nationalNumber)) {
        return 'Please enter a valid Indian mobile number.';
      }
      return null;
    }

    return 'Please enter a valid 10-digit mobile number.';
  }

  /// Validates a 6-digit SMS OTP.
  static String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the 6-digit OTP.';
    }

    final trimmed = value.trim();
    if (trimmed.length != 6 || !RegExp(r'^\d{6}$').hasMatch(trimmed)) {
      return 'OTP must be exactly 6 digits.';
    }

    return null;
  }
}
