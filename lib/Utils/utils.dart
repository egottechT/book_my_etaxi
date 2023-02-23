
import 'dart:convert' as jsonData;
import 'dart:ui';
import 'package:book_my_taxi/Utils/constant.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

Future<Uint8List> getImages(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
      targetHeight: width);
  FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ImageByteFormat.png))!
      .buffer
      .asUint8List();
}

Future<LocationData> getCurrentLocation() async {
  Location currentLocation = Location();
  var location = await currentLocation.getLocation();
  return location;
}

Future<String> getAddressFromLatLng(double lat, double lng,String previousLocation) async {
  String host = 'https://maps.google.com/maps/api/geocode/json';
  final url = '$host?key=$mapApiKey&language=en&latlng=$lat,$lng';

  var response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    Map data = jsonData.jsonDecode(response.body);
    String formattedAddress = data["results"][0]["formatted_address"];
    return formattedAddress;
  } else {
    return previousLocation;
  }
}