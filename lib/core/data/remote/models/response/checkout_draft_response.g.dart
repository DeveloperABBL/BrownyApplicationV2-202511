// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_draft_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckoutDraftResponse _$CheckoutDraftResponseFromJson(
  Map<String, dynamic> json,
) => CheckoutDraftResponse(
  data: json['data'] == null
      ? null
      : CheckoutDraftData.fromJson(json['data'] as Map<String, dynamic>),
  success: json['success'] as bool?,
  message: json['message'] as String?,
  errorType: json['error_type'] as String?,
);

Map<String, dynamic> _$CheckoutDraftResponseToJson(
  CheckoutDraftResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'data': instance.data,
};

CheckoutDraftData _$CheckoutDraftDataFromJson(
  Map<String, dynamic> json,
) => CheckoutDraftData(
  id: json['id'] as String?,
  customerId: json['customer_id'] as String?,
  status: json['status'] as String?,
  paymentMethod: json['payment_method'] as String?,
  paymentStatus: json['payment_status'] as String?,
  paymentRef: json['payment_ref'] as String?,
  subtotal: json['subtotal'] as num?,
  shippingTotal: json['shipping_total'] as num?,
  flashSaleDiscount: json['flash_sale_discount'] as num?,
  productDiscount: json['product_discount'] as num?,
  couponDiscount: json['coupon_discount'] as num?,
  discountAmount: json['discount_amount'] as num?,
  priceOriginal: json['price_original'] as num?,
  priceFinal: json['price_final'] as num?,
  coinAmountUsed: json['coin_amount_used'] as num?,
  coinValue: json['coin_value'] as num?,
  expiresAt: const DateTimeConverter().fromJson(json['expires_at'] as String?),
  paidAt: const DateTimeConverter().fromJson(json['paid_at'] as String?),
  receiptNo: json['receipt_no'] as String?,
  customerAddressId: (json['customer_address_id'] as num?)?.toInt(),
  shippingAddress: json['shipping_address'] == null
      ? null
      : CheckoutShippingAddressData.fromJson(
          json['shipping_address'] as Map<String, dynamic>,
        ),
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => CheckoutItemData.fromJson(e as Map<String, dynamic>))
      .toList(),
  summary: json['summary'] == null
      ? null
      : CheckoutSummaryData.fromJson(json['summary'] as Map<String, dynamic>),
  paymentUrl: json['payment_url'] as String?,
  responsePayload: json['response_payload'] == null
      ? null
      : CheckoutResponsePayload.fromJson(
          json['response_payload'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$CheckoutDraftDataToJson(CheckoutDraftData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'status': instance.status,
      'payment_method': instance.paymentMethod,
      'payment_status': instance.paymentStatus,
      'payment_ref': instance.paymentRef,
      'subtotal': instance.subtotal,
      'shipping_total': instance.shippingTotal,
      'flash_sale_discount': instance.flashSaleDiscount,
      'product_discount': instance.productDiscount,
      'coupon_discount': instance.couponDiscount,
      'discount_amount': instance.discountAmount,
      'price_original': instance.priceOriginal,
      'price_final': instance.priceFinal,
      'coin_amount_used': instance.coinAmountUsed,
      'coin_value': instance.coinValue,
      'expires_at': const DateTimeConverter().toJson(instance.expiresAt),
      'paid_at': const DateTimeConverter().toJson(instance.paidAt),
      'receipt_no': instance.receiptNo,
      'customer_address_id': instance.customerAddressId,
      'shipping_address': instance.shippingAddress,
      'items': instance.items,
      'summary': instance.summary,
      'payment_url': instance.paymentUrl,
      'response_payload': instance.responsePayload,
    };

CheckoutResponsePayload _$CheckoutResponsePayloadFromJson(
  Map<String, dynamic> json,
) => CheckoutResponsePayload(
  qrcode: json['qrcode'] as String?,
  wechat: json['wechat'] as String?,
  method: json['method'] as String?,
  amount: json['amount'] as num?,
  coinAmountUsed: json['coin_amount_used'] as num?,
);

Map<String, dynamic> _$CheckoutResponsePayloadToJson(
  CheckoutResponsePayload instance,
) => <String, dynamic>{
  'qrcode': instance.qrcode,
  'wechat': instance.wechat,
  'method': instance.method,
  'amount': instance.amount,
  'coin_amount_used': instance.coinAmountUsed,
};

CheckoutShippingAddressData _$CheckoutShippingAddressDataFromJson(
  Map<String, dynamic> json,
) => CheckoutShippingAddressData(
  id: (json['id'] as num?)?.toInt(),
  recipientName: json['recipient_name'] as String?,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  phone: json['phone'] as String?,
  zipcode: json['zipcode'] as String?,
  province: json['province'] as String?,
  district: json['district'] as String?,
  subdistrict: json['subdistrict'] as String?,
  address: json['address'] as String?,
  fullAddress: json['full_address'] as String?,
  country: json['country'] as String?,
  note: json['note'] as String?,
);

Map<String, dynamic> _$CheckoutShippingAddressDataToJson(
  CheckoutShippingAddressData instance,
) => <String, dynamic>{
  'id': instance.id,
  'recipient_name': instance.recipientName,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'phone': instance.phone,
  'zipcode': instance.zipcode,
  'province': instance.province,
  'district': instance.district,
  'subdistrict': instance.subdistrict,
  'address': instance.address,
  'full_address': instance.fullAddress,
  'country': instance.country,
  'note': instance.note,
};

CheckoutItemData _$CheckoutItemDataFromJson(Map<String, dynamic> json) =>
    CheckoutItemData(
      productId: json['product_id'] as String?,
      productSubId: (json['product_sub_id'] as num?)?.toInt(),
      quantity: (json['quantity'] as num?)?.toInt(),
      unitCoinPrice: json['unit_coin_price'] as num?,
      unitMoneyPrice: json['unit_money_price'] as num?,
      lineSubtotal: json['line_subtotal'] as num?,
      unitShippingFee: json['unit_shipping_fee'] as num?,
      isFlashSale: json['is_flash_sale'] as bool?,
    );

Map<String, dynamic> _$CheckoutItemDataToJson(CheckoutItemData instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'product_sub_id': instance.productSubId,
      'quantity': instance.quantity,
      'unit_coin_price': instance.unitCoinPrice,
      'unit_money_price': instance.unitMoneyPrice,
      'line_subtotal': instance.lineSubtotal,
      'unit_shipping_fee': instance.unitShippingFee,
      'is_flash_sale': instance.isFlashSale,
    };

CheckoutSummaryData _$CheckoutSummaryDataFromJson(Map<String, dynamic> json) =>
    CheckoutSummaryData(
      success: json['success'] as bool?,
      subtotal: json['subtotal'] as num?,
      shippingTotal: json['shipping_total'] as num?,
      flashSaleDiscount: json['flash_sale_discount'] as num?,
      productDiscount: json['product_discount'] as num?,
      couponDiscount: json['coupon_discount'] as num?,
      totalDiscount: json['total_discount'] as num?,
      priceOriginal: json['price_original'] as num?,
      finalPrice: json['final_price'] as num?,
      coinAmountRequired: json['coin_amount_required'] as num?,
      coinValue: json['coin_value'] as num?,
      couponCustomerId: (json['coupon_customer_id'] as num?)?.toInt(),
      paymentMethod: json['payment_method'] as String?,
      coupon: json['coupon'] == null
          ? null
          : CouponData.fromJson(json['coupon'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>?)
          ?.map(
            (e) => CheckoutSummaryItemData.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$CheckoutSummaryDataToJson(
  CheckoutSummaryData instance,
) => <String, dynamic>{
  'success': instance.success,
  'subtotal': instance.subtotal,
  'shipping_total': instance.shippingTotal,
  'flash_sale_discount': instance.flashSaleDiscount,
  'product_discount': instance.productDiscount,
  'coupon_discount': instance.couponDiscount,
  'total_discount': instance.totalDiscount,
  'price_original': instance.priceOriginal,
  'final_price': instance.finalPrice,
  'coin_amount_required': instance.coinAmountRequired,
  'coin_value': instance.coinValue,
  'coupon_customer_id': instance.couponCustomerId,
  'payment_method': instance.paymentMethod,
  'coupon': instance.coupon,
  'items': instance.items,
};

CheckoutSummaryItemData _$CheckoutSummaryItemDataFromJson(
  Map<String, dynamic> json,
) => CheckoutSummaryItemData(
  productId: json['product_id'] as String?,
  productSubId: (json['product_sub_id'] as num?)?.toInt(),
  quantity: (json['quantity'] as num?)?.toInt(),
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
);

Map<String, dynamic> _$CheckoutSummaryItemDataToJson(
  CheckoutSummaryItemData instance,
) => <String, dynamic>{
  'product_id': instance.productId,
  'product_sub_id': instance.productSubId,
  'quantity': instance.quantity,
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
};
