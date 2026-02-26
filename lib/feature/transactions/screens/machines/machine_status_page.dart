import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/feature/transactions/models/machine_program_model.dart';
import 'package:browny_applications_new/feature/transactions/repository/coupon_voucher_repo.dart';
import 'package:browny_applications_new/feature/transactions/repository/machine_transaction_repo.dart';
import 'package:browny_applications_new/feature/transactions/repository/transaction_repo.dart';
import 'package:browny_applications_new/feature/transactions/viewmodel/transactions_viewmodel.dart';

class MachineStatusPage extends StatelessWidget {
  const MachineStatusPage({
    super.key,
    required this.machineId,
  });

  static final pagePath = '/machine_status_page';
  static final pageName = 'machine_status_page';

  /// util function route to pageName
  static Future<T?> goToPage<T>(
    BuildContext context, {
    required String machineId,
  }) async {
    return await context.pushNamed(
      MachineStatusPage.pageName,
      extra: machineId,
    );
  }

  static void goReplacementPage(
    BuildContext context, {
    required String machineId,
  }) async {
    return context.pushReplacementNamed(
      MachineStatusPage.pageName,
      extra: machineId,
    );
  }

  final String machineId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MachineTransactionViewmodel(
        context: context,
        couponRepo: CouponVoucherRepo(),
        transactionRepo: TransactionRepo(),
        machineRepo: MachineRepo(),
      ),
      child: MachineStatusContent(
        machineId: machineId,
      ),
    );
  }
}

class MachineStatusContent extends StatefulWidget {
  const MachineStatusContent({
    super.key,
    required this.machineId,
  });
  final String machineId;

  @override
  State<MachineStatusContent> createState() => _MachineStatusContentState();
}

class _MachineStatusContentState extends State<MachineStatusContent> {
  TextStyle get _textPrimary => context.textTheme.labelLarge!.copyWith(
    color: AppColors.textPrimary,
  );
  TextStyle get _textPrimarySelected => context.textTheme.labelLarge!.copyWith(
    color: AppColors.primary,
  );
  TextStyle get _textPrice => context.textTheme.headlineSmall!.copyWith(
    fontSize: AppDims.size_16.sp,
    color: AppColors.textPrimary,
  );

  late final MachineTransactionViewmodel _viewmodel;
  MachineProgramModel? _machineProgram;

