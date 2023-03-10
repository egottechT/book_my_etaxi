import 'dart:async';

import 'package:book_my_taxi/listeners/location_bottom_string.dart';
import 'package:book_my_taxi/listeners/location_string_listener.dart';
import 'package:book_my_taxi/listeners/user_provider.dart';
import 'package:book_my_taxi/model/driver_model.dart';
import 'package:book_my_taxi/model/user_model.dart';
import 'package:book_my_taxi/screens/driver_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

final databaseReference = FirebaseDatabase(
        databaseURL:
            "https://book-my-etaxi-default-rtdb.asia-southeast1.firebasedatabase.app")
    .ref();
String key = "";

Future<void> getUserInfo(BuildContext context, bool wait) async {
  String uid = FirebaseAuth.instance.currentUser!.uid.toString();
  debugPrint("uid is:- $uid");
  if (wait) {
    await databaseReference.child("customer").child(uid).once().then((value) {
      Map map = value.snapshot.value as Map;
      debugPrint("Values :- ${map.toString()}");
      UserModel model = UserModel().getDataFromMap(map);
      Provider.of<UserModelProvider>(context, listen: false).setData(model);
    });
  } else {
    databaseReference.child("customer").child(uid).once().then((value) {
      Map map = value.snapshot.value as Map;
      debugPrint("Values :- ${map.toString()}");
      UserModel model = UserModel().getDataFromMap(map);
      Provider.of<UserModelProvider>(context, listen: false).setData(model);
    });
  }
}

Future<void> addUserToDatabase(String name, UserModel model) async {
  try {
    await databaseReference
        .child("customer")
        .child(name)
        .set(UserModel().toMap(model));
  } catch (e) {
    debugPrint(e.toString());
  }
}

Future<bool> checkDatabaseForUser(String uid) async {
  Completer<bool> completer = Completer();
  databaseReference.child("customer").child(uid).onValue.listen((event) {
    completer.complete(event.snapshot.exists);
  });
  return completer.future;
}

void uploadTripInfo(BuildContext context,String price,String distance) async {
  var pickUp =
      Provider.of<PickupLocationProvider>(context, listen: false).position;
  var destination =
      Provider.of<DestinationLocationProvider>(context, listen: false).position;
  final newChildRef = databaseReference.child("trips").push();

  final userData = Provider.of<UserModelProvider>(context, listen: false).data;

  await newChildRef.set({
    "title": userData.name,
    "body": "Please Pickup me",
    "phoneNumber": userData.phoneNumber,
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
    "price": price,
    "distance": distance,
    "driver": false
  });
  key = newChildRef.key.toString();
  if (context.mounted) {
    checkDriveRequest(context);
  }
}

void checkDriveRequest(BuildContext context) {
  // databaseReference.child("trips").child(key).onChildChanged.listen((event) {
  //   debugPrint("Child Changed ${event.snapshot.value.toString()}");
  // });

  databaseReference.child("trips").child(key).onChildAdded.listen((event) {
    // debugPrint("Child Added : - ${event.snapshot.value.toString()}");
    if (event.snapshot.key == "driver_info") {
      Map map = event.snapshot.value as Map;
      DriverModel model = DriverModel().getDataFromMap(map);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => DriverInfoScreen(
                    driver: model,
                  )),
          ModalRoute.withName('/mapScreen'));
    }
  });
}

void driveLocationUpdate(GoogleMapController mapController, Function function) {
  databaseReference.child("trips").child(key).onChildChanged.listen((event) {
    Map map = event.snapshot.value as Map;
    LatLng center = LatLng(map["lat"], map["long"]);
    CameraPosition cameraPosition = CameraPosition(target: center, zoom: 16);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    function(center);
    // debugPrint("Driver Location Update:-  ${map["lat"]} ${map["long"]}");
  });
}

Future<void> cancelRequest(String reason) async {
  databaseReference
      .child("trips")
      .child(key)
      .update({"cancel": true, "reason": reason});
}
