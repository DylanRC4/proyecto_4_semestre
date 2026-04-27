/// Temas claro y oscuro de la aplicación.
/// Paleta: Rojo Radical (#FF1744) + Carbon Profundo (#121212).
import 'package:flutter/material.dart';

class AppTheme {
  static const _radicalRed = Color(0xFFFF1744);
  static const _flashYellow = Color(0xFFFFEA00);
  static const _deepCarbon = Color(0xFF121212);
  static const _elevatedGray = Color(0xFF1E1E1E);
  static const _silverMist = Color(0xFFBDBDBD);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _radicalRed,
      primary: _radicalRed,
      secondary: _flashYellow,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: _deepCarbon,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: _deepCarbon),
        actionsIconTheme: IconThemeData(color: _deepCarbon),
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: _deepCarbon,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _radicalRed,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _radicalRed,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(color: _radicalRed.withValues(alpha: 0.5)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _radicalRed, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(color: Colors.grey.shade600),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: _radicalRed,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        showCheckmark: false,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: _deepCarbon,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 0.5,
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _radicalRed,
      primary: _radicalRed,
      secondary: _flashYellow,
      brightness: Brightness.dark,
      surface: _elevatedGray,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: _deepCarbon,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: _elevatedGray,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _radicalRed,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _radicalRed,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(color: _radicalRed.withValues(alpha: 0.5)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _elevatedGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _radicalRed, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: _silverMist),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _elevatedGray,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade800),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _elevatedGray,
        selectedColor: _radicalRed,
        labelStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
        secondaryLabelStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
        side: BorderSide(color: Colors.grey.shade700),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        showCheckmark: false,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade800,
        thickness: 0.5,
      ),
    );
  }
}