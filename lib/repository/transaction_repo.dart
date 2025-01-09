import 'dart:async';

import 'package:book_my_taxi/model/driver_model.dart';
import 'package:firebase_database/firebase_database.dart';

class TransactionRepo {
  final databaseReference = FirebaseDatabase.instance.ref();

  Future<void> uploadRatingUser(DriverModel driverModel, double stars,
      String title, String name, double amount) async {
    await databaseReference
        .child("driver")
        .child(driverModel.id)
        .child("rating")
        .push()
        .set({
      "rating": stars,
      "description": title,
      "customerName": name,
      "date": DateTime.now().toString()
    });
    if (stars == 5.0) {
      int addedValue = (0.02 * amount).round();
      await databaseReference.child("driver").child(driverModel.id).update({
        "amount": amount + addedValue,
      });

      final DatabaseReference transactionRef = databaseReference
          .child("driver")
          .child(driverModel.id)
          .child("transaction")
          .push();

      String orderIdKey = "RAT" + (transactionRef.key?.substring(0, 6) ?? "");

      await transactionRef.set({
        "amount": addedValue,
        "status": "5 Star Reward",
        "is_added": true,
        "date": DateTime.now().toString(),
        "order_id": orderIdKey,
        "current_balance": amount + addedValue,
        "user_name": name
      });
    }
  }

  Future<void> updateDriverAmount(
      String uuid, int incrementBy, String userName) async {
    try {
      if (uuid.isEmpty) return;
      final DatabaseReference driverRef =
          FirebaseDatabase.instance.ref("driver/$uuid");

      final DataSnapshot snapshot = await driverRef.get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic>? driverData =
            snapshot.value as Map<dynamic, dynamic>?;
        int currentAmount = driverData?['amount'] ?? 0;

        await driverRef.update({'amount': currentAmount + incrementBy});
        final DatabaseReference transactionRef =
            driverRef.child("transaction").push();
        String orderIdKey = "COM" + (transactionRef.key?.substring(0, 6) ?? "");

        await transactionRef.set({
          "amount": incrementBy,
          "status": "Referral Bonus",
          "is_added": true,
          "date": DateTime.now().toString(),
          "order_id": orderIdKey,
          "current_balance": currentAmount + incrementBy,
          "user_name": userName
        });
      } else {
        print("Driver with UUID $uuid not found.");
      }
    } catch (e) {
      print("Error: ${e.toString()}");
    }
  }
}
