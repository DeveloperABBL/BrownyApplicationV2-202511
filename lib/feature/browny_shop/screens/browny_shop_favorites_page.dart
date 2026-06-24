import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';
import 'package:browny_applications_new/feature/browny_shop/screens/browny_shop_product_detail_page.dart';
import 'package:browny_applications_new/feature/browny_shop/viewmodel/browny_shop_favorites_viewmodel.dart';
import 'package:browny_applications_new/feature/browny_shop/widgets/browny_shop_categories_grid_section.dart';

/// หน้าแสดงรายการสินค้าโปรด (สินค้าที่บันทึกไว้) ของลูกค้า
///
/// Figma: node 272:1462
/// - ดึงข้อมูลจาก [BrownyShopFavoritesViewmodel.fetchFavorites]
/// - แสดงด้วย [BrownyShopCategoriesGridSection] (ปิดส่วนหมวดหมู่ + chips)
/// - แตะสินค้าเพื่อเปิด [BrownyShopProductDetailPage]
class BrownyShopFavoritesPage extends StatelessWidget {
  const BrownyShopFavoritesPage({super.key});

  static final pagePath = '/browny_shop_favorites';
  static final pageName = 'BrownyShopFavoritesPage';

  static Future<T?> goToPage<T>(BuildContext context) async {
    return await context.pushNamed(BrownyShopFavoritesPage.pageName);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BrownyShopFavoritesViewmodel(
        context: context,
        repo: BrownyShopRepo(),
      ),
      child: const _BrownyShopFavoritesWidget(),
    );
  }
}

class _BrownyShopFavoritesWidget extends StatefulWidget {
  const _BrownyShopFavoritesWidget();

  @override
  State<_BrownyShopFavoritesWidget> createState() =>
      _BrownyShopFavoritesWidgetState();
}

class _BrownyShopFavoritesWidgetState
    extends State<_BrownyShopFavoritesWidget> {
  BrownyShopFavoritesViewmodel get _vm =>
      context.read<BrownyShopFavoritesViewmodel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm.attachContext(context);
      _vm.fetchFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: FlexibleSpaceBar(
          background: Assets.png.bgAppBar.image(
            fit: BoxFit.cover,
          ),
        ),
        title: AppText(
          // สินค้าที่บันทึกไว้
          context.wording.savedItems,
          textAlign: TextAlign.center,
          style: context.textTheme.titleLarge?.copyWith(
            color: AppColors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // grid สินค้าโปรด — ปิดส่วน "หมวดหมู่ + chips"
            BrownyShopCategoriesGridSection(
              showCategoryHeader: false,
              topBoxDecoration: const BoxDecoration(),
              productsListenable: _vm.favoritesNotifier,
              onProductTap: (p) {
                if (p.id != null) {
                  BrownyShopProductDetailPage.goToPage(
                    context,
                    productId: p.id!,
                  );
                }
              },
              onProductFavoriteTap: _vm.toggleProductFavorite,
            ),
            AppDims.vericalPadding_24,
          ],
        ),
      ),
    );
  }
}
