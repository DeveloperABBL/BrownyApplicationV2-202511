import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/machine_order_receipt_response_extension.dart';
import 'package:browny_applications_new/core/utils/share_helper.dart';
import 'package:browny_applications_new/feature/home/screens/home_page.dart';
import 'package:browny_applications_new/feature/transactions/screens/machines/machine_status_page.dart';
import 'package:browny_applications_new/feature/transactions/viewmodel/transactions_viewmodel.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class ReceiptMachinePage extends StatelessWidget {
  const ReceiptMachinePage({
    super.key,
    required this.viewmodel,
  });

  final MachineTransactionViewmodel viewmodel;

  static final pagePath = '/machine_receipt';
  static final pageName = 'machineReceiptPage';

  /// util function route to pageName
  static Future<T?> goToPage<T>(
    BuildContext context, {
    required MachineTransactionViewmodel viewmodel,
  }) async {
    return await context.pushNamed(
      ReceiptMachinePage.pageName,
      extra: viewmodel,
    );
  }

  static void goReplacementPage(
    BuildContext context, {
    required MachineTransactionViewmodel viewmodel,
  }) {
    context.pushReplacementNamed(
      ReceiptMachinePage.pageName,
      extra: viewmodel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewmodel,
      child: ReceiptWidget(
        viewmodel: viewmodel,
      ),
    );
  }
}

class ReceiptWidget extends StatefulWidget {
  const ReceiptWidget({
    super.key,
    required this.viewmodel,
  });

  final MachineTransactionViewmodel viewmodel;

  @override
  State<ReceiptWidget> createState() => _ReceiptWidgetState();
}

class _ReceiptWidgetState extends State<ReceiptWidget> {
  final GlobalKey _receiptKey = GlobalKey();

  MachineTransactionViewmodel get _viewmodel => widget.viewmodel;

