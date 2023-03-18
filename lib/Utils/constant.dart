import 'package:flutter/material.dart';

String mapApiKey = "AIzaSyB9veCDeodL87QObk_JXfVvdNvG-JQKafU";
Color primaryColor = const Color(0xFF6d1872);
Color secondaryColor = const Color(0xffecdbed);
Color lightGrey = Colors.grey[300] as Color;
double zoomLevel = 16;

extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.green,
  }) {
    ScaffoldMessenger.of(this)..removeCurrentSnackBar()..showSnackBar(SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
        maxLines: 2,
      ),
      backgroundColor: backgroundColor,
    ));
  }

  void showErrorSnackBar({required String message}) {
    showSnackBar(message: message, backgroundColor: Colors.red);
  }
}

Map getDummyData(){
  Map map = {
    "title": "Aryan text",
    "body": "Please Pickup me",
    "phoneNumber": "84492",
    "destination": {
      "lat": 30.2939471,
      "long": 78.0578826,
      "location":
      "Rispana Pull, Dehradun,248001 ,jksdf ajlsdf ajllsadfl fasdfjl, Uttarakhand, India",
    },
    "pick-up": {
      "location":
      "73JM+573, Nehrugram, Dehradun, Uttarakhand 248005, India",
      "lat":30.2803492,
      "long": 78.0831859,
    },
    "price": 300,
    "distance": "10.5",
    "isFinished": false,
    "id": "9Tae9quZkEREdLErYUqUDmhmegk2"
  };
  // uploadDummyData(map);
  return map;
}