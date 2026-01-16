import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:browny_applications_new/res/dims/app_dims.dart';
import 'package:flutter/material.dart';

/// วิดเจ็ตคอนเทนเนอร์ที่มีมุมโค้งแบบกำหนดเอง
///
/// วิดเจ็ตนี้สร้างคอนเทนเนอร์ที่มีความสูง ความกว้าง สี และมุมโค้งที่สามารถปรับแต่งได้
/// หากไม่ได้กำหนดค่า จะใช้ค่าเริ่มต้นดังนี้:
/// - ความกว้าง: double.infinity (เต็มความกว้างที่มี)
/// - สี: AppColors.background
/// - มุมโค้ง: โค้งเฉพาะมุมบนซ้ายและบนขวาด้วยรัศมี AppDims.primaryRadius
///
/// พารามิเตอร์:
/// - [height]: ความสูงของคอนเทนเนอร์ (ไม่บังคับ)
/// - [width]: ความกว้างของคอนเทนเนอร์ (ไม่บังคับ)
/// - [color]: สีพื้นหลังของคอนเทนเนอร์ (ไม่บังคับ)
/// - [borderRadius]: รัศมีมุมโค้งแบบกำหนดเอง (ไม่บังคับ)
class AppContainerRadius extends StatelessWidget {
  const AppContainerRadius({
    super.key,
    this.height,
    this.width,
    this.color,
    this.borderRadius,
    this.child,
    this.alignment,
    this.padding,
    this.margin,
    this.decoration,
    this.foregroundDecoration,
    this.constraints,
    this.transform,
    this.transformAlignment,
    this.clipBehavior = Clip.none,
  });

  final double? height;
  final double? width;
  final Color? color;
  final BorderRadius? borderRadius;
  final Widget? child;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final BoxConstraints? constraints;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      alignment: alignment,
      padding: padding,
      margin: margin,
      decoration:
          decoration ??
          BoxDecoration(
            color: color ?? AppColors.background,
            borderRadius:
                borderRadius ??
                BorderRadius.only(
                  topLeft: Radius.circular(AppDims.primaryRadius),
                  topRight: Radius.circular(AppDims.primaryRadius),
                ),
          ),
      foregroundDecoration: foregroundDecoration,
      constraints: constraints,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}
