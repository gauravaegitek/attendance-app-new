import 'package:flutter/material.dart';

class AppTheme {
  // =================== COLORS ===================
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFFECFDF5);
  static const Color accent = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color warning = Color(0xFFF97316);
  static const Color warningLight = Color(0xFFFFF7ED);
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFF0FDF4);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color background = Color(0xFFF9FAFB);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF3F4F6);

  // =================== TEXT STYLES ===================
  static const TextStyle headline1 = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w700,
    color: textPrimary, fontFamily: 'Poppins',
  );
  static const TextStyle headline2 = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w600,
    color: textPrimary, fontFamily: 'Poppins',
  );
  static const TextStyle headline3 = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600,
    color: textPrimary, fontFamily: 'Poppins',
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w400,
    color: textPrimary, fontFamily: 'Poppins',
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: textPrimary, fontFamily: 'Poppins',
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: textSecondary, fontFamily: 'Poppins',
  );
  static const TextStyle caption = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w400,
    color: textHint, fontFamily: 'Poppins',
  );
  static const TextStyle buttonText = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: Colors.white, fontFamily: 'Poppins',
  );

  // =================== THEME DATA ===================
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      error: error,
      background: background,
      surface: cardBackground,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w600,
        color: Colors.white, fontFamily: 'Poppins',
      ),
    ),
    cardTheme: CardThemeData( 
      color: cardBackground,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: buttonText,
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error),
      ),
      hintStyle: const TextStyle(color: textHint, fontFamily: 'Poppins'),
    ),
    dividerTheme: const DividerThemeData(color: divider, thickness: 1),
  );

  // =================== DECORATIONS ===================
  static BoxDecoration get gradientDecoration => const BoxDecoration(
    gradient: LinearGradient(
      colors: [primary, primaryDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static BoxDecoration cardDecoration({Color? color, double radius = 16}) =>
      BoxDecoration(
        color: color ?? cardBackground,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );
}
