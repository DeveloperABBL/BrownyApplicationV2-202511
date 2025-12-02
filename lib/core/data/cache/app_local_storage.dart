import 'package:browny_applications_new/core/data/cache/hive/hive_registrar.g.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

mixin AppLocalStoreMixin {
  /// เรียกใช้เพื่อทำการดึงค่าจาก [sharedPref] ผ่าน [key] ที่ส่งเข้ามา และ return [R]
  /// ออกไปตามที่กำหนดไว้ว่าเป็น return type อะไร
  ///
  /// Example :
  /// ```dart
  /// int age = sharedPref.read<int>(key: 'AGE');
  /// ```
  ///
  /// และสามารถ [defaultValue] ได้หากไม่มี [key] ที่ตรงกัน
  ///
  /// Example :
  /// ```dart
  /// int age = sharedPref.readSecure<int>(key: 'AGE', defaultValue: 15);
  /// ```
  R? read<R>(String key, {R? defaultValue});

  /// เรียกใช้เพื่อทำเขียนค่าลงที่ [sharedPref] ผ่าน [key] ที่ส่งเข้ามา โดยจะกำหนด type
  /// ของ data ที่ต้องการจะ write ด้วย [W]
  ///
  /// **NOTE:** [W] ขึ้นอยู่กับ [sharedPref] ที่ใช้งาน ว่ารองรับการ type อะไรได้บ้่าง
  ///
  /// Example :
  /// ```dart
  /// sharedPref.write<String>('nameKey', 'myName');
  /// ```
  void write<W>({
    required String key,
    required W value,
  });

  /// เรียกใช้เพื่อทำการลบ [key] และ value ที่อยู่ใน [sharedPref] ออก ผ่าน [key] ที่ส่งเข้ามา
  ///
  /// Example :
  /// ```dart
  /// sharedPref.delete('nameKey');
  /// ```
  void delete(String key);

  /// เรียกใช้เพื่อทำการลบ key และ value ที่อยู่ใน [sharedPref] ออกทั้งหมด
  ///
  /// **NOTE:** ขึ้นอยู่กับ [sharedPref] ที่ใช้งาน ว่ารองรับ function นี่หรือไม่
  ///
  /// Example :
  /// ```dart
  /// sharedPref.deleteAll();
  /// ```
  void deleteAll();
}

class AppLocalStorage with AppLocalStoreMixin {
  AppLocalStorage._();
  static final _boxKey = 'browny_preferences';
  static final _instance = AppLocalStorage._();

  factory AppLocalStorage.instance() => _instance;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);
    Hive.registerAdapters();
    await Hive.openBox(_boxKey);
  }

  @override
  void delete(String key) {
    Hive.box(_boxKey).delete(key);
  }

  @override
  void deleteAll() {
    Hive.box(_boxKey).deleteFromDisk();
  }

  @override
  R? read<R>(String key, {R? defaultValue}) {
    try {
      return Hive.box(_boxKey).get(key, defaultValue: defaultValue) as R;
    } catch (e) {
      if (defaultValue != null) return defaultValue as R;
      return null;
    }
  }

  @override
  void write<W>({required String key, required W value}) {
    Hive.box(_boxKey).put(key, value);
  }
}
