/// คลาสสำหรับจัดการผลลัพธ์จาก Repository ที่สามารถมีสถานะต่างๆ ได้
///
/// [RepoResult] เป็น generic class ที่ใช้ wrap ข้อมูลที่ได้จาก repository
/// พร้อมกับสถานะของการดำเนินการ ซึ่งจะช่วยให้การจัดการ error และ empty state
/// เป็นไปอย่างสะดวกและมีประสิทธิภาพ
///
/// สถานะที่เป็นไปได้:
/// - [RepoState.success]: การดำเนินการสำเร็จและมีข้อมูล
/// - [RepoState.empty]: การดำเนินการสำเร็จแต่ไม่มีข้อมูล
/// - [RepoState.error]: เกิดข้อผิดพลาดระหว่างการดำเนินการ
///
/// ตัวอย่างการใช้งาน:
/// ```dart
/// RepoResult<List<User>> result = await userRepository.getUsers();
///
/// if (result.isSuccess) {
///   List<User> users = result.data;
///   // ทำงานกับข้อมูลที่ได้รับ
/// } else if (result.isEmpty) {
///   // แสดง UI สำหรับกรณีที่ไม่มีข้อมูล
/// } else if (result.hasError) {
///   // จัดการกับข้อผิดพลาด
///   Exception error = result.error;
/// }
/// ```
enum RepoState {
  success,
  empty,
  error,
}

/// คลาส `RepoResult<T>` ใช้สำหรับเก็บผลลัพธ์จากการดึงข้อมูลจาก repository
/// โดยรองรับสถานะต่าง ๆ ได้แก่ สำเร็จ (success), ว่างเปล่า (empty), และเกิดข้อผิดพลาด (error)
///
/// - `T` คือชนิดข้อมูลของผลลัพธ์ที่ต้องการเก็บ
///
/// Constructor factory:
/// - `RepoResult.success({required T data})`
///   สร้างผลลัพธ์ที่สำเร็จและมีข้อมูล
/// - `RepoResult.empty({required T data, Exception? error})`
///   สร้างผลลัพธ์ที่ว่างเปล่า อาจมีหรือไม่มี error ก็ได้
/// - `RepoResult.error({required Exception error})`
///   สร้างผลลัพธ์ที่เกิดข้อผิดพลาด
///
/// Getter:
/// - `isSuccess` คืนค่า true ถ้าสถานะเป็น success
/// - `isEmpty` คืนค่า true ถ้าสถานะเป็น empty
/// - `hasError` คืนค่า true ถ้าสถานะเป็น error
/// - `state` คืนค่าสถานะปัจจุบัน
/// - `data` คืนค่าข้อมูล (ต้องแน่ใจว่าสถานะเป็น success ก่อนเรียกใช้)
/// - `error` คืนค่า exception ที่เกิดขึ้น (ต้องแน่ใจว่าสถานะเป็น error ก่อนเรียกใช้)
class RepoResult<T> {
  RepoResult._internal(
    this._state,
    this._data,
    this._error,
  );

  final T? _data;

  final RepoState _state;

  final Exception? _error;

  /// Constructor factory:
  /// - `RepoResult.success({required T data})`
  ///   สร้างผลลัพธ์ที่สำเร็จและมีข้อมูล
  factory RepoResult.success({required T data}) => RepoResult._internal(
    RepoState.success,
    data,
    null,
  );

  /// Constructor factory:
  /// - `RepoResult.empty({required T data, Exception? error})`
  ///   สร้างผลลัพธ์ที่ว่างเปล่า อาจมีหรือไม่มี error ก็ได้
  factory RepoResult.empty({
    Exception? error,
  }) => RepoResult._internal(RepoState.empty, null, error);

  /// Constructor factory:
  /// - `RepoResult.empty({required T data, Exception? error})`
  ///   สร้างผลลัพธ์ที่ว่างเปล่า อาจมีหรือไม่มี error ก็ได้
  factory RepoResult.error({
    required Exception error,
  }) => RepoResult._internal(RepoState.error, null, error);

  factory RepoResult.dependOn(T? data) {
    if (data == null) {
      return RepoResult.empty();
    }
    return RepoResult.success(data: data);
  }

  /// Getter:
  /// - `isSuccess` คืนค่า true ถ้าสถานะเป็น success
  bool get isSuccess => _state == RepoState.success;

  /// Getter:
  /// - `isEmpty` คืนค่า true ถ้าสถานะเป็น empty
  bool get isEmpty => _state == RepoState.empty;

  /// Getter:
  /// - `isError` คืนค่า true ถ้าสถานะเป็น error
  bool get isError => _state == RepoState.error;

  /// Getter:
  /// - `hasError` คืนค่า true ถ้าสถานะเป็น error
  bool get hasError => _error != null;

  /// Getter:
  /// - `hasData` คืนค่า true ถ้า _data != null
  bool get hasData => _data != null;

  /// Getter:
  /// - `state` คืนค่าสถานะปัจจุบัน
  RepoState get state => _state;

  /// Getter:
  /// - `data` คืนค่าข้อมูล (ต้องแน่ใจว่าสถานะเป็น success ก่อนเรียกใช้)
  T get data => _data!;

  /// Getter:
  /// - `error` คืนค่า exception ที่เกิดขึ้น (ต้องแน่ใจว่าสถานะเป็น error ก่อนเรียกใช้)
  Exception get error => _error!;
}
