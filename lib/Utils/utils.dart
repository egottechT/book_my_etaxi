import 'dart:convert' as json_data;
import 'dart:math';
import 'dart:ui';

import 'package:book_my_taxi/Utils/constant.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:vector_math/vector_math.dart';

double getBearing(LatLng begin, LatLng end) {
  double lat = (begin.latitude - end.latitude).abs();
  double lng = (begin.longitude - end.longitude).abs();

  if (begin.latitude < end.latitude && begin.longitude < end.longitude) {
    return degrees(atan(lng / lat));
  } else if (begin.latitude >= end.latitude &&
      begin.longitude < end.longitude) {
    return (90 - degrees(atan(lng / lat))) + 90;
  } else if (begin.latitude >= end.latitude &&
      begin.longitude >= end.longitude) {
    return degrees(atan(lng / lat)) + 180;
  } else if (begin.latitude < end.latitude &&
      begin.longitude >= end.longitude) {
    return (90 - degrees(atan(lng / lat))) + 270;
  }
  return -1;
}

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

Future<String> getAddressFromLatLng(
    double lat, double lng, String previousLocation) async {
  String host = 'https://maps.google.com/maps/api/geocode/json';
  final url = '$host?key=$mapApiKey&language=en&latlng=$lat,$lng';

  var response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    Map data = json_data.jsonDecode(response.body);
    String formattedAddress = data["results"][0]["formatted_address"];
    return formattedAddress;
  } else {
    return previousLocation;
  }
}

void correctCameraAngle(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
    GoogleMapController mapController) async {
  double miny = (startLatitude <= destinationLatitude)
      ? startLatitude
      : destinationLatitude;
  double minx = (startLongitude <= destinationLongitude)
      ? startLongitude
      : destinationLongitude;
  double maxy = (startLatitude <= destinationLatitude)
      ? destinationLatitude
      : startLatitude;
  double maxx = (startLongitude <= destinationLongitude)
      ? destinationLongitude
      : startLongitude;

  double southWestLatitude = miny;
  double southWestLongitude = minx;
  double northEastLatitude = maxy;
  double northEastLongitude = maxx;
  mapController.animateCamera(
    CameraUpdate.newLatLngBounds(
      LatLngBounds(
        northeast: LatLng(northEastLatitude, northEastLongitude),
        southwest: LatLng(southWestLatitude, southWestLongitude),
      ),
      100.0,
    ),
  );
}
