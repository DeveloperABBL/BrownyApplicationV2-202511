import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';
import 'package:flutter/foundation.dart';

/// Store กลางเก็บ "จำนวนรายการในตะกร้า" Browny Shop — ใช้แสดง badge บนไอคอนถุง
///
/// นับแบบ distinct SKU (จำนวนบรรทัดในตะกร้า ไม่ใช่ผลรวม quantity) ตามที่ตกลง
/// เกิน 100 แสดงเป็น "99+"
///
/// รีเฟรชเมื่อ: เข้าหน้า Shop / หน้ารายละเอียดสินค้า และหลังเพิ่มของลงตะกร้า
class BrownyShopCartCountStore extends ChangeNotifier {
  BrownyShopCartCountStore({BrownyShopDataSourceMixin? repo})
    : _repo = repo ?? BrownyShopRepo();

  final BrownyShopDataSourceMixin _repo;

  int _count = 0;
  int get count => _count;

  /// ข้อความบน badge — null = ไม่แสดง (ตะกร้าว่าง), เกิน 99 = "99+"
  String? get badgeText {
    if (_count <= 0) return null;
    return _count > 99 ? '99+' : '$_count';
  }

  /// ดึงตะกร้าจาก server แล้วนับจำนวนรายการ (distinct SKU)
  /// error → คงค่าเดิมไว้ (ไม่รีเซ็ตเป็น 0 กัน badge กระพริบ)
  Future<void> refresh(String customerId) async {
    if (customerId.isEmpty) {
      _set(0);
      return;
    }
    final result = await _repo.fetchCart(customerId: customerId);
    if (result.isSuccess) {
      _set(result.data.items?.length ?? 0);
    } else if (result.isEmpty) {
      _set(0);
    }
  }

  void _set(int value) {
    if (_count == value) return;
    _count = value;
    notifyListeners();
  }
}
