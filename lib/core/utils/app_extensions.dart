import 'package:browny_applications_new/core/data/remote/models/response/introductions_response.dart';
import 'package:flutter/material.dart';
import 'package:retrofit/dio.dart';

extension AppBuildeContext on BuildContext {
  ThemeData get appTheme => Theme.of(this);
  TextTheme get textTheme => appTheme.textTheme;
}

extension LocalizedContentExtension on ContentLocalizeData {
  /// ดึงข้อความตาม locale ปัจจุบัน
  String getText(BuildContext context) {
    final locale = Localizations.localeOf(context);

    switch (locale.languageCode) {
      case 'th':
        return th ?? en ?? zh ?? '';
      case 'zh':
        return zh ?? en ?? th ?? '';
      case 'en':
      default:
        return en ?? th ?? zh ?? '';
    }
  }

  /// ดึงข้อความตาม locale code โดยตรง (ไม่ต้องใช้ context)
  String getTextByLocale(String localeCode) {
    switch (localeCode.toLowerCase()) {
      case 'th':
        return th ?? en ?? zh ?? '';
      case 'zh':
        return zh ?? en ?? th ?? '';
      case 'en':
      default:
        return en ?? th ?? zh ?? '';
    }
  }
}

extension HttpResponseExtension on HttpResponse {
  bool get isSuccessful =>
      response.statusCode != null &&
      response.statusCode! >= 200 &&
      response.statusCode! < 300;
}

/// Extension ที่จัดการกับ [List] โดยสามารถเรียกผ่านตัวแปร null ได้เลย
/// ใช้เพื่อลดการเขียนโค้ดที่ซ้ำซ่้อนหรือต้องเขียนเยอะๆ ยาวๆ มี logic หรือการ loop เยอะๆ
extension IterableExtensions<E> on List<E>? {
  /// สามารถนำเอาต่อกับ [List] ที่เป็น Nullable แต่ไม่ต้องการให้ตัวแปรนั้นมีค่าเป็น null
  /// ต้องการให้ default ด้วย emptyList
  ///
  ///
  /// Example:
  /// ```dart
  /// List<String> someListNullable;
  /// // ปกติอาจจะใช้
  /// return someListNullable ?? List.empty();
  /// // OR
  /// return someListNullable ?? [];
  ///
  /// // สามารถลดรูปด้านบนได้ด้วยการใช้
  /// return someListNullable.orEmpty;
  /// ```
  List<E> get orEmpty => this ?? List<E>.empty();

  /// ใช้สำหรับ loop [List] เพื่อสร้าง [List] ใหม่แต่ต้องเช็ค Condition ของแต่ละ element
  /// ก่อนที่จะ add element นั้นเข้าไปใน list สามารถใช้ [toListCondition] สำหรับจัดการตรงนั้นได้
  /// โดยจะ call [condition] เพื่อเช็คก่อนว่า element นั้นตรง condition หรือไม่
  /// สุดท้ายจะ return [List] ใหม่ออกไป
  ///
  /// Example:
  /// ```dart
  /// final result = someMethod().toListCondition((element) => element.userName.isNotEmpty);
  ///
  /// List<String> someMethod() => //...
  /// ```
  ///
  /// Param:
  /// - [condition] กำหนด Function ไว้ตรวจสอบ Condition ให้จะมี element ของ [List]
  ///   ออกไปด้วย
  List<E> toListCondition(bool Function(E element) condition) {
    if (orEmpty.isEmpty) {
      return List.empty();
    }
    final result = List<E>.empty();
    for (var element in this!) {
      if (condition(element)) {
        result.add(element);
      }
    }
    return result;
  }

  /// ใช้สำหรับ loop [List] เพื่อสร้าง [List] ใหม่แต่ต้องเช็ค Condition ของแต่ละ element
  /// ก่อนที่จะ add element นั้นเข้าไปใน list สามารถใช้ [toListConditionIndex] สำหรับจัดการตรงนั้นได้
  /// โดยจะ call [condition] เพื่อเช็คก่อนว่า element นั้นตรง condition หรือไม่
  /// สุดท้ายจะ return [List] ใหม่ออกไป
  ///
  /// Example:
  /// ```dart
  /// final result = someMethod().toListConditionIndex((index, element) =>
  ///   element.userName.isNotEmpty
  /// );
  ///
  /// List<String> someMethod() => //...
  /// ```
  ///
  /// Param:
  /// - [condition] กำหนด Function ไว้ตรวจสอบ Condition ให้จะมี index และ element
  ///  ของ [List] ออกไปด้วย
  List<E> toListConditionIndex(bool Function(int index, E element) condition) {
    if (orEmpty.isEmpty) {
      return List.empty();
    }
    final result = List<E>.empty();
    this!.asMap().forEach((index, value) {
      if (condition(index, value)) {
        result.add(value);
      }
    });
    return result;
  }

  /// ใช้สำหรับ loop [List] เพื่อหา element ใน list ตาม [condition] ที่กำหนด
  ///
  /// Example:
  /// ```dart
  /// final result = List.empty();
  /// someMethod().forEachCondition(
  ///   condition: (e) => e.isNotEmpty,
  ///   onFound: (e) => result.add(e),
  /// );
  ///
  /// List<String> someMethod() {
  ///   return // someList
  /// }
  /// ```
  void forEachCondition({
    required bool Function(E element) condition,
    required void Function(E element) onFound,
  }) {
    if (orEmpty.isNotEmpty) {
      for (var element in this!) {
        if (condition(element)) {
          onFound(element);
        }
      }
    }
  }

  /// DONG 24 02 2022
  ///
  /// ใช้สำหรับ ​loop map ที่มี index ออกมาให้ด้วย สำหรับ for loop ที่ต้องการ index ในการ
  /// build element สามารถใช้แทน [List.asMap] เพื่อดึงเอา [MapEntry] เพ่ือดึง [MapEntry.key]
  /// อีกที
  ///
  /// Example:
  /// ```dart
  /// // ปกติจะใช้
  /// final myNewWidgets = myList.asMap().entries.map((entry) {
  ///   int idx = entry.key;
  ///   String val = entry.value;
  ///
  ///   return somethingBuildWidget(idx, val);
  /// }).toList();
  ///
  /// // ใช้ [mapIndex] แทน
  /// final myNewWidgets = myList.mapIndex(
  ///   (index, e) => somethingBuildWidget(index, e),
  /// ).toList();
  /// ```
  Iterable<T> mapIndex<T>(T Function(int index, E value) action) =>
      orEmpty.asMap().entries.map(
        (e) => action(
          e.key,
          e.value,
        ),
      );

  /// DONG 04 07 2022
  /// remove object ที่ duplicate ใน [IterableExtensions] ออก
  ///
  /// Param:
  /// - [target] กำหนด unique key ใน object
  /// - [inplace] กำหนดว่าใช้ instance เดียวกันหรือสร้าง [List] ใหม่
  ///
  /// Example:
  /// ```dart
  /// final models = [Model('1', 'A'), Model('1', 'A'), Model('2', 'B')];
  /// final result = models.removeDupWhere((x) => x.id);
  /// return result; // [Model('1', 'A'), Model('2', 'B')]
  /// ```
  List<E>? removeDupWhere<T>([
    T Function(E element)? target,
    bool inplace = true,
  ]) {
    final ids = <dynamic>{};
    var list = inplace ? this : List<E>.from(orEmpty.toList());
    list?.retainWhere((x) => ids.add(target != null ? target(x) : x as T));
    return list;
  }
}

extension StringExtension on String? {
  String get orEmpty => this ?? '';
}
