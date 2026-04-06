import 'package:browny_applications_new/res/dims/app_dims.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors/app_colors.dart';

/// App text styles based on Mitr font family from Google Fonts
class AppTextStyles {
  AppTextStyles._();

  // Display styles
  static TextStyle displayLarge = GoogleFonts.mitr(
    fontSize: 32.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle displayMedium = GoogleFonts.mitr(
    fontSize: 28.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle displaySmall = GoogleFonts.mitr(
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Headline styles
  static TextStyle headlineLarge = GoogleFonts.mitr(
    fontSize: 22.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineMedium = GoogleFonts.mitr(
    fontSize: 20.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineSmall = GoogleFonts.mitr(
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Title styles
  static TextStyle titleLarge = GoogleFonts.mitr(
    fontSize: 18.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle titleMedium = GoogleFonts.mitr(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle titleSmall = GoogleFonts.mitr(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // Body styles
  static TextStyle bodyLarge = GoogleFonts.mitr(
    fontSize: 16.sp,
    fontWeight: FontWeight.w300,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = GoogleFonts.mitr(
    fontSize: 14.sp,
    fontWeight: FontWeight.w300,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySmall = GoogleFonts.mitr(
    fontSize: 12.sp,
    fontWeight: FontWeight.w300,
    color: AppColors.textSecondary,
  );

  // Label styles
  static TextStyle labelLarge = GoogleFonts.mitr(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle labelMedium = GoogleFonts.mitr(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle labelSmall = GoogleFonts.mitr(
    fontSize: 10.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}

/// App text number styles based on Prompt font family from Google Fonts
/// ใช้สำหรับตัวเลข เพื่อให้อ่านง่ายและชัดเจน
class AppTextNumberStyles {
  AppTextNumberStyles._();

  // Display styles
  static TextStyle displayLarge = GoogleFonts.prompt(
    fontSize: 32.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle displayMedium = GoogleFonts.prompt(
    fontSize: 28.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle displaySmall = GoogleFonts.prompt(
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Headline styles
  static TextStyle headlineLarge = GoogleFonts.prompt(
    fontSize: 22.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineMedium = GoogleFonts.prompt(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineSmall = GoogleFonts.prompt(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Title styles
  static TextStyle titleLarge = GoogleFonts.prompt(
    fontSize: 24.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle titleMedium = GoogleFonts.prompt(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle titleSmall = GoogleFonts.prompt(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // Body styles
  static TextStyle bodyLarge = GoogleFonts.prompt(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = GoogleFonts.prompt(
    fontSize: 14.sp,
    fontWeight: FontWeight.w300,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySmall = GoogleFonts.prompt(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Label styles
  static TextStyle labelLarge = GoogleFonts.prompt(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle labelMedium = GoogleFonts.prompt(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle labelSmall = GoogleFonts.prompt(
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}

class AppElevatedButtonStyle {
  static ButtonStyle defaultStyle =
      ElevatedButton.styleFrom(
        // maximumSize: Size(double.infinity, AppDims.size_40.h),
        minimumSize: Size(double.infinity, AppDims.size_42.h),
        backgroundColor: AppColors.ctaPrimaryDefault,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.ctaPrimaryDisable,
        disabledForegroundColor: AppColors.white,
        elevation: 0,
        shadowColor: AppColors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        textStyle: AppTextStyles.labelLarge,
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.ctaPrimaryHover.withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColors.ctaPrimaryClicked.withValues(alpha: 0.7);
            }
            return null;
          },
        ),
      );

  static ButtonStyle buttomBackStyle =
      ElevatedButton.styleFrom(
        backgroundColor: AppColors.transparent,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.ctaPrimaryDisable,
        disabledForegroundColor: AppColors.white,
        elevation: 0,
        shadowColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        textStyle: AppTextStyles.labelLarge,
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.gradientStart.withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColors.gradientStart.withValues(alpha: 0.7);
            }
            return null;
          },
        ),
      );

  static ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: AppColors.ctaPrimaryDefault,
    minimumSize: Size(double.infinity, AppDims.size_40.h),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    textStyle: AppTextStyles.labelLarge,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.r),
    ),
  );

  static ButtonStyle outlineButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AppColors.ctaPrimaryDefault,
    minimumSize: Size(double.infinity, AppDims.size_40.h),
    side: const BorderSide(
      color: AppColors.ctaPrimaryDefault,
      width: 1.5,
    ),
    // padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.r),
    ),
    textStyle: AppTextStyles.labelLarge,
  );
}