  @override
  void initState() {
    super.initState();
    _viewmodel = context.read();
    _viewmodel.attachContext(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewmodel.fetchMachinePrograms(widget.machineId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      persistentFooterDecoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: AppColors.defatultShadow,
      ),
      persistentFooterButtons: [
        // ปุ่มยืนยันสั่งเครื่องทำงาน
        Container(
          padding: EdgeInsets.only(
            left: AppDims.size_16.w,
            right: AppDims.size_16.w,
            top: AppDims.size_8.h,
          ),
          child: ElevatedButton(
            onPressed: () {
              context.pop();
            },
            child: AppText(
              context.wording.backToMainPage,
              style: context.textTheme.headlineSmall!.copyWith(
                fontSize: AppDims.size_14.sp,
                color: AppColors.textWhite,
              ),
            ),
          ),
        ),
      ],
      body: ValueListenableBuilder(
        valueListenable: _viewmodel.machineProgramsNotifier,
        builder: (context, result, child) {
          if (result.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (result.hasError || result.isEmpty) {
            return Center(
              child: AppText(
                // เดิม: ไม่พบข้อมูลเครื่องหรือเกิดข้อผิดพลาด\nกรุณาตรวจสอบและลองใหม่อีกครั้ง
                context.wording.machineDataLoadError,
              ),
            );
          }
          // assign value
          _machineProgram = result.data!;
          return Column(
            children: [
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      // Fixed Header with Machine Image
                      _buildFixedHeader(),

                      // Title เครื่องซัก, สาขา
                      _mainTitle(),

                      // Program ของเครื่องซักที่มี
                      // _programWidget(),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDims.size_16.w,
                        ),
                        child: Row(
                          children: [
                            Assets.svg.icPawRoundedGreen.svg(
                              width: 30.w,
                            ),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: 0.3,
                                backgroundColor: AppColors.ci7,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                            Assets.svg.icCheckedTrans.svg(
                              width: 30.w,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDims.size_16.w,
                        ),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                AppText(
                                  'เริ่มต้น',
                                  style: _textPrimary.copyWith(
                                    fontSize: AppDims.size_12.sp,
                                  ),
                                ),
                                AppText(
                                  '16:00',
                                  style: _textPrimary.copyWith(
                                    color: AppColors.gray500,
                                    fontSize: AppDims.size_12.sp,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Column(
                              children: [
                                AppText(
                                  'สำเร็จ',
                                  style: _textPrimary.copyWith(
                                    fontSize: AppDims.size_12.sp,
                                  ),
                                ),
                                AppText(
                                  '16:24',
                                  style: _textPrimary.copyWith(
                                    color: AppColors.gray500,
                                    fontSize: AppDims.size_12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      AppDims.vericalPadding_16,

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDims.size_16.w,
                        ),
                        child: Divider(),
                      ),

                      // Summary Transaction
                      _summary(),

                      // Extra padding เพื่อให้ scroll พ้น footer button
                      // SizedBox(height: 42.h),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFixedHeader() {
    return Container(
      height: 365.h, // กำหนดความสูงเท่าเดิม (ตาม SliverAppBar expandedHeight)
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.png.bgMachine.provider(),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // AppBar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: AppText(
                  context.wording.startOperation, // เดิม: เริ่มต้นทำงาน
                  style: context.appBarTextThemeWhite,
                ),
              ),
            ),

            // Machine Model Image
            Padding(
              padding: EdgeInsets.only(
                top: AppDims.size_42.h,
                bottom: AppDims.size_42.h,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 56.w),
                  Image.network(
                    _machineProgram!.machineImage.orEmpty,
                  ),
                  Container(
                    padding: EdgeInsets.only(right: AppDims.size_16.w),
                    width: 56.w,
                    height: 87.h,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Machine No
                        Stack(
                          children: [
                            Assets.png.icPaw2RoundedGreen.image(
                              width: AppDims.size_39.w,
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: AlignmentGeometry.center,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 2.0.w,
                                    top: 8.0.h,
                                  ),
                                  child: AppText(
                                    _machineProgram!.machineNo.toString(),
                                    style: context.textTheme.headlineSmall!
                                        .copyWith(
                                          fontSize: AppDims.size_16.sp,
                                          color: AppColors.primary,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppDims.vericalPadding_8,
                        ValueListenableBuilder(
                          valueListenable: _viewmodel.machineProgramsNotifier,
                          builder: (context, result, child) {
                            return Container(
                              width: AppDims.size_40.h,
                              height: result.data?.selectedProgram == null
                                  ? null
                                  : AppDims.size_40.h,
                              padding: EdgeInsets.symmetric(
                                vertical: AppDims.size_8.h,
                                horizontal: AppDims.size_13.w,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.ci3,
                                shape: BoxShape.circle,
                              ),
                              child: result.data?.selectedProgram == null
                                  ? AppText(
                                      '?',
                                      style: context.textTheme.labelLarge!
                                          .copyWith(
                                            color: AppColors.primary,
                                            fontSize: AppDims.size_24.sp,
                                          ),
                                    )
                                  : Image.network(
                                      result.data!.selectedProgram!.image!,
                                    ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Background Radius
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AppContainerRadius(
                height: AppDims.size_24.h,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mainTitle() {
    return Column(
      children: [
        // Title เครื่องซัก
        AppText(
          _machineProgram!.machineName!.getByLocaleCode(
            context.languageCode,
          )!,
          style: context.textTheme.headlineMedium,
        ),
        AppDims.vericalPadding_4,

        // สาขา
        AppText(
          _machineProgram!.storeName!.getByLocaleCode(
            context.languageCode,
          )!,
          style: context.textTheme.bodyMedium!.copyWith(
            color: AppColors.gray500,
          ),
        ),

        AppDims.vericalPadding_24,
      ],
    );
  }

  Widget _summary() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDims.size_16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppDims.vericalPadding_16,
          // detail
          // Order ID
          _lineSummay(
            title: 'Order ID',
            tailing: 'BBB3330000',
          ),
          AppDims.vericalPadding_16,
          // บริการ
          _lineSummay(
            // บริการ
            title: context.wording.services,
            tailing: 'บริการที่เลือก',
          ),
          AppDims.vericalPadding_16,
          // สถานะ
          _lineSummay(
            // สถานะ
            title: context.wording.status,
            tailing: 'สถานะเครื่อง',
          ),
          AppDims.vericalPadding_16,
          // เวลาที่เหลือโดยประมาณ
          _lineSummay(
            title: 'เวลาที่เหลือโดยประมาณ',
            tailing: '21:02',
            textPriceColor: AppColors.primary,
          ),
          AppDims.vericalPadding_16,
        ],
      ),
    );
  }

  Widget _title({
    required Widget icon,
    required String title,
  }) {
    return ElevatedButton.icon(
      onPressed: null,
      icon: icon,
      label: AppText(
        title,
        style: context.textTheme.labelLarge!.copyWith(
          fontSize: AppDims.size_16.sp,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.transparent,
        foregroundColor: AppColors.primary,
        alignment: AlignmentDirectional.centerStart,
        padding: EdgeInsets.zero,
        disabledBackgroundColor: AppColors.transparent,
        overlayColor: AppColors.transparent,
      ),
    );
  }

  Widget _lineSummay({
    required String title,
    required String tailing,
    Color? textPriceColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          title,
          style: _textPrimary.copyWith(fontSize: AppDims.size_16.sp),
        ),

        AppText(
          tailing,
          style: _textPrimary,
        ),
      ],
    );
  }
}
