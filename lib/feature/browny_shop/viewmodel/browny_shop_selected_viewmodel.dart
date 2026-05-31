import 'dart:async';

import 'package:browny_applications_new/core/core_index.dart';
import 'package:flutter/foundation.dart';
import 'package:browny_applications_new/core/data/remote/models/request/cart_summary_request.dart';
import 'package:browny_applications_new/core/data/remote/models/response/cart_item_add_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/cart_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/address_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/checkout_draft_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/payment_status_check_response.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/address_repo.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';
import 'package:browny_applications_new/feature/transactions/models/coupon_detail_model.dart';
import 'package:browny_applications_new/feature/transactions/models/customer_coupon_model.dart';
import 'package:browny_applications_new/feature/transactions/repository/coupon_voucher_repo.dart';
import 'package:browny_applications_new/feature/transactions/repository/machine_transaction_repo.dart';
import 'package:browny_applications_new/feature/transactions/repository/transaction_repo.dart';
import 'package:browny_applications_new/feature/transactions/screens/coupons_evoucher/coupon_voucher_page.dart';
import 'package:browny_applications_new/feature/transactions/viewmodel/transactions_viewmodel.dart';

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

  /// สต็อกคงเหลือของ sub นี้ (null = ไม่จำกัด/ไม่มีข้อมูล)
  int? get stock {
    final raw = data.matchedSub?.stock;
    if (raw == null || raw.isEmpty) return null;
    return num.tryParse(raw)?.toInt();
  }

  /// สินค้าหมดสต็อก — เลือกชำระเงินไม่ได้ (stock = 0)
  bool get isOutOfStock => stock != null && stock! <= 0;

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

/// ViewModel ของ Browny Shop ตะกร้า + checkout
///
/// ใช้ร่วมกันทั้ง [BrownyShopCartPage] และ [BrownyShopSelected] (checkout) —
/// flow ต้องผ่านหน้าตะกร้าก่อนเสมอ จึงสร้าง VM ที่หน้าตะกร้าแล้วส่ง instance
/// ต่อให้หน้า checkout
///
/// extends [TransactionsViewmodel] เพื่อ reuse ระบบ payment method / order ที่
/// integrate API ไว้แล้ว — ตั้ง [couponState] = brownyShop ให้ logic ฝั่ง
/// payment เลือก path ของ shop (ดู fetchPaymentMethod/onPaymentChanged)
///
/// แนวคิด sync ตะกร้า (debounced batch): ทุกการแก้จำนวน (+/−/พิมพ์) แก้ที่
/// ฝั่ง app ก่อน (instant) แล้ว debounce — เมื่อ user หยุดแก้ครบ [_syncDelay]
/// จึง batch sync ขึ้น server: ลบรายการที่เปลี่ยน → addCartItem จำนวนใหม่ →
/// fetchCart ใหม่
class BrownyShopSelectedViewModel extends TransactionsViewmodel {
  BrownyShopSelectedViewModel({
    required super.context,
    required BrownyShopDataSourceMixin repo,
    CustomerCouponModel? buyNowCoupon,
  }) : _repo = repo,
       super(
         couponRepo: CouponVoucherRepo(),
         transactionRepo: TransactionRepo(),
         machineRepo: MachineRepo(),
       ) {
    // บอก logic ฝั่ง payment ว่าอยู่ใน context ของ Browny Shop
    couponState = CouponVoucherState.brownyShop;
    // auto-apply คูปองที่เลือกมาจากหน้ารายละเอียดสินค้า (flow "ซื้อเลย")
    if (buyNowCoupon != null) {
      _selectedCouponNotifier.value = buyNowCoupon;
    }
  }

  final BrownyShopDataSourceMixin _repo;

  /// ระยะ debounce หลัง event แก้จำนวนล่าสุด
  static const _syncDelay = Duration(milliseconds: 700);

  Timer? _debounce;

  /// คูปอง Browny Shop ที่เลือกใช้ (auto-apply จาก buy-now หรือเลือกในหน้านี้)
  final ValueNotifier<CustomerCouponModel?> _selectedCouponNotifier =
      ValueNotifier(null);
  ValueListenable<CustomerCouponModel?> get selectedCouponNotifier =>
      _selectedCouponNotifier;

