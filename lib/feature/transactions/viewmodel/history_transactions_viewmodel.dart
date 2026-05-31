import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/browny_shop_orders_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/order_history_response.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';
import 'package:browny_applications_new/feature/transactions/models/history_entry.dart';
import 'package:browny_applications_new/feature/transactions/repository/history_transaction_repo.dart';
import 'package:browny_applications_new/feature/transactions/viewmodel/transactions_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class HistoryTransactionsViewmodel extends MachineTransactionViewmodel {
  HistoryTransactionsViewmodel({
    required super.context,
    required super.couponRepo,
    required super.transactionRepo,
    required super.machineRepo,
    required this.historyTransactionRepo,
    required this.brownyShopRepo,
  });

  // ========== Repo ==========
  final HistoryTransactionDataSource historyTransactionRepo;
  final BrownyShopDataSourceMixin brownyShopRepo;

  // ========== Flags ==========
  @override
  bool get isFromHistory => true;

  // ========== Pagination state ==========
  int _currentPage = 1;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  // ========== Date filter state ==========
  late DateTime _startDate = DateTime.now().subtract(const Duration(days: 6));
  late DateTime _endDate = DateTime.now();

  // ========== Merge state (เครื่อง/คูปอง + Browny Shop) ==========
  /// ออร์เดอร์เครื่อง/คูปอง สะสมข้ามหน้า (pagination)
  List<OrderHistoryItem> _machineItems = [];

  /// คำสั่งซื้อ Browny Shop (ดึงครั้งเดียวต่อช่วงวันที่ — ทุกสถานะ)
  List<BrownyShopOrderItem> _shopItems = [];

  // ========== ValueNotifiers ==========
  final ValueNotifier<UiResult<List<HistoryEntry>>> _orderHistoryNotifier =
      ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<List<HistoryEntry>>> get orderHistoryNotifier =>
      _orderHistoryNotifier;

  final ValueNotifier<DateTimeRange> _dateRangeNotifier = ValueNotifier(
    DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 6)),
      end: DateTime.now(),
    ),
  );
  ValueListenable<DateTimeRange> get dateRangeNotifier => _dateRangeNotifier;

  final ValueNotifier<bool> _isLoadingMoreNotifier = ValueNotifier(false);
  ValueListenable<bool> get isLoadingMoreNotifier => _isLoadingMoreNotifier;

  // ========== Helpers ==========
  String get _startDateParam => DateFormat('yyyy-MM-dd').format(_startDate);
  String get _endDateParam => DateFormat('yyyy-MM-dd').format(_endDate);

  // ========== Dispose ==========
  @override
  void dispose() {
    _orderHistoryNotifier.dispose();
    _dateRangeNotifier.dispose();
    _isLoadingMoreNotifier.dispose();
    super.dispose();
  }

  // ========== Logic ==========

  /// โหลดหน้าแรก (หรือ refresh)
  ///
  /// หน้าแรก/refresh: ดึงคำสั่งซื้อ Browny Shop (ทุกสถานะ ตามช่วงวันที่) ครั้งเดียว
  /// แล้วผสานกับประวัติเครื่อง/คูปอง — หน้าถัดไป (loadMore) ต่อท้ายเฉพาะของเครื่อง
  Future<void> fetchOrderHistory({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
    }

    final customerId = currentCustomerProvider.current.id.orEmpty;
    if (customerId.isEmpty) {
      _orderHistoryNotifier.value = UiResult.empty();
      return;
    }

    // หน้าแรก → loading + reset accumulators + ดึง Browny Shop orders
    if (_currentPage == 1) {
      _orderHistoryNotifier.value = UiResult.loading();
      _machineItems = [];
      await _fetchShopOrders(customerId);
    }

    final result = await historyTransactionRepo.fetchOrderHistory(
      customerId: customerId,
      page: _currentPage,
      startDate: _startDateParam,
      endDate: _endDateParam,
    );

    if (result.hasError) {
      // เครื่อง error — ถ้ามี Browny Shop orders ก็ยังแสดงได้
      if (_currentPage == 1 && _shopItems.isEmpty) {
        _orderHistoryNotifier.value = UiResult.error(error: result.error);
      } else if (_currentPage == 1) {
        _rebuildMerged();
      }
      return;
    }

    if (result.isEmpty) {
      _hasMoreData = false;
      if (_currentPage == 1) _rebuildMerged();
      return;
    }

    final newItems = result.data.data ?? [];
    final meta = result.data.meta;
    _hasMoreData = meta?.hasNextPage ?? false;
    _machineItems.addAll(newItems);
    if (meta != null) {
      _currentPage = (meta.currentPage ?? _currentPage) + 1;
    }
    _rebuildMerged();
  }

  /// ดึงคำสั่งซื้อ Browny Shop ตามช่วงวันที่ที่เลือก (ทุกสถานะ)
  Future<void> _fetchShopOrders(String customerId) async {
    final result = await brownyShopRepo.fetchBrownyShopOrders(
      customerId: customerId,
      startDate: _startDateParam,
      endDate: _endDateParam,
    );
    _shopItems = result.isSuccess ? result.data : <BrownyShopOrderItem>[];
  }

  /// ผสานประวัติเครื่อง/คูปอง + Browny Shop แล้ว sort ตามวันที่ (ใหม่สุดก่อน)
  void _rebuildMerged() {
    final entries = <HistoryEntry>[
      ..._machineItems.map(HistoryEntry.machine),
      ..._shopItems.map(HistoryEntry.shop),
    ];
    entries.sort((a, b) {
      final da = a.sortDate;
      final db = b.sortDate;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });
    _orderHistoryNotifier.value = entries.isEmpty
        ? UiResult.empty()
        : UiResult.success(data: entries);
  }

  /// โหลดหน้าถัดไป (pagination)
  Future<void> loadMore() async {
    if (!_hasMoreData || _isLoadingMore) return;

    _isLoadingMore = true;
    _isLoadingMoreNotifier.value = true;

    await fetchOrderHistory();

    _isLoadingMore = false;
    _isLoadingMoreNotifier.value = false;
  }

  /// อัปเดต date range filter และ reload
  Future<void> onDateRangeSelected(DateTimeRange range) async {
    _startDate = range.start;
    _endDate = range.end;
    _dateRangeNotifier.value = range;
    await fetchOrderHistory(refresh: true);
  }
}
