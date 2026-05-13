import 'package:browny_applications_new/core/data/remote/models/response/customer_profile_response.dart';
import 'package:browny_applications_new/feature/browny_shop/models/product_data_selected.dart';
import 'package:browny_applications_new/feature/transactions/models/machine_program_model.dart';
import 'package:browny_applications_new/models/user_model.dart';
import 'package:flutter/material.dart';

class CustomerProvider extends ChangeNotifier {
  UserModel _current = UserModel.guest();
  UserModel get current => _current;

  /// ใช้สำหรับเก็บ Transactions ของ User เอาไว้ เช่น การสั่งเครื่องซัก/อบ
  /// อนาคตรองรับ BownyShop
  UserTransactionsHolder _transactionsHolder = UserTransactionsHolder(
    machineUsing: {},
  );

  /// getter ไว้สำหรับตรวจสอบ Transactions ที่ User มี
  UserTransactionsHolder get userTransactions => _transactionsHolder;

  /// setter สำหรับ Update Transaction ใหม่ หรือ ของเดิมที่มีอยู่
  set updateTransactions(UserTransactionsHolder newTransaction) {
    _transactionsHolder = newTransaction;
  }

  /// เช็ค Transaction ทั้งหมดของ User ที่มี
  bool get hasTransaction => userTransactions.machineUsing.isNotEmpty;

  /// เช็ค Transaction การใช้งานเครื่องซัก/อบ ที่มี
  bool get hasMachineUsing => userTransactions.machineUsing.isNotEmpty;

  // ========== Browny Shop Cart (POC — in-memory) ==========

  /// รายการสินค้าที่ user เพิ่มเข้าตะกร้า (POC: in-memory, ยังไม่ sync API)
  final List<ProductDataSelected> _shopCartItems = [];

  /// อ่านรายการในตะกร้า (unmodifiable view)
  List<ProductDataSelected> get shopCartItems =>
      List.unmodifiable(_shopCartItems);

  /// จำนวนบรรทัดในตะกร้า (= จำนวน product_sub ที่ต่างกัน)
  int get shopCartLineCount => _shopCartItems.length;

  /// จำนวนรายการที่ติ๊กเลือกเอาไว้
  int get shopCartSelectedCount =>
      _shopCartItems.where((e) => e.selected).length;

  /// ยอดรวม money ของรายการที่ติ๊กเลือก
  num get shopCartSelectedMoneyTotal => _shopCartItems
      .where((e) => e.selected)
      .fold<num>(0, (sum, e) => sum + e.lineMoneyTotal);

  /// ยอดส่วนลด money ของรายการที่ติ๊กเลือก
  num get shopCartSelectedMoneyDiscount => _shopCartItems
      .where((e) => e.selected)
      .fold<num>(0, (sum, e) => sum + e.lineMoneyDiscount);

  /// หา index จาก (productId, selectedSubId) — -1 ถ้าไม่พบ
  int _findShopCartIndex(String productId, int selectedSubId) {
    return _shopCartItems.indexWhere(
      (e) => e.id == productId && e.selectedSubId == selectedSubId,
    );
  }

  /// เพิ่มรายการสินค้าเข้าตะกร้า — ถ้ามี (productId, selectedSubId) แล้ว
  /// จะเพิ่ม quantity แทน
  void addShopCartItem(ProductDataSelected item) {
    if (item.id == null) return;
    final i = _findShopCartIndex(item.id!, item.selectedSubId);
    if (i >= 0) {
      _shopCartItems[i].quantity += item.quantity;
    } else {
      _shopCartItems.add(item);
    }
    notifyListeners();
  }

  /// อัพเดท quantity ของรายการในตะกร้า (clamp ≥1)
  void updateShopCartItemQuantity(
    String productId,
    int selectedSubId,
    int quantity,
  ) {
    final i = _findShopCartIndex(productId, selectedSubId);
    if (i < 0) return;
    _shopCartItems[i].quantity = quantity < 1 ? 1 : quantity;
    notifyListeners();
  }

  /// toggle ติ๊กเลือก/ไม่เลือก รายการ
  void toggleShopCartItemSelected(String productId, int selectedSubId) {
    final i = _findShopCartIndex(productId, selectedSubId);
    if (i < 0) return;
    _shopCartItems[i].selected = !_shopCartItems[i].selected;
    notifyListeners();
  }

  /// true เมื่อรายการในตะกร้าทั้งหมดถูกติ๊กเลือก (สำหรับช่อง "ทั้งหมด")
  bool get shopCartIsAllSelected =>
      _shopCartItems.isNotEmpty && _shopCartItems.every((e) => e.selected);

  /// เซ็ตติ๊กเลือก/ไม่เลือก ทุกรายการในตะกร้าพร้อมกัน
  void setShopCartAllSelected(bool selected) {
    if (_shopCartItems.isEmpty) return;
    var changed = false;
    for (final item in _shopCartItems) {
      if (item.selected != selected) {
        item.selected = selected;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  /// ลบรายการออกจากตะกร้า
  void removeShopCartItem(String productId, int selectedSubId) {
    _shopCartItems.removeWhere(
      (e) => e.id == productId && e.selectedSubId == selectedSubId,
    );
    notifyListeners();
  }

  /// เคลียร์ตะกร้าทั้งหมด
  void clearShopCart() {
    if (_shopCartItems.isEmpty) return;
    _shopCartItems.clear();
    notifyListeners();
  }

  set newUser(UserModel data) {
    _current = data;
    notifyListeners();
  }

  void updateCreditAndCoinBalance(CustomerProfileData data) {
    newUser = current.copyWith(
      creditBalance: data.creditBalance,
      brownyCoin: data.brownyCoin,
      currentCoin: data.currentCoin,
      coinValue: data.coinValue,
    );
  }

  UserModel logout() {
    _current = UserModel.guest();
    notifyListeners();
    return _current;
  }
}

class UserTransactionsHolder {
  UserTransactionsHolder({
    required this.machineUsing,
  });

  final Map<String, MachineProgramModel> machineUsing;

  void addNewMachineTracsactions(MachineProgramModel machine) {
    machineUsing.putIfAbsent(machine.machineId.toString(), () => machine);
    // machineUsing.clear();
  }

  UserTransactionsHolder copyWith({
    UserTransactionsHolder? newInstance,
  }) {
    return UserTransactionsHolder(
      machineUsing: newInstance?.machineUsing ?? machineUsing,
    );
  }
}
