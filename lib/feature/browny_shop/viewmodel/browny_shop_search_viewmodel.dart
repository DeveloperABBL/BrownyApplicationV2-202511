import 'dart:async';

import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/products_response.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';
import 'package:browny_applications_new/feature/browny_shop/viewmodel/browny_shop_favorite_mixin.dart';
import 'package:flutter/foundation.dart';

/// ViewModel หน้าค้นหาสินค้า Browny Shop ([BrownyShopSearchPage])
///
/// แนวคิด performance: โหลดสินค้าทั้งหมดไว้ครั้งเดียวตอนเข้าหน้า แล้ว
/// - ขณะ user พิมพ์ → ค้นใน client ก่อน (instant ไม่ยิง server)
/// - ถ้าค้นใน client ไม่เจอเลย → debounce แล้วค่อยยิง API (search query)
class BrownyShopSearchViewModel extends AppViewModel
    with BrownyShopFavoriteMixin {
  BrownyShopSearchViewModel({
    required super.context,
    required BrownyShopDataSourceMixin repo,
  }) : _repo = repo;

  final BrownyShopDataSourceMixin _repo;

  @override
  BrownyShopDataSourceMixin get favoriteRepo => _repo;

  /// fav toggle ทำกับ list ผลลัพธ์ที่กำลังแสดง
  @override
  ValueNotifier<UiResult<List<ProductData>>> get favoriteProductsNotifier =>
      _resultsNotifier;

  /// debounce การยิง API (เฉพาะตอนค้นใน client ไม่เจอ)
  static const _debounceDelay = Duration(milliseconds: 400);
  Timer? _debounce;

  /// สินค้าทั้งหมด — ใช้ filter ฝั่ง client + สร้าง suggestions
  List<ProductData> _allProducts = const [];

  /// คำค้นปัจจุบัน (ว่าง = โหมด suggestions)
  final ValueNotifier<String> _queryNotifier = ValueNotifier('');
  ValueListenable<String> get queryNotifier => _queryNotifier;

  /// suggestions ก่อน user เริ่มพิมพ์ — ชื่อสินค้า 4 ตัวแรกจากที่ fetch มา
  final ValueNotifier<List<ProductData>> _suggestionsNotifier =
      ValueNotifier(const []);
  ValueListenable<List<ProductData>> get suggestionsNotifier =>
      _suggestionsNotifier;

  /// ผลการค้นหา (grid)
  final ValueNotifier<UiResult<List<ProductData>>> _resultsNotifier =
      ValueNotifier(UiResult.success(data: const []));
  ValueListenable<UiResult<List<ProductData>>> get resultsNotifier =>
      _resultsNotifier;

  @override
  void dispose() {
    _debounce?.cancel();
    _queryNotifier.dispose();
    _suggestionsNotifier.dispose();
    _resultsNotifier.dispose();
    super.dispose();
  }

  String get _customerId => currentCustomerProvider.current.id.orEmpty;

  /// โหลดสินค้าทั้งหมดไว้เป็นฐานสำหรับ filter + suggestions
  Future<void> init() async {
    final result = await _repo.fetchProducts(
      productType: 'all',
      customerId: _customerId,
    );
    if (result.isSuccess) {
      _allProducts = result.data.product ?? const [];
      _suggestionsNotifier.value = _allProducts.take(4).toList();
    }
  }

  /// user พิมพ์/เปลี่ยนคำค้น
  void onQueryChanged(String text) {
    _queryNotifier.value = text;
    _debounce?.cancel();

    final query = text.trim();
    if (query.isEmpty) {
      // โหมด suggestions — เคลียร์ผลลัพธ์
      _resultsNotifier.value = UiResult.success(data: const []);
      return;
    }

    // 1) ค้นใน client ก่อน (instant)
    final local = _filterLocal(query);
    if (local.isNotEmpty) {
      _resultsNotifier.value = UiResult.success(data: local);
      return;
    }

    // 2) ไม่เจอใน client → debounce แล้วยิง API
    _resultsNotifier.value = UiResult.loading();
    _debounce = Timer(_debounceDelay, () => _searchApi(query));
  }

  /// filter ฝั่ง client จากชื่อสินค้า (ครอบทุก locale)
  List<ProductData> _filterLocal(String query) {
    final q = query.toLowerCase();
    return _allProducts.where((p) {
      final th = p.getNameDisplay('th').toLowerCase();
      final en = p.getNameDisplay('en').toLowerCase();
      final zh = p.getNameDisplay('zh').toLowerCase();
      return th.contains(q) || en.contains(q) || zh.contains(q);
    }).toList();
  }

  /// GET /products?search= — ยิงเมื่อ client ไม่เจอ
  Future<void> _searchApi(String query) async {
    final result = await _repo.fetchProducts(
      productType: 'all',
      customerId: _customerId,
      search: query,
    );
    // กันผลลัพธ์เก่าทับใหม่ — query เปลี่ยนระหว่างรอ
    if (_queryNotifier.value.trim() != query) return;

    if (result.hasError) {
      _resultsNotifier.value = UiResult.error(error: result.error);
      return;
    }
    final products = result.isSuccess
        ? (result.data.product ?? const <ProductData>[])
        : const <ProductData>[];
    _resultsNotifier.value = products.isEmpty
        ? UiResult.empty()
        : UiResult.success(data: products);
  }
}
