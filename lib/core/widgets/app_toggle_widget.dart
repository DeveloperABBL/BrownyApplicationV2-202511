import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:browny_applications_new/res/dims/app_dims.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// LocaleToggleWidget - Widget สำหรับเปลี่ยนภาษา
///
/// ประกอบด้วย 3 ภาษา:
/// - ไทย (th)
/// - English (en)
/// - 中文 (zh)
class AppToggleWidget extends StatefulWidget {
  const AppToggleWidget({
    super.key,
    required this.onChange,
    required this.data,
  });

  final ValueSetter<AppToggleData<int>> onChange;
  final List<AppToggleData<int>> data;

  @override
  State<AppToggleWidget> createState() => _AppToggleWidgetState();
}

class _AppToggleWidgetState extends State<AppToggleWidget> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 250.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.border,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(AppDims.size_24.r),
      ),
      child: Row(
        spacing: AppDims.size_8.w,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...widget.data.map(
            (e) => _buildLanguageButton(
              e.value,
              context: context,
              data: e,
            ),
          ),
          // _buildLanguageButton(
          //   0,
          //   context: context,
          //   label: 'ทั้งหมด',
          //   isSelected: _index == 0,
          // ),
          // AppDims.horizonPadding_8,

          // _buildLanguageButton(
          //   1,
          //   context: context,
          //   label: 'ซักอบ',
          //   isSelected: _index == 1,
          // ),
          // AppDims.horizonPadding_8,

          // _buildLanguageButton(
          //   2,
          //   context: context,
          //   label: 'การสั่งซื้อ',
          //   isSelected: _index == 2,
          // ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(
    int index, {
    required BuildContext context,
    required AppToggleData<int> data,
    // required String label,
    // required bool isSelected,
  }) {
    bool isSelected = data.value == _index;
    return GestureDetector(
      onTap: data.enable
          ? () {
              setState(() {
                _index = index;
                widget.onChange(data);
              });
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: AppDims.size_12.w,
          vertical: AppDims.size_4.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDims.size_20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
              style: context.textTheme.labelMedium!.copyWith(
                color: data.enable
                    ? (isSelected ? AppColors.textWhite : AppColors.textPrimary)
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              child: Text(data.lable),
            ),
          ],
        ),
      ),
    );
  }
}

class AppToggleData<T> {
  final String lable;
  final T value;
  final bool enable;

  AppToggleData({
    required this.lable,
    required this.value,
    this.enable = true,
  });
}
