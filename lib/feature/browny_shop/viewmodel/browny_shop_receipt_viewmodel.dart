import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/browny_shop_receipt_response.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';
import 'package:flutter/foundation.dart';

class BrownyShopReceiptViewModel extends AppViewModel {
  BrownyShopReceiptViewModel({
    required super.context,
    required BrownyShopDataSourceMixin repo,
    required this.orderId,
  }) : _repo = repo {
    fetchReceipt(orderId);
  }

  final BrownyShopDataSourceMixin _repo;

  /// id คำสั่งซื้อ — ใช้ fetch ใบเสร็จ + ส่งต่อหน้าตรวจสอบสถานะ
  final String orderId;

  // ========== Dispose ==========
  @override
  void dispose() {
    _receiptNotifier.dispose();
    _reviewScoreNotifier.dispose();
    super.dispose();
  }

  // ========== ValueNotifier ==========
  final _receiptNotifier = ValueNotifier<UiResult<BrownyShopReceiptResponse>>(
    UiResult.loading(),
  );
  ValueListenable<UiResult<BrownyShopReceiptResponse>> get receiptNotifier =>
      _receiptNotifier;

  final _reviewScoreNotifier = ValueNotifier<int?>(-1);
  ValueListenable<int?> get reviewScoreNotifier => _reviewScoreNotifier;

  /// ยังไม่เคยรีวิว (reviewScore จาก server == null) — แก้คะแนนได้เฉพาะตอนนี้
  /// ล้อ [MachineTransactionViewmodel] (`_isFirstReviewScore`)
  bool _isFirstReviewScore = true;
  bool get isFirstReviewed => _isFirstReviewScore;

  // ========== Actions ==========
  Future<void> fetchReceipt(String orderId) async {
    _receiptNotifier.value = UiResult.loading();
    final result = await _repo.fetchBrownyShopReceipt(orderId: orderId);
    if (result.isSuccess) {
      _receiptNotifier.value = UiResult.success(data: result.data);
      // init คะแนนรีวิวจาก server — reviewScore == null = ยังไม่เคยรีวิว
      final score = result.data.reviewScore;
      _isFirstReviewScore = score == null;
      _reviewScoreNotifier.value = score ?? -1;
    } else if (result.isEmpty) {
      _receiptNotifier.value = UiResult.empty();
    } else {
      _receiptNotifier.value = UiResult.error(error: result.error);
    }
  }

  /// เลือกคะแนนรีวิว — ถ้าเคยรีวิวแล้วจะแก้ไม่ได้ (ล้อ machine)
  /// เก็บคะแนนไว้ก่อน แล้วส่งขึ้น server ตอนออกจากหน้า ([submitReview])
  void onScoreTap(int score) {
    if (!_isFirstReviewScore) return;
    _reviewScoreNotifier.value = score;
  }

  /// ส่งคะแนนรีวิวขึ้น server — เรียกตอนออกจากหน้าใบเสร็จ (ล้อ machine `_popPage`)
  ///
  /// ทำงานเฉพาะเมื่อยังไม่เคยรีวิว + มีการเลือกคะแนนแล้ว (1-5)
  /// สำเร็จแล้วตั้ง [isFirstReviewed] = false กันส่งซ้ำ
  Future<void> submitReview() async {
    if (!_isFirstReviewScore) return;
    final score = _reviewScoreNotifier.value;
    if (score == null || score < 1) return;

    final result = await _repo.submitReview(orderId: orderId, score: score);
    if (result.isSuccess && result.data) {
      _isFirstReviewScore = false;
    }
  }
}
