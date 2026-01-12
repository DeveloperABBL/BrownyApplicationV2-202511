import 'package:browny_applications_new/feature/authentication/repository/customer_data_repo.dart';
import 'package:browny_applications_new/res/icons/assets.gen.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/widgets/app_text.dart';
import 'package:browny_applications_new/feature/scaner/viewmodel/scanner_viewmodel.dart';
import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:browny_applications_new/res/dims/app_dims.dart';
import 'package:browny_applications_new/res/strings/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  static final pagePath = '/scanner';
  static final pageName = 'scannerPage';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          ScannerViewModel(context: context, repo: CustomerDataRepo()),
      child: _ScannerWidget(),
    );
  }
}

class _ScannerWidget extends StatefulWidget {
  const _ScannerWidget();

  @override
  State<_ScannerWidget> createState() => __ScannerWidgetState();
}

class __ScannerWidgetState extends State<_ScannerWidget>
    with SingleTickerProviderStateMixin {
  late ScannerViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ScannerViewModel>();
    _viewModel.attachContext(context);

    // Initialize camera controller
    _viewModel.cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    // Initialize camera after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewModel.initializeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: ValueListenableBuilder(
        valueListenable: _viewModel.selectedTab,
        builder: (context, tabIndex, _) {
          return Scaffold(
            extendBody: tabIndex == 0,
            extendBodyBehindAppBar: tabIndex == 0,
            persistentFooterDecoration: BoxDecoration(),
            persistentFooterButtons: [
              tabIndex == 0
                  ? _buildBottomButtons(context)
                  : ElevatedButton(
                      onPressed: () => context.pop(),
                      child: AppText(context.wording.backToHome),
                    ),
            ],
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(context, tabIndex),
            body: TabBarView(
              children: [
                // index 0 : Scanner
                _buildScannerView(context),

                // index 1 : QRCode
                FutureBuilder(
                  future: _viewModel.fetchCustomerQRCode(),
                  builder: (context, snapshot) {
                    return ValueListenableBuilder(
                      valueListenable: _viewModel.qrNotifier,
                      builder: (context, result, child) {
                        if (result.isEmpty) {
                          return SizedBox();
                        }
                        return Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.background,

                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.centerRight,
                                colors: [
                                  AppColors.ci2.withValues(
                                    alpha: 0.03,
                                  ),
                                  AppColors.background,
                                ],
                              ),
                            ),
                            child: Center(
                              child: result.isLoading
                                  ? CircularProgressIndicator()
                                  : Container(
                                      width: 292.w,
                                      height: 427.h,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                        border: BoxBorder.all(
                                          color: AppColors.border,
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.1,
                                            ),
                                            blurRadius: 10.r,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.all(
                                        AppDims.size_24.w,
                                      ),
                                      child: Column(
                                        children: [
                                          // PromptPay Logo
                                          Assets.png.brownyHorizaontal2.image(
                                            height: 44.w,
                                            width: 135.h,
                                          ),
                                          AppDims.vericalPadding_20,
                                          Divider(),
                                          AppDims.vericalPadding_16,

                                          // QR Code
                                          Image.network(result.data!.url!),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, int tabIndex) {
    return AppBar(
      backgroundColor: tabIndex == 0
          ? AppColors.black.withValues(alpha: 0.5)
          : AppColors.primary,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      bottom: TabBar(
        indicatorColor: tabIndex == 0 ? AppColors.primary : AppColors.white,
        labelStyle: context.textTheme.titleMedium!.copyWith(
          color: tabIndex == 0 ? AppColors.primary : AppColors.white,
        ),
        unselectedLabelStyle: context.textTheme.titleMedium!.copyWith(
          color: tabIndex == 0 ? AppColors.gray500 : AppColors.white,
        ),
        onTap: (index) {
          _viewModel.onTabChanged(index);
        },
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Adjust alignment as needed
              children: [
                AppText(
                  context.wording.scanQR,
                ),
                SizedBox(width: 8), // Add spacing between text and icon
                Assets.svg.icScan2.svg(
                  colorFilter: ColorFilter.mode(
                    tabIndex == 0 ? AppColors.primary : AppColors.white,
                    BlendMode.srcIn,
                  ),
                ), // Your trailing icon
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Adjust alignment as needed
              children: [
                AppText(
                  context.wording.brownyID,
                ),
                SizedBox(width: 8), // Add spacing between text and icon
                Assets.svg.icQrDummy.svg(
                  colorFilter: ColorFilter.mode(
                    tabIndex == 0 ? AppColors.gray500 : AppColors.white,
                    BlendMode.srcIn,
                  ),
                ), // Your trailing icon
              ],
            ),
          ),
        ],
      ),
      title: AppText(
        context.wording.scanning,
        style: context.textTheme.titleLarge!.copyWith(
          color: AppColors.white,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildScannerView(BuildContext context) {
    return Stack(
      children: [
        // Camera view
        MobileScanner(
          controller: _viewModel.cameraController,
          onDetect: _viewModel.onQRCodeDetected,
        ),

        // Scanning frame overlay
        Center(
          child: Assets.svg.icCrossHair.svg(),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDims.size_24.w,
        vertical: AppDims.size_32.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Flash button
          ValueListenableBuilder<bool>(
            valueListenable: _viewModel.isFlashOn,
            builder: (context, isFlashOn, _) {
              return _buildCircleButton(
                icon: Icons.flash_on,
                isActive: isFlashOn,
                onTap: _viewModel.toggleFlash,
              );
            },
          ),

          SizedBox(width: 48.w),

          // Gallery button
          _buildCircleButton(
            icon: Icons.image,
            isActive: false,
            onTap: _viewModel.pickImageAndScan,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 60.w,
        height: 60.w,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.walletBackground
              : AppColors.textSecondary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.white,
          size: 28.sp,
        ),
      ),
    );
  }
}
