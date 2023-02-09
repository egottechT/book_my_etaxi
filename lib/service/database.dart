import 'package:book_my_taxi/listeners/location_bottom_string.dart';
import 'package:book_my_taxi/listeners/location_string_listener.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

final databaseReference = FirebaseDatabase(databaseURL: "https://book-my-etaxi-default-rtdb.asia-southeast1.firebasedatabase.app").ref();

Future<void> addUserToDatabase(String name) async {
  try {
    await databaseReference.child(name).set({
        "created": true
    });
  }
  catch(e){
    print(e.toString());
  }
}

Future<List<String>> readData() async {
  List<String> msg = [];
  final snapshot = await databaseReference.get();
  for(var snap in snapshot.children){
    final uid = snap.key as String;
    msg.add(uid);
  };
  return msg;
}

void uploadTripInfo(BuildContext context){
  var pickUp = Provider.of<PickupLocationProvider>(
      context,
      listen: false)
      .position;
  var destination = Provider.of<DestinationLocationProvider>(
      context,
      listen: false)
      .position;
  databaseReference.child("active_driver").push().set({
    "title": "Abhay sati",
    "body": "Please Pickup me",
    "destination": {
      "lat": destination.latitude,
      "long": destination.longitude,
      "location": Provider.of<DestinationLocationProvider>(
          context,
          listen: false)
          .location,
    },
    "pick-up": {
      "location": Provider.of<PickupLocationProvider>(
          context,
          listen: false)
          .location,
      "lat": pickUp.latitude,
      "long": pickUp.longitude,
    },
  });
}

