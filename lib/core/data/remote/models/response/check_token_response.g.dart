// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_token_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckTokenResponse _$CheckTokenResponseFromJson(Map<String, dynamic> json) =>
    CheckTokenResponse(
      message: json['message'] as String?,
      client: json['client'] == null
          ? null
          : CheckTokenClientData.fromJson(
              json['client'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$CheckTokenResponseToJson(CheckTokenResponse instance) =>
    <String, dynamic>{'message': instance.message, 'client': instance.client};

CheckTokenClientData _$CheckTokenClientDataFromJson(
  Map<String, dynamic> json,
) => CheckTokenClientData(
  version: json['version'] as String?,
  status: json['status'] as String?,
);

Map<String, dynamic> _$CheckTokenClientDataToJson(
  CheckTokenClientData instance,
) => <String, dynamic>{'version': instance.version, 'status': instance.status};
