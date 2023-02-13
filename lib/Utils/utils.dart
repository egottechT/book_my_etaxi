import 'dart:convert';
import 'dart:ui' as ui;
import 'package:book_my_taxi/Utils/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

Future<Uint8List> getImages(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetHeight: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
      .buffer
      .asUint8List();
}

Future<String> getAddressFromLatLng(double lat, double lng,String location ) async {
  String host = 'https://maps.google.com/maps/api/geocode/json';
  final url = '$host?key=$mapApiKey&language=en&latlng=$lat,$lng';

  var response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    Map data = jsonDecode(response.body);
    String formattedAddress = data["results"][0]["formatted_address"];
    debugPrint("response ==== $formattedAddress");
    return formattedAddress;
  } else {
    return location;
  }
}