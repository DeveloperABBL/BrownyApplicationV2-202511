import 'dart:async';

import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/cart_item_add_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/cart_response.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';

/// 1 บรรทัดในตะกร้า — ห่อ [CartItemData] จาก server + state ฝั่ง client
/// ([quantity] ที่แก้ได้ก่อน sync, [selected] สำหรับติ๊กชำระเงิน)
class CartLine {
  CartLine({
    required this.data,
    required this.quantity,
    this.selected = true,
  });

  /// ข้อมูล cart item จาก server (snapshot ล่าสุดที่ fetch มา)
  final CartItemData data;

  /// จำนวนที่ user แก้ไว้ฝั่ง app (ยังไม่ sync)
  int quantity;

  /// ติ๊กเลือกเพื่อชำระเงิน
  bool selected;

  int? get itemId => data.id;

  /// จำนวนล่าสุดฝั่ง server
  int get serverQuantity => data.quantity ?? 0;

  /// จำนวนถูกแก้ไขจากค่า server หรือยัง
  bool get isChanged => quantity != serverQuantity;

  num get unitMoneyPrice => data.unitMoneyPrice ?? 0;
  num get unitCoinPrice => data.unitCoinPrice ?? 0;

  /// ยอดรวมบรรทัด (money) ตามจำนวนปัจจุบันฝั่ง app
  num get lineMoneyTotal => unitMoneyPrice * quantity;
  num get lineCoinTotal => unitCoinPrice * quantity;

  /// ส่วนลด money ต่อบรรทัด (อาศัย product ที่ nest มา — 0 ถ้าไม่มีข้อมูล)
  num get lineMoneyDiscount {
    final original = data.matchedSub?.originalMoneyPrice;
    if (original == null || original <= unitMoneyPrice) return 0;
    return (original - unitMoneyPrice) * quantity;
  }

  /// key เสถียรข้าม sync — id เปลี่ยนหลัง remove+add แต่ product/sub ไม่เปลี่ยน
  String get selectionKey => '${data.productId}:${data.productSubId}';
}

/// ViewModel หน้าตะกร้า Browny Shop ([BrownyShopSelected])
///
/// แนวคิด sync (debounced batch): ทุกการแก้จำนวน (+/−/พิมพ์) แก้ที่ฝั่ง app
/// ก่อน (instant) แล้ว debounce — เมื่อ user หยุดแก้ครบ [_syncDelay] จึง batch
/// sync ขึ้น server: ลบรายการที่เปลี่ยน → addCartItem จำนวนใหม่ → fetchCart ใหม่
///
/// ระหว่าง debounce/sync ปุ่มชำระเงินจะถูก disable ([canCheckout])
class BrownyShopSelectedViewModel extends AppViewModel {
  BrownyShopSelectedViewModel({
    required super.context,
    required BrownyShopDataSourceMixin repo,
  }) : _repo = repo;

  final BrownyShopDataSourceMixin _repo;

  /// ระยะ debounce หลัง event แก้จำนวนล่าสุด
  static const _syncDelay = Duration(milliseconds: 700);

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // ========== State ==========

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Object? _loadError;
  bool get hasError => _loadError != null;

  bool _isSyncing = false;

  /// กำลัง batch sync ขึ้น server (UI ควรขึ้น loading + ปิดการแก้ไข)
  bool get isSyncing => _isSyncing;

  bool _pendingSync = false;

  /// มีการแก้จำนวนที่ยังไม่ sync (debounce timer กำลังนับ)
  bool get hasPendingSync => _pendingSync;

  bool _syncError = false;

  /// true เมื่อ batch sync รอบล่าสุดมีบาง request ล้มเหลว
  /// (View อ่านแล้วเรียก [consumeSyncError] เพื่อเคลียร์)
  bool get syncError => _syncError;
  void consumeSyncError() => _syncError = false;

  List<CartLine> _lines = [];
  List<CartLine> get lines => List.unmodifiable(_lines);

  /// id ของรายการที่ user กดลบ — รอ sync ลบจริงบน server
  final Set<int> _pendingRemovalIds = {};

  /// ตะกร้าว่าง (โหลดเสร็จแล้วแต่ไม่มีรายการ)
  bool get isEmpty => !_isLoading && !hasError && _lines.isEmpty;

  // ========== Derived (สรุปยอดชำระเงิน) ==========

  Iterable<CartLine> get _selectedLines => _lines.where((e) => e.selected);

  int get selectedCount => _selectedLines.length;

  num get selectedMoneyTotal =>
      _selectedLines.fold<num>(0, (s, e) => s + e.lineMoneyTotal);

  num get selectedMoneyDiscount =>
      _selectedLines.fold<num>(0, (s, e) => s + e.lineMoneyDiscount);

  bool get isAllSelected =>
      _lines.isNotEmpty && _lines.every((e) => e.selected);

  /// ปุ่มชำระเงินกดได้เมื่อ: โหลดเสร็จ, ไม่มี event ค้าง/ไม่ได้ sync, มีของติ๊ก
  bool get canCheckout =>
      !_isLoading && !_isSyncing && !_pendingSync && selectedCount > 0;

