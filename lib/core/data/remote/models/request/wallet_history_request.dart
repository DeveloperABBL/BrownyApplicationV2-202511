import 'package:json_annotation/json_annotation.dart';

part 'wallet_history_request.g.dart';

@JsonSerializable()
class WalletHistoryRequest {
  @JsonKey(name: 'customer_id')
  final String customerId;

  WalletHistoryRequest({
    required this.customerId,
  });

  factory WalletHistoryRequest.fromJson(Map<String, dynamic> json) =>
      _$WalletHistoryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WalletHistoryRequestToJson(this);
}
