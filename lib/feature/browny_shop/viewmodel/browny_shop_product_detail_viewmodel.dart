import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/cart_item_add_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/products_response.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';
import 'package:browny_applications_new/feature/transactions/models/customer_coupon_model.dart';
import 'package:flutter/foundation.dart';

/// 1 รายการ thumbnail — ต้องเก็บคู่ (id, imageUrl) เพราะ
/// product_subs หลายรายการอาจ share รูปเดียวกัน → ถ้า select ด้วย url
/// อย่างเดียวจะทำให้ thumbnail ติดสองอันพร้อมกัน
class ProductImageThumb {
  const ProductImageThumb({this.subId, required this.imageUrl});

  /// id ของ product_sub — null = mainImageUrl (รูปหลักของสินค้า)
  final int? subId;
  final String imageUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductImageThumb &&
          subId == other.subId &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => Object.hash(subId, imageUrl);
}

/// ViewModel ของหน้า BrownyShopProductDetailPage
///
/// รับผิดชอบ:
/// - fetch รายละเอียดสินค้าจาก API
/// - เก็บ thumbnail ที่ user เลือก ([ProductImageThumb])
class BrownyShopProductDetailViewmodel extends AppViewModel {
  BrownyShopProductDetailViewmodel({
    required super.context,
    required BrownyShopDataSourceMixin repo,
    required this.productId,
  }) : _repo = repo;

  final BrownyShopDataSourceMixin _repo;
  final String productId;

  @override
  void dispose() {
    _productNotifier.dispose();
    _selectedThumbnailNotifier.dispose();
    _selectedCouponNotifier.dispose();
    super.dispose();
  }

  final ValueNotifier<UiResult<ProductData>> _productNotifier =
      ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<ProductData>> get productNotifier =>
      _productNotifier;

  /// Thumbnail ที่ user เลือกอยู่ (เริ่มต้น = main image)
  final ValueNotifier<ProductImageThumb?> _selectedThumbnailNotifier =
      ValueNotifier(null);
  ValueListenable<ProductImageThumb?> get selectedThumbnailNotifier =>
      _selectedThumbnailNotifier;

  void onThumbnailSelected(ProductImageThumb thumb) {
    _selectedThumbnailNotifier.value = thumb;
  }

  // ========== คูปอง Browny Shop ที่เลือกใช้กับสินค้านี้ ==========

  /// คูปองที่ user เลือกมาใช้ (null = ยังไม่เลือก) — carry ไปหน้า checkout เมื่อ
  /// กด "ซื้อเลย"
  final ValueNotifier<CustomerCouponModel?> _selectedCouponNotifier =
      ValueNotifier(null);
  ValueListenable<CustomerCouponModel?> get selectedCouponNotifier =>
      _selectedCouponNotifier;

  /// ตั้ง/ล้างคูปองที่เลือก — เรียกหลังกลับจาก [CouponVoucherPage]
  void setSelectedCoupon(CustomerCouponModel? coupon) {
    _selectedCouponNotifier.value = coupon;
  }

  /// sub แรกของสินค้าปัจจุบัน (ใช้เป็น basis ตรวจเงื่อนไขคูปอง)
  ProductSubData? get _firstSub {
    final subs = _productNotifier.value.data?.productSubs;
    return (subs != null && subs.isNotEmpty) ? subs.first : null;
  }

  /// ยอดที่ใช้ตรวจ min_order_amount บนหน้า detail = ราคาต่อชิ้น × 1
  num get couponOrderAmount => _firstSub?.moneyPriceValue ?? 0;
  bool get couponHasFlashSale => _firstSub?.isFlashSale ?? false;
  bool get couponHasProductDiscount => _firstSub?.hasMoneyDiscount ?? false;

  /// error message ถ้าคูปองที่เลือกใช้กับสินค้านี้ไม่ได้ (null = ใช้ได้)
  String? validSelectedCouponMessage(BuildContext context) {
    return _selectedCouponNotifier.value?.validBrownyShopCouponMessage(
      context,
      orderAmount: couponOrderAmount,
      hasFlashSale: couponHasFlashSale,
      hasProductDiscount: couponHasProductDiscount,
    );
  }

  /// สร้าง list ของ thumbnail — main image (subId=null) นำหน้า ตามด้วย product_subs
  List<ProductImageThumb> buildThumbnails(ProductData product) {
    final result = <ProductImageThumb>[];
    if ((product.mainImageUrl ?? '').isNotEmpty) {
      result.add(ProductImageThumb(imageUrl: product.mainImageUrl!));
    }
    for (final sub in product.productSubs ?? <ProductSubData>[]) {
      final url = sub.imageUrl;
      if (url == null || url.isEmpty) continue;
      result.add(ProductImageThumb(subId: sub.id, imageUrl: url));
    }
    return result;
  }

  Future<void> fetchProductDetail() async {
    _productNotifier.value = UiResult.loading();

    final customerId = currentCustomerProvider.current.id.orEmpty;
    final result = await _repo.fetchProductDetail(
      productId: productId,
      customerId: customerId,
    );

    if (result.hasError) {
      _productNotifier.value = UiResult.error(error: result.error);
      return;
    }
    if (result.isEmpty) {
      _productNotifier.value = UiResult.empty();
      return;
    }
    final product = result.data.product;
    if (product == null) {
      _productNotifier.value = UiResult.empty();
      return;
    }
    // auto-select main image
    if ((product.mainImageUrl ?? '').isNotEmpty) {
      _selectedThumbnailNotifier.value = ProductImageThumb(
        imageUrl: product.mainImageUrl!,
      );
    }
    _productNotifier.value = UiResult.success(data: product);
  }

  /// เพิ่มสินค้าลงตะกร้าออนไลน์ (ระบุ subId + จำนวน)
  ///
  /// คืน [UiResult] ให้ฝั่ง View แสดง toast/dialog ตามผลลัพธ์
  Future<UiResult<CartItemData>> addToCart({
    required int subId,
    required int quantity,
  }) async {
    final customerId = currentCustomerProvider.current.id.orEmpty;
    final result = await _repo.addCartItem(
      customerId: customerId,
      productId: productId,
      subId: subId,
      quantity: quantity,
    );

    if (result.hasError) {
      return UiResult.error(error: result.error);
    }
    if (result.isEmpty) {
      return UiResult.empty();
    }
    return UiResult.success(data: result.data);
  }
}
