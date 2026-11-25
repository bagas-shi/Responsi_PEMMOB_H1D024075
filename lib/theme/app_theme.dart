import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Konfigurasi Design System aplikasi (Material 3 + Light Neumorphism / Soft UI).
/// Menyediakan palet warna, gradasi, bayangan lembut (soft diffused shadows),
/// serta tipografi Google Fonts Poppins secara terpusat.
class AppTheme {
  AppTheme._();

  // ================= PALET WARNA UTAMA =================
  /// Background utama: Light cool gray / off-white
  static const Color background = Color(0xFFF0F4F8);

  /// Permukaan cekung/recessed untuk track progress bar & container halus
  static const Color recessedSurface = Color(0xFFEEF2F6);

  /// Permukaan kartu utama: Putih bersih
  static const Color cardSurface = Color(0xFFFFFFFF);

  /// Primary Accent: Gradasi biru langit cerah ke cyan
  static const Color primaryStart = Color(0xFF4FC3F7);
  static const Color primaryEnd = Color(0xFF0288D1);

  /// Secondary Accent: Gradasi kuning matahari hangat ke amber
  static const Color secondaryStart = Color(0xFFFFD54F);
  static const Color secondaryEnd = Color(0xFFFFB300);

  /// Warna teks utama (Dark Slate) & label pendukung (Muted Gray)
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF8A99AD);

  /// Warna status & semantik
  static const Color errorColor = Color(0xFFEF4444);
  static const Color borderLight = Color(0xFFFFFFFF);
  static const Color dividerSoft = Color(0xFFE5ECF3);

  // ================= GRADASI KHAS SOFT UI =================
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryStart, primaryEnd],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF56CCF2), Color(0xFF29B6F6), Color(0xFF0288D1)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryStart, secondaryEnd],
  );

  static const LinearGradient softSurfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FBFF)],
  );

  // ================= NEUMORPHIC & GLOW SHADOWS =================
  /// Bayangan halus untuk kartu utama (highlight putih kiri-atas & biru-abu kanan-bawah)
  static List<BoxShadow> get softCardShadows => [
        BoxShadow(
          color: const Color(0xFFCBD5E1).withValues(alpha: 0.55),
          offset: const Offset(8, 10),
          blurRadius: 24,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.92),
          offset: const Offset(-6, -6),
          blurRadius: 16,
          spreadRadius: 0,
        ),
      ];

  /// Bayangan lembut berukuran ringkas untuk tombol ikon bundar & badge
  static List<BoxShadow> get softSmallShadows => [
        BoxShadow(
          color: const Color(0xFFCBD5E1).withValues(alpha: 0.50),
          offset: const Offset(4, 5),
          blurRadius: 12,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.95),
          offset: const Offset(-3, -3),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ];

  /// Colored glow shadow biru/cyan di bawah elemen bergradasi utama
  static List<BoxShadow> get primaryGlowShadows => [
        BoxShadow(
          color: primaryEnd.withValues(alpha: 0.30),
          offset: const Offset(0, 10),
          blurRadius: 22,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: primaryStart.withValues(alpha: 0.20),
          offset: const Offset(0, 4),
          blurRadius: 10,
        ),
      ];

  /// Colored glow shadow kuning hangat di bawah tombol sekunder / aksen matahari
  static List<BoxShadow> get secondaryGlowShadows => [
        BoxShadow(
          color: secondaryEnd.withValues(alpha: 0.28),
          offset: const Offset(0, 8),
          blurRadius: 18,
          spreadRadius: -2,
        ),
      ];

  // ================= KONFIGURASI MATERIAL 3 THEME =================
  static ThemeData get lightTheme {
    final poppinsFamily = GoogleFonts.poppins().fontFamily;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: poppinsFamily,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryEnd,
        brightness: Brightness.light,
        primary: primaryEnd,
        secondary: secondaryEnd,
        surface: cardSurface,
        error: errorColor,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
        ),
        displayMedium: GoogleFonts.poppins(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
        ),
        headlineMedium: GoogleFonts.poppins(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: GoogleFonts.poppins(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.poppins(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.poppins(
          color: textPrimary,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: textSecondary,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.poppins(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardSurface,
        hintStyle: GoogleFonts.poppins(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryStart, width: 1.5),
        ),
      ),
    );
  }
}
