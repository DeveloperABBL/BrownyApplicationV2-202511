import 'package:browny_applications_new/core/res/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Utility class สำหรับจัดการ Overlay widgets
/// เช่น Loading indicator, Custom dialogs, Toast messages
class AppOverlays {
  // Private constructor เพื่อป้องกันการสร้าง instance
  AppOverlays._();

  // เก็บ OverlayEntry สำหรับ loading indicator
  static OverlayEntry? _loadingOverlay;

  /// แสดง Loading overlay แบบเต็มหน้าจอ
  ///
  /// [context] - BuildContext สำหรับการแสดงผล
  /// [message] - ข้อความที่จะแสดงใต้ loading indicator (ถ้ามี)
  /// [barrierDismissible] - กำหนดว่าสามารถปิด overlay ด้วยการแตะพื้นหลังได้หรือไม่
  static void showLoading(
    BuildContext context, {
    String? message,
    bool barrierDismissible = false,
  }) {
    // ถ้ามี loading อยู่แล้ว ไม่ต้องแสดงซ้ำ
    if (_loadingOverlay != null) return;

    _loadingOverlay = OverlayEntry(
      builder: (context) => _LoadingOverlay(
        message: message,
        barrierDismissible: barrierDismissible,
        onDismiss: hideLoading,
      ),
    );

    Overlay.of(context).insert(_loadingOverlay!);
  }

  /// ซ่อน Loading overlay
  static void hideLoading() {
    _loadingOverlay?.remove();
    _loadingOverlay = null;
  }

  /// แสดง Custom overlay widget
  ///
  /// [context] - BuildContext สำหรับการแสดงผล
  /// [builder] - Function สำหรับสร้าง widget ที่จะแสดงใน overlay
  /// [barrierColor] - สีของพื้นหลัง overlay
  /// [barrierDismissible] - กำหนดว่าสามารถปิด overlay ด้วยการแตะพื้นหลังได้หรือไม่
  ///
  /// Returns OverlayEntry ที่สามารถใช้เพื่อควบคุม overlay ได้
  static OverlayEntry showCustomOverlay(
    BuildContext context, {
    required Widget Function(VoidCallback dismiss) builder,
    Color? barrierColor,
    bool barrierDismissible = true,
  }) {
    late OverlayEntry overlayEntry;

    void dismiss() {
      overlayEntry.remove();
    }

    overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: barrierDismissible ? dismiss : null,
        child: Material(
          color: barrierColor ?? Colors.black.withOpacity(0.5),
          child: GestureDetector(
            onTap: () {}, // ป้องกันการ dismiss เมื่อแตะที่ content
            child: builder(dismiss),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    return overlayEntry;
  }

  /// แสดง Toast message แบบสั้นๆ
  ///
  /// [context] - BuildContext สำหรับการแสดงผล
  /// [message] - ข้อความที่จะแสดง
  /// [duration] - ระยะเวลาที่จะแสดง toast (default: 2 วินาที)
  /// [backgroundColor] - สีพื้นหลังของ toast
  /// [textColor] - สีตัวอักษร
  static void showToast(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color? textColor,
  }) {
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        left: 20,
        right: 20,
        child: _ToastWidget(
          message: message,
          backgroundColor: backgroundColor ?? AppColors.darkBrown,
          textColor: textColor ?? Colors.white,
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // ลบ toast หลังจากเวลาที่กำหนด
    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  /// แสดง Dialog แบบกำหนดเอง (Browny Coin Dialog)
  ///
  /// [context] - BuildContext สำหรับการแสดงผล
  /// [title] - หัวข้อของ dialog (ไม่บังคับ)
  /// [message] - ข้อความที่จะแสดงใน dialog
  /// [confirmText] - ข้อความปุ่มยืนยัน (default: "รับทราบ")
  /// [cancelText] - ข้อความปุ่มยกเลิก (ถ้ามี)
  /// [onConfirm] - Callback เมื่อกดปุ่มยืนยัน
  /// [onCancel] - Callback เมื่อกดปุ่มยกเลิก
  /// [barrierDismissible] - กำหนดว่าสามารถปิด dialog ด้วยการแตะพื้นหลังได้หรือไม่
  ///
  /// Returns Future<bool?> - true ถ้ากดยืนยัน, false ถ้ากดยกเลิก, null ถ้าปิดด้วยวิธีอื่น
  static Future<bool?> showBrownyDialog(
    BuildContext context, {
    String? title,
    required String message,
    String confirmText = 'รับทราบ',
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
    Widget? image,
    String? imageAsset,
  }) async {
    late OverlayEntry overlayEntry;
    bool? result;

    void dismiss([bool? value]) {
      result = value;
      overlayEntry.remove();
    }

    overlayEntry = OverlayEntry(
      builder: (context) => _BrownyDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        image: image,
        imageAsset: imageAsset,
        onConfirm: () {
          onConfirm?.call();
          dismiss(true);
        },
        onCancel: cancelText != null
            ? () {
                onCancel?.call();
                dismiss(false);
              }
            : null,
        onDismiss: barrierDismissible ? () => dismiss(null) : null,
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // รอจนกว่า dialog จะถูกปิด
    while (overlayEntry.mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return result;
  }
}

/// Widget สำหรับแสดง Loading overlay
class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({
    this.message,
    required this.barrierDismissible,
    required this.onDismiss,
  });

  final String? message;
  final bool barrierDismissible;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: barrierDismissible ? onDismiss : null,
      child: Material(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // ป้องกันการ dismiss เมื่อแตะที่ loading indicator
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget สำหรับแสดง Toast message
class _ToastWidget extends StatelessWidget {
  const _ToastWidget({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
  });

  final String message;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Widget สำหรับแสดง Browny Dialog
class _BrownyDialog extends StatelessWidget {
  const _BrownyDialog({
    this.title,
    required this.message,
    required this.confirmText,
    this.cancelText,
    required this.onConfirm,
    this.onCancel,
    this.onDismiss,
    this.image,
    this.imageAsset,
  });

  final String? title;
  final String message;
  final String confirmText;
  final String? cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onDismiss;
  final Widget? image;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Material(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // ป้องกันการปิด dialog เมื่อแตะที่ content
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // รูป Browny Mascot
                  image ??
                      Image.asset(
                        imageAsset ?? '',
                        width: 120.w,
                        height: 120.h,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) {
                          // Fallback ถ้าไม่มีรูป
                          return SizedBox();
                        },
                      ),
                  const SizedBox(height: 16),

                  // Title (ถ้ามี)
                  if (title != null) ...[
                    Text(
                      title!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Message
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  if (cancelText != null && onCancel != null) ...[
                    // มีทั้งปุ่มยืนยันและยกเลิก
                    Row(
                      children: [
                        // ปุ่มยกเลิก (พื้นหลังสีขาว, border สีเขียว)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onCancel,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              cancelText!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // ปุ่มยืนยัน (พื้นหลังสีเขียว)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onConfirm,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              confirmText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // มีแค่ปุ่มยืนยัน
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onConfirm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          confirmText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
