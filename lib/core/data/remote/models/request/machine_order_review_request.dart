import 'package:json_annotation/json_annotation.dart';

part 'machine_order_review_request.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// Request model สำหรับส่ง review score ของคำสั่งซื้อเครื่องซัก/อบ
@JsonSerializable()
class MachineOrderReviewRequest {
  MachineOrderReviewRequest({
    required this.score,
  });

  /// คะแนนรีวิว (1-5)
  @JsonKey(name: 'score')
  final int score;

  factory MachineOrderReviewRequest.fromJson(Map<String, dynamic> json) =>
      _$MachineOrderReviewRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MachineOrderReviewRequestToJson(this);
}
