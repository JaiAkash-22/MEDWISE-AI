import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// MedWise AI's visual identity.
///
/// Direction: calm, trustworthy, warm — not clinical-cold, not a stock
/// Material teal. Deep pine-green anchors trust; a warm amber accent
/// draws attention to the one action that matters (Scan). Generous
/// text sizes and spacing throughout, since this app is built for
/// elderly users and people scanning a label in a hurry.
class AppTheme {
  static const Color pine = Color(0xFF1B4B43);
  static const Color pineDark = Color(0xFF0F332D);
  static const Color amber = Color(0xFFE8A33D);
  static const Color cream = Color(0xFFF7F5EF);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1A241F);
  static const Color inkMuted = Color(0xFF5C6B63);
  static const Color danger = Color(0xFFB3492B);

  static ThemeData get theme {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);

    final headingFont = GoogleFonts.poppinsTextTheme();
    final bodyFont = GoogleFonts.interTextTheme();

    return base.copyWith(
      scaffoldBackgroundColor: cream,
      colorScheme: base.colorScheme.copyWith(
        primary: pine,
        onPrimary: Colors.white,
        secondary: amber,
        onSecondary: pineDark,
        surface: cardSurface,
        onSurface: ink,
        error: danger,
      ),
      textTheme: bodyFont.copyWith(
        displayLarge: headingFont.displayLarge?.copyWith(color: ink, fontWeight: FontWeight.w700),
        displayMedium: headingFont.displayMedium?.copyWith(color: ink, fontWeight: FontWeight.w700),
        headlineLarge: headingFont.headlineLarge?.copyWith(color: ink, fontWeight: FontWeight.w600),
        headlineMedium: headingFont.headlineMedium?.copyWith(color: ink, fontWeight: FontWeight.w600),
        headlineSmall: headingFont.headlineSmall?.copyWith(color: ink, fontWeight: FontWeight.w600),
        titleLarge: headingFont.titleLarge?.copyWith(color: ink, fontWeight: FontWeight.w600),
        bodyLarge: bodyFont.bodyLarge?.copyWith(color: ink, fontSize: 18, height: 1.4),
        bodyMedium: bodyFont.bodyMedium?.copyWith(color: ink, fontSize: 16, height: 1.4),
        bodySmall: bodyFont.bodySmall?.copyWith(color: inkMuted, fontSize: 13),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cream,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: headingFont.titleLarge?.copyWith(
          color: ink,
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        shadowColor: pine.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: amber,
          foregroundColor: pineDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: headingFont.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: pine,
          side: const BorderSide(color: pine, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: headingFont.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: amber,
        foregroundColor: pineDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: pine,
      ),
    );
  }
}