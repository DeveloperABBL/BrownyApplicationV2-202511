// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browny_shop_order_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrownyShopOrderDetailResponse _$BrownyShopOrderDetailResponseFromJson(
  Map<String, dynamic> json,
) => BrownyShopOrderDetailResponse(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  errorType: json['error_type'] as String?,
  data: json['data'] == null
      ? null
      : BrownyShopOrderDetailData.fromJson(
          json['data'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$BrownyShopOrderDetailResponseToJson(
  BrownyShopOrderDetailResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'data': instance.data?.toJson(),
};

BrownyShopOrderDetailData _$BrownyShopOrderDetailDataFromJson(
  Map<String, dynamic> json,
) => BrownyShopOrderDetailData(
  type: json['type'] as String?,
  orderId: json['order_id'] as String?,
  paymentRef: json['payment_ref'] as String?,
  receiptNo: json['receipt_no'] as String?,
  status: json['status'] as String?,
  statusLabel: json['status_label'] == null
      ? null
      : ContentLocalizeData.fromJson(
          json['status_label'] as Map<String, dynamic>,
        ),
  statusSteps: json['status_steps'] == null
      ? null
      : BrownyShopOrderStatusStepsData.fromJson(
          json['status_steps'] as Map<String, dynamic>,
        ),
  trackingNumber: json['tracking_number'] as String?,
  priceOriginal: json['price_original'] as String?,
  priceFinal: json['price_final'] as String?,
  amount: json['amount'] as String?,
  discountAmount: json['discount_amount'] as String?,
  totalQuantity: (json['total_quantity'] as num?)?.toInt(),
  itemCount: (json['item_count'] as num?)?.toInt(),
  paymentMethod: json['payment_method'] as String?,
  paymentIcon: json['payment_icon'] as String?,
  paymentChannel: json['payment_channel'] as String?,
  paymentDisplay: json['payment_display'] == null
      ? null
      : ContentLocalizeData.fromJson(
          json['payment_display'] as Map<String, dynamic>,
        ),
  createdAt: json['created_at'] as String?,
  paidAt: json['paid_at'] as String?,
  shippedAt: json['shipped_at'] as String?,
  deliveredAt: json['delivered_at'] as String?,
  deliveryDate: json['delivery_date'] as String?,
  receiptAt: json['receipt_at'] as String?,
  reviewScore: (json['review_score'] as num?)?.toInt(),
  bonus: json['bonus'] as String?,
  qrImage: json['qr_image'] as String?,
  shippingAddress: json['shipping_address'] == null
      ? null
      : CheckoutShippingAddressData.fromJson(
          json['shipping_address'] as Map<String, dynamic>,
        ),
  items: (json['items'] as List<dynamic>?)
      ?.map(
        (e) => BrownyShopOrderDetailItem.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  summary: json['summary'] == null
      ? null
      : BrownyShopReceiptSummary.fromJson(
          json['summary'] as Map<String, dynamic>,
        ),
  callCenter: json['call_center'] as String?,
  lineLink: json['line_link'] as String?,
);

Map<String, dynamic> _$BrownyShopOrderDetailDataToJson(
  BrownyShopOrderDetailData instance,
) => <String, dynamic>{
  'type': instance.type,
  'order_id': instance.orderId,
  'payment_ref': instance.paymentRef,
  'receipt_no': instance.receiptNo,
  'status': instance.status,
  'status_label': instance.statusLabel?.toJson(),
  'status_steps': instance.statusSteps?.toJson(),
  'tracking_number': instance.trackingNumber,
  'price_original': instance.priceOriginal,
  'price_final': instance.priceFinal,
  'amount': instance.amount,
  'discount_amount': instance.discountAmount,
  'total_quantity': instance.totalQuantity,
  'item_count': instance.itemCount,
  'payment_method': instance.paymentMethod,
  'payment_icon': instance.paymentIcon,
  'payment_channel': instance.paymentChannel,
  'payment_display': instance.paymentDisplay?.toJson(),
  'created_at': instance.createdAt,
  'paid_at': instance.paidAt,
  'shipped_at': instance.shippedAt,
  'delivered_at': instance.deliveredAt,
  'delivery_date': instance.deliveryDate,
  'receipt_at': instance.receiptAt,
  'review_score': instance.reviewScore,
  'bonus': instance.bonus,
  'qr_image': instance.qrImage,
  'shipping_address': instance.shippingAddress?.toJson(),
  'items': instance.items?.map((e) => e.toJson()).toList(),
  'summary': instance.summary?.toJson(),
  'call_center': instance.callCenter,
  'line_link': instance.lineLink,
};

BrownyShopOrderStatusStepsData _$BrownyShopOrderStatusStepsDataFromJson(
  Map<String, dynamic> json,
) => BrownyShopOrderStatusStepsData(
  ordered: json['ordered'] == null
      ? null
      : BrownyShopOrderStatusStepData.fromJson(
          json['ordered'] as Map<String, dynamic>,
        ),
  paid: json['paid'] == null
      ? null
      : BrownyShopOrderStatusStepData.fromJson(
          json['paid'] as Map<String, dynamic>,
        ),
  shipping: json['shipping'] == null
      ? null
      : BrownyShopOrderStatusStepData.fromJson(
          json['shipping'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$BrownyShopOrderStatusStepsDataToJson(
  BrownyShopOrderStatusStepsData instance,
) => <String, dynamic>{
  'ordered': instance.ordered?.toJson(),
  'paid': instance.paid?.toJson(),
  'shipping': instance.shipping?.toJson(),
};

BrownyShopOrderStatusStepData _$BrownyShopOrderStatusStepDataFromJson(
  Map<String, dynamic> json,
) => BrownyShopOrderStatusStepData(
  done: json['done'] as bool?,
  at: json['at'] as String?,
);

Map<String, dynamic> _$BrownyShopOrderStatusStepDataToJson(
  BrownyShopOrderStatusStepData instance,
) => <String, dynamic>{'done': instance.done, 'at': instance.at};

BrownyShopOrderDetailItem _$BrownyShopOrderDetailItemFromJson(
  Map<String, dynamic> json,
) => BrownyShopOrderDetailItem(
  productId: json['product_id'] as String?,
  productSubId: (json['product_sub_id'] as num?)?.toInt(),
  quantity: (json['quantity'] as num?)?.toInt(),
  name: json['name'] == null
      ? null
      : ContentLocalizeData.fromJson(json['name'] as Map<String, dynamic>),
  unit: json['unit'] == null
      ? null
      : ContentLocalizeData.fromJson(json['unit'] as Map<String, dynamic>),
  unitCoinPrice: json['unit_coin_price'] as num?,
  unitMoneyPrice: json['unit_money_price'] as num?,
  originalCoinPrice: json['original_coin_price'] as num?,
  originalMoneyPrice: json['original_money_price'] as num?,
  isFlashSale: json['is_flash_sale'] as bool?,
  flashSaleId: (json['flash_sale_id'] as num?)?.toInt(),
  flashSaleDiscount: json['flash_sale_discount'] as num?,
  productDiscount: json['product_discount'] as num?,
  lineSubtotal: json['line_subtotal'] as num?,
  unitShippingFee: json['unit_shipping_fee'] as num?,
  lineShippingFee: json['line_shipping_fee'] as num?,
  bonus: json['bonus'] as String?,
  imageUrl: json['image_url'] as String?,
);

Map<String, dynamic> _$BrownyShopOrderDetailItemToJson(
  BrownyShopOrderDetailItem instance,
) => <String, dynamic>{
  'product_id': instance.productId,
  'product_sub_id': instance.productSubId,
  'quantity': instance.quantity,
  'name': instance.name?.toJson(),
  'unit': instance.unit?.toJson(),
  'unit_coin_price': instance.unitCoinPrice,
  'unit_money_price': instance.unitMoneyPrice,
  'original_coin_price': instance.originalCoinPrice,
  'original_money_price': instance.originalMoneyPrice,
  'is_flash_sale': instance.isFlashSale,
  'flash_sale_id': instance.flashSaleId,
  'flash_sale_discount': instance.flashSaleDiscount,
  'product_discount': instance.productDiscount,
  'line_subtotal': instance.lineSubtotal,
  'unit_shipping_fee': instance.unitShippingFee,
  'line_shipping_fee': instance.lineShippingFee,
  'bonus': instance.bonus,
  'image_url': instance.imageUrl,
};
