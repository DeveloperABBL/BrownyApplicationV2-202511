// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browny_shop_orders_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrownyShopOrdersResponse _$BrownyShopOrdersResponseFromJson(
  Map<String, dynamic> json,
) => BrownyShopOrdersResponse(
  success: json['success'] as bool?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => BrownyShopOrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'] == null
      ? null
      : OrderHistoryMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BrownyShopOrdersResponseToJson(
  BrownyShopOrdersResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data?.map((e) => e.toJson()).toList(),
  'meta': instance.meta?.toJson(),
};

BrownyShopOrderItem _$BrownyShopOrderItemFromJson(Map<String, dynamic> json) =>
    BrownyShopOrderItem(
      type: json['type'] as String?,
      orderId: json['order_id'] as String?,
      receiptNo: json['receipt_no'] as String?,
      status: json['status'] as String?,
      statusLabel: json['status_label'] == null
          ? null
          : ContentLocalizeData.fromJson(
              json['status_label'] as Map<String, dynamic>,
            ),
      deliveredAt: json['delivered_at'] as String?,
      deliveryDate: json['delivery_date'] as String?,
      receiptAt: json['receipt_at'] as String?,
      paymentMethod: json['payment_method'] == null
          ? null
          : OrderHistoryPaymentMethod.fromJson(
              json['payment_method'] as Map<String, dynamic>,
            ),
      amount: json['amount'] as String?,
      priceFinal: json['price_final'] as String?,
      itemCount: (json['item_count'] as num?)?.toInt(),
      lineCount: (json['line_count'] as num?)?.toInt(),
      title: json['title'] == null
          ? null
          : ContentLocalizeData.fromJson(json['title'] as Map<String, dynamic>),
      previewImage: json['preview_image'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map(
            (e) => BrownyShopOrderLineItem.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      sortAt: json['sort_at'] as String?,
    );

Map<String, dynamic> _$BrownyShopOrderItemToJson(
  BrownyShopOrderItem instance,
) => <String, dynamic>{
  'type': instance.type,
  'order_id': instance.orderId,
  'receipt_no': instance.receiptNo,
  'status': instance.status,
  'status_label': instance.statusLabel?.toJson(),
  'delivered_at': instance.deliveredAt,
  'delivery_date': instance.deliveryDate,
  'receipt_at': instance.receiptAt,
  'payment_method': instance.paymentMethod?.toJson(),
  'amount': instance.amount,
  'price_final': instance.priceFinal,
  'item_count': instance.itemCount,
  'line_count': instance.lineCount,
  'title': instance.title?.toJson(),
  'preview_image': instance.previewImage,
  'items': instance.items?.map((e) => e.toJson()).toList(),
  'sort_at': instance.sortAt,
};

BrownyShopOrderLineItem _$BrownyShopOrderLineItemFromJson(
  Map<String, dynamic> json,
) => BrownyShopOrderLineItem(
  name: json['name'] == null
      ? null
      : ContentLocalizeData.fromJson(json['name'] as Map<String, dynamic>),
  imageUrl: json['image_url'] as String?,
  quantity: (json['quantity'] as num?)?.toInt(),
);

Map<String, dynamic> _$BrownyShopOrderLineItemToJson(
  BrownyShopOrderLineItem instance,
) => <String, dynamic>{
  'name': instance.name?.toJson(),
  'image_url': instance.imageUrl,
  'quantity': instance.quantity,
};
