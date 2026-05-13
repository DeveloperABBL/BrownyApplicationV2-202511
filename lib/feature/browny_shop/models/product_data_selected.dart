import 'package:browny_applications_new/core/data/remote/models/response/products_response.dart';

/// Model สำหรับสินค้าที่ถูกเพิ่มเข้าตะกร้า
///
/// extends [ProductData] เพื่อ reuse field และ helper methods ของ product
/// เพิ่ม:
/// - [selectedSubId] — id ของ product_sub ที่ user เลือก
/// - [quantity]      — จำนวนที่หยิบใส่ตะกร้า
/// - [selected]      — ติ๊กเลือก ณ หน้าตะกร้า (สำหรับชำระเงิน)
class ProductDataSelected extends ProductData {
  ProductDataSelected({
    super.id,
    super.isFreeShipping,
    super.favoriteStatus,
    super.hasFlashSale,
    super.flashSaleStartsAt,
    super.flashSaleEndsAt,
    super.unit,
    super.translations,
    super.productSubs,
    super.mainImageUrl,
    required this.selectedSubId,
    this.quantity = 1,
    this.selected = true,
  });

  /// id ของ product_sub ที่ user เลือกตอนกดเพิ่มลงตะกร้า
  final int selectedSubId;

  /// จำนวนที่อยู่ในตะกร้า (mutable เพื่อให้ +/- ได้)
  int quantity;

  /// ติ๊กเลือกในตะกร้า (default true)
  bool selected;

  /// สร้างจาก [ProductData] เดิม
  factory ProductDataSelected.fromProduct(
    ProductData product, {
    required int selectedSubId,
    int quantity = 1,
    bool selected = true,
  }) {
    return ProductDataSelected(
      id: product.id,
      isFreeShipping: product.isFreeShipping,
      favoriteStatus: product.favoriteStatus,
      hasFlashSale: product.hasFlashSale,
      flashSaleStartsAt: product.flashSaleStartsAt,
      flashSaleEndsAt: product.flashSaleEndsAt,
      unit: product.unit,
      translations: product.translations,
      productSubs: product.productSubs,
      mainImageUrl: product.mainImageUrl,
      selectedSubId: selectedSubId,
      quantity: quantity,
      selected: selected,
    );
  }

  /// sub ที่ user เลือก (อาจ null ถ้าไม่พบใน productSubs)
  ProductSubData? get selectedSub {
    final subs = productSubs;
    if (subs == null || subs.isEmpty) return null;
    for (final s in subs) {
      if (s.id == selectedSubId) return s;
    }
    return null;
  }

  /// ราคาต่อหน่วย (money) — fallback 0
  num get unitMoneyPrice => selectedSub?.moneyPrice ?? 0;

  /// ราคาต่อหน่วย (coin) — fallback 0
  num get unitCoinPrice => selectedSub?.coinPrice ?? 0;

  /// ยอดรวมบรรทัด — money
  num get lineMoneyTotal => unitMoneyPrice * quantity;

  /// ยอดรวมบรรทัด — coin
  num get lineCoinTotal => unitCoinPrice * quantity;

  /// ส่วนลด money ต่อหน่วย (ราคาเดิม − ราคาขาย) คูณ quantity
  num get lineMoneyDiscount {
    final original = selectedSub?.originalMoneyPrice ?? 0;
    final sale = selectedSub?.moneyPrice ?? 0;
    if (original <= sale) return 0;
    return (original - sale) * quantity;
  }
}