  /// ตั้ง/ล้างคูปอง — อัปเดต notifier (สำหรับ _CouponCard) + re-fetch summary
  /// (POST /cart/summary ด้วย coupon_customer_id ใหม่)
  void setSelectedCoupon(CustomerCouponModel? coupon) {
    _selectedCouponNotifier.value = coupon;
    notifyListeners();
    _scheduleSummaryFetch();
  }

  // ========== Cart summary (POST /browny-shop/cart/summary) ==========

  Timer? _summaryDebounce;

  /// summary จาก server — แหล่งความจริงของยอด/ส่วนลด/ค่าจัดส่งในหน้า checkout
  final ValueNotifier<UiResult<CheckoutSummaryData>> _summaryNotifier =
      ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<CheckoutSummaryData>> get summaryNotifier =>
      _summaryNotifier;

  /// error message เมื่อคูปองที่เลือกใช้ไม่ได้ (HTTP 422 จาก cart/summary)
  /// — null = ใช้ได้ / ไม่มีคูปอง
  String? _summaryCouponError;
  String? get summaryCouponError => _summaryCouponError;

  /// items[] ของรายการที่ติ๊กเลือก สำหรับส่งเข้า cart/summary + confirm
  List<CartSummaryItemRequest> _selectedSummaryItems() {
    final items = <CartSummaryItemRequest>[];
    for (final line in _selectedLines) {
      final subId = line.data.productSubId;
      if (subId == null) continue;
      items.add(
        CartSummaryItemRequest(productSubId: subId, quantity: line.quantity),
      );
    }
    return items;
  }

  /// debounce การยิง cart/summary (รวม event coupon/qty/payment ที่ติดกัน)
  ///
  /// ตั้ง summary เป็น loading ทันที → ปุ่มชำระเงิน disable ระหว่างรอ แล้ว
  /// re-enable ครั้งเดียวเมื่อ cart/summary คืนผลสำเร็จ (กันปุ่มกระพริบ)
  void _scheduleSummaryFetch() {
    _markSummaryLoading();
    _summaryDebounce?.cancel();
    _summaryDebounce = Timer(
      const Duration(milliseconds: 350),
      fetchCartSummary,
    );
  }

  /// ตั้ง summary เป็น loading (ถ้ายังไม่ใช่) — ปุ่มชำระเงินจะ disable ทันที
  void _markSummaryLoading() {
    if (!_summaryNotifier.value.isLoading) {
      _summaryNotifier.value = UiResult.loading();
      notifyListeners();
    }
  }

  /// POST /browny-shop/cart/summary — คำนวณยอดจาก items ที่เลือก + คูปอง + วิธีชำระ
  /// คูปองใช้ไม่ได้ (422) → เก็บข้อความไว้ + ยิงซ้ำแบบไม่ใส่คูปอง เพื่อให้ยังเห็นยอด
  Future<void> fetchCartSummary() async {
    final items = _selectedSummaryItems();
    if (items.isEmpty) {
      _summaryCouponError = null;
      _summaryNotifier.value = UiResult.empty();
      notifyListeners();
      return;
    }

    if (!_summaryNotifier.value.isLoading) {
      _summaryNotifier.value = UiResult.loading();
      notifyListeners();
    }

    final customerId = currentCustomerProvider.current.id.orEmpty;
    final couponId = _selectedCouponNotifier.value?.customerCouponId;
    final method = paymentSelected?.method;

    final result = await _repo.fetchCartSummary(
      customerId: customerId,
      items: items,
      couponCustomerId: couponId,
      paymentMethod: method,
    );

    if (result.isSuccess) {
      _summaryCouponError = null;
      _summaryNotifier.value = UiResult.success(data: result.data);
      notifyListeners();
      return;
    }

    // คูปองใช้ไม่ได้ → เก็บ error แล้วยิงซ้ำแบบไม่ใส่คูปอง (ให้ยังเห็นยอดสินค้า)
    final err = result.error;
    if (err is BrownyShopApiException && couponId != null) {
      _summaryCouponError = err.message;
      final retry = await _repo.fetchCartSummary(
        customerId: customerId,
        items: items,
        couponCustomerId: null,
        paymentMethod: method,
      );
      if (retry.isSuccess) {
        _summaryNotifier.value = UiResult.success(data: retry.data);
      } else {
        _summaryNotifier.value = UiResult.error(error: retry.error);
      }
      notifyListeners();
      return;
    }

    _summaryCouponError = null;
    _summaryNotifier.value = UiResult.error(error: result.error);
    notifyListeners();
  }

