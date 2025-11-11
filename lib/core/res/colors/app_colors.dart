import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ============================================================================
  // Primary Gradient Colors (from Figma)
  // ============================================================================

  /// Primary gradient - linear-gradient(161.35deg, #82C346 -0.78%, #50B748 37.72%, #26A14C 98.07%)
  static const Color gradientStart = Color(0xFF82C346); // #82C346
  static const Color gradientMiddle = Color(0xFF50B748); // #50B748
  static const Color gradientEnd = Color(0xFF26A14C); // #26A14C

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    transform: GradientRotation(161.35 * 3.14159 / 90), // 161.35 degrees
    colors: [
      gradientStart, // -0.78%
      gradientMiddle, // 37.72%
      gradientEnd, // 98.07%
    ],
    stops: [
      -0.0078, // -0.78%
      0.3772, // 37.72%
      0.9807, // 98.07%
    ],
  );

  /// Secondary gradient - linear-gradient(91.26deg, #D4CF46 -0.38%, #87CE45 47.14%, #24B52D 105.71%)
  static const LinearGradient yellowToGreenGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    transform: GradientRotation(91.26 * 3.14159 / 180), // 91.26 degrees
    colors: [
      Color(0xFFD4CF46), // #D4CF46 Yellow
      Color(0xFF87CE45), // #87CE45 Light Green
      Color(0xFF24B52D), // #24B52D Green
    ],
    stops: [
      -0.0038, // -0.38%
      0.4714, // 47.14%
      1.0571, // 105.71%
    ],
  );

  // ============================================================================
  // Primary CTA Colors
  // ============================================================================

  /// CTA Primary Default - สีหลักสำหรับปุ่มกด
  static const Color ctaPrimaryDefault = Color(0xFF2FBA38); // #2FBA38

  /// CTA Primary Hover - สีเมื่อ hover
  static const Color ctaPrimaryHover = Color(0xFF36D341); // #36D341

  /// CTA Primary Clicked - สีเมื่อกด
  static const Color ctaPrimaryClicked = Color(0xFF28A530); // #28A530

  /// CTA Primary Disable - สีเมื่อ disable
  static const Color ctaPrimaryDisable = Color(0xFFD3D3D3); // #D3D3D3

  /// Alias: Primary color (ชี้ไปที่ CTA Default)
  static const Color primary = ctaPrimaryDefault;

  // ============================================================================
  // Background Colors
  // ============================================================================

  /// สีพื้นหลังหลัก (ขาว)
  static const Color background = Color(0xFFFFFFFF); // #FFFFFF

  /// สีพื้นหลังสำหรับ Product Card
  static const Color productBackground = Color(0xFFFFFFFF); // #FFFFFF

  // ============================================================================
  // Text Colors
  // ============================================================================

  /// สีข้อความหลัก (น้ำตาลเข้ม)
  static const Color textPrimary = Color(0xFF593817); // #593817 (Dark Brown)

  /// สีข้อความรอง (เทา)
  static const Color textSecondary = Color(0xFF777777); // #777777

  // ============================================================================
  // Border/Stroke Colors
  // ============================================================================

  /// สีขอบปกติ (เทาอ่อน)
  static const Color border = Color(0xFFCDCDCD); // #CDCDCD

  /// สีขอบ Product Card
  static const Color productStroke = Color(0xFFDFDFDF); // #DFDFDF

  /// สีขอบเมื่อเกิด Error/Invalid
  static const Color borderError = Color(0xFFFF334B); // #FF334B

  /// Alias: Invalid Border
  static const Color invalidBorder = borderError;

  // ============================================================================
  // Checkbox & Radio Colors
  // ============================================================================

  /// Checkbox Unselected Enable - พื้นหลัง
  static const Color checkboxUnselectedBg = Color(0xFFFFFFFF); // #FFFFFF

  /// Checkbox Unselected Enable - ขอบ
  static const Color checkboxUnselectedBorder = Color(0xFFCDCDCD); // #CDCDCD

  /// Checkbox Selected Enable - พื้นหลัง
  static const Color checkboxSelectedBg = Color(0xFF2FBA38); // #2FBA38

  /// Checkbox Selected Disable - พื้นหลัง
  static const Color checkboxSelectedDisableBg = Color(0xFFD3D3D3); // #D3D3D3

  // ============================================================================
  // Input Field Colors
  // ============================================================================

  /// Input Field Default - พื้นหลัง
  static const Color inputFieldDefaultBg = Color(0xFFF5F5F5); // #F5F5F5

  /// Input Field Default - ขอบ
  static const Color inputFieldDefaultBorder = Color(0xFFB3B3B3); // #B3B3B3

  /// Input Field Default - ไอคอน
  static const Color inputFieldDefaultIcon = Color(0xFF777777); // #777777

  /// Input Field Focused - ขอบและไอคอน
  static const Color inputFieldFocusedBorder = Color(0xFF000000); // #000000
  static const Color inputFieldFocusedIcon = Color(0xFF000000); // #000000

  /// Input Field Active - ขอบและไอคอน
  static const Color inputFieldActiveBorder = Color(0xFF000000); // #000000
  static const Color inputFieldActiveIcon = Color(0xFF000000); // #000000

  /// Input Field Invalid - ขอบ
  static const Color inputFieldInvalidBorder = Color(0xFFFF334B); // #FF334B

  /// Input Field Valid - ขอบ
  static const Color inputFieldValidBorder = Color(0xFF2FBA38); // #2FBA38

  /// Input Field Disable - พื้นหลัง
  static const Color inputFieldDisableBg = Color(0xFFFCFCFC); // #FCFCFC

  /// Input Field Disable - ข้อความ, ขอบ, ไอคอน
  static const Color inputFieldDisableText = Color(0xFFD3D3D3); // #D3D3D3
  static const Color inputFieldDisableBorder = Color(0xFFD3D3D3); // #D3D3D3
  static const Color inputFieldDisableIcon = Color(0xFFD3D3D3); // #D3D3D3

  // ============================================================================
  // Overlay Colors
  // ============================================================================

  /// Overlay สีดำโปร่งแสง 50%
  static const Color overlay = Color(0x80000000); // #000000 50%

  // ============================================================================
  // Product/Wishlist Colors
  // ============================================================================

  /// Wishlist Gray (ไม่ได้เลือก)
  static const Color wishlistGray = Color(0xFFCDCDCD); // #CDCDCD

  /// Wishlist CI (เลือกแล้ว)
  static const Color wishlistCi = Color(0xFF2FBA38); // #2FBA38

  /// Product Text Color
  static const Color productText = Color(0xFF593817); // #593817 (Dark Brown)

  // ============================================================================
  // Filter/Category Colors
  // ============================================================================

  /// White
  static const Color white = Color(0xFFFFFFFF); // #FFFFFF

  /// Green 400 (จากคำอธิบาย แต่ค่าคือ #DFDFDF ซึ่งเป็นเทาอ่อน - ใช้ตามข้อมูลที่ให้มา)
  static const Color green400 = Color(0xFFDFDFDF); // #DFDFDF

  /// Gray 400
  static const Color gray400 = Color(0xFFCDCDCD); // #CDCDCD

  /// CI (Corporate Identity) - สีเขียวหลัก
  static const Color ci = Color(0xFF2FBA38); // #2FBA38

  /// Dark Brown
  static const Color darkBrown = Color(0xFF593817); // #593817

  // ============================================================================
  // Status Colors
  // ============================================================================

  /// สีแสดงสถานะ Error
  static const Color error = Color(0xFFFF334B); // #FF334B
}
