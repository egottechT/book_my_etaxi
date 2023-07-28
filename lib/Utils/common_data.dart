import 'dart:convert';
import 'dart:io';

import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../model/user_model.dart';

Future<String> showLocationFromLatLng(
    double latitude, double longitude, String location) async {
  try {
    var text = await getAddressFromLatLng(latitude, longitude, location);
    return text;
  } catch (e) {
    debugPrint("No address found");
  }
  return location;
}

Future<Duration> calculateTravelTime(LatLng origin, LatLng destination) async {
  final apiUrl =
      'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=${origin.latitude},${origin.longitude}&destinations=${destination.latitude},${destination.longitude}&key=$mapApiKey';
  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final durationInSeconds =
        data['rows'][0]['elements'][0]['duration']['value'];
    return Duration(seconds: durationInSeconds);
  } else {
    throw Exception('Failed to calculate travel time');
  }
}

String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);

  final hourString = hours.toString().padLeft(2, '0');
  final minutesString = minutes.toString().padLeft(2, '0');

  if (hourString == "00") {
    return '$minutesString minutes';
  }
  return '$hourString hours, $minutesString minutes';
}

Future<File?> selectImage(context) async {
  final ImagePicker picker = ImagePicker();
  try {
    final XFile? selectedImg =
        await picker.pickImage(source: ImageSource.gallery);
    if (selectedImg == null) {
      return null;
    }
    return File(selectedImg.path);
  } on PlatformException catch (error) {
    context.showErrorSnackBar(
        message: "Can't pick Images !\nError: ${error.message}");
  }
  return null;
}

ImageProvider showProfileImage(UserModel userModel, File? imgFile) {
  if (imgFile != null) {
    return Image(image: FileImage(File(imgFile.path))).image;
  }
  if (userModel.profilePic.isEmpty) {
    return Image.asset(
      "assets/images/profile.png",
    ).image;
  }
  return NetworkImage(userModel.profilePic);
}
