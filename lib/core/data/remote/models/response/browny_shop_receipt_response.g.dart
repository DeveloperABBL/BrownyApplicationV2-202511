// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browny_shop_receipt_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrownyShopReceiptResponse _$BrownyShopReceiptResponseFromJson(
  Map<String, dynamic> json,
) => BrownyShopReceiptResponse(
  type: json['type'] as String?,
  orderId: json['order_id'] as String?,
  paymentRef: json['payment_ref'] as String?,
  receiptNo: json['receipt_no'] as String?,
  total: json['total'] as String?,
  priceOriginal: json['price_original'] as String?,
  priceFinal: json['price_final'] as String?,
  discountAmount: json['discount_amount'] as String?,
  totalQuantity: (json['total_quantity'] as num?)?.toInt(),
  paymentIcon: json['payment_icon'] as String?,
  paymentChannel: json['payment_channel'] as String?,
  paymentDisplay: json['payment_display'] == null
      ? null
      : ContentLocalizeData.fromJson(
          json['payment_display'] as Map<String, dynamic>,
        ),
  paidAt: const DateTimeConverter().fromJson(json['paid_at'] as String?),
  receiptAt: const DateTimeConverter().fromJson(json['receipt_at'] as String?),
  coinAmountUsed: json['coin_amount_used'] as String?,
  coinValue: json['coin_value'] as num?,
  luckyNo: json['lucky_no'] as String?,
  luckyImage: json['lucky_image'] as String?,
  shippingAddress: json['shipping_address'] == null
      ? null
      : CheckoutShippingAddressData.fromJson(
          json['shipping_address'] as Map<String, dynamic>,
        ),
  summary: json['summary'] == null
      ? null
      : BrownyShopReceiptSummary.fromJson(
          json['summary'] as Map<String, dynamic>,
        ),
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => BrownyShopReceiptItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  callCenter: json['call_center'] as String?,
  lineLink: json['line_link'] as String?,
  qrImage: json['qr_image'] as String?,
  reviewScore: (json['review_score'] as num?)?.toInt(),
  bonus: json['bonus'] as String?,
  trackingNumber: json['tracking_number'] as String?,
  shippingProvider: json['shipping_provider'] == null
      ? null
      : ShippingProviderData.fromJson(
          json['shipping_provider'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$BrownyShopReceiptResponseToJson(
  BrownyShopReceiptResponse instance,
) => <String, dynamic>{
  'type': instance.type,
  'order_id': instance.orderId,
  'payment_ref': instance.paymentRef,
  'receipt_no': instance.receiptNo,
  'total': instance.total,
  'price_original': instance.priceOriginal,
  'price_final': instance.priceFinal,
  'discount_amount': instance.discountAmount,
  'total_quantity': instance.totalQuantity,
  'payment_icon': instance.paymentIcon,
  'payment_channel': instance.paymentChannel,
  'payment_display': instance.paymentDisplay?.toJson(),
  'paid_at': const DateTimeConverter().toJson(instance.paidAt),
  'receipt_at': const DateTimeConverter().toJson(instance.receiptAt),
  'coin_amount_used': instance.coinAmountUsed,
  'coin_value': instance.coinValue,
  'lucky_no': instance.luckyNo,
  'lucky_image': instance.luckyImage,
  'shipping_address': instance.shippingAddress?.toJson(),
  'summary': instance.summary?.toJson(),
  'items': instance.items?.map((e) => e.toJson()).toList(),
  'call_center': instance.callCenter,
  'line_link': instance.lineLink,
  'qr_image': instance.qrImage,
  'review_score': instance.reviewScore,
  'bonus': instance.bonus,
  'tracking_number': instance.trackingNumber,
  'shipping_provider': instance.shippingProvider?.toJson(),
};

BrownyShopReceiptSummary _$BrownyShopReceiptSummaryFromJson(
  Map<String, dynamic> json,
) => BrownyShopReceiptSummary(
  quantity: json['quantity'] == null
      ? null
      : BrownyShopReceiptSummaryItem.fromJson(
          json['quantity'] as Map<String, dynamic>,
        ),
  subtotal: json['subtotal'] == null
      ? null
      : BrownyShopReceiptSummaryItem.fromJson(
          json['subtotal'] as Map<String, dynamic>,
        ),
  discount: json['discount'] == null
      ? null
      : BrownyShopReceiptSummaryItem.fromJson(
          json['discount'] as Map<String, dynamic>,
        ),
  flashSaleDiscount: json['flash_sale_discount'] == null
      ? null
      : BrownyShopReceiptSummaryItem.fromJson(
          json['flash_sale_discount'] as Map<String, dynamic>,
        ),
  productDiscount: json['product_discount'] == null
      ? null
      : BrownyShopReceiptSummaryItem.fromJson(
          json['product_discount'] as Map<String, dynamic>,
        ),
  couponDiscount: json['coupon_discount'] == null
      ? null
      : BrownyShopReceiptSummaryItem.fromJson(
          json['coupon_discount'] as Map<String, dynamic>,
        ),
  shipping: json['shipping'] == null
      ? null
      : BrownyShopReceiptSummaryItem.fromJson(
          json['shipping'] as Map<String, dynamic>,
        ),
  total: json['total'] == null
      ? null
      : BrownyShopReceiptSummaryItem.fromJson(
          json['total'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$BrownyShopReceiptSummaryToJson(
  BrownyShopReceiptSummary instance,
) => <String, dynamic>{
  'quantity': instance.quantity?.toJson(),
  'subtotal': instance.subtotal?.toJson(),
  'discount': instance.discount?.toJson(),
  'flash_sale_discount': instance.flashSaleDiscount?.toJson(),
  'product_discount': instance.productDiscount?.toJson(),
  'coupon_discount': instance.couponDiscount?.toJson(),
  'shipping': instance.shipping?.toJson(),
  'total': instance.total?.toJson(),
};

BrownyShopReceiptSummaryItem _$BrownyShopReceiptSummaryItemFromJson(
  Map<String, dynamic> json,
) => BrownyShopReceiptSummaryItem(
  wording: json['wording'] == null
      ? null
      : ContentLocalizeData.fromJson(json['wording'] as Map<String, dynamic>),
  amount: json['amount'] as String?,
  code: json['code'] as String?,
  couponName: json['coupon_name'] == null
      ? null
      : ContentLocalizeData.fromJson(
          json['coupon_name'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$BrownyShopReceiptSummaryItemToJson(
  BrownyShopReceiptSummaryItem instance,
) => <String, dynamic>{
  'wording': instance.wording?.toJson(),
  'amount': instance.amount,
  'code': instance.code,
  'coupon_name': instance.couponName?.toJson(),
};

BrownyShopReceiptItem _$BrownyShopReceiptItemFromJson(
  Map<String, dynamic> json,
) => BrownyShopReceiptItem(
  productId: json['product_id'] as String?,
  productSubId: (json['product_sub_id'] as num?)?.toInt(),
  quantity: (json['quantity'] as num?)?.toInt(),
  name: json['name'] == null
      ? null
      : ContentLocalizeData.fromJson(json['name'] as Map<String, dynamic>),
  unit: json['unit'] == null
      ? null
      : ContentLocalizeData.fromJson(json['unit'] as Map<String, dynamic>),
  imageUrl: json['image_url'] as String?,
  unitMoneyPrice: json['unit_money_price'] as num?,
  originalMoneyPrice: json['original_money_price'] as num?,
  lineSubtotal: json['line_subtotal'] as num?,
  flashSaleDiscount: json['flash_sale_discount'] as num?,
  productDiscount: json['product_discount'] as num?,
  unitShippingFee: json['unit_shipping_fee'] as num?,
  isFlashSale: json['is_flash_sale'] as bool?,
);

Map<String, dynamic> _$BrownyShopReceiptItemToJson(
  BrownyShopReceiptItem instance,
) => <String, dynamic>{
  'product_id': instance.productId,
  'product_sub_id': instance.productSubId,
  'quantity': instance.quantity,
  'name': instance.name?.toJson(),
  'unit': instance.unit?.toJson(),
  'image_url': instance.imageUrl,
  'unit_money_price': instance.unitMoneyPrice,
  'original_money_price': instance.originalMoneyPrice,
  'line_subtotal': instance.lineSubtotal,
  'flash_sale_discount': instance.flashSaleDiscount,
  'product_discount': instance.productDiscount,
  'unit_shipping_fee': instance.unitShippingFee,
  'is_flash_sale': instance.isFlashSale,
};
