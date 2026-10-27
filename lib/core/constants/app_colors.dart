import 'package:flutter/material.dart';

/// Central color palette adhering to a modern enterprise real-estate aesthetic:
/// Deep slate navy primary, soft neutral surfaces, teal accents, and accessible semantic status colors.
class AppColors {
  // Brand & Primary
  static const Color primaryNavy = Color(0xFF0F172A); // Slate 900
  static const Color primaryNavyDark = Color(0xFF020617); // Slate 950
  static const Color navySurface = Color(0xFF1E293B); // Slate 800
  static const Color primaryBlue = Color(0xFF2563EB); // Blue 600

  // Accents
  static const Color accentTeal = Color(0xFF0D9488); // Teal 600
  static const Color accentTealDark = Color(0xFF0F766E); // Teal 700
  static const Color accentTealLight = Color(0xFFCCFBF1); // Teal 100
  static const Color accentTealBg = Color(0xFFF0FDFA); // Teal 50
  static const Color accentGreen = Color(0xFF10B981); // Emerald 500

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color cardSurface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF1F5F9); // Slate 100
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color borderMedium = Color(0xFFCBD5E1); // Slate 300
  static const Color divider = Color(0xFFE2E8F0);

  // Text Colors (High Contrast & Accessible)
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textOnNavy = Colors.white;

  // Status Colors (WCAG compliant contrast)
  // Registered -> Indigo / Blue
  static const Color statusRegisteredText = Color(0xFF1D4ED8); // Blue 700
  static const Color statusRegisteredBg = Color(0xFFEFF6FF); // Blue 50
  static const Color statusRegisteredBorder = Color(0xFFBFDBFE); // Blue 200

  // Checked In -> Emerald / Green
  static const Color statusCheckedInText = Color(0xFF047857); // Emerald 700
  static const Color statusCheckedInBg = Color(0xFFECFDF5); // Emerald 50
  static const Color statusCheckedInBorder = Color(0xFFA7F3D0); // Emerald 200

  // Checked Out -> Slate / Completed
  static const Color statusCheckedOutText = Color(0xFF475569); // Slate 600
  static const Color statusCheckedOutBg = Color(0xFFF1F5F9); // Slate 100
  static const Color statusCheckedOutBorder = Color(0xFFCBD5E1); // Slate 300

  // Feedback Colors
  static const Color errorRed = Color(0xFFDC2626); // Red 600
  static const Color errorLight = Color(0xFFFEF2F2); // Red 50
  static const Color errorBorder = Color(0xFFFECACA); // Red 200
  static const Color warningOrange = Color(0xFFD97706); // Amber 600
  static const Color warningLight = Color(0xFFFFFBEB); // Amber 50
  static const Color warningBorder = Color(0xFFFDE68A); // Amber 200
  static const Color successGreen = Color(0xFF16A34A); // Green 600
  static const Color successLight = Color(0xFFF0FDF4); // Green 50

  // Avatar deterministic palette
  static const List<Color> avatarColors = [
    Color(0xFF0284C7), // Sky 600
    Color(0xFF0D9488), // Teal 600
    Color(0xFF4F46E5), // Indigo 600
    Color(0xFF7C3AED), // Violet 600
    Color(0xFF059669), // Emerald 600
    Color(0xFFD97706), // Amber 600
    Color(0xFFE11D48), // Rose 600
    Color(0xFF475569), // Slate 600
  ];

  /// Get deterministic avatar color based on visitor name
  static Color getAvatarColor(String name) {
    if (name.isEmpty) return avatarColors[0];
    final hash = name.codeUnits.fold(0, (prev, elem) => prev + elem);
    return avatarColors[hash % avatarColors.length];
  }
}
