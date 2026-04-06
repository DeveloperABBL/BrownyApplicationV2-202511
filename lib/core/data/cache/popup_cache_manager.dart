import 'package:browny_applications_new/core/data/cache/app_local_storage.dart';
import 'package:browny_applications_new/core/data/remote/models/response/popup_response.dart';

/// Manager สำหรับจัดการ popup cache
///
/// ใช้เก็บข้อมูลว่า popup ไหนถูก dismiss ไปแล้วในวันนี้
class PopupCacheManager {
  static const String _keyPrefixPopups = 'popup_dismissed_';
  static const String _keyInviteFriend = 'invit_friend_dismissed_';

  final AppLocalStorage _storage;

  PopupCacheManager(this._storage);

  /// บันทึกว่า popup list นี้ถูก dismiss แล้วในวันนี้
  ///
  /// [popups] - List ของ popups ที่ต้องการ dismiss
  void markAsDismissedToday(List<PopupData> popups) {
    final today = _getTodayKey();
    for (final popup in popups) {
      final key = _getDismissKey(popup.id);
      _storage.write<String>(key: key, value: today);
    }
  }

  /// บันทึกว่า popup ID นี้ถูก dismiss แล้วในวันนี้
  ///
  /// [popupId] - ID ของ popup
  void markPopupAsDismissedToday(int popupId) {
    final key = _getDismissKey(popupId);
    final today = _getTodayKey();
    _storage.write<String>(key: key, value: today);
  }

  void markInvitFriendAsDismissedToday() {
    final today = _getTodayKey();
    _storage.write<String>(key: _keyInviteFriend, value: today);
  }

  /// ตรวจสอบว่า popup นี้ถูก dismiss ไปแล้วในวันนี้หรือยัง
  ///
  /// [popupId] - ID ของ popup
  ///
  /// Returns: true ถ้าถูก dismiss ไปแล้วในวันนี้
  bool isDismissedToday(int popupId) {
    final key = _getDismissKey(popupId);
    final dismissedDate = _storage.read<String>(key);

    if (dismissedDate == null) {
      return false;
    }

    final today = _getTodayKey();
    return dismissedDate == today;
  }

  bool isInvitFriendDismissedToday() {
    final dismissedDate = _storage.read<String>(_keyInviteFriend);

    if (dismissedDate == null) {
      return false;
    }

    final today = _getTodayKey();
    return dismissedDate == today;
  }

  /// ลบ cache ของ popup ที่หมดอายุ (เก่ากว่าวันนี้)
  ///
  /// เรียกใช้เมื่อเปิด app เพื่อทำความสะอาด cache เก่า
  void cleanupExpiredCache() {
    // TODO: Implement cleanup logic if needed
    // ใน implementation ปัจจุบัน cache จะถูกเขียนทับอัตโนมัติเมื่อวันใหม่มาถึง
  }

  /// ลบ cache ของ popup นี้ทั้งหมด
  ///
  /// [popupId] - ID ของ popup
  void clearDismiss(int popupId) {
    final key = _getDismissKey(popupId);
    _storage.delete(key);
  }

  /// ลบ cache ของ popup ทั้งหมด
  void clearAllDismiss() {
    // Note: ใน implementation ปัจจุบันไม่มี method list all keys
    // ถ้าต้องการ implement ให้ครบถ้วน อาจต้องเก็บ list ของ popup IDs ไว้
  }

  /// สร้าง cache key สำหรับ popup นี้
  String _getDismissKey(int popupId) {
    return '$_keyPrefixPopups$popupId';
  }

  /// สร้าง key สำหรับวันนี้ (ใช้เป็น value)
  ///
  /// Format: YYYY-MM-DD
  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