  /// Capture widget เป็นรูปภาพ
  Future<Uint8List?> _captureWidget() async {
    try {
      RenderRepaintBoundary boundary =
          _receiptKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  /// แชร์ใบเสร็จ
  Future<void> _shareReceipt() async {
    try {
      // Capture widget
      final imageBytes = await _captureWidget();

      if (imageBytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText(
                context.wording.errorOccurred,
                style: context.textTheme.labelLarge!.copyWith(
                  color: AppColors.white,
                ),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
      if (!mounted) return;

      // แชร์รูปภาพ
      await ShareHelper.shareImage(
        imageBytes,
        fileName: 'browny_receipt_${DateTime.now().millisecondsSinceEpoch}.png',
        text: context.wording.brownyReceipt, // ใบเสร็จ Browny
      );
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
          ),
        );
      }
    }
  }

  /// บันทึกใบเสร็จลงอุปกรณ์
  Future<void> _captureAndSaveReceipt() async {
    try {
      // Request storage permission using helper
      // final status = await PermissionHelper.requestStoragePermission(context);

      // if (status.isGranted || status.isLimited) {
      // Capture the widget
      final pngBytes = await _captureWidget();

      if (pngBytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText(
                context.wording.errorOccurred,
                style: context.textTheme.labelLarge!.copyWith(
                  color: AppColors.white,
                ),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Save to gallery
      final result = await ImageGallerySaverPlus.saveImage(
        pngBytes,
        quality: 100,
        name: 'browny_receipt_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (mounted) {
        if (result['isSuccess'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText(
                context.wording.saveTheReceipt,
                style: context.textTheme.labelLarge!.copyWith(
                  color: AppColors.white,
                ),
              ),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                left: AppDims.size_24.w,
                right: AppDims.size_24.w,
                bottom: AppDims.size_24.w,
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
      // } else if (status.isPermanentlyDenied) {
      //   if (mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: AppText(
      //           context.wording.pleaseAllowPhotoLibraryAccess,
      //           style: context.textTheme.labelLarge!.copyWith(
      //             color: AppColors.white,
      //           ),
      //         ),
      //         backgroundColor: AppColors.error,
      //         action: SnackBarAction(
      //           label: context.wording.openSettings,
      //           textColor: AppColors.white,
      //           onPressed: () {
      //             PermissionHelper.openAppSettings();
      //           },
      //         ),
      //       ),
      //     );
      //   }
      // }
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

  void _popPage() {
    if (_viewmodel.isFromHistory) {
      if (context.canPop()) {
        context.pop();
        return;
      }
    }
    context.popUntil(
      predicate: (route) {
        return route.name.orEmpty == HomePage.pageName;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: AppColors.textPrimary,
          onPressed: () {
            _popPage();
          },
        ),
        title: AppText(
          context.wording.receipt, // ใบเสร็จ
          style: context.textTheme.titleLarge!.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      persistentFooterDecoration: BoxDecoration(color: AppColors.background),
      persistentFooterButtons: [
        Container(
          padding: EdgeInsets.only(
            left: AppDims.size_24.w,
            right: AppDims.size_24.w,
            // top: AppDims.size_8.h,
          ),
          child: ElevatedButton(
            onPressed: () async {
              if (_viewmodel.isFirstReviewed) {
                await _viewmodel.submitMachineOrderReview();
              }
              if (!context.mounted) return;
              if (_viewmodel.isFromHistory) {}
              _popPage();
            },
            child: AppText(
              _viewmodel.isFromHistory
                  ?
                    // ย้อนกลับ
                    context.wording.back
                  :
                    // กลับสู่หน้าหลัก
                    context.wording.backToHome,
            ),
          ),
        ),
        if (!_viewmodel.isFromHistory)
          Container(
            padding: EdgeInsets.only(
              left: AppDims.size_24.w,
              right: AppDims.size_24.w,
              top: AppDims.size_8.h,
              bottom: AppDims.size_26.w,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: AppColors.ci3,
              ),
              onPressed: () async {
                if (_viewmodel.isFirstReviewed) {
                  await _viewmodel.submitMachineOrderReview();
                }

                if (!context.mounted) return;
                _popPage();
                MachineStatusPage.goToPage(
                  context,
                  machineId: _viewmodel.machineId,
                );
              },
              child: AppText(
                context.wording.checkStatus, // ตรวจสอบสถานะ
              ),
            ),
          ),
      ],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Card หลัก - ใบเสร็จ
            _capturableArea(
              child: ValueListenableBuilder(
                valueListenable: _viewmodel.machineTransactionStateNotifier,
                builder: (context, result, child) {
                  // Loading state
                  if (result.isLoading || result.data?.isLoading == true) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Error state
                  if (result.hasError) {
                    return Center(
                      child: AppText(
                        // เกิดข้อผิดพลาด
                        result.error.toString(),
                      ),
                    );
                  }

                  // API Error state
                  if (result.data?.hasError == true) {
                    return Center(
                      child: AppText(
                        // เกิดข้อผิดพลาด
                        result.data?.error?.toString() ??
                            context.wording.errorOccurred,
                      ),
                    );
                  }

                  // No receipt data
                  if (!result.data!.hasReceipt) {
                    return Center(
                      child: AppText(
                        context.wording.receiptNotFound,
                      ), // ไม่พบข้อมูลใบเสร็จ
                    );
                  }

                  final receiptData = result.data!.receipt!;
                  return Column(
                    children: [
                      AppDims.vericalPadding_24,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDims.size_24.w,
                        ),
                        child: Column(
                          children: [
                            Assets.png.brownySuccess.image(
                              width: AppDims.size_100.w,
                            ),
                            AppDims.vericalPadding_4,

                            AppText(
                              context
                                  .wording
                                  .operationSuccessful, // ดำเนินการสำเร็จ
                              style: context.textTheme.titleMedium!.copyWith(
                                color: AppColors.textBlack,
                              ),
                            ),
                            AppText(
                              receiptData.receiptDateDisplay(context),
                              style: context.textTheme.bodySmall!.copyWith(
                                color: AppColors.gray600,
                              ),
                            ),
                            AppDims.vericalPadding_8,

                            Divider(),
                          ],
                        ),
                      ),
                      AppDims.vericalPadding_8,

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDims.size_24.w,
                        ),
                        child: Column(
                          children: [
                            // ข้อมูลเพิ่มเติมของใบเสร็จ
                            AppText(
                              receiptData.totalFormatted,
                              style: context.textTheme.displayLarge!.copyWith(
                                color: AppColors.primary,
                                fontSize: AppDims.size_36.sp,
                              ),
                            ),
                            // Browny Coin Bonus
                            if (receiptData.bonus.orEmpty.isNotEmpty) ...[
                              AppDims.vericalPadding_4,
                              Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppDims.size_2.h,
                                  horizontal: AppDims.size_8.w,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.walletCoinBonusGradient,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Assets.png.brownyCoin.image(
                                      width: 20.w,
                                      height: 20.w,
                                    ),
                                    SizedBox(width: 8.w),
                                    AppText(
                                      // คุณได้รับโบนัส
                                      context.wording.youReceivedBonus,
                                      style: context.textTheme.labelMedium!
                                          .copyWith(
                                            color: AppColors.cocoaBrown,
                                          ),
                                    ),
                                    AppText(
                                      ' Browny Coin ${formatCurrency(string: receiptData.bonus, leadingSign: '+ ')}',
                                      style: context.textTheme.labelMedium!
                                          .copyWith(
                                            color: AppColors.cocoaBrown,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            AppDims.vericalPadding_16,

                            _listTile(
                              // Order ID
                              leading: 'Order ID',
                              trailing: receiptData.receiptNo.orEmpty,
                            ),
                            _listTile(
                              // สาขา
                              leading: context.wording.branch, // สาขา
                              trailing: receiptData.branchNameDisplay(context),
                            ),
                            _listTile(
                              // ประเภทเครื่อง
                              leading:
                                  context.wording.machineType, // ประเภทเครื่อง
                              trailing: receiptData.machineTypeDisplay(context),
                            ),
                            _listTile(
                              // หมายเลขเครื่อง
                              leading: context
                                  .wording
                                  .machineNumber, // หมายเลขเครื่อง
                              trailing: receiptData.machineNoDisplay,
                            ),
                            _listTile(
                              // Date
                              leading: context.wording.dateTime, // วัน / เวลา
                              trailing: receiptData.receiptDateDisplay(
                                context,
                              ),
                            ),
                            _listTile(
                              // Payment Method
                              leading: context
                                  .wording
                                  .paymentMethod, // ช่องทางการชำระเงิน
                              trailing: receiptData.paymentMethodNameDisplay(
                                context,
                              ),
                            ),
                            AppDims.vericalPadding_4,
                            _listTile(
                              // Icon
                              leading: '',
                              trailing: '',
                              trailingWidget: Image.network(
                                width: AppDims.size_30.w,
                                height: AppDims.size_30.h,
                                receiptData.paymentIcon.orEmpty,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.account_balance_rounded,
                                    ),
                              ),
                            ),
                            AppDims.vericalPadding_8,

                            Divider(),
                          ],
                        ),
                      ),
                      AppDims.vericalPadding_8,

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDims.size_24.w,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _listTile(
                              // บริการ
                              leading: context.wording.services, // บริการ
                              trailing: '',
                            ),
                            if (receiptData.hasSummary &&
                                receiptData.summary!.program != null)
                              _listTile(
                                // Program ที่เลือกมา
                                leading: receiptData.programNameDisplay(
                                  context,
                                ),
                                trailing: '',
                                trailingWidget: AppText(
                                  receiptData.programPrice,
                                  style: context.textTheme.headlineMedium!
                                      .copyWith(
                                        fontSize: AppDims.size_14.sp,
                                        color: AppColors.gray600,
                                      ),
                                ),
                              ),

                            _listTile(
                              // ส่วนลด/โปรโมชั่น
                              leading: receiptData.hasDiscount
                                  ? receiptData.summary!.discount!.wording!
                                        .getTextByLocale(
                                          context.languageCode,
                                        )
                                  : context
                                        .wording
                                        .storePromotion, // โปรโมชั่นสาขา
                              trailing: '',
                              trailingWidget: AppText(
                                receiptData.discountAmount,
                                style: context.textTheme.headlineMedium!
                                    .copyWith(
                                      fontSize: AppDims.size_14.sp,
                                      color: receiptData.hasDiscount
                                          ? AppColors.error
                                          : AppColors.gray600,
                                    ),
                              ),
                            ),

                            _listTile(
                              // Coupon ส่วนลด
                              leading: receiptData.hasCouponDiscount
                                  ? receiptData.couponDiscountNameDisplay(
                                      context,
                                    )
                                  : context
                                        .wording
                                        .discountCoupon, // คูปองส่วนลด
                              trailing: '',
                              trailingWidget: AppText(
                                receiptData.couponDiscountAmount,
                                style: context.textTheme.headlineMedium!
                                    .copyWith(
                                      fontSize: AppDims.size_14.sp,
                                      color: receiptData.hasCouponDiscount
                                          ? AppColors.error
                                          : AppColors.gray600,
                                    ),
                              ),
                            ),

                            _listTile(
                              // E-Voucher
                              leading: receiptData.hasCouponEvoucher
                                  ? receiptData.couponEvoucherNameDisplay(
                                      context,
                                    )
                                  : 'E-Voucher',
                              trailing: '',
                              trailingWidget: AppText(
                                receiptData.couponEvoucherAmount,
                                style: context.textTheme.headlineMedium!
                                    .copyWith(
                                      fontSize: AppDims.size_14.sp,
                                      color: receiptData.hasCouponEvoucher
                                          ? AppColors.error
                                          : AppColors.gray600,
                                    ),
                              ),
                            ),
                            _listTile(
                              // ยอดรวมทั้งหมด
                              leading:
                                  context.wording.totalAmount, // ยอดรวมทั้งหมด
                              trailing: '',
                              trailingWidget: AppText(
                                receiptData.totalFormatted,
                                style: context.textTheme.headlineMedium!
                                    .copyWith(
                                      fontSize: AppDims.size_14.sp,
                                      color: AppColors.primary,
                                    ),
                              ),
                            ),
                            AppDims.vericalPadding_16,

                            // QR Code สำหรับ Support
                            _listTile(
                              leading: '',
                              trailing: '',
                              trailingWidget: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppDims.size_2.h,
                                  horizontal: AppDims.size_4.w,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.bareBackground,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(AppDims.size_4.r),
                                  ),
                                ),
                                child: AppText(
                                  context
                                      .wording
                                      .qrCodeForSupportOnly, // QR Code สำหรับฝ่าย Browny Support เท่านั้น
                                  style: context.textTheme.labelSmall!.copyWith(
                                    fontSize: AppDims.size_10.sp,
                                  ),
                                ),
                              ),
                            ),
                            // AppDims.vericalPadding_10,
                            Image.network(
                              receiptData.qrImage.orEmpty,
                              width: 90.w,
                              height: 90.w,
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) =>
                                  SizedBox(),
                            ),
                          ],
                        ),
                      ),

                      AppDims.vericalPadding_24,

                      Align(
                        alignment: AlignmentGeometry.bottomCenter,
                        child: Image.network(
                          receiptData.luckyImage.orEmpty,
                          errorBuilder: (context, error, stackTrace) =>
                              SizedBox(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            AppDims.vericalPadding_24,

            // ปุ่ม แชร์ และ บันทึกใบเสร็จ
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ปุ่มแชร์
                InkResponse(
                  onTap: _shareReceipt,
                  child: Column(
                    children: [
                      Assets.svg.icShare.svg(),
                      AppDims.vericalPadding_8,
                      AppText(
                        context.wording.share,
                        style: context.textTheme.labelSmall!.copyWith(
                          color: AppColors.textBlack,
                        ),
                      ),
                    ],
                  ),
                ),
                AppDims.horizonPadding_32,
                // ปุ่มบันทึกใบเสร็จ
                InkResponse(
                  onTap: _captureAndSaveReceipt,
                  child: Column(
                    children: [
                      Assets.svg.icDownStorage.svg(),
                      AppDims.vericalPadding_8,
                      AppText(
                        context.wording.saveTheReceipt,
                        style: context.textTheme.labelSmall!.copyWith(
                          color: AppColors.textBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppDims.vericalPadding_32,

            // ให้ความเพิ่งพอใจ
            ValueListenableBuilder(
              valueListenable: _viewmodel.machineTransactionStateNotifier,
              builder: (context, result, child) {
                // Loading state
                if (result.isLoading || result.data?.isLoading == true) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Error state
                if (result.hasError || result.isEmpty) {
                  return SizedBox();
                }

                final receiptData = result.data!.receipt!;
                int? reviewScore = int.tryParse(
                  receiptData.reviewScore.ifNullOrEmpty('-1'),
                );
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: AppDims.size_15.h,
                    horizontal: AppDims.size_6.w,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: AppDims.size_15.w),
                  decoration: BoxDecoration(
                    gradient: AppColors.popupGradient,
                    color: AppColors.bareBackground,
                    image: DecorationImage(
                      image: Assets.icReviews.bgReview.provider(),
                      fit: BoxFit.cover,
                    ),
                    border: BoxBorder.all(color: AppColors.productStroke),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    spacing: 6.h,
                    children: [
                      Assets.icReviews.brownyReview.image(
                        width: AppDims.size_77.w,
                      ),
                      AppText(
                        context
                            .wording
                            .rateStoreCleanlinessTitle, // ให้คะแนนความสะอาดของร้าน
                        style: context.textTheme.labelLarge,
                      ),
                      AppDims.vericalPadding_2,
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDims.size_6.w,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            _buildReviewScoreItem(
                              context.wording.reviewVeryBad, // แย่มาก
                              icon: Assets.icReviews.icLv1,
                              context: context,
                              reviewScore: reviewScore,
                              selfScore: 1,
                            ),
                            _buildReviewScoreItem(
                              context.wording.reviewDissatisfied, // ไม่พอใจ
                              icon: Assets.icReviews.icLv2,
                              context: context,
                              reviewScore: reviewScore,
                              selfScore: 2,
                            ),
                            _buildReviewScoreItem(
                              context.wording.reviewNeutral, // เฉยๆ
                              icon: Assets.icReviews.icLv3,
                              context: context,
                              reviewScore: reviewScore,
                              selfScore: 3,
                            ),
                            _buildReviewScoreItem(
                              context.wording.reviewGood, // ดี
                              icon: Assets.icReviews.icLv4,
                              context: context,
                              reviewScore: reviewScore,
                              selfScore: 4,
                            ),
                            _buildReviewScoreItem(
                              context.wording.reviewExcellent, // ดีเยี่ยม
                              icon: Assets.icReviews.icLv5,
                              context: context,
                              reviewScore: reviewScore,
                              selfScore: 5,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            AppDims.vericalPadding_32,

            ValueListenableBuilder(
              valueListenable: _viewmodel.machineTransactionStateNotifier,
              builder: (context, result, child) {
                if (result.isEmpty || result.data == null) {
                  // ไม่มีข้อมูลอะไร
                  return SizedBox();
                }
                if (result.hasError) {
                  // Error
                  return Center(
                    child: AppText('''
${context.wording.errorUi}
Result Error : ${result.error.toString()}
'''),
                  );
                }
                if (result.data!.hasError) {
                  return Center(
                    child: AppText('''
${context.wording.errorUi}
Data Error : ${result.data!.error.toString()}
'''),
                  );
                }
                if (result.data!.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = result.data!.receipt!;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppDims.size_16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Browny Care
                      GestureDetector(
                        onTap: () => LaunchHelper.makePhoneCall(
                          data.callCenter.orEmpty,
                        ),
                        child: Container(
                          padding: EdgeInsets.only(
                            left: AppDims.size_8.w,
                            top: AppDims.size_8.h,
                            right: AppDims.size_16.w,
                            bottom: AppDims.size_12.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: AppColors.productStroke),
                          ),
                          child: Row(
                            children: [
                              Assets.iconProfilePreferences.icCallOut.svg(
                                width: AppDims.size_44.w,
                              ),
                              AppDims.horizonPadding_8,

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    'Browny Care',
                                    style: context.textTheme.labelLarge!
                                        .copyWith(fontSize: AppDims.size_14.sp),
                                  ),
                                  AppText(
                                    result.data!.receipt!.callCenter.orEmpty,
                                    style: context.textTheme.labelMedium!
                                        .copyWith(
                                          fontSize: AppDims.size_12.sp,
                                          color: AppColors.gray500,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // LINE Browny Official
                      GestureDetector(
                        onTap: () => LaunchHelper.openUrlInWebView(
                          data.lineLink.orEmpty,
                        ),
                        child: Container(
                          padding: EdgeInsets.only(
                            left: AppDims.size_8.w,
                            top: AppDims.size_8.h,
                            right: AppDims.size_16.w,
                            bottom: AppDims.size_12.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: AppColors.productStroke),
                          ),
                          child: Row(
                            children: [
                              Assets.iconProfilePreferences.lineRegPng.image(
                                width: AppDims.size_44.w,
                              ),
                              AppDims.horizonPadding_8,

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    'LINE',
                                    style: context.textTheme.labelLarge!
                                        .copyWith(
                                          fontSize: AppDims.size_14.sp,
                                        ),
                                  ),
                                  AppText(
                                    'Browny Official',
                                    style: context.textTheme.labelMedium!
                                        .copyWith(
                                          fontSize: AppDims.size_12.sp,
                                          color: AppColors.gray500,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            AppDims.vericalPadding_32,
          ],
        ),
      ),
    );
  }

  Widget _buildReviewScoreItem(
    String text, {
    required AssetGenImage icon,
    required BuildContext context,
    required int? reviewScore,
    required int selfScore,
  }) {
    return GestureDetector(
      onTap: () => onScoreTap(selfScore),
      child: Container(
        foregroundDecoration: _reviewScrollShow(
          reviewScore,
          selfScore,
        ),
        child: Column(
          spacing: 8.h,
          children: [
            icon.image(
              width: AppDims.size_44.w,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: AppDims.size_44.w,
              ),
              child: AppText(
                // 'แย่มาก,
                text,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration? _reviewScrollShow(int? reviewScored, int score) {
    return (reviewScored == null || reviewScored != score)
        ? BoxDecoration(
            color: Colors.grey,
            backgroundBlendMode: BlendMode.saturation,
          )
        : null;
  }

  void onScoreTap(int scored) {
    widget.viewmodel.onScoreTap(scored);
  }

  Widget _listTile({
    required String leading,
    Widget? leadingWidget,
    required String trailing,
    Widget? trailingWidget,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDims.size_2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child:
                leadingWidget ??
                AppText(
                  leading,
                  style: context.textTheme.titleMedium!.copyWith(
                    color: AppColors.gray600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
          ),
          trailingWidget ??
              AppText(
                trailing,
                style: context.textTheme.titleMedium!.copyWith(
                  color: AppColors.gray600,
                ),
              ),
        ],
      ),
    );
  }

  Widget _capturableArea({required Widget child}) {
    return RepaintBoundary(
      key: _receiptKey,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background,
          image: DecorationImage(
            alignment: AlignmentGeometry.topCenter,
            image: Assets.png.bgPawnPattern.provider(),
            repeat: ImageRepeat.repeatY,
            isAntiAlias: true,
            opacity: 0.15,
          ),
          borderRadius: BorderRadius.circular(AppDims.size_16.r),
          boxShadow: AppColors.defatultShadow,
        ),
        // padding: EdgeInsets.all(AppDims.size_24.w),
        margin: EdgeInsets.all(AppDims.size_15.w),
        child: child,
      ),
    );
  }
}
