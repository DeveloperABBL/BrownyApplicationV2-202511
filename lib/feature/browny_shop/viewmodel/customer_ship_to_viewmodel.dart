import 'package:browny_applications_new/core/data/remote/models/request/address_request.dart';
import 'package:browny_applications_new/core/data/remote/models/response/address_response.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';
import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/address_repo.dart';
import 'package:flutter/foundation.dart';

/// ViewModel ของหน้าเลือกที่อยู่จัดส่ง ([CustomerShipToPage])
///
/// page-scoped — คุมรายการที่อยู่ (API), CRUD (เพิ่ม/แก้ไข/ลบ/ตั้งค่าเริ่มต้น)
/// และที่อยู่ที่เลือกอยู่
///
/// expose state เป็น [ValueListenable] ให้ View ฟังผ่าน [ValueListenableBuilder]
/// (ไม่ใช้ notifyListeners/Consumer) — extends [ChangeNotifier] เพื่อให้
/// [ChangeNotifierProvider] สร้าง + dispose ให้
///
/// แยกจาก [BrownyShopSelectedViewModel] เพราะคนละ scope/หน้า
class CustomerShipToViewModel extends ChangeNotifier {
  CustomerShipToViewModel({
    required this.customerId,
    AddressDataSourceMixin? repo,
  }) : _repo = repo ?? AddressRepo();

  /// uuid ของลูกค้า (ส่งมาจากหน้า ผ่าน `CustomerProvider`)
  final String customerId;

  final AddressDataSourceMixin _repo;

  // ========== State (ValueListenable) ==========

  /// รายการที่อยู่ + สถานะโหลด/error
  final ValueNotifier<UiResult<List<AddressData>>> _addressesNotifier =
      ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<List<AddressData>>> get addressesNotifier =>
      _addressesNotifier;

  /// id ของที่อยู่ที่เลือก (ส่งกลับหน้า checkout)
  final ValueNotifier<int?> _selectedIdNotifier = ValueNotifier(null);
  ValueListenable<int?> get selectedIdNotifier => _selectedIdNotifier;

  /// กำลังทำ action (ลบ/ตั้ง default/บันทึก) — UI ควรขึ้น loading overlay
  final ValueNotifier<bool> _busyNotifier = ValueNotifier(false);
  ValueListenable<bool> get busyNotifier => _busyNotifier;

  /// ที่อยู่ที่เลือกอยู่ตอนนี้ (อิงค่าปัจจุบันของ notifier)
  AddressData? get selectedAddress {
    final list = _addressesNotifier.value.data;
    if (list == null) return null;
    for (final a in list) {
      if (a.id == _selectedIdNotifier.value) return a;
    }
    return null;
  }

  @override
  void dispose() {
    _addressesNotifier.dispose();
    _selectedIdNotifier.dispose();
    _busyNotifier.dispose();
    super.dispose();
  }

  // ========== Load ==========

  /// โหลดรายการที่อยู่จาก server
  Future<void> load() async {
    _addressesNotifier.value = UiResult.loading();

    final result = await _repo.fetchAddresses(customerId: customerId);
    if (result.hasError) {
      _addressesNotifier.value = UiResult.error(error: result.error);
      return;
    }
    final list = result.isSuccess ? result.data : <AddressData>[];
    _ensureSelection(list);
    _addressesNotifier.value = UiResult.success(data: list);
  }

  /// ตั้ง selectedId เริ่มต้น = ที่อยู่หลัก (ไม่มีก็ตัวแรก) — คงค่าเดิมถ้ายังมีอยู่
  void _ensureSelection(List<AddressData> list) {
    if (list.isEmpty) {
      _selectedIdNotifier.value = null;
      return;
    }
    if (list.any((a) => a.id == _selectedIdNotifier.value)) return;
    final defaults = list.where((a) => a.isDefaultAddress);
    _selectedIdNotifier.value = defaults.isNotEmpty
        ? defaults.first.id
        : list.first.id;
  }

  /// เลือกที่อยู่ (สำหรับส่งกลับหน้า checkout)
  void select(AddressData address) {
    _selectedIdNotifier.value = address.id;
  }

  // ========== CRUD ==========

  /// ลบที่อยู่ — คืน true ถ้าสำเร็จ
  Future<bool> deleteAddress(int addressId) =>
      _runAction(() => _repo.deleteAddress(addressId: addressId));

  /// ตั้งเป็นที่อยู่เริ่มต้น — คืน true ถ้าสำเร็จ
  Future<bool> setDefault(int addressId) =>
      _runAction(() => _repo.setDefaultAddress(addressId: addressId));

  /// บันทึกที่อยู่ — [addressId] null = เพิ่มใหม่, ไม่ null = แก้ไข
  /// ถ้า [makeDefault] จะตั้งเป็นที่อยู่หลักต่อหลังบันทึก — คืน true ถ้าสำเร็จ
  Future<bool> saveAddress({
    int? addressId,
    required AddressRequest body,
    required bool makeDefault,
  }) async {
    _busyNotifier.value = true;

    final saved = addressId == null
        ? await _repo.createAddress(customerId: customerId, body: body)
        : await _repo.updateAddress(addressId: addressId, body: body);

    final ok = saved.isSuccess;
    if (ok) {
      if (makeDefault) {
        final id = saved.data.id ?? addressId;
        if (id != null) {
          await _repo.setDefaultAddress(addressId: id);
        }
      }
      await _reload();
    }

    _busyNotifier.value = false;
    return ok;
  }

  /// ทำ action แล้ว reload รายการใหม่ให้ตรง server (default/รายการเปลี่ยน)
  Future<bool> _runAction(Future<RepoResult<Object>> Function() action) async {
    _busyNotifier.value = true;
    final result = await action();
    final ok = result.isSuccess;
    if (ok) await _reload();
    _busyNotifier.value = false;
    return ok;
  }

  /// โหลดรายการที่อยู่ใหม่จาก server (คงสถานะ selected)
  Future<void> _reload() async {
    final reload = await _repo.fetchAddresses(customerId: customerId);
    if (!reload.hasError) {
      final list = reload.isSuccess ? reload.data : <AddressData>[];
      _ensureSelection(list);
      _addressesNotifier.value = UiResult.success(data: list);
    }
  }
}
