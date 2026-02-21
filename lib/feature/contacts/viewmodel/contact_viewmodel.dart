import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/contacts/models/contact_model.dart';
import 'package:browny_applications_new/feature/contacts/repository/contact_repo.dart';
import 'package:flutter/foundation.dart';

class ContactViewmodel extends AppViewModel {
  ContactViewmodel({
    required super.context,
    required this.repo,
  });

  final ContactDataSourceMixin repo;

  // ========== Dispose ==========
  @override
  void dispose() {
    _contactNotifier.dispose();
    super.dispose();
  }

  // ========== ValueNotifier ==========
  final ValueNotifier<UiResult<List<ContactModel>>> _contactNotifier =
      ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<List<ContactModel>>> get contactNotifier =>
      _contactNotifier;

  // ========== Logic ==========
  /// API fetch ข้อมูล Contact (social media links)
  Future<void> fetchContact([
    List<ContactProvider> providers = ContactProvider.values,
  ]) async {
    _contactNotifier.value = UiResult.loading();

    final result = await repo.fetchContact();

    if (result.hasError) {
      _contactNotifier.value = UiResult.error(error: result.error);
      return;
    }

    if (result.isEmpty) {
      _contactNotifier.value = UiResult.empty();
      return;
    }

    // Mapping ContactResponse to List<ContactModel>
    final contactResponse = result.data;
    final contactList = <ContactModel>[];

    // ดึงทุก field จาก ContactResponse และเช็คว่าไม่เป็น null หรือว่าง
    final fields = contactResponse.toJson();

    fields.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        try {
          // หา ContactProvider ที่ name ตรงกับ key จาก JSON
          final provider = ContactProvider.values.firstWhere(
            (p) => p.equalsName(key),
          );

          // เช็คว่า provider อยู่ใน filter list หรือไม่
          if (!providers.contains(provider)) {
            return; // skip ถ้าไม่ได้อยู่ใน filter
          }

          final data = value.toString();
          final type = _getContactType(data);

          contactList.add(
            ContactModel(
              data: data,
              type: type,
              provider: provider,
            ),
          );
        } catch (e) {
          // ไม่เจอ provider ที่ตรงกับ key, skip field นี้
        }
      }
    });

    if (contactList.isEmpty) {
      _contactNotifier.value = UiResult.empty();
      return;
    }
    // Sorting เอา Browny Care Contact ขึ้นก่อน
    contactList.sort((l, r) {
      if (l.provider == ContactProvider.brownyCareContact) return 0;
      return 1;
    });

    _contactNotifier.value = UiResult.success(data: contactList);
  }

  /// เช็ค format ของข้อมูลว่าเป็น URL link หรือ phone number
  ContactType _getContactType(String data) {
    // เช็คว่าเป็น URL (http://, https://)
    if (data.startsWith('http://') || data.startsWith('https://')) {
      return ContactType.link;
    }

    // เช็คว่าเป็น phone number (รองรับตัวเลข, ตัวอักษร O/o, +, -, (), space)
    // รองรับกรณีที่พิมพ์ O แทน 0 เช่น O99-635-1211
    final phoneRegex = RegExp(r'^[A-Za-z0-9\s\+\-\(\)]+$');
    if (phoneRegex.hasMatch(data)) {
      return ContactType.call;
    }

    // Default เป็น link
    return ContactType.link;
  }
}
