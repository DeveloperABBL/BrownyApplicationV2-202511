import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/request/cart_summary_request.dart';
import 'package:browny_applications_new/core/data/remote/models/response/address_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/cart_item_add_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/checkout_draft_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/products_response.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/browny_shop/providers/browny_shop_favorite_store.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/address_repo.dart';
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

  final AddressRepo _addressRepo = AddressRepo();

  @override
  void dispose() {
    _productNotifier.dispose();
    _selectedThumbnailNotifier.dispose();
    _selectedSubIdNotifier.dispose();
    _selectedCouponNotifier.dispose();
    _shippingAddressNotifier.dispose();
    _summaryNotifier.dispose();
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

  /// subId ของ "ตัวเลือกสินค้า" (variant) ที่เลือกใน [_ProductSubsSection]
  ///
  /// แยกออกจาก [selectedThumbnailNotifier] โดยตั้งใจ — กดตัวเลือกแล้ว "รูปหลัก
  /// ต้องไม่เลื่อน" (รูปหลัก/thumbnail strip ขับด้วย selectedThumbnailNotifier
  /// เท่านั้น). ใช้เป็นค่าเริ่มต้น subId ของ add-to-cart bottom sheet ด้วย
  final ValueNotifier<int?> _selectedSubIdNotifier = ValueNotifier(null);
  ValueListenable<int?> get selectedSubIdNotifier => _selectedSubIdNotifier;

  void onSubOptionSelected(int? subId) {
    _selectedSubIdNotifier.value = subId;
  }

  // ========== คูปอง Browny Shop ที่เลือกใช้กับสินค้านี้ ==========

  /// คูปองที่ user เลือกมาใช้ (null = ยังไม่เลือก) — carry ไปหน้า checkout เมื่อ
  /// กด "ซื้อเลย"
  final ValueNotifier<CustomerCouponModel?> _selectedCouponNotifier =
      ValueNotifier(null);
  ValueListenable<CustomerCouponModel?> get selectedCouponNotifier =>
      _selectedCouponNotifier;

  /// ตั้ง/ล้างคูปองที่เลือก — เรียกหลังกลับจาก [CouponVoucherPage]
  /// แล้ว re-fetch summary เพื่ออัปเดตค่าจัดส่ง/ส่วนลด
  void setSelectedCoupon(CustomerCouponModel? coupon) {
    _selectedCouponNotifier.value = coupon;
    fetchSummary();
  }

  // ========== ที่อยู่จัดส่ง + summary (ค่าจัดส่งโดยประมาณ) ==========

  /// ที่อยู่จัดส่งที่เลือก (เริ่มต้น = ที่อยู่หลักของลูกค้า)
  final ValueNotifier<AddressData?> _shippingAddressNotifier =
      ValueNotifier(null);
  ValueListenable<AddressData?> get shippingAddressNotifier =>
      _shippingAddressNotifier;

  /// summary จาก POST /browny-shop/cart/summary — แหล่งของ shipping_total
  final ValueNotifier<UiResult<CheckoutSummaryData>> _summaryNotifier =
      ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<CheckoutSummaryData>> get summaryNotifier =>
      _summaryNotifier;

  /// ตั้งที่อยู่จัดส่ง — เรียกหลังเลือกจาก [CustomerShipToPage] แล้ว re-fetch summary
  void setShippingAddress(AddressData? address) {
    _shippingAddressNotifier.value = address;
    fetchSummary();
  }

  /// โหลดที่อยู่หลักมาเป็นค่าเริ่มต้น (ข้ามถ้าเลือกไว้แล้ว)
  Future<void> loadDefaultShippingAddress() async {
    if (_shippingAddressNotifier.value != null) return;
    final result = await _addressRepo.fetchAddresses(
      customerId: currentCustomerProvider.current.id.orEmpty,
    );
    if (!result.isSuccess) return;
    final list = result.data;
    if (list.isEmpty) return;
    final defaults = list.where((a) => a.isDefaultAddress);
    _shippingAddressNotifier.value = defaults.isNotEmpty
        ? defaults.first
        : list.first;
  }

  /// POST /browny-shop/cart/summary — คำนวณค่าจัดส่งโดยประมาณของสินค้านี้
  /// (sub แรก จำนวน 1) แนบคูปอง + ที่อยู่จัดส่งที่เลือก
  Future<void> fetchSummary() async {
    final subId = _firstSub?.id;
    if (subId == null) {
      _summaryNotifier.value = UiResult.empty();
      return;
    }
    _summaryNotifier.value = UiResult.loading();
    final result = await _repo.fetchCartSummary(
      customerId: currentCustomerProvider.current.id.orEmpty,
      items: [CartSummaryItemRequest(productSubId: subId, quantity: 1)],
      couponCustomerId: _selectedCouponNotifier.value?.customerCouponId,
      customerAddressId: _shippingAddressNotifier.value?.id,
    );
    if (result.isSuccess) {
      _summaryNotifier.value = UiResult.success(data: result.data);
    } else if (result.isEmpty) {
      _summaryNotifier.value = UiResult.empty();
    } else {
      _summaryNotifier.value = UiResult.error(error: result.error);
    }
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
    // ค่าเริ่มต้นตัวเลือกสินค้า = sub แรก (สำหรับ default ของ add-to-cart)
    final subs = product.productSubs;
    _selectedSubIdNotifier.value = (subs != null && subs.isNotEmpty)
        ? subs.first.id
        : null;
    _productNotifier.value = UiResult.success(data: product);

    // หลังได้สินค้าแล้ว → โหลดที่อยู่หลัก แล้วประเมินค่าจัดส่ง (cart/summary)
    await loadDefaultShippingAddress();
    fetchSummary();
  }

  /// toggle "สินค้าโปรด" ของสินค้าที่กำลังดูอยู่ — optimistic update + revert ถ้า fail
  Future<void> toggleFavorite() async {
    final product = _productNotifier.value.data;
    final id = product?.id;
    if (product == null || id == null) return;

    final current = product.favoriteStatus ?? false;
    final next = !current;

    // อัปเดต UI ทันที (optimistic) + เขียน store กลางเพื่อ sync ไปหน้า list
    _productNotifier.value = UiResult.success(
      data: product.copyWith(favoriteStatus: next),
    );
    _favoriteStore.setFavorite(id, next);

    final result = await _repo.setFavorite(
      customerId: currentCustomerProvider.current.id.orEmpty,
      productId: id,
      favorite: next,
    );

    final latest = _productNotifier.value.data;
    if (latest == null || latest.id != id) return;
    if (!result.isSuccess) {
      // ล้มเหลว → คืนค่าเดิม
      _productNotifier.value = UiResult.success(
        data: latest.copyWith(favoriteStatus: current),
      );
      _favoriteStore.setFavorite(id, current);
      return;
    }
    // sync กับสถานะจริงจาก server
    if (result.data != next) {
      _productNotifier.value = UiResult.success(
        data: latest.copyWith(favoriteStatus: result.data),
      );
      _favoriteStore.setFavorite(id, result.data);
    }
  }

  /// store กลางสถานะสินค้าโปรด (sync ข้ามหน้า)
  BrownyShopFavoriteStore get _favoriteStore =>
      context.read<BrownyShopFavoriteStore>();

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
