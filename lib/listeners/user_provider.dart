import 'package:book_my_taxi/model/user_model.dart';
import 'package:flutter/material.dart';

class UserModelProvider extends ChangeNotifier { // create a common file for data
  UserModel _user = UserModel();

  UserModel get data => _user;

  void setData(UserModel st) {
    _user = st;
    notifyListeners();
  }
}