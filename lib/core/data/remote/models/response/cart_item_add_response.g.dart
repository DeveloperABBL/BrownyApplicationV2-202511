// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_add_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItemAddResponse _$CartItemAddResponseFromJson(Map<String, dynamic> json) =>
    CartItemAddResponse(
      data: json['data'] == null
          ? null
          : CartItemData.fromJson(json['data'] as Map<String, dynamic>),
      success: json['success'] as bool?,
      message: json['message'] as String?,
      errorType: json['error_type'] as String?,
    );

Map<String, dynamic> _$CartItemAddResponseToJson(
  CartItemAddResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'data': instance.data,
};

CartItemData _$CartItemDataFromJson(Map<String, dynamic> json) => CartItemData(
  id: (json['id'] as num?)?.toInt(),
  customerId: json['customer_id'] as String?,
  productId: json['product_id'] as String?,
  productSubId: (json['product_sub_id'] as num?)?.toInt(),
  quantity: (json['quantity'] as num?)?.toInt(),
  unitCoinPrice: json['unit_coin_price'] as num?,
  unitMoneyPrice: json['unit_money_price'] as num?,
  isFlashSale: json['is_flash_sale'] as bool?,
  flashSaleId: (json['flash_sale_id'] as num?)?.toInt(),
  lineCoinTotal: json['line_coin_total'] as num?,
  lineMoneyTotal: json['line_money_total'] as num?,
  priceChanged: json['price_changed'] as bool?,
);

Map<String, dynamic> _$CartItemDataToJson(CartItemData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'product_id': instance.productId,
      'product_sub_id': instance.productSubId,
      'quantity': instance.quantity,
      'unit_coin_price': instance.unitCoinPrice,
      'unit_money_price': instance.unitMoneyPrice,
      'is_flash_sale': instance.isFlashSale,
      'flash_sale_id': instance.flashSaleId,
      'line_coin_total': instance.lineCoinTotal,
      'line_money_total': instance.lineMoneyTotal,
      'price_changed': instance.priceChanged,
    };
