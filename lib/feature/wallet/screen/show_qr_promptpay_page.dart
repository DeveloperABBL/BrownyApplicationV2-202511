import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:browny_applications_new/res/icons/assets.gen.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/permission_helper.dart';
import 'package:browny_applications_new/core/widgets/app_overlays.dart';
import 'package:browny_applications_new/core/widgets/app_text.dart';
import 'package:browny_applications_new/feature/wallet/screen/payment_sucess_page.dart';
import 'package:browny_applications_new/feature/wallet/viewmodel/wallet_viewmodel.dart';
import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:browny_applications_new/res/dims/app_dims.dart';
import 'package:browny_applications_new/res/strings/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ShowQRPromptpayPage extends StatefulWidget {
  const ShowQRPromptpayPage({
    super.key,
    required this.viewModel,
  });

  static const pagePath = '/show-qr-promptpay';
  static const pageName = 'showQRPromptpayPage';

  final WalletViewModel viewModel;

  @override
  State<ShowQRPromptpayPage> createState() => _ShowQRPromptpayPageState();
}

class _ShowQRPromptpayPageState extends State<ShowQRPromptpayPage> {
  final GlobalKey _qrKey = GlobalKey();
  late WebViewController controller;
  String? _qrCodeData;

  @override
  void initState() {
    super.initState();
    _initializeData();
    if (_qrCodeData != null) {
      widget.viewModel.startPaymentStatusCheck(() {
        if (mounted) {
          context.pushReplacementNamed(
            PaymentSuccessPage.pageName,
            extra: widget.viewModel,
          );
        }
      });
    }
  }

  void _initializeData() {
    final topupResponse = widget.viewModel.topupResponse;
    if (topupResponse != null) {
      _qrCodeData = topupResponse.qrCodeData;
    }

    controller = WebViewController()
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )
      ..setBackgroundColor(
        const Color(0x00000000),
      )
      ..loadRequest(
        Uri.parse(_qrCodeData.orEmpty),
      );
  }

  Future<void> _captureAndSaveQR() async {
    try {
      // Request storage permission using helper
      final status = await PermissionHelper.requestStoragePermission(context);

      if (status.isGranted || status.isLimited) {
        // Capture the widget
        RenderRepaintBoundary boundary =
            _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        // Save to gallery
        final result = await ImageGallerySaverPlus.saveImage(
          pngBytes,
          quality: 100,
          name: 'promptpay_qr_${DateTime.now().millisecondsSinceEpoch}',
        );

        if (mounted) {
          if (result['isSuccess'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: AppText(
                  context.wording.qrCodeSavedSuccessfully,
                  style: context.textTheme.labelLarge!.copyWith(
                    color: AppColors.white,
                  ),
                ),
                backgroundColor: AppColors.walletBackground,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(
                  bottom: AppDims.size_84.w,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: AppText(
                  context.wording.cannotSaveQRCode,
                  style: context.textTheme.labelLarge!.copyWith(
                    color: AppColors.white,
                  ),
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(
                  bottom: AppDims.size_64.w,
                ),
              ),
            );
          }
        }
      } else if (status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText(
                context.wording.pleaseAllowPhotoLibraryAccess,
                style: context.textTheme.labelLarge!.copyWith(
                  color: AppColors.white,
                ),
              ),
              backgroundColor: AppColors.error,
              action: SnackBarAction(
                label: context.wording.openSettings,
                textColor: AppColors.white,
                onPressed: () {
                  PermissionHelper.openAppSettings();
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText(
              '${context.wording.errorOccurred}: $e',
              style: context.textTheme.labelLarge!.copyWith(
                color: AppColors.white,
              ),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: AppDims.size_64.w,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    widget.viewModel.stopPaymentStatusCheck();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        AppOverlays.showWalletDialog(
          context,
          title: context.wording.cancelTransaction,
          message: context.wording.confirmCancelTransaction,
          confirmText: context.wording.confirm,
          cancelText: context.wording.cancel,
          onConfirm: () {
            context.pop();
          },
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.darkBlue,
          title: AppText(
            context.wording.payment,
            style: context.textTheme.titleLarge!.copyWith(
              color: AppColors.white,
            ),
          ),
          centerTitle: true,
        ),

        bottomSheet: Padding(
          padding: EdgeInsets.only(
            left: AppDims.size_24.w,
            right: AppDims.size_24.w,
            bottom: AppDims.size_24.w,
            top: AppDims.size_8.w,
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: context.appTheme.elevatedButtonTheme.style!.copyWith(
              backgroundColor: WidgetStatePropertyAll(
                AppColors.walletBackground,
              ),
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.hovered)) {
                    return AppColors.walletBackgroundHover.withValues(
                      alpha: 0.1,
                    );
                  }
                  if (states.contains(WidgetState.pressed)) {
                    return AppColors.walletBackgroundClicked.withValues(
                      alpha: 0.7,
                    );
                  }
                  return null;
                },
              ),
            ),
            child: AppText(
              context.wording.backToHome,
              style: context.textTheme.labelLarge!.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.centerRight,
              colors: [
                AppColors.walletBackgroundHover.withValues(alpha: 0.1),
                AppColors.background,
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDims.size_24.w,
                  vertical: AppDims.size_32.h,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // QR Code Section
                    RepaintBoundary(
                      key: _qrKey,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10.r,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(AppDims.size_24.w),
                        child: Column(
                          children: [
                            // PromptPay Logo
                            Assets.png.promptpayBadgeNoLine.image(
                              height: 73.w,
                              width: 228.h,
                            ),
                            AppDims.vericalPadding_16,

                            // QR Code
                            if (_qrCodeData.orEmpty.isNotEmpty)
                              SizedBox(
                                width: 228.w,
                                height: 228.h,
                                child: WebViewWidget(
                                  controller: controller,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    AppDims.vericalPadding_24,

                    // ปุ่มบันทึกรูปภาพ
                    GestureDetector(
                      onTap: _captureAndSaveQR,
                      child: Column(
                        children: [
                          Assets.svg.icDownStorage.svg(),
                          AppDims.vericalPadding_8,
                          AppText(
                            context.wording.save,
                            style: context.textTheme.labelLarge!.copyWith(
                              color: AppColors.textBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
