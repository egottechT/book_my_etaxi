import 'package:book_my_taxi/Utils/utils.dart';
import 'package:flutter/material.dart';

Future<String> showLocationFromLatLng(double latitude, double longitude,String location) async {
  try {
    var text = await getAddressFromLatLng(latitude, longitude,location);
    return text;
  } catch (e) {
    debugPrint("No address found");
  }
  return location;
}