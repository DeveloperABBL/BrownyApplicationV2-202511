import 'package:browny_applications_new/core/data/remote/models/response/customer_profile_response.dart';
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

  set newUser(UserModel data) {
    _current = data;
    notifyListeners();
  }

  void updateCreditAndCoinBalance(CustomerProfileData data) {
    newUser = current.copyWith(
      creditBalance: data.creditBalance,
      brownyCoin: data.brownyCoin,
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
