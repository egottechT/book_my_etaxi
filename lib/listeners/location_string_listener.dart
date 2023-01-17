import 'package:flutter/material.dart';

class StringProvider extends ChangeNotifier { // create a common file for data
  String _str = "Pickup Location";

  String get location => _str;

  void setString(String st) {
    _str = st;
    notifyListeners();
  }
}