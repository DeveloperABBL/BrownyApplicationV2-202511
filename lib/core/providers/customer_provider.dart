import 'package:browny_applications_new/core/data/remote/models/response/customer_profile_response.dart';
import 'package:browny_applications_new/models/user_model.dart';
import 'package:flutter/material.dart';

class CustomerProvider extends ChangeNotifier {
  UserModel _current = UserModel.guest();
  UserModel get current => _current;

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
