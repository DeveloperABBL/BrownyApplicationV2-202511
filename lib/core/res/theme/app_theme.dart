import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors/app_colors.dart';

/// AppTheme - จัดการ ThemeData สำหรับแอป Browny
class AppTheme {
  AppTheme._();

  /// Light Theme สำหรับแอป Browny
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // ============================================================================
      // Color Scheme
      // ============================================================================
      colorScheme: ColorScheme.light(
        primary: AppColors.ctaPrimaryDefault,
        onPrimary: AppColors.white,
        primaryContainer: AppColors.ctaPrimaryHover,
        onPrimaryContainer: AppColors.white,
        secondary: AppColors.ctaPrimaryDefault,
        onSecondary: AppColors.white,
        error: AppColors.error,
        onError: AppColors.white,
        surface: AppColors.background,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.inputFieldDefaultBg,
        outline: AppColors.border,
        outlineVariant: AppColors.inputFieldDefaultBorder,
      ),

      // ============================================================================
      // Scaffold
      // ============================================================================
      scaffoldBackgroundColor: AppColors.background,

      // ============================================================================
      // AppBar
      // ============================================================================
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.mitr(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),

      // ============================================================================
      // Text Theme
      // ============================================================================
      textTheme: TextTheme(
        // Display styles
        displayLarge: GoogleFonts.mitr(
          fontSize: 32.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.mitr(
          fontSize: 28.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        displaySmall: GoogleFonts.mitr(
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),

        // Headline styles
        headlineLarge: GoogleFonts.mitr(
          fontSize: 22.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.mitr(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.mitr(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),

        // Title styles
        titleLarge: GoogleFonts.mitr(
          fontSize: 24.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.mitr(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: GoogleFonts.mitr(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),

        // Body styles
        bodyLarge: GoogleFonts.mitr(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.mitr(
          fontSize: 14.sp,
          fontWeight: FontWeight.w300,
          color: AppColors.textPrimary,
        ),
        bodySmall: GoogleFonts.mitr(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),

        // Label styles
        labelLarge: GoogleFonts.mitr(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        labelMedium: GoogleFonts.mitr(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        labelSmall: GoogleFonts.mitr(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),

      // ============================================================================
      // Input Decoration Theme
      // ============================================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFieldDefaultBg,

        // Border styles
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.inputFieldDefaultBorder,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.inputFieldDefaultBorder,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.inputFieldFocusedBorder,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.inputFieldInvalidBorder,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.inputFieldInvalidBorder,
            width: 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.inputFieldDisableBorder,
            width: 1,
          ),
        ),

        // Text styles
        hintStyle: GoogleFonts.mitr(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelStyle: GoogleFonts.mitr(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        errorStyle: GoogleFonts.mitr(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.error,
        ),

        // Icon theme
        iconColor: AppColors.inputFieldDefaultIcon,
        prefixIconColor: AppColors.inputFieldDefaultIcon,
        suffixIconColor: AppColors.inputFieldDefaultIcon,

        // Content padding
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // ============================================================================
      // Elevated Button Theme
      // ============================================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: AppColors.ctaPrimaryDefault,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.ctaPrimaryDisable,
              disabledForegroundColor: AppColors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.mitr(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.hovered)) {
                    return AppColors.ctaPrimaryHover.withOpacity(0.1);
                  }
                  if (states.contains(WidgetState.pressed)) {
                    return AppColors.ctaPrimaryClicked.withOpacity(0.2);
                  }
                  return null;
                },
              ),
            ),
      ),

      // ============================================================================
      // Text Button Theme
      // ============================================================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ctaPrimaryDefault,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.mitr(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ============================================================================
      // Outlined Button Theme
      // ============================================================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ctaPrimaryDefault,
          side: const BorderSide(
            color: AppColors.ctaPrimaryDefault,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.mitr(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ============================================================================
      // Checkbox Theme
      // ============================================================================
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.checkboxSelectedDisableBg;
            }
            if (states.contains(WidgetState.selected)) {
              return AppColors.checkboxSelectedBg;
            }
            return AppColors.checkboxUnselectedBg;
          },
        ),
        checkColor: WidgetStateProperty.all(AppColors.white),
        side: WidgetStateBorderSide.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return const BorderSide(
                color: AppColors.checkboxSelectedBg,
                width: 2,
              );
            }
            return const BorderSide(
              color: AppColors.checkboxUnselectedBorder,
              width: 2,
            );
          },
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // ============================================================================
      // Radio Theme
      // ============================================================================
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.checkboxSelectedDisableBg;
            }
            if (states.contains(WidgetState.selected)) {
              return AppColors.checkboxSelectedBg;
            }
            return AppColors.checkboxUnselectedBorder;
          },
        ),
      ),

      // ============================================================================
      // Card Theme
      // ============================================================================
      cardTheme: CardThemeData(
        color: AppColors.productBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: AppColors.productStroke,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ============================================================================
      // Divider Theme
      // ============================================================================
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // ============================================================================
      // Icon Theme
      // ============================================================================
      iconTheme: const IconThemeData(
        color: AppColors.primary,
        size: 24,
      ),

      // ============================================================================
      // Bottom Navigation Bar Theme
      // ============================================================================
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.ctaPrimaryDefault,
        unselectedItemColor: AppColors.textSecondary,
        selectedIconTheme: const IconThemeData(
          color: AppColors.ctaPrimaryDefault,
          size: 24,
        ),
        unselectedIconTheme: const IconThemeData(
          color: AppColors.textSecondary,
          size: 24,
        ),
        selectedLabelStyle: GoogleFonts.mitr(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.mitr(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ============================================================================
      // Dialog Theme
      // ============================================================================
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.background,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: GoogleFonts.mitr(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: GoogleFonts.mitr(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
      ),

      // ============================================================================
      // Snackbar Theme
      // ============================================================================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.mitr(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // ============================================================================
      // Floating Action Button Theme
      // ============================================================================
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.ctaPrimaryDefault,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
    );
  }
}
