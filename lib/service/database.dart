import 'dart:async';
import 'dart:io';

import 'package:book_my_taxi/model/message_model.dart';
import 'package:book_my_taxi/repository/driver_repo.dart';
import 'package:book_my_taxi/repository/trip_repo.dart';
import 'package:book_my_taxi/repository/user_repo.dart';
import 'package:book_my_taxi/service/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

final databaseReference = FirebaseDatabase.instance.ref();
final FirebaseStorage storage = FirebaseStorage.instance;

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
  String uid = UserRepo.userUUid;
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
      .child(UserRepo.userUUid)
      .update({name: url});
}

Future<File> compressImage(File file) async {
  var result = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    quality: 50,
  );
  return File.fromRawPath(result!);
}

Future<bool> addReferAndEarn(String phoneNumber) async {
  if (phoneNumber.isEmpty) return false;
  String uuid =
      await DriverRepo().getDriverUuidByPhoneNumber("+91$phoneNumber");
  if (uuid == "No driver match") {
    return false;
  }

  await databaseReference
      .child("customer")
      .child(FirebaseAuth.instance.currentUser!.uid)
      .update({"referred": true, "driver_referred": uuid});
  return true;
}
