import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App text styles based on Manrope font family from Google Fonts
class AppTextStyles {
  AppTextStyles._();

  static final TextStyle _getTextStyleByFontFamily = GoogleFonts.mitr();

  // Display styles (for large headings)
  static TextStyle displayLarge = _getTextStyleByFontFamily.copyWith(
    fontSize: 57,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static TextStyle displayMedium = _getTextStyleByFontFamily.copyWith(
    fontSize: 45,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    height: 1.16,
  );

  static TextStyle displaySmall = _getTextStyleByFontFamily.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    height: 1.22,
  );

  // Headline styles (for section headings)
  static TextStyle headlineLarge = _getTextStyleByFontFamily.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.056,
    height: 1.25,
  );

  static TextStyle headlineMedium = _getTextStyleByFontFamily.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.29,
  );

  static TextStyle headlineSmall = _getTextStyleByFontFamily.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.33,
  );

  // Title styles (for card headers, dialog titles)
  static TextStyle titleLarge = _getTextStyleByFontFamily.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );

  static TextStyle titleMedium = _getTextStyleByFontFamily.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.50,
  );

  static TextStyle titleSmall = _getTextStyleByFontFamily.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // Body styles (for body text)
  static TextStyle bodyLarge = _getTextStyleByFontFamily.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.50,
  );

  static TextStyle bodyMedium = _getTextStyleByFontFamily.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static TextStyle bodySmall = _getTextStyleByFontFamily.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // Label styles (for labels, buttons)
  static TextStyle labelLarge = _getTextStyleByFontFamily.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static TextStyle labelMedium = _getTextStyleByFontFamily.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static TextStyle labelSmall = _getTextStyleByFontFamily.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // Button text style
  static TextStyle button = _getTextStyleByFontFamily.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.50,
  );

  // Input text style
  static TextStyle input = _getTextStyleByFontFamily.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.50,
  );

  // Caption style (for helper text, captions)
  static TextStyle caption = _getTextStyleByFontFamily.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // Overline style (for overline text)
  static TextStyle overline = _getTextStyleByFontFamily.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.60,
  );

  // Additional button styles
  static TextStyle buttonSmall = _getTextStyleByFontFamily.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    height: 1.43,
  );

  static TextStyle buttonLarge = _getTextStyleByFontFamily.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.56,
  );
}
