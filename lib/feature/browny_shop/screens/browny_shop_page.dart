import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';
import 'package:browny_applications_new/feature/browny_shop/viewmodel/browny_shop_page_viewmodel.dart';
import 'package:browny_applications_new/feature/browny_shop/widgets/browny_shop_categories_grid_section.dart';
import 'package:browny_applications_new/feature/browny_shop/widgets/flash_deals_section.dart';

class BrownyShopPage extends StatelessWidget {
  const BrownyShopPage({super.key});

  static final pagePath = '/browny_shop_page';
  static final pageName = 'BrownyShopPage';

  static Future<T?> goToPage<T>(BuildContext context) async {
    return await context.pushNamed(BrownyShopPage.pageName);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BrownyShopPageViewmodel(
        context: context,
        repo: BrownyShopRepo(),
      ),
      child: const _BrownyShopPageWidget(),
    );
  }
}

class _BrownyShopPageWidget extends StatefulWidget {
  const _BrownyShopPageWidget();

  @override
  State<_BrownyShopPageWidget> createState() => _BrownyShopPageWidgetState();
}

class _BrownyShopPageWidgetState extends State<_BrownyShopPageWidget> {
  BrownyShopPageViewmodel get _vm => context.read<BrownyShopPageViewmodel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm.attachContext(context);
      _vm.fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          95.h + MediaQuery.of(context).padding.top,
        ),
        child: _buildAppBar(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppDims.vericalPadding_24,
            // [1] Flash Deals — placeholder รอ API
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDims.size_16.w),
              child: const FlashDealsSection(),
            ),
            // [2] หมวดหมู่ + chips + grid (shared widget กับ home)
            BrownyShopCategoriesGridSection(
              topBoxDecoration: BoxDecoration(),
              productsListenable: _vm.productsNotifier,
              selectedCategoryListenable: _vm.selectedCategoryNotifier,
              onCategorySelected: _vm.onCategorySelected,
              onProductTap: (p) => debugPrint('tap product: ${p.id}'),
              onProductFavoriteTap: (p) => debugPrint('fav product: ${p.id}'),
            ),
            AppDims.vericalPadding_24,
          ],
        ),
      ),
      bottomNavigationBar: BrownyBottomNav(
        currentIndex: 3,
        onTap: BrownyBottomNav.onTapAppDefault,
      ),
    );
  }

  /// AppBar — 2 rows: (back + Browny Shop logo + notification) / (search + bag + headset)
  Widget _buildAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // gradient: AppColors.primaryGradient,
        image: DecorationImage(
          fit: BoxFit.fill,
          image: Assets.png.bgAppBar.provider(),
        ),
      ),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDims.size_16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTopRow(context),
            AppDims.vericalPadding_8,
            _buildBottomRow(context),
            AppDims.vericalPadding_16,
          ],
        ),
      ),
    );
  }

  /// Top Row: back button + Browny Shop logo + "Shop" text + notification (white)
  Widget _buildTopRow(BuildContext context) {
    return SizedBox(
      height: AppDims.size_39.h,
      child: Row(
        children: [
          BackButton(
            color: AppColors.white,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Assets.icShop.icBrownyShop.image(
                  height: AppDims.size_24.h,
                ),
                SizedBox(width: AppDims.size_4.w),
                AppText(
                  context.wording.brownyShopTitle,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => debugPrint('tap notification (TODO)'),
            child: SizedBox(
              width: AppDims.size_39.w,
              height: AppDims.size_39.w,
              child: Center(
                child: Assets.svg.icNotification.svg(
                  width: AppDims.size_24.w,
                  height: AppDims.size_24.w,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom Row: search box + shopping bag + headset
  Widget _buildBottomRow(BuildContext context) {
    return SizedBox(
      height: AppDims.size_40.h,
      child: Row(
        children: [
          Expanded(child: _buildSearchBox(context)),
          SizedBox(width: AppDims.size_8.w),
          _buildIconButton(
            context,
            svg: Assets.icShop.icShoppingBag,
            onTap: () => debugPrint('tap shopping bag (TODO)'),
          ),
          SizedBox(width: AppDims.size_8.w),
          _buildIconButton(
            context,
            svg: Assets.svg.icHeadset,
            onTap: () => debugPrint('tap headset (TODO)'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox(BuildContext context) {
    return GestureDetector(
      onTap: () => debugPrint('tap search → SearchPage (TODO)'),
      child: Container(
        height: AppDims.size_40.h,
        padding: EdgeInsets.symmetric(horizontal: AppDims.size_16.w),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          border: Border.all(color: AppColors.productStroke),
          borderRadius: BorderRadius.circular(AppDims.size_8.r),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: AppDims.size_16.w,
              color: AppColors.gray500,
            ),
            SizedBox(width: AppDims.size_8.w),
            Expanded(
              child: AppText(
                context.wording.searchProductPlaceholder,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required SvgGenImage svg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: AppDims.size_30.w,
        height: AppDims.size_30.w,
        child: Center(
          child: svg.svg(
            width: AppDims.size_24.w,
            height: AppDims.size_24.w,
            colorFilter: const ColorFilter.mode(
              AppColors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
