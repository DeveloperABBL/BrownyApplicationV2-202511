import 'dart:io';
import 'package:live_activities/live_activities.dart';

// MARK: - Data Model

/// ข้อมูลสำหรับ Live Activity เครื่องซักอบ
/// field name ต้องตรงกับ BrownyMachineActivityAttributes.ContentState (Swift)
class LaundryLiveActivityData {
  final String machineId;
  final String machineNumber;
  final String serviceType; // "wash" / "dry" / "wash_dry"
  final String branchName;
  final int remainingSeconds;
  final int totalSeconds;
  final bool isCompleted;

  const LaundryLiveActivityData({
    required this.machineId,
    required this.machineNumber,
    required this.serviceType,
    required this.branchName,
    required this.remainingSeconds,
    required this.totalSeconds,
    this.isCompleted = false,
  });

  /// แปลงเป็น Map สำหรับส่งไปยัง live_activities plugin
  /// Key ต้องตรงกับ CodingKey ใน Swift ContentState
  Map<String, dynamic> toActivityMap() => {
    // Static attribute
    'machine_id': machineId,
    // ContentState (dynamic)
    'machine_number': machineNumber,
    'service_type': serviceType,
    'branch_name': branchName,
    'remaining_seconds': remainingSeconds,
    'total_seconds': totalSeconds,
    'is_completed': isCompleted,
  };

  LaundryLiveActivityData copyWith({
    int? remainingSeconds,
    bool? isCompleted,
  }) => LaundryLiveActivityData(
    machineId: machineId,
    machineNumber: machineNumber,
    serviceType: serviceType,
    branchName: branchName,
    remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    totalSeconds: totalSeconds,
    isCompleted: isCompleted ?? this.isCompleted,
  );
}

// MARK: - Service

/// Service จัดการ Live Activity สำหรับเครื่องซักอบ
///
/// **การใช้งาน:**
/// ```dart
/// final service = LaundryLiveActivityService.instance;
///
/// // เริ่ม activity เมื่อเครื่องเริ่มทำงาน
/// await service.startActivity(data: LaundryLiveActivityData(...));
///
/// // อัพเดทเวลาทุก 15 วินาที
/// await service.updateRemainingTime(seconds: remaining);
///
/// // จบเมื่อเสร็จ
/// await service.endActivity(isCompleted: true);
/// ```
class LaundryLiveActivityService {
  LaundryLiveActivityService._();
  static final instance = LaundryLiveActivityService._();

  static const _appGroupId =
      'group.com.brownywash.brownyapplications.liveactivity';

  final _plugin = LiveActivities();
  bool _isInitialized = false;
  String? _currentActivityId;
  LaundryLiveActivityData? _currentData;

  String? get currentActivityId => _currentActivityId;
  bool get hasActiveActivity => _currentActivityId != null;

  // MARK: - Public API

  /// Initialize plugin — เรียกครั้งเดียวก่อนใช้งาน
  /// ปลอดภัยถ้าเรียกซ้ำ (idempotent)
  Future<void> initialize() async {
    if (!Platform.isIOS) return;
    if (_isInitialized) return;
    await _plugin.init(appGroupId: _appGroupId);
    _isInitialized = true;
  }

  /// เริ่ม Live Activity ใหม่
  /// ถ้ามี activity อยู่แล้วจะ end ก่อน
  Future<void> startActivity({required LaundryLiveActivityData data}) async {
    if (!Platform.isIOS) return;

    await initialize();

    final enabled = await _plugin.areActivitiesEnabled();
    if (enabled != true) {
      // ผู้ใช้ปิด Live Activities หรือ iOS รุ่นเก่า
      return;
    }
    await _plugin.endAllActivities();

    if (_currentActivityId != null) {
      await _endCurrentActivity(isCompleted: false);
    }

    _currentData = data;
    _currentActivityId = await _plugin.createActivity(
      'browny_machine_${data.machineId}',
      data.toActivityMap(),
    );

    _currentActivityId ??= 'browny_machine_${data.machineId}';
  }

  /// อัพเดทเวลาที่เหลือ
  Future<void> updateRemainingTime({required int remainingSeconds}) async {
    if (!Platform.isIOS) return;
    if (_currentActivityId == null || _currentData == null) return;

    final updated = _currentData!.copyWith(
      remainingSeconds: remainingSeconds,
      isCompleted: false,
    );
    _currentData = updated;

    await _plugin.updateActivity(
      _currentActivityId!,
      updated.toActivityMap(),
    );
  }

  /// จบ Activity
  /// [isCompleted] = true → แสดง "เสร็จสิ้น" state แล้วค่อย dismiss
  Future<void> endActivity({bool isCompleted = true}) async {
    if (!Platform.isIOS) return;
    if (_currentActivityId == null) return;

    if (isCompleted && _currentData != null) {
      // อัพเดทครั้งสุดท้ายก่อน end เพื่อแสดง completed state
      final completedData = _currentData!.copyWith(
        remainingSeconds: 0,
        isCompleted: true,
      );
      await _plugin.updateActivity(
        _currentActivityId!,
        completedData.toActivityMap(),
      );
      // รอสักครู่ให้ user เห็น completed state
      await Future.delayed(const Duration(seconds: 5));
    }

    await _endCurrentActivity(isCompleted: isCompleted);
  }

  /// จบ activities ทั้งหมด (เรียกตอน logout/reset)
  Future<void> endAllActivities() async {
    if (!Platform.isIOS) return;
    await initialize();
    await _plugin.endAllActivities();
    _currentActivityId = null;
    _currentData = null;
  }

  // MARK: - Private

  Future<void> _endCurrentActivity({required bool isCompleted}) async {
    if (_currentActivityId == null) return;
    await _plugin.endActivity(_currentActivityId!);
    _currentActivityId = null;
    _currentData = null;
  }
}
