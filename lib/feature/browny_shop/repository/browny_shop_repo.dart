import 'package:browny_applications_new/core/data/remote/models/response/flash_sales_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/products_response.dart';
import 'package:browny_applications_new/core/data/repo/app_repository.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';

/// Mixin Interface สำหรับ Repository ของ Browny Shop
mixin BrownyShopDataSourceMixin {
  /// API fetch รายการสินค้า Browny Shop
  ///
  /// Parameters:
  /// - productType: String (เช่น "all", "popular", "browny-sale")
  /// - customerId: String (uuid)
  Future<RepoResult<ProductsResponse>> fetchProducts({
    required String productType,
    required String customerId,
  });

  /// API fetch รายการ Flash Sale ที่ active อยู่ (Browny Shop)
  Future<RepoResult<FlashSalesResponse>> fetchFlashSales();
}

/// Repository สำหรับ Browny Shop feature
class BrownyShopRepo extends AppRepository with BrownyShopDataSourceMixin {
  @override
  Future<RepoResult<ProductsResponse>> fetchProducts({
    required String productType,
    required String customerId,
  }) async {
    try {
      final response = await requireRemote.fetchProducts(
        productType,
        customerId,
      );
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<FlashSalesResponse>> fetchFlashSales() async {
    try {
      final response = await requireRemote.fetchFlashSales();
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
