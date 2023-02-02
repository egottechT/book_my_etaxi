import 'package:flutter/material.dart';

class DestinationLocationProvider extends ChangeNotifier { // create a common file for data
  String _str = "Search Your Destination";

  String get location => _str;

  void setString(String st) {
    _str = st;
    notifyListeners();
  }
}