import 'dart:async';
import 'dart:io';

import 'package:book_my_taxi/model/driver_model.dart';
import 'package:book_my_taxi/model/message_model.dart';
import 'package:book_my_taxi/repository/trip_repo.dart';
import 'package:book_my_taxi/screens/maps/driver_info.dart';
import 'package:book_my_taxi/service/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final databaseReference = FirebaseDatabase.instance.ref();
final FirebaseStorage storage = FirebaseStorage.instance;

void checkDriveRequest(BuildContext context, Map data) {
  databaseReference
      .child("trips")
      .child(TripRepo.key)
      .onChildAdded
      .listen((event) {
    // debugPrint("Child Added : - ${event.snapshot.value.toString()}");
    if (event.snapshot.key == "driver_info") {
      Map map = event.snapshot.value as Map;
      DriverModel model = DriverModel().getDataFromMap(map);
      NotificationService()
          .showNotification("Driver Accepted the Request", "Driver on the way");
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => DriverInfoScreen(
                    driver: model,
                    data: data,
                  )),
          ModalRoute.withName('/mapScreen'));
    }
  });
}

void driveLocationUpdate(GoogleMapController mapController, Function function) {
  databaseReference
      .child("trips")
      .child(TripRepo.key)
      .onChildChanged
      .listen((event) {
    if (event.snapshot.key.toString() == "driver_info") {
      Map map = event.snapshot.value as Map;
      LatLng center = LatLng(map["lat"], map["long"]);
      CameraPosition cameraPosition = CameraPosition(target: center, zoom: 16);
      mapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      function(center);
    }
  });
}

Future<void> uploadChatData(String msg) async {
  databaseReference
      .child("trips")
      .child(TripRepo.key)
      .child("messages")
      .push()
      .set({"message": msg, "sender": "customer"});
}

Future<void> listenChangeMessages(Function readData) async {
  databaseReference
      .child("trips")
      .child(TripRepo.key)
      .child("messages")
      .onChildAdded
      .listen((event) {
    readData();
  });
}

Future<void> notificationChangeMessages() async {
  databaseReference
      .child("trips")
      .child(TripRepo.key)
      .child("messages")
      .onChildAdded
      .listen((event) {
    Map map = event.snapshot.value as Map;
    if (map['sender'] == 'driver') {
      NotificationService()
          .showNotification("Message from Driver", map["message"]);
    }
  });
}

Future<List<MessageModel>> fetchMessageData() async {
  List<MessageModel> list = [];
  await databaseReference
      .child("trips")
      .child(TripRepo.key)
      .child("messages")
      .once()
      .then((value) {
    for (var event in value.snapshot.children) {
      Map map = event.value as Map;
      MessageModel model = MessageModel().fromMap(map);
      list.add(model);
    }
  });
  return list;
}

Future<void> uploadPhotoToStorage(File file, String name) async {
  String uid = FirebaseAuth.instance.currentUser!.uid.toString();
  Reference ref = storage.ref().child('images/$uid/$name.jpg');
  // File compressedFile = await compressImage(file);
  UploadTask uploadTask = ref.putFile(file);
  String url = "a";
  await uploadTask.then((res) async {
    String downloadURL = await res.ref.getDownloadURL();
    debugPrint("url:- $downloadURL");
    url = downloadURL;
  }).catchError((err) {
    // Handle the error.
  });

  await databaseReference
      .child("customer")
      .child(FirebaseAuth.instance.currentUser!.uid.toString())
      .update({name: url});
}

Future<File> compressImage(File file) async {
  var result = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    quality: 50,
  );
  return File.fromRawPath(result!);
}

Future<String> getDriverUuidByPhoneNumber(String phoneNumber) async {
  try {
    // Reference to the Firebase Realtime Database
    final DatabaseReference databaseRef =
        FirebaseDatabase.instance.ref("driver");

    // Fetch the driver data once
    final DataSnapshot snapshot = await databaseRef.get();

    // Check if the snapshot contains data
    if (snapshot.exists) {
      final Map<dynamic, dynamic>? driversData =
          snapshot.value as Map<dynamic, dynamic>?;

      // Iterate over the drivers data
      if (driversData != null) {
        for (final uuid in driversData.keys) {
          final dynamic driverData = driversData[uuid];

          // Check if the driver data contains a matching phone number
          if (driverData is Map<dynamic, dynamic> &&
              driverData['phoneNumber'] == phoneNumber) {
            return uuid; // Return the UUID of the matching driver
          }
        }
      }
    }

    // If no match is found, return no match message
    return "No driver match";
  } catch (e) {
    // Handle any errors that occur
    return "Error: ${e.toString()}";
  }
}

Future<bool> addReferAndEarn(String phoneNumber) async {
  if (phoneNumber.isEmpty) return false;
  String uuid = await getDriverUuidByPhoneNumber("+91$phoneNumber");
  if (uuid == "No driver match") {
    return false;
  }

  await databaseReference
      .child("customer")
      .child(FirebaseAuth.instance.currentUser!.uid)
      .update({"referred": true, "driver_referred": uuid});
  return true;
}
