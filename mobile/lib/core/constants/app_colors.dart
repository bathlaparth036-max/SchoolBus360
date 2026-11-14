import 'package:flutter/material.dart';

/// Application color palette designed for high visibility and contrast
/// on budget Android devices and outdoor/sunlight conditions in India.
class AppColors {
  AppColors._();

  // Brand Colors
  static const Color primary = Color(0xFF1E293B); // Dark Slate
  static const Color primaryLight = Color(0xFF334155);
  static const Color accentBusYellow = Color(0xFFF59E0B); // Amber / Bus Yellow
  static const Color accentBusYellowDark = Color(0xFFD97706);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE2E8F0);

  // Text Colors (High Contrast)
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Status & Feedback Colors
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFEA580C);
  static const Color info = Color(0xFF0284C7);

  // Offline banner
  static const Color offlineBannerBg = Color(0xFF475569);
  static const Color offlineBannerText = Colors.white;
}
