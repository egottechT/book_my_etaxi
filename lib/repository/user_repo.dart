import 'dart:async';

import 'package:book_my_taxi/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UserRepo {
  final databaseReference = FirebaseDatabase.instance.ref();

  Future<UserModel> getUserInfo(BuildContext context, bool wait) async {
    Completer<UserModel> completer = Completer();
    String uid = FirebaseAuth.instance.currentUser!.uid.toString();
    if (wait) {
      await databaseReference.child("customer").child(uid).once().then((value) {
        Map map = value.snapshot.value as Map;
        UserModel model = UserModel().getDataFromMap(map);
        model.key = value.snapshot.key.toString().substring(0, 6);
        completer.complete(model);
      });
    } else {
      databaseReference.child("customer").child(uid).once().then((value) {
        Map map = value.snapshot.value as Map;
        UserModel model = UserModel().getDataFromMap(map);
        model.key = value.snapshot.key.toString().substring(0, 6);
        completer.complete(model);
      });
    }
    return completer.future;
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
}
