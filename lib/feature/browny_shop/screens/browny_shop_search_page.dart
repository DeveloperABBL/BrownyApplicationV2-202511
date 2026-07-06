import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/products_response.dart';
import 'package:browny_applications_new/feature/browny_shop/providers/browny_shop_favorite_store.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';
import 'package:browny_applications_new/feature/browny_shop/screens/browny_shop_product_detail_page.dart';
import 'package:browny_applications_new/feature/browny_shop/viewmodel/browny_shop_search_viewmodel.dart';
import 'package:browny_applications_new/feature/browny_shop/widgets/product_item_widget.dart';

/// หน้าค้นหาสินค้า Browny Shop (Figma node 81:929)
///
/// - ก่อนพิมพ์: แสดง suggestions (ชื่อสินค้า 4 ตัวแรก)
/// - พิมพ์แล้ว: ค้นใน client ก่อน, ไม่เจอจึงยิง API (`GET /products?search=`)
/// - รองรับ add/remove favorite จากผลลัพธ์
class BrownyShopSearchPage extends StatelessWidget {
  const BrownyShopSearchPage({super.key});

  static final pagePath = '/browny_shop_search';
  static final pageName = 'BrownyShopSearch';

  static Future<T?> goToPage<T>(BuildContext context) async {
    return await context.pushNamed(BrownyShopSearchPage.pageName);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BrownyShopSearchViewModel(
        context: context,
        repo: BrownyShopRepo(),
      ),
      child: const _BrownyShopSearchWidget(),
    );
  }
}

class _BrownyShopSearchWidget extends StatefulWidget {
  const _BrownyShopSearchWidget();

  @override
  State<_BrownyShopSearchWidget> createState() =>
      _BrownyShopSearchWidgetState();
}

class _BrownyShopSearchWidgetState extends State<_BrownyShopSearchWidget> {
  final TextEditingController _controller = TextEditingController();

  BrownyShopSearchViewModel get _vm =>
      context.read<BrownyShopSearchViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm.attachContext(context);
      _vm.init();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// เลือก suggestion → เติมคำค้น + ค้นหา
  void _onSuggestionTap(String name) {
    _controller.value = TextEditingValue(
      text: name,
      selection: TextSelection.collapsed(offset: name.length),
    );
    _vm.onQueryChanged(name);
  }

  void _onProductTap(ProductData product) {
    if (product.id != null) {
      BrownyShopProductDetailPage.goToPage(context, productId: product.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          AppDims.size_56.h + MediaQuery.of(context).padding.top,
        ),
        child: _buildAppBar(context),
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: _vm.queryNotifier,
        builder: (context, query, _) {
          // ว่าง = โหมด suggestions, มีคำค้น = ผลลัพธ์
          if (query.trim().isEmpty) {
            return _buildSuggestions(context);
          }
          return _buildResults(context);
        },
      ),
    );
  }

  /// AppBar — gradient bg + back + ช่องค้นหา (ตัดปุ่ม action ออกทั้งหมด)
  Widget _buildAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fill,
          image: Assets.png.bgAppBar.provider(),
        ),
      ),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDims.size_16.w),
        child: SizedBox(
          height: AppDims.size_56.h,
          child: Row(
            children: [
              BackButton(color: AppColors.white),
              Expanded(child: _buildSearchField(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      height: AppDims.size_40.h,
      padding: EdgeInsets.symmetric(horizontal: AppDims.size_16.w),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        border: Border.all(color: AppColors.productStroke),
        borderRadius: BorderRadius.circular(AppDims.size_8.r),
      ),
      child: Row(
        children: [
          Assets.svg.icMagnify.svg(
            width: AppDims.size_16.w,
            colorFilter: ColorFilter.mode(
              AppColors.gray500,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: AppDims.size_8.w),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _vm.onQueryChanged,
              style: context.textTheme.titleMedium,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: context.wording.searchProductPlaceholder,
                hintStyle: context.textTheme.titleMedium?.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            ),
          ),
          // ปุ่มล้างคำค้น (โผล่เมื่อมีข้อความ)
          ValueListenableBuilder<String>(
            valueListenable: _vm.queryNotifier,
            builder: (context, query, _) {
              if (query.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () {
                  _controller.clear();
                  _vm.onQueryChanged('');
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.only(left: AppDims.size_8.w),
                  child: Icon(
                    Icons.close,
                    size: AppDims.size_16.w,
                    color: AppColors.gray500,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// suggestions ก่อน user เริ่มพิมพ์ — ชื่อสินค้า 4 ตัวแรก
  Widget _buildSuggestions(BuildContext context) {
    final locale = context.languageCode;
    return ValueListenableBuilder<List<ProductData>>(
      valueListenable: _vm.suggestionsNotifier,
      builder: (context, suggestions, _) {
        if (suggestions.isEmpty) return const SizedBox.shrink();
        return ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: AppDims.size_16.w,
            vertical: AppDims.size_8.h,
          ),
          itemCount: suggestions.length,
          separatorBuilder: (_, _) =>
              Divider(height: 1, color: AppColors.productStroke),
          itemBuilder: (context, index) {
            final name = suggestions[index].getNameDisplay(locale);
            return GestureDetector(
              onTap: () => _onSuggestionTap(name),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppDims.size_12.h),
                child: AppText(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: AppColors.darkBrown,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// ผลการค้นหา — grid (reuse [ProductItemWidget])
  Widget _buildResults(BuildContext context) {
    final locale = context.languageCode;
    return ValueListenableBuilder<UiResult<List<ProductData>>>(
      valueListenable: _vm.resultsNotifier,
      builder: (context, result, _) {
        if (result.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (result.hasError) {
          return Center(child: AppText(context.wording.errorUi));
        }
        final products = result.data ?? const <ProductData>[];
        if (result.isEmpty || products.isEmpty) {
          return Center(child: AppText(context.wording.dataNotFound));
        }
        return GridView.builder(
          padding: EdgeInsets.all(AppDims.size_16.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppDims.size_16.w,
            mainAxisSpacing: AppDims.size_16.h,
            childAspectRatio: 0.62,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final p = products[index];
            final firstSub = (p.productSubs?.isNotEmpty ?? false)
                ? p.productSubs!.first
                : null;
            return Consumer<BrownyShopFavoriteStore>(
              builder: (context, favStore, _) => ProductItemWidget(
                imageUrl: p.mainImageUrl ?? firstSub?.imageUrl,
                name: p.getNameDisplay(locale),
                coinPrice: firstSub?.coinPrice?.toString(),
                moneyPrice: firstSub?.moneyPrice?.toString(),
                isFreeShipping: p.isFreeShipping ?? false,
                isFavorite: favStore.resolve(p.id, p.favoriteStatus ?? false),
                onTap: () => _onProductTap(p),
                onFavoriteTap: () => _vm.toggleProductFavorite(p),
              ),
            );
          },
        );
      },
    );
  }
}
