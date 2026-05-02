import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/order_history_response.dart';
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
  });

  // ========== Repo ==========
  final HistoryTransactionDataSource historyTransactionRepo;

  // ========== Flags ==========
  @override
  bool get isFromHistory => true;

  // ========== Pagination state ==========
  int _currentPage = 1;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  // ========== Date filter state ==========
  late DateTime _startDate = DateTime.now();
  late DateTime _endDate = DateTime.now();

  // ========== ValueNotifiers ==========
  final ValueNotifier<UiResult<List<OrderHistoryItem>>> _orderHistoryNotifier =
      ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<List<OrderHistoryItem>>> get orderHistoryNotifier =>
      _orderHistoryNotifier;

  final ValueNotifier<DateTimeRange> _dateRangeNotifier = ValueNotifier(
    DateTimeRange(start: DateTime.now(), end: DateTime.now()),
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

    // แสดง loading สำหรับหน้าแรก
    if (_currentPage == 1) {
      _orderHistoryNotifier.value = UiResult.loading();
    }

    final result = await historyTransactionRepo.fetchOrderHistory(
      customerId: customerId,
      page: _currentPage,
      startDate: _startDateParam,
      endDate: _endDateParam,
    );

    if (result.hasError) {
      if (_currentPage == 1) {
        _orderHistoryNotifier.value = UiResult.error(error: result.error);
      }
      return;
    }

    if (result.isEmpty) {
      if (_currentPage == 1) {
        _orderHistoryNotifier.value = UiResult.empty();
      }
      _hasMoreData = false;
      return;
    }

    final newItems = result.data.data ?? [];
    final meta = result.data.meta;
    _hasMoreData = meta?.hasNextPage ?? false;

    if (_currentPage == 1) {
      _orderHistoryNotifier.value = UiResult.success(data: newItems);
    } else {
      final existing = _orderHistoryNotifier.value.data ?? <OrderHistoryItem>[];
      _orderHistoryNotifier.value = UiResult.success(
        data: [...existing, ...newItems],
      );
    }

    if (meta != null) {
      _currentPage = (meta.currentPage ?? _currentPage) + 1;
    }
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
