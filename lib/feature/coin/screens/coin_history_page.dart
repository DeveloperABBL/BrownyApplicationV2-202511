import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coin_history_response.dart';
import 'package:browny_applications_new/feature/coin/viewmodel/coin_viewmodel.dart';
import 'package:browny_applications_new/feature/coin/widgets/coin_history_item_widget.dart';

class CoinHistoryPage extends StatefulWidget {
  const CoinHistoryPage({
    super.key,
    required this.viewmodel,
  });

  static final pagePath = '/coin_history';
  static final pageName = 'coin_history';

  final CoinViewmModel viewmodel;

  @override
  State<CoinHistoryPage> createState() => _CoinHistoryPageState();
}

class _CoinHistoryPageState extends State<CoinHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 0, length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      widget.viewmodel.fetchCoinHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bareBackground,
      body: CustomScrollView(
        slivers: [
          // AppBar with background
          SliverAppBar(
            flexibleSpace: FlexibleSpaceBar(
              background: Assets.png.bgAppBar.image(
                fit: BoxFit.cover,
              ),
            ),
            title: AppText(
              // เหรียญของฉัน
              context.wording.myCoins,
              style: context.textTheme.titleLarge!.copyWith(
                color: AppColors.textWhite,
              ),
            ),
            pinned: true,
            floating: false,
          ),

          // Card แสดง Coin ที่มีและกำลังจะหมดอายุ
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(AppDims.size_16),
              padding: EdgeInsets.all(AppDims.size_16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: ValueListenableBuilder(
                valueListenable: widget.viewmodel.coinHistoryNotifier,
                builder: (context, result, child) {
                  if (result.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (result.hasError) {
                    return Center(child: AppText(context.wording.errorUi));
                  }
                  final data = result.data!.data!;
                  return Column(
                    children: [
                      // Title
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Assets.png.brownyCoin.image(
                            width: AppDims.size_33.w,
                          ),
                          AppDims.horizonPadding_8,
                          AppText(
                            data.getBrownyCoinDisplay(),
                            style: context.textTheme.headlineSmall!.copyWith(
                              fontSize: AppDims.size_24,
                            ),
                          ),
                          AppDims.horizonPadding_8,
                          AppText(
                            context.wording.availableCoins,
                            style: context.textTheme.headlineSmall!.copyWith(
                              fontSize: AppDims.size_14,
                            ),
                          ),
                        ],
                      ),
                      AppDims.vericalPadding_8,

                      // ช่องกรอก
                      Row(
                        children: [
                          AppText(
                            data.getExpiredDateDisplay(context.languageCode),
                            style: context.textTheme.labelMedium!.copyWith(
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // TabBar
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              TabBar(
                controller: _tabController,
                dividerColor: AppColors.transparent,
                indicatorPadding: EdgeInsets.symmetric(horizontal: 8.w),
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: context.textTheme.titleMedium!.copyWith(
                  color: AppColors.primary,
                ),
                unselectedLabelStyle: context.textTheme.titleMedium!.copyWith(
                  color: AppColors.gray500,
                ),
                tabs: [
                  Tab(child: AppText(context.wording.allHistory)),
                  Tab(child: AppText(context.wording.received)),
                  Tab(child: AppText(context.wording.used)),
                ],
              ),
            ),
          ),

          // TabBarView content
          SliverFillRemaining(
            hasScrollBody: true,
            child: Container(
              color: AppColors.background,
              child: SafeArea(
                top: false,
                child: ValueListenableBuilder(
                  valueListenable: widget.viewmodel.coinHistoryNotifier,
                  builder: (context, result, child) {
                    if (result.isLoading) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (result.hasError) {
                      return Center(child: AppText(context.wording.errorUi));
                    }

                    final data = result.data!.data!;
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        // ประวัติทั้งหมด
                        _buildTabContent(data.history.orEmpty),

                        // ที่ได้รับ
                        _buildTabContent(data.getHistoryReceived()),

                        // ที่ถูกใช้
                        _buildTabContent(data.getHistoryUsed()),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(List<CoinHistoryItem> list) {
    if (list.isEmpty) {
      return Center(
        child: AppText(
          context.wording.noData,
          style: context.textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final groups = list.groupByMonth();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDims.size_16.w,
        vertical: AppDims.size_14.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.inputFieldDefaultBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: AppDims.size_1.w,
          vertical: AppDims.size_8.h,
        ),
        itemCount: groups.length,
        separatorBuilder: (context, index) => AppDims.vericalPadding_8,
        itemBuilder: (context, groupIndex) {
          final group = groups[groupIndex];
          return _buildGroupSection(context, group);
        },
      ),
    );
  }

  /// สร้าง Section สำหรับแสดง Group ของเดือน
  Widget _buildGroupSection(BuildContext context, CoinHistoryGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header - แสดงเดือน ปี
        AppText(
          group.formatGroupDate(context.languageCode),
          style: context.textTheme.titleSmall?.copyWith(
            color: AppColors.gray600,
          ),
        ),
        // List ของ items ภายใต้ group
        ...group.items.sortByDateDesc().map((history) {
          final locale = context.languageCode;
          return _buildSingleItem(
            context,
            title: history.getNameDisplay(locale),
            date:
                history.date?.formatDateDDMMMMyyyyHHmmMinText(
                  locale,
                  pattern: 'dd MMM yyyy - HH:mm:ss',
                ) ??
                '',
            amount: history.getAmountDisplay(),
            isExpired: history.isExpired,
            isPlus: history.isPlus,
          );
        }),
      ],
    );
  }

  /// สร้าง Single Item สำหรับแสดงประวัติรายการ
  Widget _buildSingleItem(
    BuildContext context, {
    required String title,
    required String date,
    required String amount,
    // true = ใช้หรือไม่ได้, false = หมดอายุ
    required bool isExpired,
    // true = เป็นค่าบวกแสดงสีเขียว, เป็นค่าลบ แสดงสีแดง
    required bool isPlus,
  }) {
    return CoinHistoryItemWidget(
      title: title,
      date: date,
      amount: amount,
      isExpired: isExpired,
      isPlus: isPlus,
    );
  }
}

// Custom SliverPersistentHeaderDelegate for sticky TabBar
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.background,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return false;
  }
}
