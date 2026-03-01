import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converter สำหรับแปลง String ISO 8601 DateTime เป็น DateTime object
/// รองรับ format: 2025-05-15T12:33:45 หรือ 2025-05-15T12:33:45.000Z
class DateTimeConverter implements JsonConverter<DateTime?, String?> {
  const DateTimeConverter();

  @override
  DateTime? fromJson(String? json) {
    if (json == null || json.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(json);
    } catch (_) {
      // ถ้า parse ไม่ได้ ให้ลอง parse ด้วย format ข้างล่างต่อก่อน
    }

    try {
      return DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).parse(json);
    } catch (_) {
      // ถ้า parse ไม่ได้ ให้ลอง parse ด้วย format ข้างล่างต่อก่อน
    }

    try {
      return DateFormat(
        'yyyy-MM-dd / HH:mm',
      ).parse(json);
    } catch (e) {
      // ถ้า parse ไม่ได้ ให้ลอง parse ด้วย format ข้างล่างต่อก่อน
    }

    try {
      return DateFormat(
        'dd-MM-yyyy / HH:mm',
      ).parse(json);
    } catch (e) {
      // ถ้า parse ไม่ได้ ให้ return null
      return null;
    }
  }

  @override
  String? toJson(DateTime? object) {
    if (object == null) {
      return null;
    }

    return object.toIso8601String();
  }
}

class DateTimeStartWithDayConverter
    implements JsonConverter<DateTime?, String?> {
  const DateTimeStartWithDayConverter();

  @override
  DateTime? fromJson(String? json) {
    if (json == null || json.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(json);
    } catch (_) {
      // ถ้า parse ไม่ได้ ให้ลอง parse ด้วย format ข้างล่างต่อก่อน
    }

    try {
      return DateFormat(
        'dd-MM-yyyy HH:mm:ss',
      ).parse(json);
    } catch (_) {
      // ถ้า parse ไม่ได้ ให้ลอง parse ด้วย format ข้างล่างต่อก่อน
    }

    try {
      return DateFormat(
        'dd-MM-yyyy / HH:mm',
      ).parse(json);
    } catch (e) {
      // ถ้า parse ไม่ได้ ให้ return null
      return null;
    }
  }

  @override
  String? toJson(DateTime? object) {
    if (object == null) {
      return null;
    }

    return object.toIso8601String();
  }
}

/// Converter สำหรับ DateTime ที่ไม่ nullable
class DateTimeConverterNonNull implements JsonConverter<DateTime, String> {
  const DateTimeConverterNonNull();

  @override
  DateTime fromJson(String json) {
    return DateTime.parse(json);
  }

  @override
  String toJson(DateTime object) {
    return object.toIso8601String();
  }
}
