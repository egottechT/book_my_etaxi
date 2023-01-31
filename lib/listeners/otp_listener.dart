import 'package:flutter/material.dart';

class OtpProvider extends ChangeNotifier { // create a common file for data
  String _otp = "";

  String get text => _otp;

  void setString(String st) {
    _otp = st;
    notifyListeners();
  }
}