  // ========== Confirm / payment status ==========

  /// ตรวจยอดคงเหลือก่อนยืนยัน (เฉพาะ TP+ Wallet / Browny Coin) — ล้อ
  /// [MachineTransactionViewmodel.verifyOrder] โดย fetchCustomerCredit ก่อน
  ///
  /// คืน:
  /// - success(true) = ยอดพอ หรือไม่ใช่ wallet/coin (qr/wechat ไม่ต้องเช็ค)
  /// - empty()       = ยอดไม่พอ (wallet/coin)
  /// - error         = ดึงยอดไม่สำเร็จ
  Future<UiResult<bool>> verifyBalance() async {
    if(kDebugMode) {
      return UiResult.success(data: true);
    }
    final payment = paymentSelected;
    if (payment == null) return UiResult.success(data: true);
    // qr / wechat ไม่ต้องเช็คยอดคงเหลือ
    if (!(payment.isTpWallet || payment.isCoin)) {
      return UiResult.success(data: true);
    }

    // refresh ยอดเงิน/coin ล่าสุดเข้า provider
    final credit = await fetchCustomerCredit();
    if (!credit.isSuccess) return UiResult.error(error: credit.error);

    final summary = _summaryNotifier.value.data;
    final user = currentCustomerProvider.current;

    if (payment.isTpWallet) {
      final balance =
          double.tryParse((user.creditBalance ?? '0').replaceAll(',', '')) ?? 0;
      final need = (summary?.finalPrice ?? 0).toDouble();
      return balance >= need ? UiResult.success(data: true) : UiResult.empty();
    }

    // coin: เทียบจำนวน Browny Coin ที่มี (brownyCoin) กับ coin_amount_required
    final balance =
        double.tryParse((user.brownyCoin ?? '0').replaceAll(',', '')) ?? 0;
    final need = (summary?.coinAmountRequired ?? 0).toDouble();
    return balance >= need ? UiResult.success(data: true) : UiResult.empty();
  }

  /// POST /browny-shop/checkout/confirm — ยืนยันสั่งซื้อ + เริ่ม process ชำระเงิน
  Future<UiResult<CheckoutDraftData>> confirmCheckout() async {
    final result = await _repo.confirmCheckout(
      customerId: currentCustomerProvider.current.id.orEmpty,
      customerAddressId: _shippingAddressNotifier.value?.id ?? 0,
      paymentMethod: paymentSelected?.method ?? '',
      couponCustomerId: _selectedCouponNotifier.value?.customerCouponId,
      items: _selectedSummaryItems(),
    );
    if (result.isSuccess) return UiResult.success(data: result.data);
    return UiResult.error(error: result.error);
  }

  /// GET /payment/browny-shop/status/{paymentRef} — polling สถานะการชำระเงิน
  Future<UiResult<PaymentStatusCheckResponse>> checkBrownyShopPaymentStatus(
    String paymentRef,
  ) async {
    final result = await _repo.checkPaymentStatus(paymentRef: paymentRef);
    if (result.isSuccess) return UiResult.success(data: result.data);
    return UiResult.error(error: result.error);
  }

