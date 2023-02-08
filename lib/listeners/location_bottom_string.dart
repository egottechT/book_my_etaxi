import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DestinationLocationProvider extends ChangeNotifier { // create a common file for data
  String _str = "Search Your Destination";
  LatLng _position = const LatLng(0,0);

  String get location => _str;
  LatLng get position => _position;
  void setString(String st) {
    _str = st;
    notifyListeners();
  }

  void setPositionLatLng(LatLng value){
    _position = value;
    notifyListeners();
  }
}