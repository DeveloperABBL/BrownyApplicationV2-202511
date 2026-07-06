import 'package:flutter/foundation.dart';

/// Store กลางเก็บสถานะ "สินค้าโปรด" ของ Browny Shop — single source of truth
///
/// ปัญหาเดิม: แต่ละหน้า (Home / Coin / Shop / Search / Favorites / รายละเอียด
/// สินค้า) ถือ `ProductData` คนละก้อน → กดถูกใจในหน้าหนึ่งไม่สะท้อนอีกหน้า
///
/// วิธีแก้: ให้ทุกจุดที่ toggle เขียนสถานะล่าสุดลง store นี้ แล้ว widget ที่แสดง
/// หัวใจอ่านจาก store (fallback เป็นค่า `favoriteStatus` ของ ProductData ถ้า
/// store ยังไม่มี override) — store เปลี่ยนเมื่อไร ทุกหน้าที่ subscribe จะ sync
class BrownyShopFavoriteStore extends ChangeNotifier {
  /// override สถานะโปรดต่อ productId (มีเฉพาะรายการที่เคย toggle ในเซสชันนี้)
  final Map<String, bool> _status = {};

  /// อ่านสถานะโปรดของสินค้า — null = ยังไม่มี override (ให้ผู้เรียก fallback ไป
  /// ใช้ `ProductData.favoriteStatus`)
  bool? statusOf(String? productId) {
    if (productId == null) return null;
    return _status[productId];
  }

  /// รวมสถานะจาก store กับค่าตั้งต้นจาก API — helper ให้ widget เรียกสั้นๆ
  bool resolve(String? productId, bool fallback) {
    return statusOf(productId) ?? fallback;
  }

  /// ตั้งสถานะโปรดล่าสุด (optimistic ตอนกด + sync ค่าจริงจาก server)
  /// notify ให้ทุกหน้าที่ subscribe อัปเดตพร้อมกัน
  void setFavorite(String? productId, bool favorite) {
    if (productId == null) return;
    if (_status[productId] == favorite) return;
    _status[productId] = favorite;
    notifyListeners();
  }
}
