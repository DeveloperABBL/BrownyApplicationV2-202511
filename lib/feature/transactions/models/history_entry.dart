import 'package:browny_applications_new/core/data/remote/models/response/browny_shop_orders_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/order_history_response.dart';

/// 1 รายการในหน้าประวัติการใช้งาน — รวมได้ทั้งออร์เดอร์เครื่อง/แพ็กเกจ
/// ([OrderHistoryItem]) และคำสั่งซื้อ Browny Shop ([BrownyShopOrderItem])
///
/// ใช้ผสาน 2 แหล่งข้อมูลเข้าเป็น list เดียวแล้ว sort ตามวันที่ ([sortDate])
class HistoryEntry {
  const HistoryEntry.machine(OrderHistoryItem item)
    : machineItem = item,
      shopItem = null;

  const HistoryEntry.shop(BrownyShopOrderItem item)
    : shopItem = item,
      machineItem = null;

  /// ออร์เดอร์เครื่อง/แพ็กเกจคูปอง (machine_order / coupon_package_order)
  final OrderHistoryItem? machineItem;

  /// คำสั่งซื้อ Browny Shop
  final BrownyShopOrderItem? shopItem;

  bool get isShop => shopItem != null;

  /// วันที่ใช้ sort — receiptAt (เครื่อง) / receiptAt ?? sortAt (Browny Shop)
  DateTime? get sortDate =>
      isShop ? shopItem!.sortDateTime : machineItem!.receiptAtDateTime;
}