  // ========== Load ==========

  /// fetch ตะกร้าจาก server แล้ว build [_lines]
  /// [preserveKeys] = set ของ selectionKey ที่ต้องคงสถานะติ๊กเลือกไว้
  Future<bool> _fetchAndBuildLines({Set<String>? preserveKeys}) async {
    final result = await _repo.fetchCart(
      customerId: currentCustomerProvider.current.id.orEmpty,
    );
    if (result.hasError) return true;

    final CartData? data = result.isEmpty ? null : result.data;
    final items = data?.items ?? const <CartItemData>[];
    _lines = items.map((e) {
      final line = CartLine(data: e, quantity: e.quantity ?? 1);
      if (preserveKeys != null) {
        line.selected = preserveKeys.contains(line.selectionKey);
      }
      return line;
    }).toList();
    return false;
  }

  /// โหลดตะกร้าครั้งแรก (เรียกตอนเข้าหน้า)
  Future<void> loadCart() async {
    _isLoading = true;
    _loadError = null;
    notifyListeners();

    final hadError = await _fetchAndBuildLines();

    _isLoading = false;
    _loadError = hadError ? Exception('fetch cart failed') : null;
    notifyListeners();
  }

  // ========== แก้จำนวน (debounced) ==========

  /// ตั้งจำนวนใหม่ของบรรทัด (จำนวน 0 ต้องผ่าน [removeLine] เท่านั้น)
  void setQuantity(CartLine line, int quantity) {
    if (quantity < 1) return;
    if (line.quantity == quantity) return;
    line.quantity = quantity;
    _scheduleSync();
  }

  void increment(CartLine line) => setQuantity(line, line.quantity + 1);

  /// ลดทีละ 1 — ถ้าจำนวน = 1 อยู่แล้ว ไม่ทำอะไร (ให้ View ถามยืนยันลบแทน)
  void decrement(CartLine line) {
    if (line.quantity <= 1) return;
    setQuantity(line, line.quantity - 1);
  }

  /// ลบทั้งบรรทัดออกจากตะกร้า — View ต้องยืนยันด้วย dialog ก่อนเรียก
  void removeLine(CartLine line) {
    final id = line.itemId;
    _lines.remove(line);
    if (id != null) _pendingRemovalIds.add(id);
    _scheduleSync();
  }

  // ========== ติ๊กเลือก ==========

  void toggleSelected(CartLine line) {
    line.selected = !line.selected;
    notifyListeners();
  }

  void setAllSelected(bool selected) {
    for (final line in _lines) {
      line.selected = selected;
    }
    notifyListeners();
  }

  // ========== Debounced batch sync ==========

  void _scheduleSync() {
    _pendingSync = true;
    notifyListeners(); // สะท้อนจำนวนใหม่ + disable ปุ่มชำระเงินทันที
    _debounce?.cancel();
    _debounce = Timer(_syncDelay, _runSync);
  }

  /// sync การเปลี่ยนแปลงทั้งหมดขึ้น server แบบ batch
  ///
  /// ทำตามลำดับ: ลบรายการที่กดลบ → (ลบ+addCartItem) รายการที่จำนวนเปลี่ยน
  /// → fetchCart ใหม่เสมอ เพื่อให้ state ตรงกับ server
  Future<void> _runSync() async {
    _pendingSync = false;
    _isSyncing = true;
    notifyListeners();

    final customerId = currentCustomerProvider.current.id.orEmpty;
    var hadError = false;

    // 1) ลบรายการที่ user กดลบ
    for (final id in _pendingRemovalIds) {
      final r = await _repo.removeCartItem(customerId: customerId, itemId: id);
      if (r.hasError) hadError = true;
    }
    _pendingRemovalIds.clear();

    // 2) รายการที่จำนวนเปลี่ยน → ลบทิ้งก่อน แล้ว addCartItem จำนวนใหม่
    //    (addCartItem จะ merge ถ้า line ยังอยู่ จึงต้องลบก่อนเสมอ)
    final changed = _lines.where((e) => e.isChanged).toList();
    for (final line in changed) {
      final id = line.itemId;
      final productId = line.data.productId;
      final subId = line.data.productSubId;
      if (id == null || productId == null || subId == null) continue;

      final removed = await _repo.removeCartItem(
        customerId: customerId,
        itemId: id,
      );
      if (removed.hasError) {
        hadError = true;
        continue; // ไม่ add ต่อ ถ้าลบไม่สำเร็จ
      }
      final added = await _repo.addCartItem(
        customerId: customerId,
        productId: productId,
        subId: subId,
        quantity: line.quantity,
      );
      if (added.hasError) hadError = true;
    }

    // 3) fetchCart ใหม่เสมอ — ให้ state ตรง server (คง selection ตาม product+sub)
    final selectedKeys = {
      for (final l in _lines.where((e) => e.selected)) l.selectionKey,
    };
    final reloadError = await _fetchAndBuildLines(preserveKeys: selectedKeys);

    _isSyncing = false;
    _syncError = hadError || reloadError;
    notifyListeners();
  }
}
