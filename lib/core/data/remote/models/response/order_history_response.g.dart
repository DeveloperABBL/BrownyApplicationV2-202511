// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_history_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderHistoryResponse _$OrderHistoryResponseFromJson(
  Map<String, dynamic> json,
) => OrderHistoryResponse(
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => OrderHistoryItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'] == null
      ? null
      : OrderHistoryMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OrderHistoryResponseToJson(
  OrderHistoryResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

OrderHistoryMeta _$OrderHistoryMetaFromJson(Map<String, dynamic> json) =>
    OrderHistoryMeta(
      currentPage: (json['current_page'] as num?)?.toInt(),
      perPage: (json['per_page'] as num?)?.toInt(),
      total: (json['total'] as num?)?.toInt(),
      lastPage: (json['last_page'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OrderHistoryMetaToJson(OrderHistoryMeta instance) =>
    <String, dynamic>{
      'current_page': instance.currentPage,
      'per_page': instance.perPage,
      'total': instance.total,
      'last_page': instance.lastPage,
    };

OrderHistoryItem _$OrderHistoryItemFromJson(Map<String, dynamic> json) =>
    OrderHistoryItem(
      type: json['type'] as String?,
      orderId: json['order_id'] as String?,
      receiptNo: json['receipt_no'] as String?,
      receiptAt: json['receipt_at'] as String?,
      store: json['store'] == null
          ? null
          : OrderHistoryStore.fromJson(json['store'] as Map<String, dynamic>),
      machineNo: (json['machine_no'] as num?)?.toInt(),
      machineType: json['machine_type'] == null
          ? null
          : ContentLocalizeData.fromJson(
              json['machine_type'] as Map<String, dynamic>,
            ),
      image: json['image'] as String?,
      luckNo: json['luck_no'] as String?,
      program: json['program'] == null
          ? null
          : OrderHistoryProgram.fromJson(
              json['program'] as Map<String, dynamic>,
            ),
      paymentMethod: json['payment_method'] == null
          ? null
          : OrderHistoryPaymentMethod.fromJson(
              json['payment_method'] as Map<String, dynamic>,
            ),
      amount: json['amount'] as String?,
      packageName: json['package_name'] == null
          ? null
          : ContentLocalizeData.fromJson(
              json['package_name'] as Map<String, dynamic>,
            ),
      itemCount: (json['item_count'] as num?)?.toInt(),
      title: json['title'] == null
          ? null
          : ContentLocalizeData.fromJson(json['title'] as Map<String, dynamic>),
      sortAt: json['sort_at'] as String?,
    );

Map<String, dynamic> _$OrderHistoryItemToJson(OrderHistoryItem instance) =>
    <String, dynamic>{
      'type': instance.type,
      'order_id': instance.orderId,
      'receipt_no': instance.receiptNo,
      'receipt_at': instance.receiptAt,
      'store': instance.store,
      'machine_no': instance.machineNo,
      'image': instance.image,
      'machine_type': instance.machineType,
      'luck_no': instance.luckNo,
      'program': instance.program,
      'payment_method': instance.paymentMethod,
      'amount': instance.amount,
      'package_name': instance.packageName,
      'item_count': instance.itemCount,
      'title': instance.title,
      'sort_at': instance.sortAt,
    };

OrderHistoryStore _$OrderHistoryStoreFromJson(Map<String, dynamic> json) =>
    OrderHistoryStore(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] == null
          ? null
          : ContentLocalizeData.fromJson(json['name'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrderHistoryStoreToJson(OrderHistoryStore instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

OrderHistoryProgram _$OrderHistoryProgramFromJson(Map<String, dynamic> json) =>
    OrderHistoryProgram(
      code: json['code'] as String?,
      name: json['name'] == null
          ? null
          : ContentLocalizeData.fromJson(json['name'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrderHistoryProgramToJson(
  OrderHistoryProgram instance,
) => <String, dynamic>{'code': instance.code, 'name': instance.name};

OrderHistoryPaymentMethod _$OrderHistoryPaymentMethodFromJson(
  Map<String, dynamic> json,
) => OrderHistoryPaymentMethod(
  key: json['key'] as String?,
  name: json['name'] == null
      ? null
      : ContentLocalizeData.fromJson(json['name'] as Map<String, dynamic>),
  image: json['image'] as String?,
);

Map<String, dynamic> _$OrderHistoryPaymentMethodToJson(
  OrderHistoryPaymentMethod instance,
) => <String, dynamic>{
  'key': instance.key,
  'name': instance.name,
  'image': instance.image,
};
