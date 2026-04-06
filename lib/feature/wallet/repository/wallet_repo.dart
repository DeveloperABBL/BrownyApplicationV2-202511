import 'dart:async';

import 'package:browny_applications_new/core/data/remote/models/request/topup_request.dart';
import 'package:browny_applications_new/core/data/remote/models/request/wallet_history_request.dart';
import 'package:browny_applications_new/core/data/remote/models/response/topup_request_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/wallet_history_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/wallet_receipt_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';
import 'package:browny_applications_new/feature/authentication/repository/customer_data_repo.dart';
import 'package:browny_applications_new/feature/wallet/error/wallet_exception.dart';
import 'package:dio/dio.dart';

mixin WalletDataSourceMixin on CustomerDataSourceMixin {
  Future<RepoResult<WalletReceiptResponse>> fetchReciept(String ref);

  Future<RepoResult<TopupRequestResponse>> requestTopup(TopupRequest request);

  Future<RepoResult<TopupRequestResponse>> checkWalletStatusPayment(
    String paymentRef,
  );

  Future<RepoResult<WalletHistoryResponse>> fetchWalletHistory(
    String customerId,
  );

  FutureOr<RepoResult<List<int>>> fetchAmountBadge();
}

class WalletRepo extends CustomerDataRepo with WalletDataSourceMixin {
  @override
  Future<RepoResult<WalletReceiptResponse>> fetchReciept(String ref) async {
    try {
      final response = await requireRemote.walletReceipt(ref);
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }

      return RepoResult.success(data: response.data);
    } on DioException catch (dioE) {
      if (dioE.response!.isDuplicated) {
        return RepoResult.error(error: PenddingException());
      }
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }

    return RepoResult.empty();
  }

  @override
  Future<RepoResult<TopupRequestResponse>> requestTopup(
    TopupRequest request,
  ) async {
    try {
      final response = await requireRemote.topupRequest(request);
      if (!response.isSuccessful) {
        return RepoResult.empty(error: Unprocessable());
      }

      return RepoResult.dependOn(response.data);
    } on DioException catch (_) {
      return RepoResult.empty(error: Unprocessable());
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<TopupRequestResponse>> checkWalletStatusPayment(
    String paymentRef,
  ) async {
    try {
      final response = await requireRemote.checkWalletStatusPayment(paymentRef);
      if (!response.isSuccessful) {
        return RepoResult.empty(error: Unprocessable());
      }

      return RepoResult.dependOn(response.data);
    } on DioException catch (dioE) {
      if (dioE.response!.isDuplicated) {
        return RepoResult.empty();
      }
      return RepoResult.empty(error: Unprocessable());
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<WalletHistoryResponse>> fetchWalletHistory(
    String customerId,
  ) async {
    try {
      final request = WalletHistoryRequest(customerId: customerId);
      final response = await requireRemote.fetchWalletHistory(request);

      if (!response.isSuccessful) {
        return RepoResult.empty(error: Unprocessable());
      }

      return RepoResult.dependOn(response.data);
    } on DioException catch (_) {
      return RepoResult.empty(error: Unprocessable());
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  FutureOr<RepoResult<List<int>>> fetchAmountBadge() {
    return RepoResult.success(data: [100, 200, 500, 1000, 2000]);
  }
}
