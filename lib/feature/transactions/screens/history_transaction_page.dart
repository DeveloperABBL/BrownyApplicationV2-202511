import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/order_history_response.dart';
import 'package:browny_applications_new/feature/transactions/repository/coupon_voucher_repo.dart';
import 'package:browny_applications_new/feature/transactions/repository/history_transaction_repo.dart';
import 'package:browny_applications_new/feature/transactions/repository/machine_transaction_repo.dart';
import 'package:browny_applications_new/feature/transactions/repository/transaction_repo.dart';
import 'package:browny_applications_new/feature/transactions/viewmodel/history_transactions_viewmodel.dart';
import 'package:browny_applications_new/feature/transactions/screens/receipt_machine_page.dart';
import 'package:browny_applications_new/feature/transactions/screens/receipt_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class HistoryTransactionPage extends StatelessWidget {
  const HistoryTransactionPage({super.key});

  static final pagePath = '/HistoryTransactionPage';
  static final pageName = 'HistoryTransactionPage';

  /// util function route to pageName
  static Future<T?> goToPage<T>(BuildContext context) async {
    return await context.pushNamed(HistoryTransactionPage.pageName);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HistoryTransactionsViewmodel(
        context: context,
        couponRepo: CouponVoucherRepo(),
        transactionRepo: TransactionRepo(),
        machineRepo: MachineRepo(),
        historyTransactionRepo: HistoryTransactionRepo(),
      ),
      child: const _HistoryTransactionContent(),
    );
  }
}

class _HistoryTransactionContent extends StatefulWidget {
  const _HistoryTransactionContent();

  @override
  State<_HistoryTransactionContent> createState() =>
      __HistoryTransactionContentState();
}

