import 'dart:async';

import 'package:analyzer_plugin/utilities/pair.dart';
import 'package:book_my_taxi/listeners/location_bottom_string.dart';
import 'package:book_my_taxi/listeners/location_string_listener.dart';
import 'package:book_my_taxi/listeners/user_provider.dart';
import 'package:book_my_taxi/model/driver_model.dart';
import 'package:book_my_taxi/model/ride_fare_model.dart';
import 'package:book_my_taxi/model/trip_model.dart';
import 'package:book_my_taxi/repository/driver_repo.dart';
import 'package:book_my_taxi/repository/user_repo.dart';
import 'package:book_my_taxi/screens/profile_screens/review_trip_screen.dart';
import 'package:book_my_taxi/service/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TripRepo {
  final databaseReference = FirebaseDatabase.instance.ref();

  static String key = "";
  static String amount = "";

  void uploadTripInfo(BuildContext context, String price, String distance,
      String carName) async {
    amount = price;
    var pickUp =
        Provider.of<PickupLocationProvider>(context, listen: false).position;
    var destination =
        Provider.of<DestinationLocationProvider>(context, listen: false)
            .position;
    final newChildRef = databaseReference.child("trips").push();

    final userData =
        Provider.of<UserModelProvider>(context, listen: false).data;
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
        "location": Provider.of<PickupLocationProvider>(context, listen: false)
            .location,
        "lat": pickUp.latitude,
        "long": pickUp.longitude,
      },
      "price": price.replaceAll('₹', ''),
      "distance": distance,
      "isFinished": false,
      "tripStarted": false,
      'id': UserRepo.userUUid,
      'car': carName,
      "date": DateTime.now().toString(),
    };
    await newChildRef.set(data);
    key = newChildRef.key.toString();
    if (context.mounted) {
      DriverRepo().checkDriveRequest(context, data);
    }
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

  Future<RideFareModel> readingFare(String state, String car) async {
    RideFareModel data = RideFareModel();
    await databaseReference
        .child("state")
        .child(state)
        .child(car)
        .once()
        .then((value) async {
      if (value.snapshot.exists) {
        Map map = value.snapshot.value as Map;

        data = RideFareModel().fromMap(map);
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
}
