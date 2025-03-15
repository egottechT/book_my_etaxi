import 'dart:async';

import 'package:book_my_taxi/model/driver_model.dart';
import 'package:book_my_taxi/repository/trip_repo.dart';
import 'package:book_my_taxi/screens/maps/driver_info.dart';
import 'package:book_my_taxi/service/notification_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverRepo {
  final databaseReference = FirebaseDatabase.instance.ref();

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
        NotificationService().showNotification(
            "Driver Accepted the Request", "Driver on the way");
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

  void driveLocationUpdate(
      GoogleMapController mapController, Function function) {
    databaseReference
        .child("trips")
        .child(TripRepo.key)
        .onChildChanged
        .listen((event) {
      if (event.snapshot.key.toString() == "driver_info") {
        Map map = event.snapshot.value as Map;
        LatLng center = LatLng(map["lat"], map["long"]);
        CameraPosition cameraPosition =
            CameraPosition(target: center, zoom: 16);
        mapController
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        function(center);
      }
    });
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
}