class __HistoryTransactionContentState
    extends State<_HistoryTransactionContent> {
  late final HistoryTransactionsViewmodel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<HistoryTransactionsViewmodel>();
    _viewModel.attachContext(context);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.fetchOrderHistory();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _viewModel.loadMore();
    }
  }

  Future<void> _onItemTap(OrderHistoryItem item) async {
    final orderId = item.orderId;
    if (orderId == null) return;
    AppOverlays.showLoading(context);
    if (item.isMachineOrder) {
      final result = await _viewModel.fetchMachineReceiptByOrderId(orderId);
      AppOverlays.hideLoading();
      if (!mounted) return;
      if (result.isSuccess) {
        await ReceiptMachinePage.goToPage(context, viewmodel: _viewModel);
        return;
      }
      if (result.hasError) {
        AppOverlays.showBrownyErrorDialog(context, error: result.error);
      }
    } else if (item.isCouponPackageOrder) {
      final result = await _viewModel.fetchCouponReceiptByOrderId(orderId);
      AppOverlays.hideLoading();
      if (!mounted) return;
      if (result.isSuccess) {
        await ReceiptPage.goToPage(context, viewmodel: _viewModel);
        return;
      }
      if (result.hasError) {
        AppOverlays.showBrownyErrorDialog(context, error: result.error);
      }
    }
  }

  Future<void> _openDateRangePicker() async {
    final current = _viewModel.dateRangeNotifier.value;
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: current,
      locale: Localizations.localeOf(context),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: GoogleFonts.promptTextTheme(
              Theme.of(context).textTheme,
            ),
          ),
          child: child!,
        );
      },
    );
    if (range != null) {
      await _viewModel.onDateRangeSelected(range);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText(
          context.wording.orderHistoryTitle,
          style: context.appBarTextThemeWhite,
        ),
        flexibleSpace: FlexibleSpaceBar(
          background: Assets.png.bgAppBar.image(
            fit: BoxFit.cover,
          ),
        ),
        // leading: BackButton(color: AppColors.darkBrown),
      ),
      backgroundColor: AppColors.bareBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Date range filter header
          _DateFilterHeader(
            viewModel: _viewModel,
            onTap: _openDateRangePicker,
          ),
          // Content
          Expanded(
            child: ValueListenableBuilder<UiResult<List<OrderHistoryItem>>>(
              valueListenable: _viewModel.orderHistoryNotifier,
              builder: (context, result, _) {
                if (result.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (result.hasError) {
                  return Center(
                    child: AppText(
                      context.wording.errorUi,
                      style: context.textTheme.labelMedium,
                    ),
                  );
                }

                if (result.isEmpty ||
                    result.data == null ||
                    result.data!.isEmpty) {
                  return Center(
                    child: AppText(
                      context.wording.noOrderHistory,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                final items = result.data!;
                final locale = context.languageCode;

                return RefreshIndicator(
                  onRefresh: () => _viewModel.fetchOrderHistory(refresh: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    // separatorBuilder: (_, _) => Divider(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    itemCount: items.length + 1,
                    itemBuilder: (context, index) {
                      if (index == items.length) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: _viewModel.isLoadingMoreNotifier,
                          builder: (_, isLoading, _) {
                            if (!isLoading) return SizedBox(height: 16.h);
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        );
                      }
                      return _OrderHistoryItem(
                        item: items[index],
                        locale: locale,
                        onTap: () => _onItemTap(items[index]),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Date filter header widget
// ─────────────────────────────────────────────
class _DateFilterHeader extends StatelessWidget {
  const _DateFilterHeader({
    required this.viewModel,
    required this.onTap,
  });

  final HistoryTransactionsViewmodel viewModel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return ValueListenableBuilder<DateTimeRange>(
      valueListenable: viewModel.dateRangeNotifier,
      builder: (context, range, _) {
        final startLabel = _formatDateLabel(range.start, locale);
        final endLabel = _formatDateLabel(range.end, locale);

        return Container(
          // width: double.infinity,
          padding: EdgeInsets.only(
            left: AppDims.size_16.w,
            right: AppDims.size_16.w,
            top: AppDims.size_16.h,
            bottom: AppDims.size_8.h,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDims.size_12.w,
              vertical: AppDims.size_8.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppDims.smallRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Assets.svg.icCalendarToday.svg(
                  colorFilter: ColorFilter.mode(
                    AppColors.darkBrown,
                    BlendMode.srcIn,
                  ),
                ),
                AppDims.horizonPadding_8,

                GestureDetector(
                  onTap: onTap,
                  child: AppText(
                    '$startLabel – $endLabel',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: AppColors.darkBrown,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AppDims.horizonPadding_4,
              ],
            ),
          ),
        );
      },
    );
  }

  /// แปลงวันที่ตาม locale: TH → พุทธศักราช 2 หลัก, EN/ZH → คริสต์ศักราช 2 หลัก
  /// ไม่เติม น. ท้าย (date-only)
  String _formatDateLabel(DateTime date, String locale) {
    initializeDateFormatting(locale);
    final year = locale == 'th' ? date.year + 543 : date.year;
    final yy = (year % 100).toString().padLeft(2, '0');
    final dayMonth = DateFormat('d MMM', locale).format(date);
    return '$dayMonth $yy';
  }
}

// ─────────────────────────────────────────────
// Order history item card
// ─────────────────────────────────────────────
class _OrderHistoryItem extends StatelessWidget {
  const _OrderHistoryItem({
    required this.item,
    required this.locale,
    required this.onTap,
  });

  final OrderHistoryItem item;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final storeName = item.store?.getNameDisplay(locale) ?? '';
    final receiptDate = item.receiptAtDisplay(locale);

    // แสดงข้อมูลย่อย: machine type + no (machine_order) หรือ package name (coupon_package_order)
    final String subtitle;
    if (item.isMachineOrder) {
      final machineType = item.getMachineTypeDisplay(locale);
      final machineNo = item.machineNo != null
          ? '\n${context.wording.machineNo} ${item.machineNo}'
          : '';
      subtitle = [machineType, machineNo].where((s) => s.isNotEmpty).join(' ');
    } else {
      subtitle = item.getPackageNameDisplay(locale);
    }

    final paymentName = item.paymentMethod?.getNameDisplay(locale) ?? '';
    final paymentImage = item.paymentMethod?.image;

    return Container(
      margin: EdgeInsets.only(bottom: AppDims.size_8.h),
      padding: EdgeInsets.all(AppDims.size_12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: BoxBorder.fromLTRB(
                bottom: BorderSide(
                  color: AppColors.border,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(bottom: AppDims.size_8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    'Order ID',
                    style: context.textTheme.labelMedium!.copyWith(
                      color: AppColors.gray600,
                    ),
                    // maxLines: 2,
                    // overflow: TextOverflow.ellipsis,
                  ),
                  AppText(
                    item.receiptNo ?? '-',
                    style: context.textTheme.labelMedium!.copyWith(
                      // color: AppColors.gray600,
                    ),
                    // maxLines: 2,
                    // overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          AppDims.vericalPadding_8,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // Image Service ที่ใช้
              Container(
                width: AppDims.size_75.w,
                height: AppDims.size_75.h,
                padding: EdgeInsets.symmetric(
                  vertical: AppDims.size_5.h,
                  horizontal: AppDims.size_12.w,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: AppColors.border,
                  // image: DecorationImage(
                  //   image: NetworkImage(
                  //     'https://dev.abgroup.co.th/storage/galleries/s3nbAR7QLSPpZ9aSTWSyGV9nXQZy6JhsPgVvaJKL.png',
                  //     // notification.icon!,
                  //   ),
                  // ),
                ),
                child: Image.network(
                  item.image.orEmpty,
                  width: AppDims.size_50.w,
                  errorBuilder: (_, _, _) => SizedBox(),
                ),
              ),
              AppDims.horizonPadding_8,
              Expanded(
                child: Column(
                  spacing: AppDims.size_2.h,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // store
                    if (storeName.isNotEmpty) ...[
                      AppText(
                        storeName,
                        style: context.textTheme.labelMedium?.copyWith(
                          // color: AppColors.darkBrown,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppDims.vericalPadding_2,
                    ],
                    // package ใช้งานเครื่อง
                    if (item.program != null) ...[
                      AppText(
                        item.program!.getNameDisplay(locale),
                        style: context.textTheme.labelMedium?.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                    ],
                    // Machine/Package subtitle
                    if (subtitle.isNotEmpty) ...[
                      AppText(
                        subtitle,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                      AppDims.vericalPadding_2,
                    ],
                    if (paymentName.orEmpty.isNotEmpty) ...[
                      Row(
                        spacing: AppDims.size_2.w,
                        children: [
                          Spacer(),
                          Image.network(
                            width: AppDims.size_24.w,
                            paymentImage.orEmpty,
                            errorBuilder: (_, _, _) => SizedBox(),
                          ),
                          AppText(
                            paymentName,
                            style: context.textTheme.labelMedium?.copyWith(
                              color: AppColors.gray600,
                            ),
                          ),
                          AppDims.horizonPadding_4,
                          if (item.amount.orEmpty.isNotEmpty)
                            AppText(
                              formatCurrency(
                                string: item.amount.ifNullOrEmpty('0.00'),
                                leadingSign: '฿',
                              ),
                              style: context.textTheme.labelMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                    ],
                  ],
                ),
              ),
            ],
          ),
          AppDims.vericalPadding_8,
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppDims.size_12.w,
                vertical: AppDims.size_8.h,
              ),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.ci3,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                spacing: AppDims.size_10.w,
                children: [
                  Assets.svg.icChecked.svg(width: AppDims.size_24.w),
                  Expanded(
                    child: AppText(
                      receiptDate,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ),
                  Assets.svg.icArrowForward.svg(
                    width: AppDims.size_24.w,
                    colorFilter: ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
