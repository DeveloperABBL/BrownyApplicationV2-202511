// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flash_sales_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlashSalesResponse _$FlashSalesResponseFromJson(Map<String, dynamic> json) =>
    FlashSalesResponse(
      flashSales: (json['flash_sales'] as List<dynamic>?)
          ?.map((e) => FlashSaleData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FlashSalesResponseToJson(FlashSalesResponse instance) =>
    <String, dynamic>{'flash_sales': instance.flashSales};

FlashSaleData _$FlashSaleDataFromJson(Map<String, dynamic> json) =>
    FlashSaleData(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      startAt: json['start_at'] as String?,
      endAt: json['end_at'] as String?,
      status: json['status'] as String?,
      products: (json['products'] as List<dynamic>?)
          ?.map((e) => FlashSaleProductData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FlashSaleDataToJson(FlashSaleData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'start_at': instance.startAt,
      'end_at': instance.endAt,
      'status': instance.status,
      'products': instance.products,
    };

FlashSaleInfoData _$FlashSaleInfoDataFromJson(Map<String, dynamic> json) =>
    FlashSaleInfoData(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      startAt: json['start_at'] as String?,
      endAt: json['end_at'] as String?,
      specialMoneyPrice: json['special_money_price'] as num?,
      specialCoinPrice: json['special_coin_price'] as num?,
      scope: json['scope'] as String?,
      coinValue: json['coin_value'] as num?,
      coinPriceSource: json['coin_price_source'] as String?,
    );

Map<String, dynamic> _$FlashSaleInfoDataToJson(FlashSaleInfoData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'start_at': instance.startAt,
      'end_at': instance.endAt,
      'special_money_price': instance.specialMoneyPrice,
      'special_coin_price': instance.specialCoinPrice,
      'scope': instance.scope,
      'coin_value': instance.coinValue,
      'coin_price_source': instance.coinPriceSource,
    };

FlashSaleProductData _$FlashSaleProductDataFromJson(
  Map<String, dynamic> json,
) => FlashSaleProductData(
  id: json['id'] as String?,
  isFreeShipping: json['is_free_shipping'] as bool?,
  isFlashSale: json['is_flash_sale'] as bool?,
  flashSale: json['flash_sale'] == null
      ? null
      : FlashSaleInfoData.fromJson(json['flash_sale'] as Map<String, dynamic>),
  unit: json['unit'] == null
      ? null
      : ContentLocalizeData.fromJson(json['unit'] as Map<String, dynamic>),
  translations: json['translations'] == null
      ? null
      : ProductTranslationsData.fromJson(
          json['translations'] as Map<String, dynamic>,
        ),
  mainImageUrl: json['main_image_url'] as String?,
  productSubs: (json['product_subs'] as List<dynamic>?)
      ?.map((e) => FlashSaleProductSubData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FlashSaleProductDataToJson(
  FlashSaleProductData instance,
) => <String, dynamic>{
  'id': instance.id,
  'is_free_shipping': instance.isFreeShipping,
  'is_flash_sale': instance.isFlashSale,
  'flash_sale': instance.flashSale,
  'unit': instance.unit,
  'translations': instance.translations,
  'main_image_url': instance.mainImageUrl,
  'product_subs': instance.productSubs,
};

FlashSaleProductSubData _$FlashSaleProductSubDataFromJson(
  Map<String, dynamic> json,
) => FlashSaleProductSubData(
  id: (json['id'] as num?)?.toInt(),
  listOrder: (json['list_order'] as num?)?.toInt(),
  name: json['name'] == null
      ? null
      : ContentLocalizeData.fromJson(json['name'] as Map<String, dynamic>),
  originalCoinPrice: json['original_coin_price'] as num?,
  originalMoneyPrice: json['original_money_price'] as num?,
  coinPrice: json['coin_price'] as num?,
  moneyPrice: json['money_price'] as num?,
  coinDiscountPercent: json['coin_discount_percent'] as num?,
  moneyDiscountPercent: json['money_discount_percent'] as num?,
  isFlashSale: json['is_flash_sale'] as bool?,
  flashSale: json['flash_sale'] == null
      ? null
      : FlashSaleInfoData.fromJson(json['flash_sale'] as Map<String, dynamic>),
  imageUrl: json['image_url'] as String?,
);

Map<String, dynamic> _$FlashSaleProductSubDataToJson(
  FlashSaleProductSubData instance,
) => <String, dynamic>{
  'id': instance.id,
  'list_order': instance.listOrder,
  'name': instance.name,
  'original_coin_price': instance.originalCoinPrice,
  'original_money_price': instance.originalMoneyPrice,
  'coin_price': instance.coinPrice,
  'money_price': instance.moneyPrice,
  'coin_discount_percent': instance.coinDiscountPercent,
  'money_discount_percent': instance.moneyDiscountPercent,
  'is_flash_sale': instance.isFlashSale,
  'flash_sale': instance.flashSale,
  'image_url': instance.imageUrl,
};
