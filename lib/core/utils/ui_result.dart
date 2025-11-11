/// สถานะต่างๆ ของ UI ที่สามารถเกิดขึ้นได้
/// - loading: กำลังโหลดข้อมูล
/// - success: โหลดข้อมูลสำเร็จ
/// - empty: ไม่มีข้อมูล
/// - error: เกิดข้อผิดพลาด
enum UiState {
  loading,
  success,
  empty,
  error,
}

/// คลาสสำหรับจัดการผลลัพธ์ของ UI ที่สามารถมีสถานะต่างๆ ได้
///
/// คลาสนี้ช่วยในการจัดการสถานะของ UI โดยรวมข้อมูล สถานะ และข้อผิดพลาดไว้ในที่เดียว
///
/// ตัวอย่างการใช้งาน:
/// ```dart
/// // สร้าง UiResult ในสถานะกำลังโหลด
/// final loading = UiResult<String>.loading();
///
/// // สร้าง UiResult ในสถานะสำเร็จ
/// final success = UiResult<String>.success(data: "Hello World");
///
/// // สร้าง UiResult ในสถานะเกิดข้อผิดพลาด
/// final error = UiResult<String>.error(error: Exception("Something went wrong"));
/// ```
class UiResult<T> {
  /// ข้อมูลที่เก็บไว้ใน UiResult
  T? _data;

  /// สถานะปัจจุบันของ UI
  final UiState _state;

  /// เก็บ Code สำหรับ Handle
  final UiCodeIndex? _code;

  /// ข้อผิดพลาดที่เกิดขึ้น (หากมี)
  final Exception? _error;

  /// Constructor แบบ private สำหรับสร้าง UiResult
  ///
  /// [data] ข้อมูลที่จะเก็บ
  /// [state] สถานะของ UI
  /// [error] ข้อผิดพลาดที่เกิดขึ้น
  UiResult._({
    required T? data,
    required UiCodeIndex? code,
    required UiState state,
    required Exception? error,
  }) : _data = data,
       _code = code,
       _state = state,
       _error = error;

  /// เรียกใช้ code เพื่อกรณีต้อง handle หรือเก็บ Log
  UiCodeIndex? get code => _code;
  String? get codeString => _code.toString();

  /// ตรวจสอบว่า UiResult อยู่ในสถานะกำลังโหลดหรือไม่
  bool get isLoading => _state == UiState.loading;

  bool get isSuccess => _state == UiState.success;

  /// ตรวจสอบว่า UiResult มีข้อมูลหรือไม่
  bool get hashData => _data != null;

  /// ตรวจสอบว่า UiResult มีข้อผิดพลาดหรือไม่
  bool get hasError => _error != null;

  /// ดึง Data ไปใช้
  T? get data => _data;
  T get requireData => _data!;

  /// สร้าง UiResult ในสถานะกำลังโหลด
  ///
  /// ใช้เมื่อต้องการแสดงว่าระบบกำลังโหลดข้อมูล
  factory UiResult.loading() => UiResult._(
    data: null,
    state: UiState.loading,
    code: null,
    error: null,
  );

  /// สร้าง UiResult ในสถานะไม่มีข้อมูล
  ///
  /// [data] ข้อมูลที่จะเก็บ (อาจเป็น null)
  /// [error] ข้อผิดพลาดที่เกิดขึ้น (หากมี)
  ///
  /// ใช้เมื่อการค้นหาหรือดึงข้อมูลไม่พบผลลัพธ์
  factory UiResult.empty({
    T? data,
    Exception? error,
  }) => UiResult._(
    data: data,
    state: UiState.empty,
    code: UiCodeIndex.code_00,
    error: error,
  );

  /// สร้าง UiResult ในสถานะเกิดข้อผิดพลาด
  ///
  /// [error] ข้อผิดพลาดที่เกิดขึ้น (จำเป็นต้องระบุ)
  ///
  /// ใช้เมื่อเกิดข้อผิดพลาดในการดึงหรือประมวลผลข้อมูล
  factory UiResult.error({
    required Exception error,
    UiCodeIndex? code,
  }) => UiResult._(
    data: null,
    state: UiState.error,
    code: code ?? UiCodeIndex.code_99,
    error: error,
  );

  /// สร้าง UiResult ในสถานะสำเร็จ
  ///
  /// [data] ข้อมูลที่ดึงมาได้สำเร็จ (จำเป็นต้องระบุ)
  ///
  /// ใช้เมื่อการดึงข้อมูลเสร็จสิ้นและได้ผลลัพธ์ที่ต้องการ
  factory UiResult.success({
    required T data,
  }) => UiResult._(
    data: data,
    state: UiState.success,
    code: UiCodeIndex.code_01,
    error: null,
  );
}

/// Enum สำหรับจัดการรหัสสถานะต่างๆ ของระบบ
/// - code_00: ผลลัพธ์ว่างเปล่า (ไม่มีข้อมูล)
/// - code_01: ดำเนินการสำเร็จ
/// - code_99: เกิดข้อผิดพลาด
enum UiCodeIndex {
  /// รหัส 00: ไม่พบข้อมูล หรือผลลัพธ์ว่างเปล่า
  code_00('Code : 00 - Result Empty'),

  /// รหัส 01: การดำเนินการสำเร็จ
  code_01('Code : 01 - Success'),

  /// รหัส 99: เกิดข้อผิดพลาดในระบบ
  code_99('Code : 99 - Error');

  /// Constructor สำหรับสร้าง CodeHandler
  ///
  /// [message] ข้อความอธิบายสถานะ
  const UiCodeIndex(this.message);

  /// ข้อความอธิบายสถานะ
  final String message;

  /// แปลงเป็น String เพื่อแสดงข้อความสถานะ
  @override
  String toString() => message;
}
