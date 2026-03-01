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

  /// Container Coin gradient - linear-gradient(90deg, rgba(255, 255, 255, 0) 0%, rgba(255, 255, 255, 0.1) 100%)
  static const LinearGradient containerCoinGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0x00FFFFFF), // rgba(255, 255, 255, 0) - สีขาวโปร่งใสสนิท
      Color(0x1AFFFFFF), // rgba(255, 255, 255, 0.1) - สีขาวโปร่งใส 10%
    ],
    stops: [0.0, 1.0],
  );

  /// Claim Coin Button gradient - Alias ของ yellowToGreenGradient สำหรับปุ่ม Claim Coin
  static const LinearGradient claimCoinButtonGradient = LinearGradient(
    // 91.26deg ใน CSS คือเกือบจะเป็นแนวนอน (Left to Right)
    // การใช้ Alignment.centerLeft ไป centerRight ให้ผลลัพธ์ที่สะอาดและใกล้เคียงที่สุด
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,

    colors: [
      Color(0xFFD4CF46), // -0.38%
      Color(0xFF87CE45), // 47.14%
      Color(0xFF24B52D), // 105.71%
    ],

    stops: [
      0.0, // แปลงจาก -0.38% (ใน Flutter เริ่มที่ 0.0)
      0.4714, // แปลงจาก 47.14%
      1.0, // แปลงจาก 105.71% (ใน Flutter จบที่ 1.0)
    ],

    // หมายเหตุ: หากต้องการความเป๊ะแบบ Pixel Perfect ตาม Figma จริงๆ
    // โดยยอมให้ค่าเกินขอบเขต 0-1 สามารถใช้ stops ด้านล่างนี้แทนได้:
    // stops: [-0.0038, 0.4714, 1.0571],
  );

  /// Purchase Background gradient - linear-gradient(91.26deg, rgba(212, 207, 70, 0.5) -0.38%, rgba(135, 206, 69, 0.5) 47.14%, rgba(36, 181, 45, 0.5) 105.71%)
  static const LinearGradient purchaseBackgroundGradient = LinearGradient(
    // คำนวณจาก 91.26deg
    begin: Alignment(-1.0, -0.04), // ประมาณค่าจากองศาที่เกิน 90 มานิดหน่อย
    end: Alignment(1.0, 0.04),
    colors: [
      Color(0x80D4CF46), // rgba(212, 207, 70, 0.5)
      Color(0x8087CE45), // rgba(135, 206, 69, 0.5)
      Color(0x8024B52D), // rgba(36, 181, 45, 0.5)
    ],
    stops: [
      0.0, // -0.38% (ปัดเป็น 0.0 สำหรับขอบด้านซ้ายสุด)
      0.4714, // 47.14%
      1.0, // 105.71% (ปัดเป็น 1.0 สำหรับขอบด้านขวาสุด)
    ],
  );

  /// Popup gradient - linear-gradient(360deg, #FFFFFF 21.94%, #BFF298 95.02%, #23AE2C 130.51%)
  static LinearGradient popupGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color(0xFFFFFFFF), // #FFFFFF
      Color(0xFFBFF298), // #BFF298
    ],
    stops: [
      0.2194, // 21.94%
      0.9502, // 95.02%
    ],
  );

  static List<BoxShadow> get defatultShadow => [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.2),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  static List<BoxShadow> get shadowOnlyTop => [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.2), // Shadow color and opacity
      blurRadius: 16, // The softness of the shadow
      offset: Offset(0, -7), // Negative Y offset shifts the shadow upwards
    ),
  ];

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

  static const Color bareBackground = Color(0xFFEFEFEF); // #EFEFEF

  static const Color walletBackgroundClicked = Color.fromARGB(
    255,
    0,
    91,
    176,
  ); // #FFFFFF

  static const Color walletBackgroundHover = Color.fromARGB(
    255,
    13,
    82,
    146,
  ); // #FFFFFF

  static const Color walletBackground = darkBlue; // #FFFFFF

  /// สีพื้นหลังสำหรับ Product Card
  static const Color productBackground = Color(0xFFFFFFFF); // #FFFFFF

  // ============================================================================
  // Text Colors
  // ============================================================================

  /// สีข้อความหลัก (น้ำตาลเข้ม)
  static const Color textPrimary = Color(0xFF593817); // #593817 (Dark Brown)

  /// สีข้อความรอง (เทา)
  static const Color textSecondary = Color(0xFF777777); // #777777

  static const Color textBlack = black2A; // #777777

  static const Color textWhite = white; // #777777

  static const Color textBare = Color(0xFF555555); // ##555555

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

  static const Color transparent = Colors.transparent;

  /// White
  static const Color white = Color(0xFFFFFFFF); // #FFFFFF

  /// Black
  static const Color black = Color(0xFF000000); // #000000

  /// Black สำหรับ Text
  static const Color black2A = Color(0xFF2A2A2A); // #2A2A2A

  /// Green 400 (จากคำอธิบาย แต่ค่าคือ #DFDFDF ซึ่งเป็นเทาอ่อน - ใช้ตามข้อมูลที่ให้มา)
  static const Color green400 = Color(0xFFDFDFDF); // #DFDFDF

  /// Gray 500
  static const Color gray500 = Color(0xFF949494); // #949494

  /// Gray 600
  static const Color gray600 = Color(0xFF777777); // #777777

  /// Gray 400
  static const Color gray400 = Color(0xFFCDCDCD); // #CDCDCD

  /// CI (Corporate Identity) - สีเขียวหลัก
  static const Color ci = Color(0xFF2FBA38); // #2FBA38

  static const Color ci2 = Color(0xFF8FCB8A); // #8FCB8A

  static const Color ci3 = Color(0xFFD8FDE8); // #D8FDE8

  static const Color ci4 = Color(0xFF8CCE45); // #8CCE45

  static const Color ci5 = Color(0xFFA6DFAA); // #A6DFAA

  static const Color ci6 = Color(0xFFC9F3CB); // #C9F3CB

  static const Color ci7 = Color(0xFFABF0AF); // #ABF0AF

  /// Dark Brown
  static const Color darkBrown = Color(0xFF593817); // #593817

  /// Dark Blue wallet background
  static const Color darkBlue = Color(0xFF002A52); // #002A52

  static const Color paleOrange = Color(0xFFFFDCC2); // #FFDCC2

  static const Color cocoaBrown = Color(0xFFCC6E29); // #CC6E29

  static const Color yellow = Color(0xFFF5E221); // #F5E221

  static const Color yellow2 = Color(0xFFFFCD46); // #FFCD46

  static const Color yellow3 = Color(0xFFFFC21F); // #FFC21F

  // ============================================================================
  // Status Colors
  // ============================================================================

  /// สีแสดงสถานะ Error
  static const Color error = Color(0xFFE02A48); // #E02A48

  static const Color walletButtonForegroundColor = paleOrange; // #FF334B
}
