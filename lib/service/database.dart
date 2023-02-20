import 'dart:async';

import 'package:book_my_taxi/listeners/location_bottom_string.dart';
import 'package:book_my_taxi/listeners/location_string_listener.dart';
import 'package:book_my_taxi/model/driver_model.dart';
import 'package:book_my_taxi/model/user_model.dart';
import 'package:book_my_taxi/screens/driver_info.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final databaseReference = FirebaseDatabase(
        databaseURL:
            "https://book-my-etaxi-default-rtdb.asia-southeast1.firebasedatabase.app")
    .ref();
String key = "";

Future<void> addUserToDatabase(String name,UserModel model) async {
  try {
    await databaseReference.child("customer").child(name).set(UserModel().toMap(model));
  } catch (e) {
    debugPrint(e.toString());
  }
}

Future<bool> checkDatabaseForUser(String uid) async{
  Completer<bool> completer = Completer();
  databaseReference.child("customer").child(uid).onValue.listen((event) {
        completer.complete(event.snapshot.exists);
  });
  return completer.future;
}

void uploadTripInfo(BuildContext context) async {
  var pickUp =
      Provider.of<PickupLocationProvider>(context, listen: false).position;
  var destination =
      Provider.of<DestinationLocationProvider>(context, listen: false).position;
  final newChildRef = databaseReference.child("active_driver").push();
  await newChildRef.set({
    "title": "Abhay sati",
    "body": "Please Pickup me",
    "destination": {
      "lat": destination.latitude,
      "long": destination.longitude,
      "location":
          Provider.of<DestinationLocationProvider>(context, listen: false)
              .location,
    },
    "pick-up": {
      "location":
          Provider.of<PickupLocationProvider>(context, listen: false).location,
      "lat": pickUp.latitude,
      "long": pickUp.longitude,
    },
    "driver": false
  });
  key = newChildRef.key.toString();
  if (context.mounted) {
    checkDriveRequest(context);
  }
}

void checkDriveRequest(BuildContext context) {
  databaseReference
      .child("active_driver")
      .child(key)
      .onChildChanged
      .listen((event) {
    debugPrint("Child Changed ${event.snapshot.value.toString()}");

  });

  databaseReference
      .child("active_driver")
      .child(key)
      .onChildAdded
      .listen((event) {
    debugPrint("Child Added : - ${event.snapshot.value.toString()}");
    if (event.snapshot.key == "driver_info") {
      Map map = event.snapshot.value as Map;
      DriverModel model = DriverModel().getDataFromMap(map);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => DriverInfoScreen(driver: model,)),
          ModalRoute.withName('/mapScreen'));
    }
  });
  // databaseReference.child("active_driver").child(key).child("driver_info").set({
  //   "name": "Aryan",
  //   "vehicleNumber" : "UK07AB4976",
  //   "phoneNumber": "908616413",
  //   "rating" : "4.6",
  //   //TODO ADD LAT AND LNG FOR DRIVER
  //
  // });
}
