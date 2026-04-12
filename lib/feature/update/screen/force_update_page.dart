import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:browny_applications_new/res/dims/app_dims.dart';
import 'package:browny_applications_new/res/icons/assets.gen.dart';
import 'package:browny_applications_new/res/strings/app_strings.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:upgrader/upgrader.dart';

class ForceUpdatePage extends StatefulWidget {
  const ForceUpdatePage({super.key});

  static const pagePath = '/force-update';
  static const pageName = 'force-update';

  @override
  State<ForceUpdatePage> createState() => _ForceUpdatePageState();
}

class _ForceUpdatePageState extends State<ForceUpdatePage> {
  final Upgrader _upgrader = Upgrader(
    debugLogging: false,
  );

  bool _isInitialized = false;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    final results = await Future.wait([
      _upgrader.initialize(),
      PackageInfo.fromPlatform(),
    ]);
    if (mounted) {
      final packageInfo = results[1] as PackageInfo;
      setState(() {
        _isInitialized = true;
        _appVersion = packageInfo.version;
      });
    }
  }

  Future<void> _openStore() async {
    await _upgrader.sendUserToAppStore();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // ปิดการกด Back เพื่อบังคับ Update
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDims.size_24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Logo
                  Assets.png.brownyLogo.image(
                    width: 140.w,
                    height: 140.w,
                    fit: BoxFit.contain,
                  ),

                  SizedBox(height: AppDims.size_32.h),

                  // Icon อัพเดท
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.system_update_rounded,
                      color: Colors.white,
                      size: 40.sp,
                    ),
                  ),

                  SizedBox(height: AppDims.size_24.h),

                  // หัวข้อ
                  AppText(
                    context.wording.forceUpdateTitle,
                    style: context.textTheme.titleLarge!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: AppDims.size_20.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: AppDims.size_12.h),

                  // คำอธิบาย พร้อม Version
                  AppText(
                    context.wording.forceUpdateDescription(_appVersion),
                    style: context.textTheme.bodyMedium!.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: AppDims.size_14.sp,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  // ปุ่ม Update Now
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isInitialized ? _openStore : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.gradientEnd,
                        disabledBackgroundColor: Colors.white.withValues(
                          alpha: 0.5,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: AppDims.size_16.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDims.size_12.r,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: AppText(
                        context.wording.forceUpdateButton,
                        style: context.textTheme.labelLarge!.copyWith(
                          color: AppColors.gradientEnd,
                          fontWeight: FontWeight.w700,
                          fontSize: AppDims.size_16.sp,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: AppDims.size_32.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
