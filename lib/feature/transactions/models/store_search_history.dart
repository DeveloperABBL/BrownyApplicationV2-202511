import 'package:hive_ce_flutter/hive_flutter.dart';

/// Model สำหรับเก็บประวัติการค้นหาสาขา
class StoreSearchHistory {
  final int packageId;
  final int? storeId;
  final String storeName;
  final String packageName;
  final String? groupOption;
  final String? distance;
  final DateTime searchedAt;

  StoreSearchHistory({
    required this.packageId,
    this.storeId,
    required this.storeName,
    required this.packageName,
    this.groupOption,
    this.distance,
    DateTime? searchedAt,
  }) : searchedAt = searchedAt ?? DateTime.now();

  /// Helper เพื่อจำกัดจำนวน history ที่เก็บ
  static const int maxHistoryCount = 1;
}

/// Helper class สำหรับจัดการ Hive box
class StoreSearchHistoryHelper {
  static const String boxName = 'store_search_history';

  /// เปิด Hive box
  static Future<Box<StoreSearchHistory>> openBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<StoreSearchHistory>(boxName);
    }
    return Hive.box<StoreSearchHistory>(boxName);
  }

  /// บันทึกประวัติการค้นหา
  static Future<void> saveHistory(StoreSearchHistory history) async {
    final box = await openBox();

    // ลบ history เดิมที่มี packageId เดียวกัน (ถ้ามี)
    final existingIndex = box.values.toList().indexWhere(
      (h) => h.packageId == history.packageId,
    );

    if (existingIndex != -1) {
      await box.deleteAt(existingIndex);
    }

    // เพิ่ม history ใหม่ลงไปด้านหน้า
    await box.add(history);

    // ถ้ามีมากเกิน maxHistoryCount ให้ลบตัวเก่าสุดออก
    if (box.length > StoreSearchHistory.maxHistoryCount) {
      await box.deleteAt(0);
    }
  }

  /// ดึงประวัติทั้งหมด (เรียงจากใหม่ไปเก่า)
  static Future<List<StoreSearchHistory>> getHistory() async {
    final box = await openBox();
    return box.values.toList().reversed.toList();
  }

  /// ลบประวัติทั้งหมด
  static Future<void> clearHistory() async {
    final box = await openBox();
    await box.clear();
  }

  /// ลบประวัติแบบ specific
  static Future<void> removeHistory(int packageId) async {
    final box = await openBox();
    final index = box.values.toList().indexWhere(
      (h) => h.packageId == packageId,
    );

    if (index != -1) {
      await box.deleteAt(index);
    }
  }
}
