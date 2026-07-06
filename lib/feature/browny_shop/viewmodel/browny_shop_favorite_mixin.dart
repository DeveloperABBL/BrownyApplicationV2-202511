import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/products_response.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/browny_shop/providers/browny_shop_favorite_store.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';

/// Mixin เพิ่มความสามารถ toggle "สินค้าโปรด" ให้ VM ที่ render grid สินค้า
/// Browny Shop (Home / Coin / BrownyShopPage)
///
/// VM ที่ใช้ต้อง override:
/// - [favoriteRepo] — repo ที่มี [BrownyShopDataSourceMixin.setFavorite]
/// - [favoriteProductsNotifier] — ValueNotifier ที่ถือ `List<ProductData>` ที่แสดงอยู่
mixin BrownyShopFavoriteMixin on AppViewModel {
  @protected
  BrownyShopDataSourceMixin get favoriteRepo;

  @protected
  ValueNotifier<UiResult<List<ProductData>>> get favoriteProductsNotifier;

  /// toggle fav/unfav สินค้า 1 ชิ้น — optimistic update ทันที แล้ว revert ถ้า API fail
  Future<void> toggleProductFavorite(ProductData product) async {
    final id = product.id;
    if (id == null) return;

    final current = product.favoriteStatus ?? false;
    final next = !current;

    // อัปเดต UI ทันที (optimistic)
    _applyFavorite(id, next);

    final result = await favoriteRepo.setFavorite(
      customerId: currentCustomerProvider.current.id.orEmpty,
      productId: id,
      favorite: next,
    );

    if (!result.isSuccess) {
      // ล้มเหลว → คืนค่าเดิม
      _applyFavorite(id, current);
      return;
    }
    // sync กับสถานะจริงจาก server (เผื่อไม่ตรงกับที่ optimistic ไว้)
    if (result.data != next) _applyFavorite(id, result.data);
  }

  /// แทนที่ favoriteStatus ของสินค้า [productId] แล้วยิง notifier ด้วย list ใหม่
  /// (ต้องเป็น instance ใหม่ ValueNotifier จึงจะ notify)
  ///
  /// เขียนลง [BrownyShopFavoriteStore] ด้วย เพื่อ sync ไปหน้าอื่น (รายละเอียด
  /// สินค้า / Home / Coin / Search / Favorites) แบบ real-time
  void _applyFavorite(String productId, bool favorite) {
    context.read<BrownyShopFavoriteStore>().setFavorite(productId, favorite);
    final list = favoriteProductsNotifier.value.data;
    if (list == null) return;
    favoriteProductsNotifier.value = UiResult.success(
      data: [
        for (final p in list)
          p.id == productId ? p.copyWith(favoriteStatus: favorite) : p,
      ],
    );
  }
}
