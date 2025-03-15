import 'dart:async';
import 'dart:io';

import 'package:analyzer_plugin/utilities/pair.dart';
import 'package:book_my_taxi/listeners/location_bottom_string.dart';
import 'package:book_my_taxi/listeners/location_string_listener.dart';
import 'package:book_my_taxi/listeners/user_provider.dart';
import 'package:book_my_taxi/model/driver_model.dart';
import 'package:book_my_taxi/model/message_model.dart';
import 'package:book_my_taxi/model/trip_model.dart';
import 'package:book_my_taxi/screens/maps/driver_info.dart';
import 'package:book_my_taxi/screens/profile_screens/review_trip_screen.dart';
import 'package:book_my_taxi/service/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

final databaseReference = FirebaseDatabase.instance.ref();
final FirebaseStorage storage = FirebaseStorage.instance;

String key = "";
String amount = "";

void uploadTripInfo(
    BuildContext context, String price, String distance, String carName) async {
  amount = price;
  var pickUp =
      Provider.of<PickupLocationProvider>(context, listen: false).position;
  var destination =
      Provider.of<DestinationLocationProvider>(context, listen: false).position;
  final newChildRef = databaseReference.child("trips").push();

  final userData = Provider.of<UserModelProvider>(context, listen: false).data;
  Map data = {
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
    "price": price.replaceAll('₹', ''),
    "distance": distance,
    "isFinished": false,
    "tripStarted": false,
    'id': FirebaseAuth.instance.currentUser!.uid.toString(),
    'car': carName,
    "date": DateTime.now().toString(),
  };
  await newChildRef.set(data);
  key = newChildRef.key.toString();
  if (context.mounted) {
    checkDriveRequest(context, data);
  }
}

void checkDriveRequest(BuildContext context, Map data) {
  databaseReference.child("trips").child(key).onChildAdded.listen((event) {
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
  databaseReference.child("trips").child(key).onChildChanged.listen((event) {
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

Future<void> cancelRequest(String reason) async {
  databaseReference
      .child("trips")
      .child(key)
      .child("cancel_trip")
      .set({"reason": reason});
}

Future<void> checkIsTripEnd(BuildContext context, DriverModel model, Map map,
    Function showReachingTime) async {
  databaseReference.child("trips").child(key).onChildChanged.listen((event) {
    if (event.snapshot.key == "tripStarted") {
      NotificationService()
          .showNotification("Your Ride is started", "Enjoy Your Ride");
      showReachingTime();
    }
    if (event.snapshot.key == "isFinished") {
      uploadTripDataInHistory(map);
      NotificationService().showNotification(
          "Your Ride is completed", "Please pay driver to Rs.$amount");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ReviewTripScreen(
                  driver: model,
                  map: map,
                )),
      );
    }
  });
}

Future<void> uploadTripDataInHistory(Map map) async {
  String uid = FirebaseAuth.instance.currentUser!.uid;

  TripModel model = TripModel().convertFromTrip(map);
  databaseReference
      .child("customer")
      .child(uid)
      .child("history")
      .push()
      .set(TripModel().toMap(model));
}

Future<List<TripModel>> fetchTripHistory() async {
  List<TripModel> list = [];
  String uid = FirebaseAuth.instance.currentUser!.uid;
  await databaseReference
      .child("customer")
      .child(uid)
      .child("history")
      .once()
      .then((value) {
    for (var data in value.snapshot.children) {
      Map map = data.value as Map;
      TripModel model = TripModel().fromMap(map);
      model.key = data.key.toString();
      list.add(model);
    }
  });
  return list;
}

Future<void> uploadChatData(String msg) async {
  databaseReference
      .child("trips")
      .child(key)
      .child("messages")
      .push()
      .set({"message": msg, "sender": "customer"});
}

Future<void> listenChangeMessages(Function readData) async {
  databaseReference
      .child("trips")
      .child(key)
      .child("messages")
      .onChildAdded
      .listen((event) {
    readData();
  });
}

Future<void> notificationChangeMessages() async {
  databaseReference
      .child("trips")
      .child(key)
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
      .child(key)
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

Future<int> readingFare(String state, String car) async {
  int data = 150;
  await databaseReference
      .child("state")
      .child(state)
      .child(car)
      .once()
      .then((value) async {
    if (value.snapshot.exists) {
      data = value.snapshot.value as int;
    }
  });
  return data;
}

Future<Pair<Map, DriverModel>> findTripUsingId(String tripId) async {
  Map data = {};
  DriverModel model = DriverModel();
  await databaseReference.child('trips').child(tripId).once().then((event) {
    data = event.snapshot.value as Map;
    Map map = data["driver_info"];
    model = DriverModel().getDataFromMap(map);
    String customerKey = event.snapshot.key.toString();
    debugPrint(data.toString());
    key = customerKey;
  });
  return Pair(data, model);
}
