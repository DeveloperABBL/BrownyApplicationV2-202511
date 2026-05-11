import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/core/data/remote/models/response/products_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'flash_sales_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-11
///
/// Response model สำหรับ API GET /flash-sales (Browny Shop — Flash Deals)
@JsonSerializable()
class FlashSalesResponse {
  FlashSalesResponse({this.flashSales});

  @JsonKey(name: 'flash_sales')
  final List<FlashSaleData>? flashSales;

  factory FlashSalesResponse.fromJson(Map<String, dynamic> json) =>
      _$FlashSalesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FlashSalesResponseToJson(this);
}

/// 1 รายการ Flash Sale (campaign) ที่ active อยู่
@JsonSerializable()
class FlashSaleData {
  FlashSaleData({
    this.id,
    this.name,
    this.startAt,
    this.endAt,
    this.status,
    this.products,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'start_at')
  final String? startAt;

  @JsonKey(name: 'end_at')
  final String? endAt;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'products')
  final List<FlashSaleProductData>? products;

  /// เช็คว่า flash sale active อยู่หรือไม่
  bool get isActive => status?.toLowerCase() == 'active';

  factory FlashSaleData.fromJson(Map<String, dynamic> json) =>
      _$FlashSaleDataFromJson(json);

  Map<String, dynamic> toJson() => _$FlashSaleDataToJson(this);
}

/// ข้อมูล flash sale ที่แนบมากับ product / product_sub
/// (อ้างอิงถึง campaign + ราคาพิเศษเฉพาะของชิ้นนั้น)
@JsonSerializable()
class FlashSaleInfoData {
  FlashSaleInfoData({
    this.id,
    this.name,
    this.startAt,
    this.endAt,
    this.specialMoneyPrice,
    this.specialCoinPrice,
    this.scope,
    this.coinValue,
    this.coinPriceSource,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'start_at')
  final String? startAt;

  @JsonKey(name: 'end_at')
  final String? endAt;

  @JsonKey(name: 'special_money_price')
  final num? specialMoneyPrice;

  @JsonKey(name: 'special_coin_price')
  final num? specialCoinPrice;

  /// scope ของ flash sale (เช่น "product", "category")
  @JsonKey(name: 'scope')
  final String? scope;

  @JsonKey(name: 'coin_value')
  final num? coinValue;

  /// แหล่งที่มาของ coin price (เช่น "calculated")
  @JsonKey(name: 'coin_price_source')
  final String? coinPriceSource;

  factory FlashSaleInfoData.fromJson(Map<String, dynamic> json) =>
      _$FlashSaleInfoDataFromJson(json);

  Map<String, dynamic> toJson() => _$FlashSaleInfoDataToJson(this);
}

/// สินค้าใน flash sale — โครงสร้างคล้าย [ProductData] แต่เพิ่ม field
/// `is_flash_sale`, `flash_sale` และ product_subs เป็น [FlashSaleProductSubData]
/// (ราคาเป็น number ไม่ใช่ string)
@JsonSerializable()
class FlashSaleProductData {
  FlashSaleProductData({
    this.id,
    this.isFreeShipping,
    this.isFlashSale,
    this.flashSale,
    this.unit,
    this.translations,
    this.mainImageUrl,
    this.productSubs,
  });

  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'is_free_shipping')
  final bool? isFreeShipping;

  @JsonKey(name: 'is_flash_sale')
  final bool? isFlashSale;

  @JsonKey(name: 'flash_sale')
  final FlashSaleInfoData? flashSale;

  @JsonKey(name: 'unit')
  final ContentLocalizeData? unit;

  @JsonKey(name: 'translations')
  final ProductTranslationsData? translations;

  @JsonKey(name: 'main_image_url')
  final String? mainImageUrl;

  @JsonKey(name: 'product_subs')
  final List<FlashSaleProductSubData>? productSubs;

  /// ดึงชื่อสินค้าตาม locale
  String getNameDisplay(String locale) {
    return translations?.getByLocale(locale)?.name ?? '';
  }

  /// ดึงคำอธิบายสินค้าตาม locale (HTML)
  String getDescriptionDisplay(String locale) {
    return translations?.getByLocale(locale)?.description ?? '';
  }

  /// ดึงหน่วยตาม locale
  String getUnitDisplay(String locale) {
    return unit?.getByLocaleCode(locale) ?? '';
  }

  /// เช็คว่ามี product_subs (ตัวเลือกย่อย) หรือไม่
  bool get hasSubs => (productSubs?.isNotEmpty ?? false);

  factory FlashSaleProductData.fromJson(Map<String, dynamic> json) =>
      _$FlashSaleProductDataFromJson(json);

  Map<String, dynamic> toJson() => _$FlashSaleProductDataToJson(this);
}

/// Sub product ของ flash sale — มี original price + discount percent
/// และ flash_sale info แยกเฉพาะรายการนั้น
@JsonSerializable()
class FlashSaleProductSubData {
  FlashSaleProductSubData({
    this.id,
    this.listOrder,
    this.name,
    this.originalCoinPrice,
    this.originalMoneyPrice,
    this.coinPrice,
    this.moneyPrice,
    this.coinDiscountPercent,
    this.moneyDiscountPercent,
    this.isFlashSale,
    this.flashSale,
    this.imageUrl,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'list_order')
  final int? listOrder;

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  @JsonKey(name: 'original_coin_price')
  final num? originalCoinPrice;

  @JsonKey(name: 'original_money_price')
  final num? originalMoneyPrice;

  @JsonKey(name: 'coin_price')
  final num? coinPrice;

  @JsonKey(name: 'money_price')
  final num? moneyPrice;

  @JsonKey(name: 'coin_discount_percent')
  final num? coinDiscountPercent;

  @JsonKey(name: 'money_discount_percent')
  final num? moneyDiscountPercent;

  @JsonKey(name: 'is_flash_sale')
  final bool? isFlashSale;

  @JsonKey(name: 'flash_sale')
  final FlashSaleInfoData? flashSale;

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  /// ดึงชื่อ sub product ตาม locale
  String getNameDisplay(String locale) {
    return name?.getByLocaleCode(locale) ?? '';
  }

  /// เช็คว่ามีส่วนลด money หรือไม่
  bool get hasMoneyDiscount =>
      (moneyDiscountPercent ?? 0) > 0 &&
      originalMoneyPrice != null &&
      moneyPrice != null &&
      moneyPrice! < originalMoneyPrice!;

  /// เช็คว่ามีส่วนลด coin หรือไม่
  bool get hasCoinDiscount =>
      (coinDiscountPercent ?? 0) > 0 &&
      originalCoinPrice != null &&
      coinPrice != null &&
      coinPrice! < originalCoinPrice!;

  factory FlashSaleProductSubData.fromJson(Map<String, dynamic> json) =>
      _$FlashSaleProductSubDataFromJson(json);

  Map<String, dynamic> toJson() => _$FlashSaleProductSubDataToJson(this);
}
