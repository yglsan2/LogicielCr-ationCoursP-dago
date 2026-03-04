import 'package:flutter/material.dart';

/// Charte graphique premium, mise en page inspirée des documents LaTeX :
/// typographie soignée, marges généreuses, rendu pro et lisible.
class AppTheme {
  static const Color primary = Color(0xFF1E3A5F);
  static const Color primaryDark = Color(0xFF0F2744);
  static const Color accent = Color(0xFF2D5A87);
  static const Color surface = Color(0xFFFAFAF9);
  static const Color surfaceVariant = Color(0xFFF3F3F2);
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color onSurfaceVariant = Color(0xFF5C5C5C);
  static const Color success = Color(0xFF0D7377);
  static const Color error = Color(0xFFC53030);

  /// Marges type document (contenu principal).
  static const EdgeInsets documentPadding = EdgeInsets.symmetric(horizontal: 24, vertical: 16);

  /// Marges pour les cartes / blocs à l’intérieur du document.
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(horizontal: 20, vertical: 8);

  /// Couleurs de surlignage type feutre fluo (pour blocs texte ou glossaire).
  static const Color highlighterYellow = Color(0x33FFEB3B);
  static const Color highlighterGreen = Color(0x338BC34A);
  static const Color highlighterPink = Color(0x33E91E63);
  static const Color highlighterBlue = Color(0x332196F3);
  static const Color highlighterOrange = Color(0x33FF9800);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        primaryContainer: accent,
        surface: surface,
        onSurface: onSurface,
        error: error,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        backgroundColor: surface,
        foregroundColor: onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        color: Colors.white,
        margin: cardMargin,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      textTheme: _buildTextTheme(),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: DividerThemeData(color: Colors.grey.shade200, thickness: 1),
    );
  }

  static TextTheme _buildTextTheme() {
    const letterSpacing = -0.2;
    return TextTheme(
      titleLarge: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onSurface,
        letterSpacing: letterSpacing,
      ),
      titleMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: onSurface,
        letterSpacing: letterSpacing,
      ),
      titleSmall: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: onSurface,
        letterSpacing: letterSpacing,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        height: 1.5,
        color: onSurface,
        letterSpacing: 0.1,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        height: 1.5,
        color: onSurface,
        letterSpacing: 0.1,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        height: 1.45,
        color: onSurfaceVariant,
        letterSpacing: 0.1,
      ),
    );
  }
}
