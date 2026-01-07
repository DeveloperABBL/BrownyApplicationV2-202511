import 'package:browny_applications_new/core/res/icons/assets.gen.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/widgets/app_container_radius.dart';
import 'package:browny_applications_new/core/widgets/app_text.dart';
import 'package:browny_applications_new/feature/wallet/viewmodel/wallet_viewmodel.dart';
import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:browny_applications_new/res/dims/app_dims.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  static final pagePath = '/wallet';
  static final pageName = 'walletPage';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WalletViewModel(context: context),
      child: WalletWidget(),
    );
  }
}

class WalletWidget extends StatefulWidget {
  const WalletWidget({super.key});

  @override
  State<WalletWidget> createState() => _WalletWidgetState();
}

class _WalletWidgetState extends State<WalletWidget> {
  late WalletViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read();
    _viewModel.attachContext(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.walletBackground,
      appBar: AppBar(
        backgroundColor: AppColors.walletBackground,
        title: AppText(
          'TP+ Wallet',
          style: context.textTheme.titleLarge!.copyWith(color: AppColors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Assets.svg.icHeadset.svg(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Assets.png.walletObjBg.image(
                  fit: BoxFit.contain,
                ),
              ),

              // onBackground Container สีขาว
              Align(
                alignment: Alignment.bottomCenter,
                child: AppContainerRadius(
                  height: (boxConstraints.maxHeight * 0.636).h,
                ),
              ),

              Center(
                child: Column(
                  children: [
                    AppDims.vericalPadding_32,
                    // Card Balance
                    SizedBox(
                      width: (boxConstraints.maxWidth * 0.7).w,
                      height: (boxConstraints.maxHeight * 0.22).h,
                      child: Card(
                        child: Container(
                          margin: EdgeInsets.all(24),
                          child: Column(
                            children: [
                              AppText(
                                'ยอดเงินคงเหลือ',
                                style: context.textTheme.bodySmall!.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              AppDims.vericalPadding_4,

                              AppText(
                                '฿2,500.00',
                                style: context.textTheme.headlineLarge!
                                    .copyWith(
                                      fontSize: AppDims.size_36.sp,
                                      color: AppColors.textBlack,
                                    ),
                              ),

                              AppDims.vericalPadding_16,

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      IconButton.filled(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.download,
                                          color: AppColors.textBlack,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.background,
                                          side: BorderSide(
                                            color: AppColors.border,
                                          ),
                                          foregroundColor: AppColors
                                              .walletButtonForegroundColor,
                                        ),
                                      ),
                                      AppText(
                                        'เติมเงิน',
                                        style: context.textTheme.bodySmall!
                                            .copyWith(
                                              fontSize: AppDims.size_10.sp,
                                              color: AppColors.textBlack,
                                            ),
                                      ),
                                    ],
                                  ),

                                  Column(
                                    children: [
                                      IconButton.filled(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.qr_code_scanner_outlined,
                                          color: AppColors.textBlack,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.background,
                                          side: BorderSide(
                                            color: AppColors.border,
                                          ),
                                          foregroundColor: AppColors
                                              .walletButtonForegroundColor,
                                        ),
                                      ),
                                      AppText(
                                        'เติมเงิน',
                                        style: context.textTheme.bodySmall!
                                            .copyWith(
                                              fontSize: AppDims.size_10.sp,
                                              color: AppColors.textBlack,
                                            ),
                                      ),
                                    ],
                                  ),

                                  Column(
                                    children: [
                                      IconButton.filled(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.schedule_rounded,
                                          color: AppColors.textBlack,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.background,
                                          side: BorderSide(
                                            color: AppColors.border,
                                          ),
                                          foregroundColor: AppColors
                                              .walletButtonForegroundColor,
                                        ),
                                      ),
                                      AppText(
                                        'เติมเงิน',
                                        style: context.textTheme.bodySmall!
                                            .copyWith(
                                              fontSize: AppDims.size_10.sp,
                                              color: AppColors.textBlack,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Text แจ้งปัญหา
                    TextButton(
                      onPressed: () {},
                      child: AppText(
                        '*ในกรณีที่ท่านพบปัญหาการใช้งาน หรือต้องการขอคืนเงิน กรุณาคลิกที่นี่',
                        style: context.textTheme.titleSmall!.copyWith(
                          fontSize: AppDims.size_10.sp,
                          color: AppColors.cocoaBrown,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.cocoaBrown,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
