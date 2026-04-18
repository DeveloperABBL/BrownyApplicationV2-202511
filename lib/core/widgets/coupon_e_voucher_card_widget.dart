import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/widgets/app_text.dart';
import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:browny_applications_new/res/dims/app_dims.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CouponEVoucherCardWidget extends StatefulWidget {
  /// สถานะ enable/disable ของ card (true = disabled)
  final bool isDisabled;

  /// Widget icon ที่แสดงด้านซ้าย
  final Widget? icon;

  /// ชื่อหัวข้อ
  final String title;

  /// คำอธิบาย
  final String description;

  /// แสดง ระยะห่าง ถ้าไม่ส่งเข้ามา badge ระยะห่างจะไม่แสดง
  final String? distance;

  /// รายละเอียดการใช้งาน
  final String detailUsing;

  /// ข้อความวันหมดอายุ
  final String expired;

  /// ข้อความเงื่อนไข (ถ้าเป็น null หรือ empty จะไม่แสดง)
  final String? conditionText;

  /// Callback เมื่อแตะที่ข้อความเงื่อนไข
  final VoidCallback? onConditionTap;

  /// Callback เมื่อแตะที่ card
  final VoidCallback? onTap;

  /// Callback เมื่อแตะที่ Checkbox
  final ValueChanged<bool?>? onChanged;

  /// flag กำหนดว่าจะแสดง checkbox หรือไม่
  final bool showCheckBox;

  final Color? borderColor;

  final bool? initialChecked;

  const CouponEVoucherCardWidget({
    super.key,
    this.isDisabled = false,
    this.icon,
    required this.title,
    required this.description,
    required this.detailUsing,
    required this.expired,
    this.distance,
    this.onChanged,
    this.showCheckBox = false,
    this.conditionText,
    this.onConditionTap,
    this.onTap,
    this.borderColor,
    this.initialChecked,
  });

  @override
  State<CouponEVoucherCardWidget> createState() =>
      _CouponEVoucherCardWidgetState();
}

class _CouponEVoucherCardWidgetState extends State<CouponEVoucherCardWidget> {
  late bool checked;

  @override
  void initState() {
    super.initState();
    checked = widget.initialChecked ?? false;
  }

  @override
  void didUpdateWidget(covariant CouponEVoucherCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    checked = widget.initialChecked ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isDisabled ? null : widget.onTap,
      child: Container(
        foregroundDecoration: widget.isDisabled
            ? BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8.r),
                border: widget.borderColor != null
                    ? BoxBorder.all(color: widget.borderColor!)
                    : null,
                backgroundBlendMode: BlendMode.saturation,
              )
            : null,
        height: 86.h,
        margin: EdgeInsets.only(bottom: AppDims.size_12),
        decoration: BoxDecoration(
          border: BoxBorder.all(
            width: 1,
            color: widget.borderColor ?? AppColors.gray400,
          ),
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 85.w,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.r),
                  bottomLeft: Radius.circular(8.r),
                ),
              ),
              child: widget.icon,
            ),

            // Title, Description ต่างๆ
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDims.size_8.w,
                  vertical: AppDims.size_4.w,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      widget.title,
                      style: context.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppDims.vericalPadding_2,

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        AppText(
                          widget.description,
                          style: context.textTheme.titleSmall!.copyWith(
                            color: AppColors.primary,
                            fontSize: AppDims.size_10.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppDims.horizonPadding_8,

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDims.size_4.w,
                            vertical: AppDims.size_2.h,
                          ),
                          decoration: widget.distance == null
                              ? null
                              : BoxDecoration(
                                  border: Border.all(color: AppColors.primary),
                                  borderRadius: BorderRadius.circular(4.r),
                                  color: AppColors.ci3,
                                ),
                          child: AppText(
                            widget.distance.orEmpty,
                            style: context.textTheme.titleSmall!.copyWith(
                              color: AppColors.primary,
                              fontSize: AppDims.size_8.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppDims.vericalPadding_2,

                    AppText(
                      widget.detailUsing,
                      style: context.textTheme.bodySmall?.copyWith(
                        fontSize: AppDims.size_10.sp,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),

                    Row(
                      children: [
                        AppText(
                          widget.expired,
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: AppDims.size_10.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        if (widget.conditionText != null &&
                            widget.conditionText!.isNotEmpty) ...[
                          AppText(' '),
                          GestureDetector(
                            onTap: widget.onConditionTap,
                            child: AppText(
                              widget.conditionText.orEmpty,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                                fontSize: AppDims.size_10.sp,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // RichText(
                    //   maxLines: 2,
                    //   softWrap: true,
                    //   overflow: TextOverflow.ellipsis,
                    //   text: TextSpan(
                    //     text: widget.expired,
                    //     style: context.textTheme.bodySmall?.copyWith(
                    //       fontSize: AppDims.size_10.sp,
                    //       color: AppColors.textSecondary,
                    //     ),
                    //     children: [
                    //       if (widget.conditionText != null &&
                    //           widget.conditionText!.isNotEmpty) ...[
                    //         TextSpan(text: ' '),
                    //         TextSpan(
                    //           text: widget.conditionText,
                    //           style: context.textTheme.labelSmall?.copyWith(
                    //             color: AppColors.primary,
                    //             fontSize: AppDims.size_10.sp,
                    //           ),
                    //           recognizer: TapGestureRecognizer()
                    //             ..onTap = widget.onConditionTap,
                    //         ),
                    //       ],
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),

            // เพิ่มเงื่อนไขการแสดง Checkbox
            if (widget.showCheckBox)
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: checked,
                  shape: CircleBorder(),
                  onChanged: (value) {
                    // setState(() {
                    //   checked = value ?? false;
                    // });
                    widget.onChanged?.call(value);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
