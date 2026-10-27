import 'package:flutter/material.dart';

/// Central color palette adhering to the enterprise real estate aesthetic:
/// Deep navy primary, soft neutral surfaces, teal/green accents, and semantic status colors.
class AppColors {
  // Brand & Primary
  static const Color primaryNavy = Color(0xFF0F2027);
  static const Color primaryNavyDark = Color(0xFF0B171C);
  static const Color navySurface = Color(0xFF1E293B);
  static const Color primaryBlue = Color(0xFF1E3A8A);

  // Accents
  static const Color accentTeal = Color(0xFF0D9488);
  static const Color accentTealLight = Color(0xFFCCFBF1);
  static const Color accentGreen = Color(0xFF10B981);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardSurface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE2E8F0);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnNavy = Colors.white;

  // Status Colors
  // Registered -> Blue / Neutral
  static const Color statusRegisteredText = Color(0xFF1D4ED8);
  static const Color statusRegisteredBg = Color(0xFFDBEAFE);
  static const Color statusRegisteredBorder = Color(0xFF93C5FD);

  // Checked In -> Fresh Green
  static const Color statusCheckedInText = Color(0xFF047857);
  static const Color statusCheckedInBg = Color(0xFFD1FAE5);
  static const Color statusCheckedInBorder = Color(0xFF6EE7B7);

  // Checked Out -> Slate / Completed Purple
  static const Color statusCheckedOutText = Color(0xFF475569);
  static const Color statusCheckedOutBg = Color(0xFFE2E8F0);
  static const Color statusCheckedOutBorder = Color(0xFFCBD5E1);

  // Feedback Colors
  static const Color errorRed = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warningOrange = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color successGreen = Color(0xFF16A34A);
}