  /// re-fetch summary เมื่อเปลี่ยนวิธีชำระเงิน (override จาก base)
  @override
  void onPaymentChanged(PaymentMethodModel payment, {bool fetchAll = false}) {
    super.onPaymentChanged(payment, fetchAll: fetchAll);
    _scheduleSummaryFetch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _summaryDebounce?.cancel();
    _shippingAddressNotifier.dispose();
    _selectedCouponNotifier.dispose();
    _summaryNotifier.dispose();
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

  /// ข้อความ error เฉพาะเจาะจง (เช่น "สต็อกไม่พอ" จาก HTTP 422)
  /// — null = error ทั่วไป (View ใช้ wording กลางแทน)
  String? _syncErrorMessage;
  String? get syncErrorMessage => _syncErrorMessage;

  void consumeSyncError() {
    _syncError = false;
    _syncErrorMessage = null;
  }

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

  /// ราคาสินค้ารวมก่อนหักส่วนลด (gross) = ยอดสุทธิ + ส่วนลดสินค้า
  num get selectedMoneySubtotal => selectedMoneyTotal + selectedMoneyDiscount;

  /// มีสินค้าที่ติ๊กเลือกเป็น Flash Sale หรือไม่ (ใช้ตรวจ allow_with_promotion)
  bool get _selectedHasFlashSale =>
      _selectedLines.any((e) => e.data.isFlashSale == true);

  /// มีสินค้าที่ติ๊กเลือกมีส่วนลดสินค้าหรือไม่ (ใช้ตรวจ allow_with_product_discount)
  bool get _selectedHasProductDiscount =>
      _selectedLines.any((e) => e.lineMoneyDiscount > 0);

  /// ส่วนลดจากคูปองที่เลือก — 0 ถ้าไม่มีคูปอง หรือคูปองใช้กับยอดปัจจุบันไม่ได้
  /// (คำนวณ client-side จาก field ของคูปอง — re-evaluate อัตโนมัติเมื่อแก้จำนวน)
  num get selectedMoneyCouponDiscount {
    final coupon = _selectedCouponNotifier.value;
    if (coupon == null) return 0;
    final usable = coupon.isUsableForBrownyShop(
      orderAmount: selectedMoneyTotal,
      hasFlashSale: _selectedHasFlashSale,
      hasProductDiscount: _selectedHasProductDiscount,
    );
    if (!usable) return 0;
    return coupon.computeBrownyShopDiscount(selectedMoneyTotal);
  }

  /// ส่วนลดรวมทั้งหมด (ส่วนลดสินค้า + คูปอง) สำหรับแสดงที่แถบล่าง
  num get selectedTotalDiscount =>
      selectedMoneyDiscount + selectedMoneyCouponDiscount;

  /// error message ถ้าคูปองที่เลือกใช้กับยอดปัจจุบันไม่ได้ (null = ใช้ได้/ไม่มีคูปอง)
  String? validSelectedCouponMessage(BuildContext context) {
    return _selectedCouponNotifier.value?.validBrownyShopCouponMessage(
      context,
      orderAmount: selectedMoneyTotal,
      hasFlashSale: _selectedHasFlashSale,
      hasProductDiscount: _selectedHasProductDiscount,
    );
  }

  /// ยอดที่ต้องชำระจริง = ราคาสินค้า − ส่วนลดคูปอง
  /// TODO(api): ยังไม่รวมค่าจัดส่ง — รอ shop order/draft API
  num get selectedMoneyGrandTotal =>
      selectedMoneyTotal - selectedMoneyCouponDiscount;

  /// "เลือกทั้งหมด" พิจารณาเฉพาะสินค้าที่เลือกได้ (ไม่นับที่หมดสต็อก)
  bool get isAllSelected {
    final selectable = _lines.where((e) => !e.isOutOfStock);
    return selectable.isNotEmpty && selectable.every((e) => e.selected);
  }

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
      // สินค้าหมดสต็อก → บังคับไม่เลือก (ชำระเงินไม่ได้)
      if (line.isOutOfStock) line.selected = false;
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
    // สินค้าหมดสต็อกเลือกไม่ได้
    if (line.isOutOfStock) return;
    line.selected = !line.selected;
    notifyListeners();
  }

  void setAllSelected(bool selected) {
    for (final line in _lines) {
      // ข้ามสินค้าหมดสต็อก (เลือกไม่ได้)
      if (line.isOutOfStock) continue;
      line.selected = selected;
    }
    notifyListeners();
  }

  // ========== Debounced batch sync ==========

