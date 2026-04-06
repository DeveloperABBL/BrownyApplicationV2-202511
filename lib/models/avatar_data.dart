import 'package:image_picker/image_picker.dart';

/// Data class สำหรับเก็บข้อมูล Avatar
/// สามารถเป็นได้ทั้ง URL จาก API หรือ XFile จาก ImagePicker
class AvatarData {
  final String? url;
  final XFile? file;

  /// Constructor สำหรับ avatar ที่มาจาก API (URL)
  AvatarData.fromUrl(this.url)
    : file = null,
      assert(url != null, 'URL cannot be null');

  /// Constructor สำหรับ avatar ที่ pick จาก Gallery/Camera
  AvatarData.fromFile(this.file)
    : url = null,
      assert(file != null, 'File cannot be null');

  /// ตรวจสอบว่าเป็น file จาก picker หรือไม่
  bool get isFromPicker => file != null;

  /// ตรวจสอบว่าเป็น URL จาก API หรือไม่
  bool get isFromUrl => url != null;

  /// ดึง path สำหรับแสดงรูป (อาจเป็น URL หรือ file path)
  String get path => isFromPicker ? file!.path : url!;

  @override
  String toString() {
    if (isFromPicker) {
      return 'AvatarData.fromFile(${file!.path})';
    }
    return 'AvatarData.fromUrl($url)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AvatarData &&
        other.url == url &&
        other.file?.path == file?.path;
  }

  @override
  int get hashCode => url.hashCode ^ (file?.path.hashCode ?? 0);
}
