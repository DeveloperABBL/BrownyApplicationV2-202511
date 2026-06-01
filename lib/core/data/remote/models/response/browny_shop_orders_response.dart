import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/core/data/remote/models/response/order_history_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/shipping_provider_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'browny_shop_orders_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-31
///
/// Response สำหรับ GET /browny-shop/orders — ประวัติคำสั่งซื้อ Browny Shop
/// (paginated) พร้อมสถานะ + รายการสินค้าย่อ + รูป preview
///
/// reuse [OrderHistoryMeta] (pagination) และ [OrderHistoryPaymentMethod]
@JsonSerializable(explicitToJson: true)
class BrownyShopOrdersResponse {
  BrownyShopOrdersResponse({this.success, this.data, this.meta});

  @JsonKey(name: 'success')
  final bool? success;

  @JsonKey(name: 'data')
  final List<BrownyShopOrderItem>? data;

  @JsonKey(name: 'meta')
  final OrderHistoryMeta? meta;

  factory BrownyShopOrdersResponse.fromJson(Map<String, dynamic> json) =>
      _$BrownyShopOrdersResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BrownyShopOrdersResponseToJson(this);
}

/// สถานะออร์เดอร์ Browny Shop สำหรับ UI (หลัง map จาก backend)
///
/// Mapping (ดู [BrownyShopOrderItem.orderStatus]):
/// - `cancelled`                       → [cancelled]
/// - ยังไม่ชำระเงิน                      → [pendingPayment]
/// - ชำระแล้ว + มี `delivered_at`        → [delivered]
/// - ชำระแล้ว แต่ยังไม่จัดส่ง             → [pendingShipment]
enum BrownyShopOrderStatus {
  pendingPayment,
  pendingShipment,
  delivered,
  cancelled,
  unknown,
}

/// 1 ออร์เดอร์ในประวัติ Browny Shop
@JsonSerializable(explicitToJson: true)
class BrownyShopOrderItem {
  BrownyShopOrderItem({
    this.type,
    this.orderId,
    this.receiptNo,
    this.status,
    this.statusLabel,
    this.trackingNumber,
    this.shippingProvider,
    this.deliveredAt,
    this.deliveryDate,
    this.receiptAt,
    this.paymentMethod,
    this.amount,
    this.priceFinal,
    this.itemCount,
    this.lineCount,
    this.title,
    this.previewImage,
    this.items,
    this.sortAt,
  });

  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'order_id')
  final String? orderId;

  @JsonKey(name: 'receipt_no')
  final String? receiptNo;

  /// "pending_payment" | "paid" | "pending_shipment" | "delivered" | "cancelled"
  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'status_label')
  final ContentLocalizeData? statusLabel;

  /// เลขพัสดุ (null/ว่าง = ยังไม่ได้จัดส่ง)
  @JsonKey(name: 'tracking_number')
  final String? trackingNumber;

  /// บริษัทขนส่ง (null = ยังไม่ได้จัดส่ง)
  @JsonKey(name: 'shipping_provider')
  final ShippingProviderData? shippingProvider;

  @JsonKey(name: 'delivered_at')
  final String? deliveredAt;

  @JsonKey(name: 'delivery_date')
  final String? deliveryDate;

  @JsonKey(name: 'receipt_at')
  final String? receiptAt;

  /// reuse [OrderHistoryPaymentMethod] ({key, name})
  @JsonKey(name: 'payment_method')
  final OrderHistoryPaymentMethod? paymentMethod;

  @JsonKey(name: 'amount')
  final String? amount;

  @JsonKey(name: 'price_final')
  final String? priceFinal;

  /// จำนวนชิ้นรวม
  @JsonKey(name: 'item_count')
  final int? itemCount;

  /// จำนวนรายการ (บรรทัด)
  @JsonKey(name: 'line_count')
  final int? lineCount;

  /// ชื่อสรุปออร์เดอร์ (เช่น "เสื้อยืด Browny (+1)")
  @JsonKey(name: 'title')
  final ContentLocalizeData? title;

  @JsonKey(name: 'preview_image')
  final String? previewImage;

  @JsonKey(name: 'items')
  final List<BrownyShopOrderLineItem>? items;

  @JsonKey(name: 'sort_at')
  final String? sortAt;

  /// ป้ายสถานะตาม locale
  String getStatusLabelDisplay(String locale) {
    return statusLabel?.getByLocaleCode(locale) ?? '';
  }

  /// ชื่อสรุปออร์เดอร์ตาม locale
  String getTitleDisplay(String locale) {
    return title?.getByLocaleCode(locale) ?? '';
  }

  bool get _hasDelivered => deliveredAt != null && deliveredAt!.isNotEmpty;

  /// สถานะที่ map แล้วสำหรับ UI — รองรับทั้ง status ที่ server ส่งมาตรงๆ
  /// และกรณีส่ง `paid` มาดิบ ๆ (derive ต่อด้วย delivered_at)
  BrownyShopOrderStatus get orderStatus {
    switch (status?.toLowerCase()) {
      case 'cancelled':
        return BrownyShopOrderStatus.cancelled;
      case 'pending_payment':
        return BrownyShopOrderStatus.pendingPayment;
      case 'delivered':
        return BrownyShopOrderStatus.delivered;
      case 'pending_shipment':
        return BrownyShopOrderStatus.pendingShipment;
      case 'paid':
        // ชำระแล้ว: มี delivered_at → จัดส่งแล้ว, ไม่มี → รอจัดส่ง
        return _hasDelivered
            ? BrownyShopOrderStatus.delivered
            : BrownyShopOrderStatus.pendingShipment;
      default:
        return BrownyShopOrderStatus.unknown;
    }
  }

  /// วันที่สำหรับ sort ในประวัติ — ใช้ receipt_at ก่อน, ไม่มีค่อยใช้ sort_at
  DateTime? get sortDateTime {
    final raw = (receiptAt != null && receiptAt!.isNotEmpty)
        ? receiptAt
        : sortAt;
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  bool get isPendingPayment =>
      orderStatus == BrownyShopOrderStatus.pendingPayment;
  bool get isPendingShipment =>
      orderStatus == BrownyShopOrderStatus.pendingShipment;
  bool get isDelivered => orderStatus == BrownyShopOrderStatus.delivered;
  bool get isCancelled => orderStatus == BrownyShopOrderStatus.cancelled;

  factory BrownyShopOrderItem.fromJson(Map<String, dynamic> json) =>
      _$BrownyShopOrderItemFromJson(json);

  Map<String, dynamic> toJson() => _$BrownyShopOrderItemToJson(this);
}

/// 1 รายการสินค้าย่อในออร์เดอร์ (สำหรับ preview ในรายการประวัติ)
@JsonSerializable(explicitToJson: true)
class BrownyShopOrderLineItem {
  BrownyShopOrderLineItem({this.name, this.imageUrl, this.quantity});

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  @JsonKey(name: 'quantity')
  final int? quantity;

  /// ดึงชื่อสินค้าตาม locale
  String getNameDisplay(String locale) {
    return name?.getByLocaleCode(locale) ?? '';
  }

  factory BrownyShopOrderLineItem.fromJson(Map<String, dynamic> json) =>
      _$BrownyShopOrderLineItemFromJson(json);

  Map<String, dynamic> toJson() => _$BrownyShopOrderLineItemToJson(this);
}
