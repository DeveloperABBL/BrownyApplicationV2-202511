// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'machine_order_receipt_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MachineOrderReceiptResponse _$MachineOrderReceiptResponseFromJson(
  Map<String, dynamic> json,
) => MachineOrderReceiptResponse(
  total: json['total'] as String?,
  receiptNo: json['receipt_no'] as String?,
  branch: json['branch'] == null
      ? null
      : ContentLocalizeData.fromJson(json['branch'] as Map<String, dynamic>),
  machineType: json['machine_type'] == null
      ? null
      : ContentLocalizeData.fromJson(
          json['machine_type'] as Map<String, dynamic>,
        ),
  machineNo: (json['machine_no'] as num?)?.toInt(),
  paymentIcon: json['payment_icon'] as String?,
  paymentChannel: json['payment_channel'] as String?,
  paymentDisplay: json['payment_display'] == null
      ? null
      : ContentLocalizeData.fromJson(
          json['payment_display'] as Map<String, dynamic>,
        ),
  paidAt: const DateTimeConverter().fromJson(json['paid_at'] as String?),
  summary: json['summary'] == null
      ? null
      : MachineOrderReceiptSummary.fromJson(
          json['summary'] as Map<String, dynamic>,
        ),
  callCenter: json['call_center'] as String?,
  lineLink: json['line_link'] as String?,
  googleMapLink: json['google_map_link'] as String?,
  luckyNo: json['lucky_no'] as String?,
  luckyImage: json['lucky_image'] as String?,
  qrImage: json['qr_image'] as String?,
  reviewScore: json['review_score'] as String?,
  bonus: json['bonus'] as String?,
);

Map<String, dynamic> _$MachineOrderReceiptResponseToJson(
  MachineOrderReceiptResponse instance,
) => <String, dynamic>{
  'total': instance.total,
  'receipt_no': instance.receiptNo,
  'branch': instance.branch?.toJson(),
  'machine_type': instance.machineType?.toJson(),
  'machine_no': instance.machineNo,
  'payment_icon': instance.paymentIcon,
  'payment_channel': instance.paymentChannel,
  'payment_display': instance.paymentDisplay?.toJson(),
  'paid_at': const DateTimeConverter().toJson(instance.paidAt),
  'summary': instance.summary?.toJson(),
  'call_center': instance.callCenter,
  'line_link': instance.lineLink,
  'google_map_link': instance.googleMapLink,
  'lucky_no': instance.luckyNo,
  'lucky_image': instance.luckyImage,
  'qr_image': instance.qrImage,
  'review_score': instance.reviewScore,
  'bonus': instance.bonus,
};

MachineOrderReceiptSummary _$MachineOrderReceiptSummaryFromJson(
  Map<String, dynamic> json,
) => MachineOrderReceiptSummary(
  program: json['program'] == null
      ? null
      : MachineOrderReceiptSummaryItem.fromJson(
          json['program'] as Map<String, dynamic>,
        ),
  discount: json['discount'] == null
      ? null
      : MachineOrderReceiptSummaryItem.fromJson(
          json['discount'] as Map<String, dynamic>,
        ),
  couponDiscount: json['coupon_discount'] == null
      ? null
      : MachineOrderReceiptSummaryItem.fromJson(
          json['coupon_discount'] as Map<String, dynamic>,
        ),
  couponEvoucher: json['coupon_evoucher'] == null
      ? null
      : MachineOrderReceiptSummaryItem.fromJson(
          json['coupon_evoucher'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$MachineOrderReceiptSummaryToJson(
  MachineOrderReceiptSummary instance,
) => <String, dynamic>{
  'program': instance.program?.toJson(),
  'discount': instance.discount?.toJson(),
  'coupon_discount': instance.couponDiscount?.toJson(),
  'coupon_evoucher': instance.couponEvoucher?.toJson(),
};

MachineOrderReceiptSummaryItem _$MachineOrderReceiptSummaryItemFromJson(
  Map<String, dynamic> json,
) => MachineOrderReceiptSummaryItem(
  wording: json['wording'] == null
      ? null
      : ContentLocalizeData.fromJson(json['wording'] as Map<String, dynamic>),
  amount: json['amount'] as String?,
);

Map<String, dynamic> _$MachineOrderReceiptSummaryItemToJson(
  MachineOrderReceiptSummaryItem instance,
) => <String, dynamic>{
  'wording': instance.wording?.toJson(),
  'amount': instance.amount,
};
