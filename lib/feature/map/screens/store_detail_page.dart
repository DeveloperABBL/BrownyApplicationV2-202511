import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/store_detail_response.dart';
import 'package:browny_applications_new/feature/scaner/screen/scanner_page.dart';

class StoreDetailPage extends StatelessWidget {
  const StoreDetailPage({
    super.key,
    required this.storeDetail,
  });

  static final pagePath = '/strore_detail';
  static final pageName = 'strore_detail';
  static final kData = 'kStoreDetailData';

  final StoreDataDetail storeDetail;

  @override
  Widget build(BuildContext context) {
    return StoreDetailContent(
      storeDetail: storeDetail,
    );
  }
}

class StoreDetailContent extends StatefulWidget {
  const StoreDetailContent({
    super.key,
    required this.storeDetail,
  });
  final StoreDataDetail storeDetail;

  @override
  State<StoreDetailContent> createState() => _StoreDetailContentState();
}

class _StoreDetailContentState extends State<StoreDetailContent> {
  StoreDataDetail get store => widget.storeDetail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterDecoration: BoxDecoration(),
      persistentFooterButtons: [
        // ปุ่มยืนยันซื้อคูปอง
        Container(
          padding: EdgeInsets.only(
            left: AppDims.size_12.w,
            right: AppDims.size_12.w,
            top: AppDims.size_8.h,
          ),
          child: ElevatedButton.icon(
            iconAlignment: IconAlignment.end,
            onPressed: () {
              ScannerPage.goToPage(context);
            },
            icon: Assets.svg.icScan2.svg(
              colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
            ),
            // สแกนเพื่อเริ่มใช้งาน
            label: AppText(context.wording.scanToStart),
          ),
        ),
      ],
      body: CustomScrollView(
        slivers: [
          // AppBar
          _buildMyAppBar(),

          // Store Info
          _buildStoreInfo(
            context,
          ),

          // Store Service available
          ..._buildStoreServiceAvailable(context),

          // Facilities
          ..._buildFacilities(context),

          // เครื่องซัก
          ..._buildMachineWasher(context),

          // เครื่องอบ
          ..._buildMachineDryer(context),
        ],
      ),
    );
  }

  List<Widget> _buildMachineDryer(BuildContext context) {
    return [
      _mySliverToBoxAdapter(
        child: ElevatedButton.icon(
          onPressed: null,
          icon: Assets.services.icWasher.svg(),
          label: AppText(
            // 'เครื่องอบ',
            context.wording.dryer,
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
        ),
      ),
      _mySliverToBoxAdapter(
        child: SizedBox(
          width: AppDims.size_109.w,
          height: AppDims.size_106.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final machine = store.machines!.dryer![index];
              return _cardMachine(
                machineImage: Assets.services.storeDryer,
                // เครื่องอบ\n${machine.name.orEmpty}',
                machine: '${context.wording.dryer}\n${machine.name.orEmpty}',
                status: machine.status!.getTextByLocale(context.languageCode),
                active: machine.isMachineAcive,
                available: machine.isAvailable(context.languageCode),
              );
            },
            separatorBuilder: (context, index) {
              return AppDims.horizonPadding_8;
            },
            itemCount: store.machines!.dryer.orEmpty.length,
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildMachineWasher(BuildContext context) {
    return [
      _mySliverToBoxAdapter(
        child: ElevatedButton.icon(
          onPressed: null,
          icon: Assets.services.icWasher.svg(),
          label: AppText(
            // 'เครื่องซักผ้า',
            context.wording.washer,
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
        ),
      ),
      _mySliverToBoxAdapter(
        child: SizedBox(
          width: AppDims.size_109.w,
          height: AppDims.size_106.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final machine = store.machines!.washer![index];
              return _cardMachine(
                machineImage: Assets.services.storeWasher,
                machine: '${context.wording.washer}\n${machine.name.orEmpty}',
                status: machine.status!.getTextByLocale(context.languageCode),
                active: machine.isMachineAcive,
                available: machine.isAvailable(context.languageCode),
              );
            },
            separatorBuilder: (context, index) {
              return AppDims.horizonPadding_8;
            },
            itemCount: store.machines!.washer.orEmpty.length,
          ),
        ),
      ),
    ];
  }

  Widget _cardMachine({
    required AssetGenImage machineImage,
    required String machine,
    required String status,
    required bool active,
    required bool available,
  }) {
    return Container(
      foregroundDecoration: active
          ? null
          : BoxDecoration(
              color: Colors.grey,
              backgroundBlendMode: BlendMode.saturation,
            ),
      child: Stack(
        children: [
          // Assets.services.storeWasher.image(
          machineImage.image(
            width: AppDims.size_109.w,
            height: AppDims.size_106.h,
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppText(
                machine,
                style: context.textTheme.labelLarge!.copyWith(
                  color: AppColors.textWhite,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              margin: const EdgeInsets.all(8.0),
              padding: EdgeInsets.symmetric(
                vertical: AppDims.size_2.h,
                horizontal: AppDims.size_8.w,
              ),
              decoration: BoxDecoration(
                color: available ? AppColors.ci3 : AppColors.green400,
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Center(
                child: AppText(
                  status,
                  style: context.textTheme.headlineSmall!.copyWith(
                    fontSize: AppDims.size_14.sp,
                    color: available ? AppColors.primary : AppColors.gray500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFacilities(BuildContext context) {
    return [
      _mySliverToBoxAdapter(child: AppDims.vericalPadding_8),
      _mySliverToBoxAdapter(
        child: ElevatedButton.icon(
          onPressed: null,
          icon: Assets.svg.icHeartRoundedGreen.svg(),
          label: AppText(
            // 'สิ่งอำนวยความสะดวก',
            context.wording.facilities,
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
        ),
      ),
      _mySliverToBoxAdapter(
        child: SizedBox(
          height: AppDims.size_64.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final service = store.services![index];
              return Container(
                padding: EdgeInsets.symmetric(
                  vertical: AppDims.size_2.h,
                  horizontal: AppDims.size_1.w,
                ),
                child: Column(
                  children: [
                    Image.network(
                      width: AppDims.size_50.w,
                      service.icon!,
                    ),
                    AppDims.vericalPadding_6,

                    AppText(
                      service.name?.getTextByLocale(
                            context.languageCode,
                          ) ??
                          '',
                      style: context.textTheme.labelSmall!.copyWith(
                        fontSize: AppDims.size_10.sp,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => AppDims.horizonPadding_8,
            itemCount: store.services.orEmpty.length,
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildStoreServiceAvailable(BuildContext context) {
    return [
      _mySliverToBoxAdapter(
        child: ElevatedButton.icon(
          onPressed: null,
          icon: Assets.svg.icPawRoundedGreen.svg(),
          label: AppText(
            // 'บริการ',
            context.wording.services,
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
        ),
      ),
      _mySliverToBoxAdapter(
        child: Row(
          children: [
            // เครื่องซัก
            Stack(
              children: [
                Assets.services.storeWasher.image(
                  width: AppDims.size_109.w,
                  height: AppDims.size_106.h,
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AppText(
                      // 'เครื่องซัก',
                      context.wording.washer,
                      style: context.textTheme.labelLarge!.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    margin: EdgeInsets.all(8.0.r),
                    padding: EdgeInsets.symmetric(
                      vertical: 8.0.r,
                      horizontal: 4.r,
                    ),
                    width: AppDims.size_24.w,
                    decoration: BoxDecoration(
                      color: AppColors.ci3,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AppText(
                        store.totalWashers.toString(),
                        style: context.textTheme.headlineSmall!.copyWith(
                          fontSize: AppDims.size_14.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            AppDims.horizonPadding_8,

            // เครื่องอบ
            Stack(
              children: [
                Assets.services.storeDryer.image(
                  width: AppDims.size_109.w,
                  height: AppDims.size_106.h,
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AppText(
                      // 'เครื่องอบ',
                      context.wording.dryer,
                      style: context.textTheme.labelLarge!.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    margin: EdgeInsets.all(8.0.r),
                    padding: EdgeInsets.symmetric(
                      vertical: 8.0.r,
                      horizontal: 4.r,
                    ),
                    width: AppDims.size_24.w,
                    decoration: BoxDecoration(
                      color: AppColors.ci3,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AppText(
                        store.totalDryers.toString(),
                        style: context.textTheme.headlineSmall!.copyWith(
                          fontSize: AppDims.size_14.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildStoreInfo(BuildContext context) {
    return _mySliverToBoxAdapter(
      child: Row(
        children: [
          // Avatar Store
          CircleAvatar(
            radius: 29,
            child: ClipOval(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      store.icon.orEmpty,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          AppDims.horizonPadding_16,

          // Name, Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                AppText(
                  store.getStoreNameDisplay(
                    context.languageCode,
                  ),
                  style: context.textTheme.headlineLarge!.copyWith(
                    fontSize: AppDims.size_16.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppDims.vericalPadding_2,
                // Type Description
                AppText(
                  store.getTypeNameDisplay(
                    context.languageCode,
                  ),
                  style: context.textTheme.labelLarge!.copyWith(
                    color: AppColors.gray500,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppDims.vericalPadding_2,
                // Rating, Distance
                Row(
                  children: [
                    // Star Icon
                    Icon(
                      Icons.star,
                      color: AppColors.yellow2,
                    ),
                    AppDims.horizonPadding_6,

                    // Rating Value
                    AppText(
                      store.ratingValue.toString(),
                      style: context.textTheme.labelLarge!.copyWith(
                        color: AppColors.gray500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppDims.horizonPadding_8,

                    // Distance and Navigator
                    GestureDetector(
                      onTap: () {
                        // Open Map
                        LaunchHelper.openMap(
                          store.latitudeValue,
                          store.longitudeValue,
                          label: store.getStoreNameDisplay(
                            context.languageCode,
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: AppDims.size_6.h,
                          horizontal: AppDims.size_8.w,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.ci3,
                          borderRadius: BorderRadius.circular(
                            AppDims.size_30.r,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Icon Map Arrow
                            Assets.svg.icMapsArrow.svg(),
                            AppDims.horizonPadding_6,

                            // Distance
                            AppText(
                              store.getDistaceDisplay(
                                context.languageCode,
                              ),
                              style: context.textTheme.labelMedium!.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyAppBar() {
    return SliverAppBar(
      pinned: false,
      floating: false,
      surfaceTintColor: AppColors.transparent,
      stretch: true,
      expandedHeight: 200.h,
      elevation: 0.0,
      leading: BackButton(
        color: AppColors.black,
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          store.image.orEmpty,
          fit: BoxFit.cover,
        ),
        stretchModes: [
          StretchMode.zoomBackground,
        ],
        expandedTitleScale: 8,
        title: AppContainerRadius(
          height: AppDims.size_2.h,
        ),
        // collapseMode: CollapseMode.none,
        titlePadding: EdgeInsets.all(0.0),
      ),
    );
  }

  SliverToBoxAdapter _mySliverToBoxAdapter({required Widget child}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppDims.size_16.w,
          right: AppDims.size_16.w,
        ),
        child: child,
      ),
    );
  }
}
