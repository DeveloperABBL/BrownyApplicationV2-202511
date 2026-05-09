// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReferralStatusResponse _$ReferralStatusResponseFromJson(
  Map<String, dynamic> json,
) => ReferralStatusResponse(
  enabled: json['enabled'] as bool?,
  terms: json['terms'] == null
      ? null
      : ContentLocalizeData.fromJson(json['terms'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ReferralStatusResponseToJson(
  ReferralStatusResponse instance,
) => <String, dynamic>{'enabled': instance.enabled, 'terms': instance.terms};
