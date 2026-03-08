import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/core/utils/json_converters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'machine_order_receipt_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable(explicitToJson: true)
class MachineOrderReceiptResponse {
  MachineOrderReceiptResponse({
    this.total,
    this.receiptNo,
    this.branch,
    this.machineType,
    this.machineNo,
    this.paymentIcon,
    this.paymentChannel,
    this.paymentDisplay,
    this.paidAt,
    this.summary,
    this.callCenter,
    this.lineLink,
    this.googleMapLink,
    this.luckyNo,
    this.luckyImage,
    this.qrImage,
    this.reviewScore,
  });

  @JsonKey(name: 'total')
  final String? total;

  @JsonKey(name: 'receipt_no')
  final String? receiptNo;

  @JsonKey(name: 'branch')
  final ContentLocalizeData? branch;

  @JsonKey(name: 'machine_type')
  final ContentLocalizeData? machineType;

  @JsonKey(name: 'machine_no')
  final int? machineNo;

  @JsonKey(name: 'payment_icon')
  final String? paymentIcon;

  @JsonKey(name: 'payment_channel')
  final String? paymentChannel;

  @JsonKey(name: 'payment_display')
  final ContentLocalizeData? paymentDisplay;

  @DateTimeConverter()
  @JsonKey(name: 'paid_at')
  final DateTime? paidAt;

  @JsonKey(name: 'summary')
  final MachineOrderReceiptSummary? summary;

  @JsonKey(name: 'call_center')
  final String? callCenter;

  @JsonKey(name: 'line_link')
  final String? lineLink;

  @JsonKey(name: 'google_map_link')
  final String? googleMapLink;

  @JsonKey(name: 'lucky_no')
  final String? luckyNo;

  @JsonKey(name: 'lucky_image')
  final String? luckyImage;

  @JsonKey(name: 'qr_image')
  final String? qrImage;

  @JsonKey(name: 'review_score')
  final String? reviewScore;

  factory MachineOrderReceiptResponse.fromJson(Map<String, dynamic> json) =>
      _$MachineOrderReceiptResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MachineOrderReceiptResponseToJson(this);

  MachineOrderReceiptResponse copyWith({
    String? total,
    String? receiptNo,
    ContentLocalizeData? branch,
    ContentLocalizeData? machineType,
    int? machineNo,
    String? paymentIcon,
    String? paymentChannel,
    ContentLocalizeData? paymentDisplay,
    DateTime? paidAt,
    MachineOrderReceiptSummary? summary,
    String? callCenter,
    String? lineLink,
    String? googleMapLink,
    String? luckyNo,
    String? luckyImage,
    String? qrImage,
    String? reviewScore,
  }) {
    return MachineOrderReceiptResponse(
      total: total ?? this.total,
      receiptNo: receiptNo ?? this.receiptNo,
      branch: branch ?? this.branch,
      machineType: machineType ?? this.machineType,
      machineNo: machineNo ?? this.machineNo,
      paymentIcon: paymentIcon ?? this.paymentIcon,
      paymentChannel: paymentChannel ?? this.paymentChannel,
      paymentDisplay: paymentDisplay ?? this.paymentDisplay,
      paidAt: paidAt ?? this.paidAt,
      summary: summary ?? this.summary,
      callCenter: callCenter ?? this.callCenter,
      lineLink: lineLink ?? this.lineLink,
      googleMapLink: googleMapLink ?? this.googleMapLink,
      luckyNo: luckyNo ?? this.luckyNo,
      luckyImage: luckyImage ?? this.luckyImage,
      qrImage: qrImage ?? this.qrImage,
      reviewScore: reviewScore ?? this.reviewScore,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class MachineOrderReceiptSummary {
  MachineOrderReceiptSummary({
    this.program,
    this.discount,
    this.couponDiscount,
    this.couponEvoucher,
  });

  @JsonKey(name: 'program')
  final MachineOrderReceiptSummaryItem? program;

  @JsonKey(name: 'discount')
  final MachineOrderReceiptSummaryItem? discount;

  @JsonKey(name: 'coupon_discount')
  final MachineOrderReceiptSummaryItem? couponDiscount;

  @JsonKey(name: 'coupon_evoucher')
  final MachineOrderReceiptSummaryItem? couponEvoucher;

  factory MachineOrderReceiptSummary.fromJson(Map<String, dynamic> json) =>
      _$MachineOrderReceiptSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$MachineOrderReceiptSummaryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MachineOrderReceiptSummaryItem {
  MachineOrderReceiptSummaryItem({
    this.wording,
    this.amount,
  });

  @JsonKey(name: 'wording')
  final ContentLocalizeData? wording;

  @JsonKey(name: 'amount')
  final String? amount;

  factory MachineOrderReceiptSummaryItem.fromJson(Map<String, dynamic> json) =>
      _$MachineOrderReceiptSummaryItemFromJson(json);

  Map<String, dynamic> toJson() => _$MachineOrderReceiptSummaryItemToJson(this);
}
