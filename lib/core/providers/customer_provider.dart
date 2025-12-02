import 'package:browny_applications_new/models/user_model.dart';
import 'package:flutter/material.dart';

class CustomerProvider extends ChangeNotifier {
  UserModel _current = UserModel.guest();
  UserModel get current => _current;

  set newUser(UserModel data) {
    _current = data;
    notifyListeners();
  }

  UserModel logout() {
    _current = UserModel.guest();
    notifyListeners();
    return _current;
  }
}
