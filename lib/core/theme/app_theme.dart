import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Palet Warna Utama (Pink, Rose, Fuchsia)
  static const Color primary = Color(0xFFDB2777); // Pink 600 - modern, vibrant, elegant
  static const Color primaryLight = Color(0xFFF472B6); // Pink 400
  static const Color primaryDark = Color(0xFF9D174D); // Pink 800 - rich deep velvet rose
  static const Color primaryHover = Color(0xFFBE185D); // Pink 700

  static const Color secondary = Color(0xFFF43F5E); // Rose 500
  static const Color secondaryLight = Color(0xFFFB7185); // Rose 400
  static const Color accent = Color(0xFFD946EF); // Fuchsia 500
  static const Color accentLight = Color(0xFFE879F9); // Fuchsia 400

  // Status Warna Harmonis & Nyaman untuk Mata
  static const Color success = Color(0xFF059669); // Emerald 600
  static const Color successLight = Color(0xFF10B981); // Emerald 500
  static const Color warning = Color(0xFFD97706); // Amber 600
  static const Color warningLight = Color(0xFFF59E0B); // Amber 500
  static const Color danger = Color(0xFFE11D48); // Rose 600
  static const Color dangerLight = Color(0xFFF43F5E); // Rose 500
  static const Color info = Color(0xFFEC4899); // Pink 500

  // Palet Light Mode (Eye-Comfort Soft Pink Tint)
  static const Color bgLight = Color(0xFFFFF0F5); // Soft Lavender Blush Pink
  static const Color bgSubtle = Color(0xFFFCE7F3); // Pink 100
  static const Color surfaceLight = Colors.white;
  static const Color borderLight = Color(0xFFFBCFE8); // Pink 200
  static const Color borderSubtle = Color(0xFFFDF2F8); // Pink 50

  static const Color textDark = Color(0xFF1C0A18); // Deep velvet plum for ultra-clear legibility
  static const Color textBody = Color(0xFF4A183C); // Dark plum body
  static const Color textMuted = Color(0xFF8B4775); // Muted rose
  static const Color textLight = Color(0xFFBE83A8); // Light rose slate

  // Palet Dark Mode (Midnight Plum & Velvet Rose - Anti Eye-Fatigue)
  static const Color bgDark = Color(0xFF0F050E); // Deep Midnight Plum 950
  static const Color bgDarkSubtle = Color(0xFF190917);
  static const Color surfaceDark = Color(0xFF1E0C1C); // Plum Velvet Surface
  static const Color surfaceDarkElevated = Color(0xFF2C1329);
  static const Color borderDark = Color(0xFF3B1A37); // Velvet Rose Border
  static const Color borderDarkSubtle = Color(0xFF261023);

  static const Color textDarkPrimary = Color(0xFFFFF1F5); // Rose White
  static const Color textDarkBody = Color(0xFFFBCFE8); // Soft Rose 200
  static const Color textDarkMuted = Color(0xFFD694BC); // Rose Lavender
  static const Color textDarkLight = Color(0xFF9E6589);

  // Dynamic Theme Helpers (Seamless Light & Dark Switching)
  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
  static Color background(BuildContext context) => isDark(context) ? bgDark : bgLight;
  static Color surface(BuildContext context) => isDark(context) ? surfaceDark : surfaceLight;
  static Color surfaceElevated(BuildContext context) => isDark(context) ? surfaceDarkElevated : bgSubtle;
  static Color border(BuildContext context) => isDark(context) ? borderDark : borderLight;
  static Color borderSubtleColor(BuildContext context) => isDark(context) ? borderDarkSubtle : borderSubtle;
  static Color text(BuildContext context) => isDark(context) ? textDarkPrimary : textDark;
  static Color textSecondary(BuildContext context) => isDark(context) ? textDarkBody : textBody;
  static Color mutedText(BuildContext context) => isDark(context) ? textDarkMuted : textMuted;
  static Color lightText(BuildContext context) => isDark(context) ? textDarkLight : textLight;

  // Gradients Modern Pink
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFDB2777), Color(0xFFF43F5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF700A38), Color(0xFF9D174D), Color(0xFFDB2777)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E0C1C), Color(0xFF2C1329)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFFF472B6), Color(0xFFDB2777)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF047857), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient skyGradient = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFFB7185)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Soft Multi-layer Shadows untuk Efek Elevasi Premium
  static List<BoxShadow> get cardShadow => [
    const BoxShadow(
      color: Color(0x0CDB2777),
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x060F172A),
      blurRadius: 4,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get darkCardShadow => [
    const BoxShadow(
      color: Color(0x40000000),
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> getCardShadow(BuildContext context) =>
      isDark(context) ? darkCardShadow : cardShadow;

  static List<BoxShadow> get primaryGlow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.25),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  // LIGHT THEME
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: bgLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        secondary: secondary,
        surface: surfaceLight,
        error: danger,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(fontWeight: FontWeight.w800, color: textDark, letterSpacing: -0.5),
        titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: textDark, letterSpacing: -0.3),
        titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: textDark),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: textBody, height: 1.5),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: textMuted, height: 1.5),
        labelLarge: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.2),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: danger, width: 1),
        ),
        hintStyle: const TextStyle(color: textLight, fontSize: 13.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textDark,
          side: const BorderSide(color: borderLight, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13.5),
        ),
      ),
    );
  }

  // DARK THEME
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData(brightness: Brightness.dark).textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryLight,
      scaffoldBackgroundColor: bgDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primaryLight,
        secondary: secondaryLight,
        surface: surfaceDark,
        error: dangerLight,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(fontWeight: FontWeight.w800, color: textDarkPrimary, letterSpacing: -0.5),
        titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: textDarkPrimary, letterSpacing: -0.3),
        titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: textDarkPrimary),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: textDarkBody, height: 1.5),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: textDarkMuted, height: 1.5),
        labelLarge: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.2),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDark, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDarkElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryLight, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dangerLight, width: 1),
        ),
        hintStyle: const TextStyle(color: textDarkLight, fontSize: 13.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textDarkPrimary,
          side: const BorderSide(color: borderDark, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
