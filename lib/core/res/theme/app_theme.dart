import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors/app_colors.dart';
import '../styles/app_text_style.dart';

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
          color: AppColors.white,
          size: 24,
        ),
      ),

      // ============================================================================
      // Text Theme
      // ============================================================================
      textTheme: TextTheme(
        // Display styles
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,

        // Headline styles
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,

        // Title styles
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,

        // Body styles
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,

        // Label styles
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
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
        prefixIconConstraints: BoxConstraints.tight(
          Size(10.w, 45.h),
        ),
        // prefixIcon: Container(
        //   width: 0,
        // ),
        contentPadding: EdgeInsets.zero,
        errorMaxLines: 3,
      ),

      // ============================================================================
      // Elevated Button Theme
      // ============================================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppElevatedButtonStyle.defaultStyle,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
        backgroundColor: AppColors.primary,
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
