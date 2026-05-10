// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductsResponse _$ProductsResponseFromJson(Map<String, dynamic> json) =>
    ProductsResponse(
      product: (json['product'] as List<dynamic>?)
          ?.map((e) => ProductData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProductsResponseToJson(ProductsResponse instance) =>
    <String, dynamic>{'product': instance.product};

ProductData _$ProductDataFromJson(Map<String, dynamic> json) => ProductData(
  id: json['id'] as String?,
  isFreeShipping: json['is_free_shipping'] as bool?,
  favoriteStatus: json['favorite_status'] as bool?,
  unit: json['unit'] == null
      ? null
      : ContentLocalizeData.fromJson(json['unit'] as Map<String, dynamic>),
  translations: json['translations'] == null
      ? null
      : ProductTranslationsData.fromJson(
          json['translations'] as Map<String, dynamic>,
        ),
  productSubs: (json['product_subs'] as List<dynamic>?)
      ?.map((e) => ProductSubData.fromJson(e as Map<String, dynamic>))
      .toList(),
  mainImageUrl: json['main_image_url'] as String?,
);

Map<String, dynamic> _$ProductDataToJson(ProductData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'is_free_shipping': instance.isFreeShipping,
      'favorite_status': instance.favoriteStatus,
      'unit': instance.unit,
      'translations': instance.translations,
      'product_subs': instance.productSubs,
      'main_image_url': instance.mainImageUrl,
    };

ProductTranslationsData _$ProductTranslationsDataFromJson(
  Map<String, dynamic> json,
) => ProductTranslationsData(
  th: json['th'] == null
      ? null
      : ProductTranslationItem.fromJson(json['th'] as Map<String, dynamic>),
  en: json['en'] == null
      ? null
      : ProductTranslationItem.fromJson(json['en'] as Map<String, dynamic>),
  zh: json['zh'] == null
      ? null
      : ProductTranslationItem.fromJson(json['zh'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProductTranslationsDataToJson(
  ProductTranslationsData instance,
) => <String, dynamic>{'th': instance.th, 'en': instance.en, 'zh': instance.zh};

ProductTranslationItem _$ProductTranslationItemFromJson(
  Map<String, dynamic> json,
) => ProductTranslationItem(
  name: json['name'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$ProductTranslationItemToJson(
  ProductTranslationItem instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
};

ProductSubData _$ProductSubDataFromJson(Map<String, dynamic> json) =>
    ProductSubData(
      id: (json['id'] as num?)?.toInt(),
      listOrder: (json['list_order'] as num?)?.toInt(),
      name: json['name'] == null
          ? null
          : ContentLocalizeData.fromJson(json['name'] as Map<String, dynamic>),
      coinPrice: json['coin_price'] as String?,
      moneyPrice: json['money_price'] as String?,
      imageUrl: json['image_url'] as String?,
      stock: json['stock'] as String?,
    );

Map<String, dynamic> _$ProductSubDataToJson(ProductSubData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'list_order': instance.listOrder,
      'name': instance.name,
      'coin_price': instance.coinPrice,
      'money_price': instance.moneyPrice,
      'image_url': instance.imageUrl,
      'stock': instance.stock,
    };
