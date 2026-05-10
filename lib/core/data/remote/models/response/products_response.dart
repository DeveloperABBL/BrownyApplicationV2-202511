import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'products_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-09
///
/// Response model สำหรับ API GET /products (Browny Shop)
@JsonSerializable()
class ProductsResponse {
  ProductsResponse({this.product});

  @JsonKey(name: 'product')
  final List<ProductData>? product;

  factory ProductsResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProductsResponseToJson(this);
}

@JsonSerializable()
class ProductData {
  ProductData({
    this.id,
    this.isFreeShipping,
    this.favoriteStatus,
    this.unit,
    this.translations,
    this.productSubs,
    this.mainImageUrl,
  });

  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'is_free_shipping')
  final bool? isFreeShipping;

  @JsonKey(name: 'favorite_status')
  final bool? favoriteStatus;

  @JsonKey(name: 'unit')
  final ContentLocalizeData? unit;

  @JsonKey(name: 'translations')
  final ProductTranslationsData? translations;

  @JsonKey(name: 'product_subs')
  final List<ProductSubData>? productSubs;

  @JsonKey(name: 'main_image_url')
  final String? mainImageUrl;

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

  factory ProductData.fromJson(Map<String, dynamic> json) =>
      _$ProductDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProductDataToJson(this);
}

/// Container สำหรับ field `translations` ที่ key เป็น locale (th/en/zh)
/// แต่ละ locale มี struct `{name, description}`
@JsonSerializable()
class ProductTranslationsData {
  ProductTranslationsData({this.th, this.en, this.zh});

  @JsonKey(name: 'th')
  final ProductTranslationItem? th;

  @JsonKey(name: 'en')
  final ProductTranslationItem? en;

  @JsonKey(name: 'zh')
  final ProductTranslationItem? zh;

  /// ดึง translation item ตาม locale code (fallback เป็น th)
  ProductTranslationItem? getByLocale(String locale) {
    switch (locale) {
      case 'en':
        return en;
      case 'zh':
        return zh;
      case 'th':
      default:
        return th;
    }
  }

  factory ProductTranslationsData.fromJson(Map<String, dynamic> json) =>
      _$ProductTranslationsDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProductTranslationsDataToJson(this);
}

@JsonSerializable()
class ProductTranslationItem {
  ProductTranslationItem({this.name, this.description});

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'description')
  final String? description;

  factory ProductTranslationItem.fromJson(Map<String, dynamic> json) =>
      _$ProductTranslationItemFromJson(json);

  Map<String, dynamic> toJson() => _$ProductTranslationItemToJson(this);
}

@JsonSerializable()
class ProductSubData {
  ProductSubData({
    this.id,
    this.listOrder,
    this.name,
    this.coinPrice,
    this.moneyPrice,
    this.imageUrl,
    this.stock,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'list_order')
  final int? listOrder;

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  @JsonKey(name: 'coin_price')
  final String? coinPrice;

  @JsonKey(name: 'money_price')
  final String? moneyPrice;

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  /// จำนวน stock คงเหลือ (มีเฉพาะใน endpoint product detail)
  @JsonKey(name: 'stock')
  final String? stock;

  /// ดึงชื่อ sub product ตาม locale
  String getNameDisplay(String locale) {
    return name?.getByLocaleCode(locale) ?? '';
  }

  /// แปลง coin_price เป็น double (default 0)
  double get coinPriceValue => double.tryParse(coinPrice ?? '0') ?? 0;

  /// แปลง money_price เป็น double (default 0)
  double get moneyPriceValue => double.tryParse(moneyPrice ?? '0') ?? 0;

  /// แปลง stock เป็น double (default 0)
  double get stockValue => double.tryParse(stock ?? '0') ?? 0;

  factory ProductSubData.fromJson(Map<String, dynamic> json) =>
      _$ProductSubDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProductSubDataToJson(this);
}
