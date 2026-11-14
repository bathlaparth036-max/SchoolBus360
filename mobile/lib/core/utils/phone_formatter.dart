/// Utility for parsing and normalizing phone numbers into E.164 standard (+91XXXXXXXXXX).
class PhoneFormatter {
  PhoneFormatter._();

  /// Normalizes an input phone string into standard E.164 Indian format (+91XXXXXXXXXX).
  static String normalizeToE164(String rawInput) {
    // Remove all whitespace, hyphens, parentheses
    String digits = rawInput.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // If starts with +91, ensure rest is 10 digits
    if (digits.startsWith('+91')) {
      return digits;
    }

    // If starts with 91 and has 12 digits total
    if (digits.startsWith('91') && digits.length == 12) {
      return '+$digits';
    }

    // If starts with leading 0 (common STD style), trim it
    if (digits.startsWith('0') && digits.length == 11) {
      digits = digits.substring(1);
    }

    // Otherwise prepend +91
    return '+91$digits';
  }

  /// Formats a 10-digit phone number for clean readability: "98765 43210"
  static String formatDisplay(String raw) {
    final clean = raw.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 10) {
      return '${clean.substring(0, 5)} ${clean.substring(5)}';
    }
    if (clean.length == 12 && clean.startsWith('91')) {
      final sub = clean.substring(2);
      return '+91 ${sub.substring(0, 5)} ${sub.substring(5)}';
    }
    return raw;
  }
}