  void _scheduleSync() {
    _pendingSync = true;
    // summary เก่าใช้ไม่ได้แล้ว (จำนวนกำลังเปลี่ยน) → disable ปุ่มชำระเงินทันที
    // จนกว่าจะ POST /cart/summary ใหม่เสร็จ (กันกดยอดเก่า + กันปุ่มกระพริบ)
    _markSummaryLoading();
    notifyListeners(); // สะท้อนจำนวนใหม่ + disable ปุ่มชำระเงินทันที
    _debounce?.cancel();
    _debounce = Timer(_syncDelay, _runSync);
  }

  /// sync การเปลี่ยนแปลงทั้งหมดขึ้น server แบบ batch
  ///
  /// ทำตามลำดับ: ลบรายการที่กดลบ → PATCH จำนวนสุดท้ายของรายการที่เปลี่ยน
  /// → fetchCart ใหม่เสมอ เพื่อให้ state ตรงกับ server
  Future<void> _runSync() async {
    _pendingSync = false;
    _isSyncing = true;
    notifyListeners();

    final customerId = currentCustomerProvider.current.id.orEmpty;
    var hadError = false;
    String? stockMessage;

    // 1) ลบรายการที่ user กดลบ
    for (final id in _pendingRemovalIds) {
      final r = await _repo.removeCartItem(customerId: customerId, itemId: id);
      if (r.hasError) hadError = true;
    }
    _pendingRemovalIds.clear();

    // 2) รายการที่จำนวนเปลี่ยน → PATCH ส่งจำนวนสุดท้ายไปตั้งค่าโดยตรง
    final changed = _lines.where((e) => e.isChanged).toList();
    for (final line in changed) {
      final id = line.itemId;
      if (id == null) continue;
      final result = await _repo.updateCartItemQuantity(
        customerId: customerId,
        itemId: id,
        quantity: line.quantity,
      );
      if (result.hasError) {
        hadError = true;
        // เก็บข้อความ "สต็อกไม่พอ" (HTTP 422) ไว้แจ้ง user
        final err = result.error;
        if (err is CartStockException) stockMessage = err.message;
      }
    }

    // 3) fetchCart ใหม่เสมอ — ให้ state ตรง server (คง selection ตาม product+sub)
    final selectedKeys = {
      for (final l in _lines.where((e) => e.selected)) l.selectionKey,
    };
    final reloadError = await _fetchAndBuildLines(preserveKeys: selectedKeys);

    _isSyncing = false;
    _syncError = hadError || reloadError;
    _syncErrorMessage = stockMessage;
    notifyListeners();

    // ปรับจำนวน (+/−) เสร็จ → คำนวณ summary ใหม่จาก items ล่าสุด
    // (เฉพาะเมื่อ sync ตะกร้าสำเร็จ — items ตรงกับ server แล้ว)
    if (!reloadError) {
      _scheduleSummaryFetch();
    }
  }

  // ========== ที่อยู่จัดส่ง ==========

  final AddressRepo _addressRepo = AddressRepo();

  /// ที่อยู่จัดส่งที่เลือกสำหรับออร์เดอร์นี้ (null = ยังไม่เลือก)
  final ValueNotifier<AddressData?> _shippingAddressNotifier = ValueNotifier(
    null,
  );
  ValueListenable<AddressData?> get shippingAddressNotifier =>
      _shippingAddressNotifier;

  /// ตั้งที่อยู่จัดส่ง — เรียกหลังเลือกจาก [CustomerShipToPage]
  void setShippingAddress(AddressData? address) {
    _shippingAddressNotifier.value = address;
  }

  /// โหลดที่อยู่หลักมาแสดงเป็นค่าเริ่มต้นในหน้า checkout
  /// (ข้ามถ้า user เลือกที่อยู่ไว้แล้ว)
  Future<void> loadDefaultShippingAddress() async {
    if (_shippingAddressNotifier.value != null) return;
    final result = await _addressRepo.fetchAddresses(
      customerId: currentCustomerProvider.current.id.orEmpty,
    );
    if (!result.isSuccess) return;
    final list = result.data;
    if (list.isEmpty) return;
    final defaults = list.where((a) => a.isDefaultAddress);
    _shippingAddressNotifier.value = defaults.isNotEmpty
        ? defaults.first
        : list.first;
  }
}
